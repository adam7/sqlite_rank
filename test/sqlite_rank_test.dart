import 'package:flutter_test/flutter_test.dart';

import 'package:sqlite_rank/sqlite_rank.dart';

void main() {
  test('When calling rank with empty matchinfo it should throw an argument error', () {
    expect(() => rank("", []), throwsArgumentError);
  });
  test('When calling rank with valid matchinfo it should return a score', () {
    expect(rank("3 2  1 3 2  0 1 1  1 2 2  0 1 1  0 0 0  1 1 1", [1, 1]), 1.83);
  });

  test('Calling matchinfoToArray parses space separated string', () {
    var expectedArray = [3, 2, 1, 0, 2];

    expect(matchinfoToArray("3 2 1 0 2"), expectedArray);
  });

  test('Calling matchinfoToArray handles multiple spaces', () {
    var expectedArray = [3, 2, 1, 3, 2];

    expect(matchinfoToArray("3 2  1   3     2"), expectedArray);
  });

  test('Calling matchinfoToArray handles multiple digits', () {
    var expectedArray = [3, 20, 111, 3333, 123456789];

    expect(matchinfoToArray("3 20 111 3333 123456789"), expectedArray);
  });
}
