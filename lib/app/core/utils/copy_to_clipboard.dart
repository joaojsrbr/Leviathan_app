import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> copyToClipboard(BuildContext context, {required String messageCopy, bool snackBar = true, String? messageSnackBar}) async {
  final ClipboardData data = ClipboardData(text: messageCopy);
  await Clipboard.setData(data).whenComplete(() {
    if (snackBar) _snackBar(context, messageCopy, messageSnackBar);
  });
}

void _snackBar(context, String messageCopy, String? messageSnackBar) {
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      duration: const Duration(milliseconds: 1500),
      behavior: SnackBarBehavior.floating,
      content: Text(
        messageSnackBar ??
            '$messageCopy '
                'copiado para a área de transferência!',
      ),
    ),
  );
}
