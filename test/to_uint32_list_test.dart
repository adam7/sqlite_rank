import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:sqlite_rank/to_uint32_list.dart';

void main() {
  group("When calling toUint32List", () {
    test('with empty matchinfo it should throw an argument error', () {
      expect(() => toUint32List(Uint8List(0)), throwsArgumentError);
    });

    test(
        "with matchinfo length that isn't divisible by four it should throw an argument error",
        () {
      expect(() => toUint32List(Uint8List(3)), throwsArgumentError);
    });

    test("with valid matchinfo it should return a 32 bit list", () {
      final uint8List = Uint8List.fromList(
          [1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 1, 1, 1, 1]);
          
      final expectedResult = [1, 256, 65536, 16777216, 16843009];

      expect(toUint32List(uint8List), equals(expectedResult));
    });
  });
}
