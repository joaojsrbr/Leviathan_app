import 'package:flutter/material.dart';
import 'package:leviathan_app/app/core/utils/is_selected.dart';
import 'package:leviathan_app/app/ui/home/controllers/library_text_editing_controller.dart';
import 'package:leviathan_app/app/ui/home/widgets/scope.dart';
import 'package:provider/provider.dart';

class LibraryControllers {
  late final IsSelected _isSelected;
  late final HomeScope _homeScope;
  late final TabController _tabController;
  late final LibraryTextEditingController libraryTextEditingController;

  LibraryControllers(BuildContext context) {
    libraryTextEditingController = LibraryTextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => _onInit(context));
  }

  void _onInit(BuildContext context) {
    _isSelected = context.read();
    _homeScope = HomeScope.of(context);
    _tabController = DefaultTabController.of(context)..addListener(_tabListener);
  }

  void _tabListener() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (_isSelected.isNotEmpty && _tabController.animation?.status == AnimationStatus.forward) {
        _homeScope.activeOverFlowWidget(false);
        _isSelected.clear(true);
      }
    });
  }

  void dispose() {
    _tabController.removeListener(_tabListener);
    // _bibliotecaTextEditingController.dispose();
  }
}
