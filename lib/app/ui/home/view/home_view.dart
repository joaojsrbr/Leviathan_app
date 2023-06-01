import 'package:animated_size_and_fade/animated_size_and_fade.dart';
import 'package:flutter/material.dart';
import 'package:hidable/hidable.dart';
import 'package:leviathan_app/app/core/constants/home.dart';
import 'package:leviathan_app/app/core/extensions/custom_extensions/context_extensions.dart';
import 'package:leviathan_app/app/core/services/hive/hive_controller.dart';
import 'package:leviathan_app/app/core/utils/custom_hidable_controler.dart';
import 'package:leviathan_app/app/core/utils/is_selected.dart';
import 'package:leviathan_app/app/ui/home/destinations/book_destination.dart';
import 'package:leviathan_app/app/ui/home/destinations/library_destination.dart';
import 'package:leviathan_app/app/ui/home/widgets/scope.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late final HiveController _hiveController;
  late final ScrollController _scrollController;
  late final TabController _tabController;

  bool _showOverFlowWidget = false;
  final List<Widget> _persistentFooterButtons = [];

  @override
  void initState() {
    _scrollController = ScrollController();
    _hiveController = context.read()..addListener(_hiveListener);
    _tabController = TabController(vsync: this, length: 2, initialIndex: _hiveController.homeSelect.index);
    super.initState();
  }

  void _hiveListener() {
    final index = _hiveController.homeSelect.index;

    if (index != _tabController.index) {
      _tabController.animateTo(
        index,
        curve: Curves.ease,
        duration: const Duration(seconds: 1),
      );
    }
  }

  void _activeOverFlowWidget(bool active, [List<Widget>? persistentFooterButtons]) {
    if (persistentFooterButtons != null && active) {
      _persistentFooterButtons.addAll(persistentFooterButtons);
    } else {
      _persistentFooterButtons.clear();
    }

    setState(() => _showOverFlowWidget = active);
  }

  @override
  Widget build(BuildContext context) {
    final hiveController = context.watch<HiveController>();
    final isSelected = context.watch<IsSelected>();
    return WillPopScope(
      onWillPop: () async {
        final isHome = hiveController.homeSelect == HomeSelect.Home;
        if (isSelected.isNotEmpty) {
          isSelected.clear();
          _activeOverFlowWidget(false);
          return false;
        } else if (!isHome && isSelected.isEmpty) {
          await hiveController.setHomeSelect(HomeSelect.Home);
          return false;
        }
        return true;
      },
      child: HomeScope(
        activeOverflow: _showOverFlowWidget,
        persistentFooterButtons: _persistentFooterButtons,
        activeOverFlowWidget: _activeOverFlowWidget,
        child: PrimaryScrollController(
          controller: _scrollController,
          child: Scaffold(
            // floatingActionButton: FloatingActionButton(onPressed: () {}, child: Icon(Icons.abc)),
            bottomNavigationBar: const BottomNavigationWidget(),
            body: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              controller: _tabController,
              children: const [
                HomeDestination(),
                LibraryDestination(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _hiveController.removeListener(_hiveListener);
    _tabController.dispose();
    super.dispose();
  }
}

class _OverFlowWidget extends StatelessWidget {
  const _OverFlowWidget();

  @override
  Widget build(BuildContext context) {
    //IntrinsicHeight
    final persistentFooterButtons = HomeScope.of(context).persistentFooterButtons;
    return Container(
      height: context.mediaQuerySize.height * .09,
      width: context.mediaQuerySize.width,
      decoration: BoxDecoration(border: Border(top: Divider.createBorderSide(context, width: 1.0))),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: OverflowBar(
            spacing: 8,
            overflowAlignment: OverflowBarAlignment.end,
            children: persistentFooterButtons,
          ),
        ),
      ),
    );
  }
}

class BottomNavigationWidget extends StatelessWidget {
  const BottomNavigationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final hiveController = context.watch<HiveController>();

    final activeOverflow = HomeScope.of(context).activeOverflow;
    return AnimatedSizeAndFade(
      alignment: Alignment.center,
      child: activeOverflow
          ? const _OverFlowWidget()
          : Hidable.custom(
              hidableController: CustomHidableController(),
              controller: PrimaryScrollController.of(context),
              preferredWidgetSize: Size.fromHeight(context.mediaQuerySize.height * .09),
              child: NavigationBar(
                labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
                selectedIndex: hiveController.homeSelect.index,
                onDestinationSelected: (value) => hiveController.setHomeSelect(HomeSelect.values.elementAt(value)),
                destinations: HomeSelect.values
                    .map(
                      (e) => NavigationDestination(
                        icon: Icon(e.icon),
                        selectedIcon: Icon(e.selectedIcon),
                        label: e.label,
                      ),
                    )
                    .toList(),
              ),
            ),
    );
  }
}
