import 'package:uuid/uuid.dart';

extension StringExtensions on String {
  String? get dataOrNull {
    if (isNotEmpty) return trim();
    return null;
  }

  String get urlToId => const Uuid().v5(Uuid.NAMESPACE_URL, this);

  Map<String, String> headers({bool referer = false}) {
    return {
      'Origin': this,
      if (referer) 'Referer': '$this/',
      'accept':
          'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9',
      'upgrade-insecure-requests': '1',
      'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/100.0.4896.75 Safari/537.36',
    };
  }
}
