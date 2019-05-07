library sqlite_rank;

import 'dart:typed_data';
import 'package:sqlite_rank/to_uint32_list.dart';

/// Method to use with SQLite matchinfo() and FTS3/4 to calculate the
/// relevancy of an FTS match. Returns the relevancy score
/// (a real value greater than or equal to zero). A larger value indicates
/// a more relevant document.
///
/// The overall relevancy returned is the sum of the relevancies of each
/// column value in the FTS table. The relevancy of a column value is the
/// sum of the following for each reportable phrase in the FTS query:
///
///   (<hit count> / <global hit count>) * <column weight>
///
/// where <hit count> is the number of instances of the phrase in the
/// column value of the current row and <global hit count> is the number
/// of instances of the phrase in the same column of all rows in the FTS
/// table. The <column weight> is a weighting factor assigned to each
/// column by the caller (see below).
///
/// The [matchinfo32] must be the return value of the FTS matchinfo() function,
/// [columnWeights] must be a list of weights for each column of the FTS table
double rank(Uint8List matchinfo, [List<double> columnWeights]) {
  List<int> matchinfo32 = toUint32List(matchinfo);
  int columnCount = 0; // Number of columns in the table
  int phraseCount = 0; // Number of phrases in the query
  double rank = 0.0;

  // Check that the number of arguments passed to this function is correct.
  if (matchinfo32.length >= 2) {
    phraseCount = matchinfo32[0];
    columnCount = matchinfo32[1];
  } else {
    throw ArgumentError("matchinfo length is less than 2, that's not right");
  }

  // If there are no column weights specified then treat them all as equal
  columnWeights = columnWeights ?? List.filled(columnCount, 1);

  var expectedMatchinfoLength = (2 + (3 * columnCount * phraseCount));

  if (matchinfo32.length != expectedMatchinfoLength)
    throw ArgumentError(
        "matchinfo length should be $expectedMatchinfoLength but it's ${matchinfo32.length}");

  if (columnWeights.length != columnCount)
    throw ArgumentError(
        "columnWeights length should be $columnCount but it's ${columnWeights.length}");

  /// Iterate through each phrase in the users query.
  for (int phraseIndex = 0; phraseIndex < phraseCount; phraseIndex++) {
    //  Now iterate through each column in the users query. For each column,
    //  increment the relevancy score by:
    //    (<hit count> / <global hit count>) * <column weight>
    int phraseLocation = 2 + (phraseIndex * columnCount * 3);

    for (int columnIndex = 0; columnIndex < columnCount; columnIndex++) {
      int hitCount = matchinfo32[phraseLocation + (3 * columnIndex)];
      int globalHitCount = matchinfo32[phraseLocation + (3 * columnIndex + 1)];
      double weight = columnWeights[columnIndex];

      if (hitCount > 0) {
        rank += (hitCount / globalHitCount) * weight;
      }
    }
  }

  return double.parse(rank.toStringAsFixed(2));
}
