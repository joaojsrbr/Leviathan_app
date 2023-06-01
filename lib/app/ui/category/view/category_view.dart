// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:leviathan_app/app/core/extensions/custom_extensions/context_extensions.dart';
import 'package:leviathan_app/app/core/models/book_categoria.dart';
import 'package:leviathan_app/app/core/services/hive/hive_controller.dart';
import 'package:leviathan_app/app/core/utils/book_utils.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/uuid_util.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  late final HiveController _hiveController;

  final GlobalKey<AnimatedListState> _key = GlobalKey();

  late final TextEditingController _textEditingController;

  @override
  void initState() {
    _hiveController = context.read();
    _textEditingController = TextEditingController();
    super.initState();
  }

  void _addSingleItem(String name) async {
    final id = const Uuid().v4(options: {'rng': UuidUtil.cryptoRNG});

    final bookCategoria = BookCategoria(name: name, books: [], id: id, createdAt: DateTime.now());

    await _hiveController.setBookCategoria((lista) {
      if (!lista.contains(bookCategoria)) lista.insert(0, bookCategoria);
      int insertIndex = 0;
      _key.currentState?.insertItem(insertIndex);
    });

    // _data.insert(insertIndex, item);
  }

  void _removeSingleItems(BuildContext context, int index, BookCategoria categoria) async {
    _key.currentState?.removeItem(index, (context, animation) => _buildItem(context, categoria, index, animation));
    await _hiveController.setBookCategoria((lista) {
      lista.remove(categoria);
    });
  }

  void _moveSingleItem(BuildContext context, int fromIndex, int toIndex) async {
    final categorias = _hiveController.categorias;
    final item = categorias.elementAt(fromIndex);
    // final item2 = categorias.elementAt(toIndex);
    // final globalKey = GlobalKey();

    _key.currentState?.removeItem(
      fromIndex,
      (context, animation) => _buildItem(context, item, fromIndex, animation),
    );

    await _hiveController.setBookCategoria((lista) {
      final item = lista.removeAt(fromIndex);
      lista.insert(toIndex, item);

      _key.currentState?.insertItem(toIndex);
    });

    // int insertIndex = 2;
    // _data.insertAll(insertIndex, items);
    // // This is a bit of a hack because currentState doesn't have
    // // an insertAll() method.
    // for (int offset = 0; offset < items.length; offset++) {
    //   _listKey.currentState.insertItem(insertIndex + offset);
    // }
  }

  Widget _buildItem(
    BuildContext context,
    BookCategoria categoria,
    int index,
    Animation<double> animation,
  ) {
    return SizeTransition(
      sizeFactor: animation,
      child: _Item(
        index,
        categoria,
        onLongPress: () async {
          _textEditingController.text = categoria.name;
          final result = await BookUtils.addCategory(context, _textEditingController, true);
          Future.delayed(const Duration(milliseconds: 200), _textEditingController.clear);
          if (result == null) return;
          await _hiveController.setBookCategoria((lista) {
            final indexOf = lista.indexOf(categoria);

            lista[indexOf] = lista[indexOf].copyWith(name: result);
          });
        },
        moveItemDown: (fromIndex, toIndex, context) => _moveSingleItem(context, fromIndex, toIndex),
        moveItemUp: (fromIndex, toIndex, context) => _moveSingleItem(context, fromIndex, toIndex),
        removeSingleItems: (context, index, categoria) => _removeSingleItems(context, index, categoria),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categorias = context.watch<HiveController>().noSortCategorias;

    return Scaffold(
      appBar: AppBar(title: const Text('Editar categorias')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await BookUtils.addCategory(context, _textEditingController);
          Future.delayed(const Duration(milliseconds: 200), _textEditingController.clear);
          if (result != null) {
            // _textEditingController.clear();
            _addSingleItem(result);
          }
        },
        icon: const Icon(MdiIcons.plus),
        label: const Text('Adicionar'),
      ),
      body: AnimatedList(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        initialItemCount: categorias.length,
        key: _key,
        itemBuilder: (context, index, animation) => _buildItem(context, categorias.elementAt(index), index, animation),
      ),
    );
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }
}

class _Item extends StatelessWidget {
  const _Item(
    this.index,
    this.categoria, {
    this.removeSingleItems,
    this.moveItemUp,
    this.moveItemDown,
    this.onLongPress,
  });

  final int index;
  final void Function(BuildContext context, int index, BookCategoria categoria)? removeSingleItems;
  final VoidCallback? onLongPress;
  final void Function(int fromIndex, int toIndex, BuildContext context)? moveItemUp;
  final void Function(int fromIndex, int toIndex, BuildContext context)? moveItemDown;
  final BookCategoria categoria;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final length = context.read<HiveController>().categorias.length - 1;
    final borderRadius = BorderRadius.circular(10);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      child: InkWell(
        borderRadius: borderRadius,
        onLongPress: onLongPress,
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 10),
          constraints: const BoxConstraints(maxHeight: 100),
          child: Builder(builder: (context) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(MdiIcons.label),
                        const SizedBox(width: 8),
                        Text(categoria.name, style: textTheme.titleMedium),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(MdiIcons.newBox, size: 18),
                        const SizedBox(width: 4),
                        Text(categoria.createdAtString(context), style: textTheme.labelSmall),
                        if (categoria.updatedAt == null) const SizedBox(width: 8),
                        if (categoria.updatedAt != null) ...[
                          // VerticalDivider(thickness: 8),
                          const SizedBox(width: 8),
                          const Icon(MdiIcons.update, size: 18),
                          const SizedBox(width: 4),
                          Text(categoria.updatedAtString(context)!, style: textTheme.labelSmall),
                          const SizedBox(width: 8),
                        ]
                      ],
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          visualDensity: const VisualDensity(vertical: -2, horizontal: -4),
                          onPressed: index == 0 ? null : () => moveItemUp?.call(index, index - 1, context),
                          iconSize: 20,
                          icon: const Icon(MdiIcons.chevronUp),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          visualDensity: const VisualDensity(vertical: -2, horizontal: -4),
                          onPressed: index == length ? null : () => moveItemDown?.call(index, index + 1, context),
                          iconSize: 20,
                          icon: const Icon(MdiIcons.chevronDown),
                        ),
                      ],
                    ),
                    IconButton(
                      visualDensity: const VisualDensity(vertical: -2, horizontal: -4),
                      onPressed: () async {
                        final result = await BookUtils.categoryRemove(context, categoria);

                        if (result == true && context.mounted) {
                          removeSingleItems?.call(context, index, categoria);
                        }
                      },
                      color: Colors.red,
                      iconSize: 20,
                      icon: const Icon(MdiIcons.trashCan),
                    ),
                  ],
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
