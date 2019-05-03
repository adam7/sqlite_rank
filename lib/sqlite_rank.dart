library sqlite_rank;

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
/// The [matchinfo] must be the return value of the FTS matchinfo() function, 
/// [columnWeights] must be a list of weights for each column of the FTS table 
Future<double> rank(String matchinfo, List<double> columnWeights) async {
  return _rankFromArray(matchinfoToArray(matchinfo), columnWeights);
}

List<int> matchinfoToArray(String matchinfo) {
  if (matchinfo.isEmpty) throw ArgumentError("Empty matchinfo");

  var map = matchinfo.split(RegExp(r" +")).map((n) => int.parse(n));

  return map.toList();
}

Future<double> _rankFromArray(
    List<int> matchinfo, List<double> columnWeights) async {
  int columnCount = 0; /* Number of columns in the table */
  int phraseCount = 0; /* Number of phrases in the query */
  double score = 0.0; /* Value to return */

  /// Check that the number of arguments passed to this function is correct.
  if (matchinfo.length >= 2) {
    phraseCount = matchinfo[0];
    columnCount = matchinfo[1];
  }

  if (matchinfo.length != (2 + (3 * columnCount * phraseCount))) {
    throw ArgumentError("invalid matchinfo length");
  }
  if (columnWeights.length != columnCount)
    throw ArgumentError("invalid columnWeights length");

  /// Iterate through each phrase in the users query.
  for (int phraseIndex = 0; phraseIndex < phraseCount; phraseIndex++) {
    //  Now iterate through each column in the users query. For each column,
    //  increment the relevancy score by:
    //    (<hit count> / <global hit count>) * <column weight>
    int phraseLocation = 2 + (phraseIndex * columnCount * 3);

    for (int columnIndex = 0; columnIndex < columnCount; columnIndex++) {
      int hitCount = matchinfo[phraseLocation + (3 * columnIndex)];
      int globalHitCount = matchinfo[phraseLocation + (3 * columnIndex + 1)];
      double weight = columnWeights[columnIndex];
      if (hitCount > 0) {
        score += (hitCount / globalHitCount) * weight;
      }
    }
  }

  return double.parse(score.toStringAsFixed(2));
}
