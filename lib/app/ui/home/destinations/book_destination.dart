import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:leviathan_app/app/core/constants/grid.dart';
import 'package:leviathan_app/app/core/models/book.dart';
import 'package:leviathan_app/app/core/repositories/load_book_repository.dart';
import 'package:leviathan_app/app/core/routes/routes.dart';
import 'package:leviathan_app/app/core/services/hive/hive_controller.dart';
import 'package:leviathan_app/app/core/widgets/shared_axis_transition.dart';
import 'package:leviathan_app/app/ui/home/widgets/buttons_widget.dart';
import 'package:leviathan_app/app/ui/home/widgets/indicator_build.dart';
import 'package:leviathan_app/app/ui/home/widgets/item_builder.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sliver_tools/sliver_tools.dart';

class HomeDestination extends StatefulWidget {
  const HomeDestination({super.key});

  @override
  State<HomeDestination> createState() => _HomeDestinationState();
}

class _HomeDestinationState extends State<HomeDestination> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final hiveController = context.watch<HiveController>();
    final repository = context.watch<LoadBookRepository>().repository;
    // final favoriteList = context.watch<BookRepository>().lista;
    final appBarTitle = hiveController.fonte.label;
    const bottom = Buttons(isBiblioteca: false);
    final mode = hiveController.modeView;

    return RefreshIndicator(
      onRefresh: () async {
        if (hiveController.type != repository.type) repository.setType = hiveController.type;
        await repository.refresh(true);
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverAppBar(
            // centerTitle: true,
            title: Text(appBarTitle),
            actions: [
              IconButton(
                onPressed: () => Navigator.push(
                  context,
                  SharedAxisTransitionPageRouterBuilder(
                    transitionKey: 'home_to_${RouteName.CONFIG}',
                    routeName: RouteName.CONFIG,
                  ),
                ),
                icon: const Icon(MdiIcons.cog),
              ),
              if (kDebugMode)
                IconButton(
                  onPressed: () => Navigator.push(
                    context,
                    SharedAxisTransitionPageRouterBuilder(
                      transitionKey: 'home_to_${RouteName.TEST}',
                      routeName: RouteName.TEST,
                    ),
                  ),
                  icon: const Icon(MdiIcons.testTube),
                ),
            ],
            pinned: true,
            floating: true,
            bottom: bottom,
          ),
          if (mode == ModeView.GRID_2X2 || mode == ModeView.GRID_3X3)
            SliverAnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              child: LoadingMoreSliverList(
                SliverListConfig<Book>(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  indicatorBuilder: indicatorBuilder,
                  // lastChildLayoutType: LastChildLayoutType.fullCrossAxisExtent,
                  itemBuilder: itemBuilder,
                  gridDelegate: mode == ModeView.GRID_2X2 ? Grid.BOOKGRIDDELEGATE : Grid.FAVORITEGRIDDELEGATE,
                  sourceList: repository,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
