import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:leviathan_app/app/core/extensions/custom_extensions/list_extensions.dart';

class DataParse {
  static double? chapterVersion(String data) {
    double? value;
    if (data.contains(RegExp(r'-[0-9]'))) {
      value = double.tryParse(stringValue(data)[stringValue(data).length - 1]);
    }

    return value;
  }

  static (String?, double, String, bool?, double?) titleParse(String title, [String type = '']) {
    String? chapterDescription;
    double chapterNumber;
    bool? chapterFix;
    double? chapterVersion;
    String newTitle;

    final regex = RegExp(r'((\+|-)?([^0-9]+)^(\.[0-9]+)?)|^^((\+|-)?\.?[^0-9]+)');
    final chapterVersionRegex = RegExp(r'-[0-9]');

    if (title.contains('fix')) {
      title = title.replaceAll('fix', '');
      chapterFix = true;
    }

    if (title.contains(chapterVersionRegex)) {
      final match = chapterVersionRegex.stringMatch(title);

      if (match != null) {
        title = title.replaceAll(match, '');
        chapterVersion = double.tryParse(match.replaceAll('-', ''));
      }
    }

    if ([type, title].isNM()) {
      if (title.contains('-')) chapterDescription = title.split('-').last.trim();
      chapterNumber = double.parse(title.split('-').first.trim().replaceAll(regex, ''));
      newTitle = title.split('-').first.trim();
    } else {
      if (title.contains('-') && title.contains(RegExp(r'[0-9]'))) {
        final split = title.split('-');
        final replace = split.first.trim();

        chapterNumber = double.parse(replace.replaceAll(regex, ''));
        chapterDescription = split.last.trim();
        newTitle = split.first.trim();
      } else {
        try {
          chapterNumber = double.parse(title.trim().replaceAll(regex, ''));
        } on FormatException catch (_, __) {
          final regex = RegExp(r'^[0-9]+');
          final math = regex.stringMatch(title.trim());
          if (math != null) {
            chapterNumber = double.parse(math);
          } else {
            chapterNumber = 0;
          }
        }
        newTitle = title;
      }
    }

    if (newTitle.endsWith('.')) newTitle = newTitle.substring(0, newTitle.length - 1);
    if ((chapterDescription?.length ?? 3) <= 2) chapterDescription = null;
    return (chapterDescription, chapterNumber, newTitle, chapterFix, chapterVersion);
  }

  static String? sinopseParse(String data) {
    if (data.isEmpty) return null;

    final StringBuffer concatenate = StringBuffer();
    final Document document = parse(data);

    final Element? selector = document.querySelector('div');
    if (selector != null) {
      return selector.text.trim();
    } else {
      final List<Element> elementList = document.querySelectorAll('p');
      for (var element in elementList) {
        concatenate.write('\n${element.text.trim()}');
      }

      if (concatenate.isEmpty) return data;
      return concatenate.toString().trim();
    }
  }

  static String stringValue(String data) {
    String value = data.trim().toLowerCase();

    if (value.contains(RegExp(r'\([0-9]\)'))) value = value.replaceAll(RegExp(r'\([0-9]\)'), '');
    if (value.contains(r'-')) value = value.replaceAll(RegExp(r'-.*'), '');
    if (value.contains(r'cap.')) value = value.replaceAll(r'cap.', '');

    return value.trim();
  }

  static String? subTitle(String data) {
    String value = data.trim().toLowerCase();
    if (!value.contains(RegExp(r'\([0-9]\)')) && !value.contains('-')) return null;
    if (value.contains(RegExp(r'\([0-9]\)'))) value = value.replaceAll(RegExp(r'\([0-9]\)'), '');
    if (value.contains(RegExp(r'cap.+[0-9].-'))) value = value.replaceAll(RegExp('cap.+[0-9].-'), '');

    return value.trim();
  }

  static double value(String data) {
    String title = stringValue(data);
    if (chapterVersion(data) != null) title = stringValue(data).replaceAll(RegExp(r'-[0-9]'), '');
    final value = double.parse(title.replaceAll(RegExp(r'[^0-9]'), ''));
    return value;
  }

  static String chapterString(String data) {
    if (stringValue(data).contains('.')) {
      final last = stringValue(data)[stringValue(data).length - 1];
      final title = stringValue(data).replaceAll(RegExp(r'\.[0-9]'), '').trim();
      return 'Capítulo #$title.$last';
    } else {
      return 'Capítulo #${value(data).toStringAsFixed(value(data) == value(data).roundToDouble() ? 0 : 2).padLeft(2, '0')}';
    }
  }
}
