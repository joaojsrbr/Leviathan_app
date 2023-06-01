// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:leviathan_app/app/core/constants/app.dart';
import 'package:leviathan_app/app/core/extensions/custom_extensions/context_extensions.dart';
import 'package:leviathan_app/app/core/extensions/custom_extensions/result_extensions.dart';
import 'package:leviathan_app/app/core/models/book.dart';
import 'package:leviathan_app/app/core/models/chapter.dart';
import 'package:leviathan_app/app/core/repositories/library_repository.dart';
import 'package:leviathan_app/app/core/repositories/load_book_repository.dart';
import 'package:leviathan_app/app/core/services/hive/hive_controller.dart';
import 'package:leviathan_app/app/core/utils/debouncer.dart';
import 'package:leviathan_app/app/core/widgets/adaptative_page_view.dart';
import 'package:leviathan_app/app/core/widgets/open_container_wrapper.dart';
import 'package:leviathan_app/app/ui/read/models/is_read.dart';
import 'package:leviathan_app/app/ui/read/widgets/scope.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

class BookRead extends StatefulWidget {
  const BookRead({super.key});

  @override
  State<BookRead> createState() => _BookReadState();
}

class _BookReadState extends State<BookRead> with TickerProviderStateMixin {
  late final Book _book;
  final Debouncer _debouncer = Debouncer(duration: const Duration(seconds: 2));
  late Chapter _chapter;
  // double? _maxScrollExtent;
  late final ReaderController _readerController;
  late final List<Chapter> _lista;
  late final LibraryRepository _library;
  late final AnimationController _animationControllerOverlayAppBar;
  late final AnimationController _animationControllerOverlayBottomBar;
  late final Animation<Offset> _overlayAppBarAnimation;
  late final Animation<Offset> _overlayBottomBarAnimation;
  late final bool _reverseList;
  final List<IsRead> _isfinished = [];

  GlobalKey? _lastWidgetKey;

  bool _isLoading = true;
  double? _lastPixels;
  double? _lastMaxScrollExtent;
  bool _hasMore = true;
  bool _overlay = false;
  bool _isNovel = false;

  int _index = 0;
  final _loadingMoreWidget = ValueNotifier(false);
  final List<Widget> _content = [];

  double get _percent {
    if (_lastPixels != null && _lastMaxScrollExtent != null) {
      return ((_readerController.position.pixels - _lastPixels!) / (_readerController.position.maxScrollExtent - _lastMaxScrollExtent!));
    } else {
      return (_readerController.position.pixels / _readerController.position.maxScrollExtent);
    }
  }

