import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:leviathan_app/app/core/extensions/custom_extensions/context_extensions.dart';
import 'package:leviathan_app/app/core/models/book.dart';
import 'package:leviathan_app/app/core/models/book_categoria.dart';
import 'package:leviathan_app/app/core/routes/routes.dart';
import 'package:leviathan_app/app/core/services/hive/hive_controller.dart';
import 'package:leviathan_app/app/core/widgets/custom_text_field.dart';
import 'package:provider/provider.dart';

class BookUtils {
  BookUtils._();

  static Future<bool?> bibliotecaAddOrRemove(BuildContext context, List<Book> books) async {
    String title;
    if (books.length == 1) {
      title = '"${books.first.title.trim()}"';
    } else {
      if (books.length >= 3) {
        title = "${books.getRange(0, 3).map((e) => '"${e.title.trim()}"').join(', ')}...";
      } else {
        title = books.map((e) => '"${e.title.trim()}"').join(', ');
      }
    }

    final textTheme = context.textTheme;
    return await showDialog<bool?>(
      context: context,
      // barrierColor: Colors.transparent,
      builder: (context) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remover'),
          ),
        ],
        title: Text('Você tem certeza?', style: textTheme.titleLarge),
        content: Text.rich(
          TextSpan(
            children: [
              const TextSpan(text: 'Você está prestes a remover '),
              TextSpan(text: title, style: textTheme.bodyMedium?.copyWith(color: Colors.blueAccent)),
              const TextSpan(text: ' de sua biblioteca.'),
            ],
          ),
          style: textTheme.bodyMedium,
        ),
      ),
    );
  }

  static Future<bool?> categoryRemove(BuildContext context, BookCategoria category) async {
    final textTheme = context.textTheme;
    return await showDialog<bool?>(
      context: context,
      // barrierColor: Colors.transparent,
      builder: (context) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remover'),
          ),
        ],
        title: Text('Deletar Categoria', style: textTheme.titleLarge),
        content: Text('Você deseja deletar a categoria "${category.name}"?', style: textTheme.bodyMedium),
      ),
    );
  }

  static Future<String?> addCategory(BuildContext context, TextEditingController controller, [bool update = false]) async {
    final textTheme = context.textTheme;
    // controller.clear();
    // final formKey = GlobalKey<FormState>();

    final result = await showDialog(
      context: context,
      builder: (context) {
        // final categorias = context.read<HiveController>().BookCategoria;
        return AlertDialog(
          content: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: CustomTextField(
              autofocus: true,
              autovalidateMode: AutovalidateMode.always,
              validator: (data) {
                if (data == null || data.isEmpty) return 'campo obrigatorio*';
                return null;
              },
              controller: controller,
              label: Text('Nome', style: textTheme.titleMedium?.copyWith(color: context.colorScheme.primary)),
            ),
          ),
          title: update ? Text('Renomear categoria', style: textTheme.titleLarge) : Text('Adicionar categoria', style: textTheme.titleLarge),
          insetPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Cancelar'),
            ),
            AnimatedBuilder(
              animation: controller,
              builder: (context, child) => TextButton(
                onPressed: controller.text.isEmpty ? null : () => Navigator.of(context).pop(controller.text.trim()),
                child: update ? const Text('OK') : const Text('Adicionar'),
              ),
            )
          ],
        );
      },
    );

    return result;
  }

  static Future category(BuildContext context, List<BookCategoria> initialData) async {
    final _CheckBoxValue lista = _CheckBoxValue(initialData);
    final result = await showDialog(
      context: context,
      builder: (context) {
        final textTheme = context.textTheme;
        final categorias = context.watch<HiveController>().categorias;
        // final padding = categorys.isEmpty ? 24.0 : 20.0;
        return AlertDialog(
          content: categorias.isNotEmpty
              ? SingleChildScrollView(
                  child: ValueListenableBuilder(
                    valueListenable: lista,
                    builder: (context, value, child) => Column(
                      children: categorias
                          .mapIndexed(
                            (index, element) => CheckboxListTile(
                              value: value.contains(element),
                              title: Text(element.name),
                              onChanged: (data) {
                                lista.add(element);
                              },
                            ),
                          )
                          .toList(),
                    ),
                  ),
                )
              : Text('Você não tem categorias ainda.', style: textTheme.bodyMedium),
          title: Text('Definir Categorias', style: textTheme.titleLarge),
          insetPadding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 20.0),
          // actionsOverflowAlignment: OverflowBarAlignment.start,
          // actionsOverflowDirection: VerticalDirection.up,
          // actionsPadding: EdgeInsets.only(left: padding, right: padding, bottom: 24.0),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              style: const ButtonStyle(visualDensity: VisualDensity(horizontal: -4)),
              onPressed: () => Navigator.of(context).pop(RouteName.CATEGORY),
              child: categorias.isEmpty ? const Text('Editar Categorias') : const Text('Editar'),
            ),
            if (categorias.isNotEmpty)
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextButton(
                    style: const ButtonStyle(visualDensity: VisualDensity(horizontal: -4)),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    style: const ButtonStyle(visualDensity: VisualDensity(horizontal: -4)),
                    onPressed: () => Navigator.of(context).pop(lista.value),
                    child: const Text('OK'),
                  ),
                ],
              ),
          ],
        );
      },
    );

    Future.delayed(const Duration(milliseconds: 200), lista.dispose);
    return result;
  }
}

class _CheckBoxValue extends ValueNotifier<List<BookCategoria>> {
  _CheckBoxValue(super._value);

  void add(BookCategoria bookCategoria) {
    if (!value.contains(bookCategoria)) {
      value.add(bookCategoria);
    } else {
      value.remove(bookCategoria);
    }
    notifyListeners();
  }
}
