// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:leviathan_app/app/core/constants/chapter_bottom_sheet.dart';
import 'package:leviathan_app/app/core/extensions/custom_extensions/book_extensions.dart';
import 'package:leviathan_app/app/core/extensions/custom_extensions/context_extensions.dart';
import 'package:leviathan_app/app/core/extensions/custom_extensions/list_extensions.dart';
import 'package:leviathan_app/app/core/extensions/custom_extensions/result_extensions.dart';
import 'package:leviathan_app/app/core/interfaces/success.dart';
import 'package:leviathan_app/app/core/models/book.dart';
import 'package:leviathan_app/app/core/models/chapter.dart';
import 'package:leviathan_app/app/core/repositories/library_repository.dart';
import 'package:leviathan_app/app/core/repositories/load_book_repository.dart';
import 'package:leviathan_app/app/core/routes/routes.dart';
import 'package:leviathan_app/app/core/services/hive/hive_controller.dart';
import 'package:leviathan_app/app/core/utils/debouncer.dart';
import 'package:leviathan_app/app/core/widgets/custom_text_field.dart';
import 'package:leviathan_app/app/core/widgets/open_container_wrapper.dart';
import 'package:leviathan_app/app/ui/info/widgets/card_sinopse_expanded.dart';
import 'package:leviathan_app/app/ui/info/widgets/chapters.dart';
import 'package:leviathan_app/app/ui/info/widgets/scope.dart';
import 'package:leviathan_app/app/ui/info/widgets/space_bar.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class BookInfoPage extends StatefulWidget {
  const BookInfoPage({super.key});

  // ignore: non_constant_identifier_names
  static final GlobalKey CHAPTERS = GlobalKey();

  @override
  State<BookInfoPage> createState() => _BookInfoPageState();
}

class _BookInfoPageState extends State<BookInfoPage> {
  late final LoadBookRepository _allRepository;
  late final LibraryRepository _library;
  late final HiveController _hiveController;
  late final TextEditingController _chapterSearch;
  bool _isLoadingChapters = true;
  ColorScheme? _colorScheme;
  bool _isExpanded = false;
  StreamSubscription<Result<Book>>? _subscription;

  Book? _book;

  @override
  void initState() {
    _chapterSearch = TextEditingController();
    _allRepository = context.read();
    _hiveController = context.read();
    _library = context.read();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => _getBook());

