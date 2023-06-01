import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:leviathan_app/app/core/extensions/custom_extensions/context_extensions.dart';
import 'package:leviathan_app/app/core/extensions/custom_extensions/list_extensions.dart';
import 'package:leviathan_app/app/core/models/book.dart';
import 'package:leviathan_app/app/core/repositories/library_repository.dart';
import 'package:leviathan_app/app/core/routes/routes.dart';
import 'package:leviathan_app/app/core/services/hive/hive_controller.dart';
import 'package:leviathan_app/app/core/utils/is_selected.dart';
import 'package:leviathan_app/app/core/widgets/custom_text_field.dart';
import 'package:leviathan_app/app/core/widgets/shared_axis_transition.dart';
import 'package:leviathan_app/app/ui/home/controllers/library_controllers.dart';
import 'package:leviathan_app/app/ui/home/controllers/library_text_editing_controller.dart';
import 'package:leviathan_app/app/ui/home/widgets/animated_widget.dart';
import 'package:leviathan_app/app/ui/home/widgets/library_grid_view.dart';
import 'package:leviathan_app/app/ui/home/widgets/scope.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

class LibraryDestination extends StatefulWidget {
  const LibraryDestination({super.key});

  @override
  State<LibraryDestination> createState() => LibraryDestinationState();
}

class LibraryDestinationState extends State<LibraryDestination> with AutomaticKeepAliveClientMixin {
  bool _showSearch = false;

  int _sortCreatedAt(Book a, Book b) {
    if (a.createdAt != null && b.createdAt != null) return b.createdAt!.compareTo(a.createdAt!);
    return 1;
  }

  int _indexOf(List<Iterable<String>> data, String search) {
    final index = data.indexWhere((lista) => lista.firstWhereOrNull((title) => title.toLowerCase().contains(search.trim().toLowerCase())) != null);
    // log(index.toString());
    return index;
    // return data.indexWhere((lista) => lista.firstWhereOrNull((title) => title.toLowerCase().contains(search.trim().toLowerCase())) != null);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final library = context.watch<LibraryRepository>();
    final favoriteList = library.sorted(_sortCreatedAt);
    final hiveController = context.watch<HiveController>();
    final isSelected = context.watch<IsSelected>();
    final categorias = hiveController.categorias;

    final filterList = favoriteList.filterList(categorias);
    final titleList = filterList.map((e) => e.map((e) => e.title)).toList();

    double? leadingWidth;

    final tabs = filterList.getTabs(categorias);

    if (_showSearch || isSelected.isNotEmpty) {
      leadingWidth = null;
    } else {
      leadingWidth = 0;
    }

    // final locale = Localizations.localeOf(context);

    return DefaultTabController(
      length: filterList.length,
      child: MultiProvider(
        providers: [
          Provider<LibraryControllers>(
            create: (context) => LibraryControllers(context),
            dispose: (context, value) => value.dispose(),
          ),
          ChangeNotifierProvider<LibraryTextEditingController>(
            create: (context) => context.read<LibraryControllers>().libraryTextEditingController,
          ),
        ],
        builder: (context, child) => NestedScrollView(
          floatHeaderSlivers: false,
          physics: const ClampingScrollPhysics(),
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              automaticallyImplyLeading: false,
              leadingWidth: leadingWidth,
              leading: CustomAnimatedWidget(
                active: isSelected.isNotEmpty || _showSearch,
                child: IconButton(
                  onPressed: () {
                    if (_showSearch) {
                      context.read<LibraryTextEditingController>().clear();
                      setState(() => _showSearch = false);
                    } else {
                      isSelected.clear(true);
                      HomeScope.of(context).activeOverFlowWidget(false);
                    }
                  },
                  icon: const Icon(MdiIcons.arrowLeft),
                ),
              ),
              forceElevated: innerBoxIsScrolled || isSelected.isNotEmpty || _showSearch,
              title: CustomAnimatedWidget(
                active: isSelected.isNotEmpty,
                replaceWidget: CustomAnimatedWidget(
                  active: _showSearch,
                  replaceWidget: const Text('Biblioteca'),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Container(
                      alignment: Alignment.center,
                      height: 40,
                      width: context.mediaQuerySize.width * .85,
                      child: CustomTextField(
                        permaButton: true,
                        autofocus: true,
                        controller: context.read<LibraryTextEditingController>(),
                        onButtonPressed: () {
                          DefaultTabController.of(context).animateTo(0);
                          setState(() => _showSearch = false);
                        },
                        onChanged: (data) {
                          final indexOf = _indexOf(titleList, data);
                          if (indexOf == -1) return;
                          final tabController = DefaultTabController.of(context);
                          final index = tabController.index;
                          if (indexOf != index) tabController.animateTo(indexOf);
                        },
                      ),
                    ),
                  ),
                ),
                child: Text(isSelected.value.length.toString()),
              ),
              pinned: true,
              bottom: _TabBarWidget(tabs),
              floating: true,
              actions: [
                if (!_showSearch)
                  IconButton(
                    onPressed: () {
                      if (isSelected.isNotEmpty) {
                        final homeScope = HomeScope.of(context);
                        isSelected.clear(true);
                        homeScope.activeOverFlowWidget(false);
                      }
                      Navigator.of(context).push(
                        SharedAxisTransitionPageRouterBuilder(
                          transitionKey: 'biblioteca_to_${RouteName.CATEGORY}',
                          routeName: RouteName.CATEGORY,
                        ),
                      );
                    },
                    icon: const Icon(MdiIcons.label),
                  ),
                if (isSelected.isEmpty && !_showSearch)
                  IconButton(
                    onPressed: () {
                      setState(() => _showSearch = !_showSearch);
                      // _textFieldFocusNode.requestFocus();
                    },
                    icon: const Icon(MdiIcons.magnify),
                  ),
                if (isSelected.isNotEmpty)
                  IconButton(
                    onPressed: () {
                      final tabController = DefaultTabController.of(context);

                      final index = tabController.index;
                      final ids = filterList.elementAt(index).map((e) => e.id).toList();
                      if (isSelected.value.length == ids.length) {
                        isSelected.clear();
                        isSelected.add(isSelected.cache ?? ids.first);
                        // HomeScope.of(context).activeOverFlowWidget(false);
                      } else {
                        isSelected.addAll(ids);
                      }
                    },
                    icon: const Icon(MdiIcons.selectAll),
                  ),
              ],
            ),
          ],
          body: TabBarView(
            physics: const ScrollPhysics(),
            children: List.generate(filterList.length, (index) => BuildGridView(lista: filterList.elementAt(index))),
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _TabBarWidget extends StatelessWidget implements PreferredSizeWidget {
  const _TabBarWidget(this.tabs);

  final List<Widget> tabs;

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: Size(context.mediaQuerySize.width, preferredSize.height),
      child: TabBar(
        splashBorderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        isScrollable: true,
        padding: const EdgeInsets.only(left: 12),
        enableFeedback: true,
        physics: const BouncingScrollPhysics(),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: context.colorScheme.primary,
        dividerColor: Colors.transparent,
        tabs: tabs,
      ),
    );
  }

  @override
  Size get preferredSize {
    double maxHeight = 46.0;
    for (final Widget item in tabs) {
      if (item is PreferredSizeWidget) {
        final double itemHeight = item.preferredSize.height;
        maxHeight = math.max(itemHeight, maxHeight);
      }
    }
    return Size.fromHeight(maxHeight + 2.0);
  }
}