  void _removeOverlays() async => await SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);

  void _animation() {
    _animationControllerOverlayAppBar = AnimationController(duration: const Duration(milliseconds: 750), vsync: this);
    _animationControllerOverlayBottomBar = AnimationController(duration: const Duration(milliseconds: 750), vsync: this);
    _overlayAppBarAnimation = Tween(begin: const Offset(0, -1), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationControllerOverlayAppBar, curve: Curves.ease),
    );
    _overlayBottomBarAnimation = Tween(begin: const Offset(0, 1), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationControllerOverlayBottomBar, curve: Curves.ease),
    );
  }

  void _addOverlays() async => await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  void _getArgs() {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args == null) return;
    _reverseList = context.read<HiveController>().chaptersReverse;
    _index = args['index'] as int;
    _lista = args['lista'] as List<Chapter>;
    _chapter = args['chapter'] as Chapter;
    _book = args['book'] as Book;
    _isNovel = _book.isNovel;
  }

  void _setRead() {
    for (final item in _isfinished) {
      final getChapter = _library.getChapter(item.chapter);
      double readPercent = item.readPercent > .90 ? 1.0 : item.readPercent;
      if ((getChapter.readPercent ?? 0) > readPercent) readPercent = getChapter.readPercent!;
      // final chapterRead = _bookRepository.getChapter(item.chapter).read;
      if (!_library.contains(chapter: item.chapter)) {
        _library.add(
          chapter: item.chapter.copyWith(
            read: item.read,
            readPercent: readPercent,
            updatedAt: DateTime.now(),
          ),
        );
      } else {
        if ((getChapter.readPercent ?? 0) > readPercent) readPercent = getChapter.readPercent!;
        _library.update(
          chapter: item.chapter.copyWith(
            read: item.read || getChapter.read,
            readPercent: readPercent,
            updatedAt: DateTime.now(),
          ),
        );
      }
    }
    log('Saved: $_isfinished');
  }

  Future<void> _getContent({Chapter? newChapter}) async {
    _lastWidgetKey = null;
    final repository = context.read<LoadBookRepository>();
    final chapter = newChapter ?? _chapter;
    _hasMore = _reverseList ? !(_index == 0) : !(_index == (_lista.length - 1));

    final result = await repository.getContent(chapter);
    result.deconstruction(
      failure: (error) {
        if (mounted) OpenContainerWrapper.closedContainer(context);
      },
      success: (data, description) {
        if (data.isEmpty && mounted) OpenContainerWrapper.closedContainer(context);

        // if (!_isNovel) await Future.wait(data.map((e) => BookRead.BOOKIMGCACHE.downloadFile(e)));

        data.forEachIndexed(
          (index, element) {
            final GlobalKey key = GlobalObjectKey('widget_$element');
            if (index == (data.length - 1)) _lastWidgetKey = key;

            Widget value = _Text(data: element, widgetKey: key);

            if (!_isNovel) value = _Image(data: element, widgetKey: key);

            if (_isNovel && index == 0) {
              value = SafeArea(child: value);
            } else if (_isNovel && index == (data.length - 1)) {
              value = Padding(padding: const EdgeInsets.only(bottom: 20), child: value);
            }

            _content.add(value);
          },
        );
        if (!mounted) return;
        setState(() {
          if (_isLoading) _isLoading = false;
        });
      },
    );
  }

  Future<void> _scrollToPercent() async {
    final chapter = _library.getChapter(_chapter);
    double? percent = chapter.readPercent;

    if (percent != null) {
      if (percent > 0.90) percent = 0.90;
      double? result = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Continuar de onde parou?', style: context.textTheme.titleLarge?.copyWith(fontSize: 20)),
          content: SizedBox(
            height: 50,
            child: StatefulBuilder(
              builder: (context, setState) => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("${(percent! * 100).clamp(0.0, 100.0).toStringAsPrecision(3)}%"),
                  Expanded(
                    child: Slider.adaptive(
                      autofocus: true,
                      value: percent!,
                      onChanged: (value) {
                        percent = value;
                        setState(() {});
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(percent!),
              child: const Text('Sim'),
            ),
          ],
        ),
      );
      if (result != null) {
        final position = _readerController.position;
        await _readerController.animateTo(
          position.maxScrollExtent * result,
          duration: const Duration(seconds: 2),
          curve: Curves.fastOutSlowIn,
        );
        double readPercent = result;
        if ((chapter.readPercent ?? 0) > result) readPercent = chapter.readPercent!;
        _library.update(chapter: chapter.copyWith(readPercent: readPercent, updatedAt: DateTime.now()));
      }
    }
  }

  Future<void> _scrollByKey(GlobalKey key) async {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final context = key.currentContext;
      if (context == null) return;
      final scrollableState = Scrollable.maybeOf(context);

      scrollableState?.position.animateTo(
        scrollableState.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.fastOutSlowIn,
      );
    });
  }

  Future<void> _loadMore() async {
    _loadingMoreWidget.value = true;
    final oldChapter = _chapter;
    _reverseList ? _index-- : _index++;
    _chapter = _lista.elementAt(_index);

    final key = GlobalKey();

    setState(() => _content.add(_LoadingMore(_chapter.chapterName, oldChapter.chapterName, key: key)));

    await _scrollByKey(key);
    // await Future.delayed(const Duration(milliseconds: 200));
    await _getContent();

    _loadingMoreWidget.value = false;
  }

  @override
  void initState() {
    _animation();
    _removeOverlays();
    _library = context.read();
    _readerController = ReaderController();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      _getArgs();
      await _getContent();
      _scrollToPercent();
    });
    super.initState();
  }

  bool _onNotification(ScrollNotification scrollNotification) {
    if (scrollNotification is ScrollStartNotification) {
      _onStartScroll(scrollNotification);
    } else if (scrollNotification is ScrollUpdateNotification) {
      _onUpdateScroll(scrollNotification);
      _onUpdateScrollDelta(scrollNotification);
    } else if (scrollNotification is ScrollEndNotification) {
      _onEndScroll(scrollNotification);
    }
    return true;
  }

  void _handleDoubleTapDown(BuildContext context, TapDownDetails details) async {
    final height = context.mediaQuerySize.height;
    final position = details.globalPosition;
    // double maxScrollExtent = 0.0;
    final metrics = _readerController.position;
    if (position.dy < height ~/ 3) {
      if (_percent == 0) return;
      log('DoubleTapDown[up][$position]');
      // maxScrollExtent = metrics.maxScrollExtent;

      // if (_lastMaxScrollExtent != null) maxScrollExtent = maxScrollExtent - _lastMaxScrollExtent!;
      await _readerController.animateTo(
        metrics.maxScrollExtent * (_percent - 0.05),
        duration: const Duration(seconds: 2),
        curve: Curves.fastOutSlowIn,
      );

      // await bookReaderScope.itemScrollController.scrollTo(
      //   index: currentIndex - 1,
      //   duration: const Duration(seconds: 1),
      //   curve: Curves.fastOutSlowIn,
      //   alignment: 0.8,
      // );
    } else if (position.dy > height ~/ 3 * 2) {
      if (_percent == 1) return;
      log('DoubleTapDown[down][$position]');

      await _readerController.animateTo(
        metrics.maxScrollExtent * (_percent + 0.05),
        duration: const Duration(seconds: 2),
        curve: Curves.fastOutSlowIn,
      );
    } else {
      log('DoubleTapDown[center][$position]');
      setState(() => _overlay = !_overlay);
      _handleOverlayInserted();
      // Future.delayed(const Duration(milliseconds: 300), () => _handleOverlayInserted.call(_visible));
      // Future.delayed(const Duration(milliseconds: 300), () => _handleOverlayInserted.call(_visible));
    }
  }

  void _handleOverlayInserted([bool? overlay]) {
    if (!(overlay ?? _overlay)) {
      _animationControllerOverlayAppBar.reverse();
      _animationControllerOverlayBottomBar.reverse();

      _removeOverlays();
      // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    } else {
      _animationControllerOverlayAppBar.forward();
      _animationControllerOverlayBottomBar.forward();

      _addOverlays();
      // SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  @override
  Widget build(BuildContext context) {
    // final size = context.mediaQuerySize;

    return ReadScope(
      chapterName: !_isLoading ? _chapter.chapterName : null,
      overlay: _overlay,
      onDoubleTapDown: _handleDoubleTapDown,
      onNotification: _onNotification,
      overlayAppBarAnimation: _overlayAppBarAnimation,
      overlayBottomBarAnimation: _overlayBottomBarAnimation,
      content: _content,
      lastPixels: _lastPixels,
      lastMaxScrollExtent: _lastMaxScrollExtent,
      readerController: _readerController,
      loadingMoreWidget: _loadingMoreWidget,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: Stack(
          fit: StackFit.expand,
          children: [
            if (!_isLoading) const BuildContent() else const Center(child: CircularProgressIndicator.adaptive()),
            if (!_isLoading) ...[
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: OverlayAppBarWidget(),
              ),
              const Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: OverlayBottomBar(),
              ),
              const Positioned(
                bottom: 8,
                left: 0,
                right: 0,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: Colors.transparent),
                  child: FooterWidget(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _onStartScroll(ScrollNotification scrollNotification) {
    final metrics = scrollNotification.metrics;
    final axisDirection = scrollNotification.metrics.axisDirection;

    if (axisDirection == AxisDirection.down && metrics.pixels == 0 && _index != 0) {
      log(metrics.pixels.toString());
    }
  }

  void _onUpdateScroll(ScrollNotification scrollNotification) {
    final metrics = scrollNotification.metrics;

    if (_percent - 0.1 >= 0.9 && _hasMore && !_loadingMoreWidget.value && (_lastWidgetKey?.currentContext != null)) {
      setState(() {
        _lastMaxScrollExtent = metrics.maxScrollExtent;
        _lastPixels = metrics.pixels;
      });
      _loadMore();
    }

    // if (_percent.isNegative) {
    //   final print = ((100 - -_percent) * 100);
    //   log('Percent: $print');
    // } else {
    //   final print = (_percent * 100);
    //   log('Percent: $print');
    // }
  }

  void _onUpdateScrollDelta(ScrollNotification scrollNotification) {
    // log('scrollDelta: ${scrollNotification.scrollDelta}');
    // _readerController.
  }

  void _onEndScroll(ScrollNotification scrollNotification) {
    if (_percent > .1 && _index != -1) {
      final chapter = _lista.elementAt(_index);
      final read = _percent > 0.90 ? true : false;
      final isRead = IsRead(read, _percent, chapter);
      if (!_isfinished.contains(isRead)) {
        _isfinished.add(isRead);
      } else {
        final indexOf = _isfinished.indexOf(isRead);
        _isfinished[indexOf] = isRead;
      }
    }
    _debouncer.call(() => _setRead());
  }

  @override
  void dispose() {
    _setRead();
    _animationControllerOverlayAppBar.dispose();
    _animationControllerOverlayBottomBar.dispose();

    _addOverlays();
    _readerController.dispose();
    _loadingMoreWidget.dispose();
    super.dispose();
  }
}

class _LoadingMore extends StatelessWidget {
  final String secondTitle;
  final String firstTitle;

  const _LoadingMore(this.secondTitle, this.firstTitle, {super.key});

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties.add(StringProperty('firstTitle', firstTitle, showName: false));
    properties.add(StringProperty('secondTitle', secondTitle, showName: false));

    super.debugFillProperties(properties);
  }

  @override
  Widget build(BuildContext context) {
    final size = context.mediaQuerySize;
    final height = size.height * .18;
    final circularSize = Size(height * .2, height * .2);

    final isLoading = ReadScope.loadingMoreOf(context);
    return AnimatedBuilder(
      animation: isLoading,
      builder: (context, child) => SizedBox(
        height: height,
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 500),
          padding: EdgeInsets.symmetric(vertical: isLoading.value ? 20 : 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(firstTitle, style: context.textTheme.labelLarge),
              if (isLoading.value) SizedBox.fromSize(size: circularSize, child: const CircularProgressIndicator.adaptive()),
              Text(secondTitle, style: context.textTheme.labelLarge),
            ],
          ),
        ),
      ),
    );
  }
}

class OverlayAppBarWidget extends StatelessWidget {
  const OverlayAppBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = ReadScope.of(context);
    return SlideTransition(
      position: scope.overlayAppBarAnimation,
      child: Card(
        margin: EdgeInsets.zero,
        // shape: const CustomShape(length: 16),
        child: Container(
          height: 90,
          color: context.colorScheme.surface,
          child: Column(
            children: [
              SizedBox(height: context.padding.top),
              Row(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                    icon: const Icon(MdiIcons.arrowLeft),
                  ),
                  if (scope.chapterName != null) Text(scope.chapterName!),
                  const Expanded(child: SizedBox.shrink()),
                  IconButton(
                    icon: const Icon(MdiIcons.dotsHorizontal),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OverlayBottomBar extends StatelessWidget {
  const OverlayBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = ReadScope.of(context);
    // final readerController = scope.readerController;

    return SlideTransition(
      position: scope.overlayBottomBarAnimation,
      child: Container(
        padding: EdgeInsets.only(
          bottom: context.viewInsets.bottom + 5,
          left: 16,
          right: 16,
          top: context.viewInsets.bottom + 10,
        ),
        decoration: BoxDecoration(color: context.colorScheme.surface),
        child: DefaultTextStyle.merge(
          style: context.textTheme.labelMedium ?? const TextStyle(fontSize: 10),
          child: Column(
            children: [
              // if (BookReaderScope.of(context)!.withExtraButtons)

              // Row(
              //   mainAxisSize: MainAxisSize.min,
              //   children: [
              //     TextButton(
              //       // onPressed: WebToonScope.of(context).onChapterUp,
              //       onPressed: () {},
              //       child: const Text('Anterior'),
              //     ),
              // Flexible(
              //   child: AnimatedBuilder(
              //     animation: readerController,
              //     builder: (context, child) {
              //       return Slider.adaptive(
              //         value: scope.percent,
              //         onChanged: (value) async {
              //           double maxScrollExtent = scope.maxScrollExtent;
              //           readerController.jumpTo(maxScrollExtent * value);
              //         },
              //         // value: (WebToonScope.webToonPageFooterOf(context).currentIndex / WebToonScope.webToonPageFooterOf(context).total),
              //         // onChanged: WebToonScope.of(context).onSliderChanged,
              //         // onChangeEnd: WebToonScope.of(context).onSliderChangeEnd,
              //       );
              //     },
              //   ),
              // ),
              //     TextButton(
              //       // onPressed: WebToonScope.of(context).onChapterDown,
              //       onPressed: () {},
              //       child: const Text('Próximo'),
              //     ),
              //   ],
              // ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {},
                    // onPressed: BookReaderScope.of(context)?.onCatalogueNavigated,
                    child: const Column(
                      children: [Icon(Icons.list_outlined), Text('Índice')],
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    // onPressed: BookReaderScope.of(context)?.onCacheNavigated,
                    child: const Column(
                      children: [Icon(Icons.download_for_offline_outlined), Text('Download')],
                    ),
                  ),
                  const TextButton(
                    onPressed: null,
                    child: Column(
                        // children: [themeModeIcon, Text(themeMode)],
                        // children: [themeModeIcon, Text(themeMode)],
                        ),
                  ),
                  const TextButton(
                    onPressed: null,
                    // onPressed: BookReaderScope.of(context)?.onSettingNavigated,
                    child: Column(
                      children: [Icon(Icons.settings_outlined), Text('Configuração')],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BuildContent extends StatelessWidget {
  const BuildContent({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = ReadScope.of(context);
    final content = scope.content;
    final readerController = scope.readerController;
    final onNotification = scope.onNotification;
    final onDoubleTapDown = scope.onDoubleTapDown;
    return NotificationListener<ScrollNotification>(
      onNotification: onNotification,
      child: Scrollbar(
        radius: const Radius.circular(8),
        child: InteractiveViewer(
          constrained: true,
          interactionEndFrictionCoefficient: 0.005,
          maxScale: 4.0,
          clipBehavior: Clip.hardEdge,
          minScale: 1.0,
          panEnabled: true,
          panAxis: PanAxis.aligned,
          scaleEnabled: true,
          child: GestureDetector(
            onDoubleTap: () {},
            onDoubleTapDown: (details) => onDoubleTapDown.call(context, details),
            child: AdaptativePageView.builder(
              itemCount: content.length,
              controller: readerController,
              cacheExtent: 95,
              key: const ValueKey('Content'),
              restorationId: 'controller',
              padEnds: false,
              itemBuilder: (context, index) => content.elementAt(index),
              allowImplicitScrolling: true,
              scrollDirection: Axis.vertical,
            ),
          ),
        ),
      ),
    );
  }
}

class _Text extends StatelessWidget {
  final String data;
  final GlobalKey widgetKey;
  const _Text({required this.data, required this.widgetKey});

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties.add(StringProperty('data', data, showName: false));

    super.debugFillProperties(properties);
  }

  @override
  Widget build(BuildContext context) {
    Widget child = Text(
      data,
      key: widgetKey,
      style: context.textTheme.bodyMedium,
    );

    if (data.contains(RegExp(r'(https?:\/\/.*\.(?:png|jpg))'))) {
      child = ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: data,
          imageBuilder: (context, imageProvider) => Image(
            image: imageProvider,
            key: widgetKey,
            fit: BoxFit.scaleDown,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: child,
    );
  }
}

class _Image extends StatelessWidget {
  final String data;
  final GlobalKey? widgetKey;
  const _Image({required this.data, this.widgetKey});

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties.add(StringProperty('image_url', data, showName: false));

    super.debugFillProperties(properties);
  }

  @override
  Widget build(BuildContext context) {
    final size = context.mediaQuerySize;
    final topPadding = context.padding.top;
    return CachedNetworkImage(
      imageUrl: data,
      imageBuilder: (context, imageProvider) => Image(
        image: imageProvider,
        key: widgetKey,
        // alignment: Alignment.center,
        fit: BoxFit.scaleDown,
      ),
      cacheManager: App.BOOKCHAPTERCACHE,
      progressIndicatorBuilder: (context, url, downloadProgress) {
        return ConstrainedBox(
          constraints: BoxConstraints(minHeight: (size.height * .35) - topPadding),
          child: Center(
            child: SizedBox.fromSize(
              size: const Size(50, 50),
              child: CircularProgressIndicator(strokeWidth: 2, value: downloadProgress.progress),
            ),
          ),
        );
      },
    );
  }
}

class FooterWidget extends StatelessWidget {
  const FooterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = ReadScope.of(context);
    final readerController = scope.readerController;

    final caption = context.textTheme.bodySmall?.copyWith(
      color: context.themeData.brightness == Brightness.light ? Colors.grey[350] : Colors.grey[200],
    );

    final locale = Localizations.localeOf(context);

    String title = '';

    return scope.overlay
        ? const SizedBox.shrink()
        : DefaultTextStyle.merge(
            style: caption,
            maxLines: 1,
            child: AnimatedBuilder(
              animation: readerController,
              builder: (context, child) {
                double percent = scope.percent * 100;
                final metrics = readerController.position;
                final date = DateFormat(DateFormat.HOUR24_MINUTE, '${locale.languageCode}_${locale.countryCode}').format(DateTime.now());

                title = percent.toStringAsPrecision(3);

                if (percent >= 10.00) {
                  title = percent.toStringAsPrecision(4);
                } else if (percent < 1) {
                  title = percent.toStringAsPrecision(2);
                  if (percent < 0.10) title = percent.toStringAsPrecision(1);
                }
                return metrics.hasContentDimensions && percent != -1
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(MdiIcons.clock, size: 16),
                              const SizedBox(width: 4),
                              Text(date),
                            ],
                          ),
                          const SizedBox(width: 20),
                          Row(
                            children: [
                              const Icon(MdiIcons.percent, size: 16),
                              const SizedBox(width: 4),
                              Text('$title%'),
                            ],
                          ),
                        ],
                      )
                    : const SizedBox.shrink();
              },
            ),
          );
  }
  // DateTime _dateTime = DateTime.now();
}



// class FooterUpdateDateTimeWidget extends StatefulWidget {
//   const FooterUpdateDateTimeWidget({super.key});

//   @override
//   State<FooterUpdateDateTimeWidget> createState() => _FooterUpdateDateTimeWidgetState();
// }

// class _FooterUpdateDateTimeWidgetState extends State<FooterUpdateDateTimeWidget> {
//   DateTime _dateTime = DateTime.now();
//   late Timer _timer;

//   @override
//   void initState() {
//     _timer = Timer.periodic(const Duration(seconds: 5), _callback);
//     super.initState();
//   }

//   @override
//   void setState(VoidCallback fn) {
//     if (mounted) super.setState(fn);
//   }

//   void _callback(Timer timer) {
//     final DateTime now = DateTime.now();
//     if (_dateTime == now) return;
//     setState(() {
//       _dateTime = now;
//     });
//   }

//   @override
//   void dispose() {
//     _timer.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // final TextStyle style = DefaultTextStyle.of(context).style;
//     final String minute = _dateTime.minute < 10 ? '0${_dateTime.minute}' : '${_dateTime.minute}';
//     final String hour = '${_dateTime.hour}';
//     return Text('$hour:$minute');
//   }
// }
