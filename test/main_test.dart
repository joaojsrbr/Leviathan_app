import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Test {
  int index;
  String name;
  _Test(this.index, this.name);
}

void main() {
  test('main ...', () async {
    final List<_Test> lista = List.generate(10, (index) => _Test(index, 'name_$index'));

    expect(lista.first.name.contains('name_0') && lista.elementAt(1).name.contains('name_1'), true);

    final result = lista.map(
      (element) {
        element.name = 'test12';
        return element;
      },
    );

    final result2 = lista.map(
      (element) {
        element.name = 'test12';
      },
    );

    // .forEach(
    //   (element) {
    //     element.name = 'test12';
    //   },
    // );
    debugPrint(result.toString());
    debugPrint(result2.toString());
    // expect(result.first == null && result.elementAt(1) == null, false);
  });
}
