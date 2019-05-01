library sqlite_rank;

double rank(String matchinfo, List<double> columnWeights) {
  return _rankFromArray(matchinfoToArray(matchinfo), columnWeights);
}

List<int> matchinfoToArray(String matchinfo) {
  if(matchinfo.isEmpty) throw ArgumentError("Empty matchinfo");

  var map = matchinfo.split(RegExp(r" +")).map((n) => int.parse(n));
  
  return map.toList();
}

/*
** SQLite user defined function to use with matchinfo() to calculate the
** relevancy of an FTS match. The value returned is the relevancy score
** (a real value greater than or equal to zero). A larger value indicates 
** a more relevant document.
**
** The overall relevancy returned is the sum of the relevancies of each 
** column value in the FTS table. The relevancy of a column value is the
** sum of the following for each reportable phrase in the FTS query:
**
**   (<hit count> / <global hit count>) * <column weight>
**
** where <hit count> is the number of instances of the phrase in the
** column value of the current row and <global hit count> is the number
** of instances of the phrase in the same column of all rows in the FTS
** table. The <column weight> is a weighting factor assigned to each
** column by the caller (see below).
**
** The first argument to this function must be the return value of the FTS 
** matchinfo() function. Following this must be one argument for each column 
** of the FTS table containing a numeric weight factor for the corresponding 
** column. Example:
**
**     CREATE VIRTUAL TABLE documents USING fts3(title, content)
**
** The following query returns the docids of documents that match the full-text
** query <query> sorted from most to least relevant. When calculating
** relevance, query term instances in the 'title' column are given twice the
** weighting of those in the 'content' column.
**
**     SELECT docid FROM documents 
**     WHERE documents MATCH <query> 
**     ORDER BY rank(matchinfo(documents), 1.0, 0.5) DESC
*/
double _rankFromArray(List<int> matchinfo, List<double> columnWeights) {
  int columnCount = 0; /* Number of columns in the table */
  int phraseCount = 0; /* Number of phrases in the query */
  double score = 0.0; /* Value to return */

  /* Check that the number of arguments passed to this function is correct.
  ** If not, jump to wrong_number_args. Set aMatchinfo to point to the array
  ** of unsigned integer values returned by FTS function matchinfo. Set
  ** nPhrase to contain the number of reportable phrases in the users full-text
  ** query, and nCol to the number of columns in the table. Then check that the
  ** size of the matchinfo blob is as expected. Return an error if it is not.
  */
  if (matchinfo.length >= 2) {
    phraseCount = matchinfo[0];
    columnCount = matchinfo[1];
  }

  if (matchinfo.length != (2 + (3 * columnCount * phraseCount))) {
    throw ArgumentError("invalid matchinfo length");
  }
  if (columnWeights.length != columnCount)
    throw ArgumentError("invalid columnWeights length");

  /* Iterate through each phrase in the users query. */
  for (int phraseIndex = 0; phraseIndex < phraseCount; phraseIndex++) {
    /* Now iterate through each column in the users query. For each column,
    ** increment the relevancy score by:
    **
    **   (<hit count> / <global hit count>) * <column weight>
    **
    ** aPhraseinfo[] points to the start of the data for phrase iPhrase. So
    ** the hit count and global hit counts for each column are found in 
    ** aPhraseinfo[iCol*3] and aPhraseinfo[iCol*3+1], respectively.
    */
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
