import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite_rank/sqlite_rank.dart';

void main() {
  final invalidLengthMatchinfo = _buildUint8bitList([1, 2, 1, 1, 1]);

  final oneColumnOnePhraseMatchinfo =
      _buildUint8bitList([1, 1, 1, 1, 1]);

  final twoColumnsOnePhraseMatchinfo =
      _buildUint8bitList([1, 2, 1, 5, 5, 1, 7, 5]);

  group("When calling rank", () {
    test('with empty matchinfo it should throw an argument error', () {
      expect(() => rank(Uint8List(0)), throwsArgumentError);
    });

    test('with invalid length matchinfo it should throw an argument error', () {
      expect(() => rank(invalidLengthMatchinfo), throwsArgumentError);
    });

    test('when passing invalid length columnWeights it should throw an argument error', () {
      expect(() => rank(oneColumnOnePhraseMatchinfo, [1, 2]), throwsArgumentError);
    });

    test('with valid matchinfo it should return a rank', () {
      expect(rank(oneColumnOnePhraseMatchinfo), 1);
      expect(rank(twoColumnsOnePhraseMatchinfo), 0.34);
    });

    test('with valid matchinfo and valid weights it should return a weighted rank', () {
      expect(rank(twoColumnsOnePhraseMatchinfo, [0.5, 1]), 0.24);
      expect(rank(twoColumnsOnePhraseMatchinfo, [1, 0.5]), 0.27);
    });
  });
}

Uint8List _buildUint8bitList(List<int> list) {
  List<int> result = List<int>();

  list.forEach((value) => {
        result.addAll([value, 0, 0, 0])
      });

  return Uint8List.fromList(result);
}
