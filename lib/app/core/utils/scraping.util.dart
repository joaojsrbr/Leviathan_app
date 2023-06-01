import 'package:collection/collection.dart';
import 'package:html/dom.dart';

class ScrapingUtil {
  late final Element element;

  bool error = false;

  ScrapingUtil(this.element) : error = false;

  ScrapingUtil.bySelector(Document document, {String? selector}) {
    final _ = document.querySelector(selector ?? 'div.site-content');
    if (_ != null) {
      element = _;
      error = false;
    } else {
      error = true;
    }
  }

  String getByAttribute({required String by, String? selector}) {
    Element? $ = element;

    if (selector != null) $ = $.querySelector(selector);
    if ($ == null) return '';

    return ($.attributes[by] ?? '').trim();
  }

  T? getInfo<T>({
    String? selector,
    T? initialData,
    String? removeSelector,
    String? endSelector,
    bool Function(Element element)? whereTest,
    T Function(String data)? endReturn,
    T Function(List<Element> element, T? initialData)? endFirstReturn,
    String Function(String? remove)? stringRemove,
  }) {
    final List<Element> elements = element.querySelectorAll(selector ?? '.post-content_item');
    if (endFirstReturn != null) return endFirstReturn.call(elements, initialData);
    if (elements.isEmpty) return null;
    elements.removeWhere(
      (element) => whereTest?.call(element) ?? _defaultRemoveWhere(element: element, stringRemove: stringRemove, selector: removeSelector),
    );
    if (elements.isEmpty) return null;
    final String? data = elements.single.querySelector(endSelector ?? '.summary-content')?.text;
    // .split(',').map((e) => Tags(title: e.trim())).toList();
    if (data != null) return endReturn?.call(data) ?? _defaultReturn<T>(data);
    return null;
  }

  T _defaultReturn<T>(String data) {
    return data.trim() as T;
  }

  bool _defaultRemoveWhere({required Element element, required String Function(String? remove)? stringRemove, String? selector}) {
    final remove = element
            .querySelector(selector ?? '.summary-heading h5')
            ?.text
            .trim()
            .replaceAll(' ', '')
            .toLowerCase()
            .replaceAll(RegExp(r'[^a-z^A-Z]'), '') ??
        '';
    return remove != stringRemove?.call(remove);
  }

  double? getScore({String? selector}) {
    return double.tryParse(element.querySelector('.post-total-rating span')?.text.trim() ?? '');
  }

  String getURL({String? selector}) {
    return getByAttribute(by: 'href', selector: selector);
  }

  String getImage({String? selector, bool? bySrcSet, bool? last}) {
    Element? $ = element;

    if (selector != null) $ = $.querySelector(selector);
    if ($ == null) return '';

    String src = $.attributes['data-src'] ?? $.attributes['src'] ?? '';

    if (bySrcSet == true) {
      src = $.attributes['data-lazy-srcset'] ??
          $.attributes['data-src-img'] ??
          $.attributes['data-srcset-img'] ??
          $.attributes['data-src'] ??
          $.attributes['data-srcset'] ??
          $.attributes['srcset'] ??
          '';

      src = _bySrcSet(src, last);
    }

    return src.trim();
  }

  String getByText({Element? root, String? selector}) {
    Element? $ = root ?? element;

    if (selector != null) $ = $.querySelector(selector);
    if ($ == null) return '';

    return $.text.trim();
  }

  String? createdAt({String? selector}) {
    return (element.querySelector(selector ?? 'span a')?.attributes['title'] ??
            element.querySelector('span i')?.text ??
            (element.children.isEmpty ? null : element.children.elementAt(1).text))
        ?.trim();
  }

  Element? getOneByMany({
    required int index,
    required String selector,
    bool Function(Element element)? filter,
  }) {
    List<Element> $ = element.querySelectorAll(selector);

    if (filter != null) $ = $.where(filter).toList();

    return (index < 0 || index > $.length - 1) ? null : $[index];
  }

  String _bySrcSet(String src, [bool? last]) {
    if (src.isEmpty) return '';
    final reges = RegExp(r'[0-9]+w');
    final lista = '$src,'.replaceAll(RegExp(r'([1-9])\w+,'), '').trim().split(' ')..removeWhere((element) => element.isEmpty);
    // final _ = '$src,'.replaceAll(RegExp(r'([1-9])\w+,'), '').trim().split(' ');
    final w = reges.allMatches('$src,').map((e) => int.parse('$src,'.substring(e.start, e.end).replaceAll(r'w', '').trim())).toList();

    final index = w.indexOf(w.reduceIndexed((index, previous, element) => element < previous ? previous : element));
    // .map((e) => int.parse(e.input.replaceAll(RegExp(r'[^0-9]'), '')));
    // .reduceIndexed((index, previous, element) => element < previous ? previous : element);

    return last == true ? lista.last : lista.elementAt(index);

    // return '$src,'
    //     .replaceAll(RegExp(r'([1-9])\w+,'), '')
    //     .trim()
    //     .split(' ')
    //     .where((value) => value.length > 5)
    //     .last
    //     .trim();
  }
}
