import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:leviathan_app/app/core/constants/grid.dart';
import 'package:leviathan_app/app/core/models/book.dart';
import 'package:leviathan_app/app/core/models/book_categoria.dart';
import 'package:leviathan_app/app/core/repositories/library_repository.dart';
import 'package:leviathan_app/app/core/routes/routes.dart';
import 'package:leviathan_app/app/core/services/hive/hive_controller.dart';
import 'package:leviathan_app/app/core/utils/book_utils.dart';
import 'package:leviathan_app/app/core/utils/is_selected.dart';
import 'package:leviathan_app/app/core/widgets/book_item.dart';
import 'package:leviathan_app/app/core/widgets/shared_axis_transition.dart';
import 'package:leviathan_app/app/ui/home/controllers/library_text_editing_controller.dart';
import 'package:leviathan_app/app/ui/home/widgets/scope.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

class BuildGridView extends StatelessWidget {
  final List<Book> lista;
  const BuildGridView({super.key, required this.lista});

  @override
  Widget build(BuildContext context) {
    final text = context.watch<LibraryTextEditingController>().text;
    final filter = lista.where((element) => element.title.toLowerCase().contains(text.toLowerCase()));
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
      gridDelegate: Grid.FAVORITEGRIDDELEGATE,
      itemBuilder: (context, index) => _itemBuilder(context, filter.elementAt(index), index),
      itemCount: filter.length,
    );
  }

  List<Widget> _persistentFooterButtons(BuildContext context, Book book) {
    final hiveController = context.read<HiveController>();
    final isSelected = context.read<IsSelected>();
    final homeScope = HomeScope.of(context);
    return [
      IconButton(
        onPressed: () async {
          final initialData = hiveController.categorias
              //
              .where((element) => element.books.contains(book.id))
              //
              .toList();
          final result = await BookUtils.category(context, initialData);

          if (result is String && context.mounted) {
            if (RouteName.CATEGORY == result) {
              isSelected.clear();
              homeScope.activeOverFlowWidget(false);
              Navigator.of(context).push(
                SharedAxisTransitionPageRouterBuilder(
                  transitionKey: 'biblioteca_to_${RouteName.CATEGORY}',
                  routeName: RouteName.CATEGORY,
                ),
              );
            }
          } else if (result is List<BookCategoria>) {
            _saveCategoria(result, isSelected, homeScope, hiveController);
          }
        },
        icon: const Icon(MdiIcons.label),
      ),
      IconButton(
        onPressed: () async {
          final ids = isSelected.value;
          final books = lista.where((element) => isSelected.contains(element.id)).toList();
          final result = await BookUtils.bibliotecaAddOrRemove(context, books);
          if (result == true && context.mounted) {
            final library = context.read<LibraryRepository>();
            final filter = lista.where((book) => ids.contains(book.id)).toList();
            library.removeAll(books: filter);
            isSelected.clear();
            homeScope.activeOverFlowWidget(false);
          }
        },
        icon: const Icon(MdiIcons.trashCan),
      )
    ];
  }

  void _saveCategoria(
    List<BookCategoria> result,
    IsSelected isSelected,
    HomeScope homeScope,
    HiveController hiveController,
  ) async {
    final ids = isSelected.value;

    await hiveController.setBookCategoria((lista) {
      for (final id in ids) {
        if (result.isEmpty) {
          _removeAll(id, lista);
        } else {
          for (final categoria in result) {
            final indexOf = lista.indexWhere((element) => element == categoria);
            // var instance = lista.firstWhereOrNull((element) => element == categoria);

            if (indexOf != -1) {
              if (!lista[indexOf].books.contains(id)) {
                lista[indexOf].books.add(id);
                lista[indexOf] = lista[indexOf].copyWith(updatedAt: DateTime.now());
              }
              _removeAll(id, lista.where((element) => !result.contains(element)));
            }
          }
        }
      }
      isSelected.clear();
      homeScope.activeOverFlowWidget(false);
    });
  }

  void _removeAll(String id, Iterable<BookCategoria> lista) {
    lista.forEachIndexed((index, categoria) {
      if (categoria.books.contains(id)) categoria.books.remove(id);
      categoria = categoria.copyWith(updatedAt: DateTime.now());
    });
  }

  Widget _itemBuilder(BuildContext context, Book book, int index) {
    return BookItem(
      book: book,
      isBiblioteca: true,
      persistentFooterButtons: _persistentFooterButtons(context, book),
    );
  }
}
