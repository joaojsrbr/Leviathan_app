import 'package:flutter/material.dart';
import 'package:leviathan_app/app/core/extensions/custom_extensions/context_extensions.dart';
import 'package:leviathan_app/app/ui/info/widgets/scope.dart';

class CardSinopseExpanded extends StatelessWidget {
  const CardSinopseExpanded({super.key});

  @override
  Widget build(BuildContext context) {
    // final length = replaceAll.length;
    // final padding = MaterialStateProperty.all(EdgeInsets.zero);

    final List<Widget> colunmChildren = [];

    // Borderadius Card, InkWell
    const borderRadius = BorderRadius.vertical(bottom: Radius.circular(12), top: Radius.circular(12));

    // Shape Card
    const shape = RoundedRectangleBorder(borderRadius: borderRadius);

    final themeData = context.themeData;

    String? sinopse = BookInfoScope.of(context).book.sinopse ?? '';
    final isExpanded = BookInfoScope.of(context).isExpanded;
    final onExpandedSinopse = BookInfoScope.of(context).onExpandedSinopse;

    assert(sinopse.isNotEmpty);

    final replaceAll = sinopse.replaceAll(RegExp(r'\s+'), '').trim();

    final textTheme = themeData.textTheme;
    final over100 = replaceAll.length > 100;
    final over200 = replaceAll.length > 200 && over100;

    if (!isExpanded && over100) {
      sinopse = '${sinopse.substring(0, sinopse.length ~/ 2.5)} ...';
      if (over200) sinopse = '${sinopse.substring(0, sinopse.length ~/ 1.5)} ...';
    }

    final Widget title = Padding(
      padding: const EdgeInsets.only(left: 8, top: 8),
      child: Text(
        'Descrição',
        style: textTheme.titleLarge?.copyWith(fontSize: 24),
      ),
    );

    final Widget sinopseWidget = Padding(
      padding: const EdgeInsets.fromLTRB(8, 10, 6, 10),
      child: AnimatedSize(
        alignment: Alignment.topCenter,
        duration: const Duration(milliseconds: 550),
        reverseDuration: const Duration(milliseconds: 550),
        child: Text(sinopse, style: textTheme.bodyMedium),
      ),
    );

    colunmChildren.add(title);
    colunmChildren.add(sinopseWidget);

    const margin = EdgeInsets.only(bottom: 4, top: 8, left: 4, right: 4);

    Widget contentWidget = Column(crossAxisAlignment: CrossAxisAlignment.start, children: colunmChildren);

    if (over100) {
      contentWidget = InkWell(
        onTap: onExpandedSinopse,
        borderRadius: borderRadius,
        child: contentWidget,
      );
    }

    return Card(
      margin: margin,
      shape: shape,
      child: contentWidget,
    );
  }
}
