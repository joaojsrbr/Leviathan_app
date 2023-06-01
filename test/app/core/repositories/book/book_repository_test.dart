import 'package:flutter_test/flutter_test.dart';
import 'package:leviathan_app/app/core/constants/fonte.dart';
import 'package:leviathan_app/app/core/repositories/load_book_repository.dart';

void main() {
  test('book repository ...', () async {
    final LoadBookRepository loadBookRepository = LoadBookRepository.empty(Fonte.NEOX_SCANS);

    final url = await loadBookRepository.repository.getURLByTitle('Return of the Broken Constellation [Novel]');

    expect(url.isNotEmpty, true);
  });
}