    super.initState();
  }

  Future<void> _getBook() async {
    if (!_isLoadingChapters) setState(() => _isLoadingChapters = true);

    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    final bookArgs = args['book'] as Book;

    final bookInDataBase = bookArgs.getBookInDatabase(context);

    // await Future.wait(hiveController.disableOnlyBookCache.values.map((e) => _cache.delete(e)));

    if (bookInDataBase != null) {
      _book = bookInDataBase;
      // if (_book?.seedColor != null) _colorScheme = ColorScheme.fromSeed(seedColor: _book!.seedColor!, brightness: context.themeData.brightness);
      await Future.delayed(const Duration(seconds: 1));
      if (mounted && bookInDataBase.chapters != null) setState(() => _isLoadingChapters = false);

      _subscription = _allRepository.bookInfo(bookArgs).asStream().listen((result) {
        result.deconstruction(
          onEnd: () {
            // final key = BookInfoPage.CHAPTERS.currentWidget as Column?;
            // if (key == null) return;
            // final children = key.children as List<ChapterScope>;
            // final result = children.firstWhere((element) => element.chapter.chapterName.contains('Cap. 264'));
            // final context = (result.key as GlobalKey).currentContext;
            // if (context == null) return;
            // final offset = (context.findRenderObject() as RenderBox).localToGlobal(Offset.zero);
            // final size = context.size;
            // final scrollState = Scrollable.of(context);
            // final position = scrollState.position;
            // position.animateTo(
            //   (offset.dy - kToolbarHeight) - (size?.height ?? 0),
            //   duration: const Duration(seconds: 1),
            //   curve: Curves.fastOutSlowIn,
            // );
            // print(offset);
          },
          failure: (error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                content: Text('Error ao atualizar dados do ${_book?.type ?? bookArgs.type ?? 'Livro'}'),
                behavior: SnackBarBehavior.floating,
              ),
            );

            if (_book?.chapters == null) OpenContainerWrapper.closedContainer(context);
          },
          success: (data, description) async {
            _book = data;
            if (_book?.seedColor == null) {
              final imageURL = _book!.getIMG;
              final colorScheme = await ColorScheme.fromImageProvider(
                provider: CachedNetworkImageProvider(imageURL),
                brightness: context.themeData.brightness,
              );
              _book = _book!.copyWith(seedColor: colorScheme.primary);
            }

            _library.update(book: _book!.copyWith(updatedAt: DateTime.now()));

            setState(() => _isLoadingChapters = false);
          },
        );
      });
    } else {
      _subscription = _allRepository.bookInfo(bookArgs).asStream().listen((result) async {
        result.deconstruction(
          failure: (error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                content: const Text('Error ao buscar o conteúdo'),
                behavior: SnackBarBehavior.floating,
              ),
            );
            Future.delayed(const Duration(seconds: 1), () => OpenContainerWrapper.closedContainer(context));
          },
          success: (data, description) async {
            _book = data;

            final imageURL = data.getIMG;
            _colorScheme = await ColorScheme.fromImageProvider(
              provider: CachedNetworkImageProvider(imageURL),
              brightness: context.themeData.brightness,
            );
            _book = _book!.copyWith(seedColor: _colorScheme?.primary);

            if (mounted) setState(() => _isLoadingChapters = false);

            // if (_bookRepository.contains(book: _book)) _bookRepository.update(book: data);
          },
        );
      });
    }
  }

  void _onExpandedSinopse() => setState(() => _isExpanded = !_isExpanded);

  Future<ChapterBottomSheetOptions?> _chapterBottomSheet(BuildContext context) async {
    final chapter = ChapterScope.of(context).chapter;
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0));
    return await showModalBottomSheet<ChapterBottomSheetOptions>(
      context: context,
      showDragHandle: true,
      shape: shape,
      builder: (context) {
        final viewInsets = context.viewInsets;
        final themeData = context.themeData;
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 18, bottom: 12),
              child: Tooltip(
                message: chapter.chapterName,
                preferBelow: false,
                child: Text(
                  chapter.chapterName,
                  style: themeData.textTheme.titleLarge?.copyWith(color: themeData.colorScheme.primary),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: viewInsets.bottom + 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: ChapterBottomSheetOptions.values
                    .map(
                      (element) => Tooltip(
                        message: element.label,
                        preferBelow: false,
                        child: ListTile(
                          dense: true,
                          minVerticalPadding: 2,
                          minLeadingWidth: 30,
                          enableFeedback: true,
                          onTap: () => Navigator.of(context).pop(element),
                          leading: Icon(element.icon, color: themeData.colorScheme.primary),
                          title: Text(element.label),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  void _onChapterBottomSheet(BuildContext context, Chapter chapter) async {
    final result = await _chapterBottomSheet(context);
    final book = _book;
    if (result == null || book == null) return;
    final chaptersReverse = _hiveController.chaptersReverse;
    final chapters = _book!.chapters!.reverse(chaptersReverse);
    // _bookRepository;
    switch (result) {
      case ChapterBottomSheetOptions.SHARE:
        await Share.share(chapter.url);
        break;
      case ChapterBottomSheetOptions.WEBVIEW:
        if (mounted) await Navigator.of(context).pushNamed(RouteName.WEBVIEW, arguments: chapter.url);
        break;
      case ChapterBottomSheetOptions.ANTERIORESLIDO:
        int start = chapters.indexWhere((element) => _library.chapterTest(element, chapter));
        int end = chapters.length;

        final filter = chapters
            .getRange(start + 1, end)
            .map((e) => e.copyWith(
                  readPercent: 1.0,
                  read: true,
                  updatedAt: DateTime.now(),
                ))
            .toList();
        _library.addAll(chapters: filter);
        log('$result[${filter.length}]');
        break;
      case ChapterBottomSheetOptions.ANTERIORESNLIDO:
        int start = chapters.indexWhere((element) => _library.chapterTest(element, chapter));
        int end = chapters.length;
        final filter = chapters.getRange(start + 1, end).toList();
        _library.removeAll(chapters: filter);
        log('$result[${filter.length}]');
        break;
      case ChapterBottomSheetOptions.INTERVALOLIDO:
        break;
      case ChapterBottomSheetOptions.INTERVALONLIDO:
        break;
    }
  }

  ColorScheme? _scheme(BuildContext context, Book book) {
    final colorSeed = book.getBookInDatabase(context)?.seedColor;

    if (colorSeed != null) {
      return ColorScheme.fromSeed(
        seedColor: colorSeed,
        brightness: context.themeData.brightness,
      );
    }
    return _colorScheme;
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    final bookArgs = args['book'];

    final size = context.mediaQuerySize;

    // final bookRepository = context.watch<BookRepository>();
    final book = _book ?? bookArgs;

    return AnimatedTheme(
      data: context.themeData.copyWith(colorScheme: _scheme(context, book)),
      child: BookInfoScope(
        onChapterBottomSheet: _onChapterBottomSheet,
        isExpanded: _isExpanded,
        onExpandedSinopse: _onExpandedSinopse,
        chapterSearch: _chapterSearch,
        isLoadingChapters: _isLoadingChapters,
        book: book,
        child: Builder(builder: (context) {
          final book = BookInfoScope.of(context).book;
          final sinopseActive = book.sinopse != null;

          final library = context.watch<LibraryRepository>();
          final favorite = library.contains(book: book);

          return Scaffold(
            backgroundColor: context.colorScheme.background,
            body: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  actions: [
                    IconButton(
                      onPressed: () => Share.share(book.url),
                      color: Colors.white,
                      icon: const Icon(MdiIcons.share),
                    ),
                    IconButton(
                      onPressed: !_isLoadingChapters
                          ? () {
                              if (favorite) {
                                library.remove(book: book);
                              } else {
                                library.add(book: book);
                              }
                            }
                          : null,
                      isSelected: favorite,
                      selectedIcon: const Icon(MdiIcons.heartRemove),
                      color: Colors.red,
                      icon: const Icon(MdiIcons.heartPlusOutline),
                    ),
                  ],
                  expandedHeight: size.height * .4,
                  stretch: true,
                  pinned: true,
                  leading: IconButton(onPressed: () => OpenContainerWrapper.closedContainer(context), icon: const Icon(MdiIcons.arrowLeft)),
                  flexibleSpace: const SpaceBar(),
                ),
                if (sinopseActive && !_isLoadingChapters) const SliverToBoxAdapter(child: CardSinopseExpanded()),
                if (!_isLoadingChapters) const SliverToBoxAdapter(child: _Buttons()),
                (_isLoadingChapters) ? const SliverFillRemaining(child: Center(child: CircularProgressIndicator.adaptive())) : const ChaptersWidget()
              ],
            ),
          );
        }),
      ),
    );
  }

  @override
  void dispose() {
    _chapterSearch.dispose();
    _subscription?.cancel();
    super.dispose();
  }
}

class _Buttons extends StatelessWidget {
  const _Buttons();

  // void _unfocusKeyBoard(BuildContext context) {
  //   FocusScopeNode currentFocus = FocusScope.of(context);

  //   if (!currentFocus.hasPrimaryFocus) currentFocus.unfocus();
  // }

  @override
  Widget build(BuildContext context) {
    Debouncer? debouncer;
    Widget? label;
    final textTheme = context.textTheme;
    final colorScheme = context.colorScheme;
    final reverseList = context.watch<HiveController>().chaptersReverse;

    final size = context.mediaQuerySize;
    final chapterSearch = BookInfoScope.of(context).chapterSearch;
    final chapters = BookInfoScope.of(context).book.chapters;
    // final filterChapters = (reverseList ? chapters?.reversed.toList() : chapters) ?? [];
    if (chapters != null) {
      label = Text('${chapters.length}', style: textTheme.titleMedium?.copyWith(color: context.colorScheme.primary));
    }

    return Padding(
      padding: const EdgeInsets.only(left: 18, top: 16, bottom: 6, right: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Capítulos', style: textTheme.titleLarge?.copyWith(fontSize: 25)),
          SizedBox(width: size.width * .02),
          Flexible(
            child: SizedBox(
              height: 36,
              width: size.width * .40,
              child: CustomTextField(
                onEditingComplete: () {
                  if ((chapters?.length ?? 0) > 500) return;
                  final value = chapterSearch.text;
                  if (value.isEmpty || !reverseList) return;

                  debouncer = null;
                  debouncer = Debouncer(duration: const Duration(seconds: 1));
                  debouncer?.call(() {
                    final scrollableState = Scrollable.of(context);
                    final position = scrollableState.position;
                    final pixels = position.pixels;
                    final maxScrollExtent = position.maxScrollExtent;
                    if (pixels == maxScrollExtent) return;
                    scrollableState.position.animateTo(
                      maxScrollExtent,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.fastOutSlowIn,
                    );
                  });
                },
                controller: chapterSearch,
                label: label,
                // keyboardType: TextInputType.number,
                keyboardType: TextInputType.visiblePassword,
                // cursorHeight: 25,
              ),
            ),
          ),

          // SizedBox(width: size.width * .02),
          IconButton(
            visualDensity: const VisualDensity(vertical: -2),
            onPressed: () {
              final hiveController = context.read<HiveController>();
              hiveController.setChaptersReverse(!hiveController.chaptersReverse);
            },
            color: colorScheme.primary,
            isSelected: reverseList,
            enableFeedback: true,
            selectedIcon: const Icon(MdiIcons.sortNumericDescending),
            tooltip: reverseList ? 'Ordem Descendente' : 'Ordem Crescente',
            icon: const Icon(MdiIcons.sortNumericAscending),
          ),
        ],
      ),
    );
  }
}
