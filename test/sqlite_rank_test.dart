import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:sqlite_rank/sqlite_rank.dart';

void main() {
  var  oneColumnWithOneResultMatchinfo = Uint8List.fromList(
          [1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0]);

  group("When calling rank", () {
    test('with empty matchinfo it should throw an argument error', () {
      expect(() => rank(Uint8List(0), []), throwsArgumentError);
    });

    test('with valid matchinfo it should return a value', () {      
      expect(rank(oneColumnWithOneResultMatchinfo), 1);
    });
  });
}
