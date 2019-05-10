import 'dart:typed_data';
import 'package:sqlite_rank/sqlite_rank.dart';


/// The SQLite matchinfo function returns a byte array representing 32-bit unsigned integers 
/// in machine byte-order in dart they are mapped to a [Uint8List]
Uint8List matchinfoOne = Uint8List.fromList(
  [1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0]); 
Uint8List matchinfoTwo = Uint8List.fromList(
  [1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0, 1, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0]); 

/// The [rank] function calculates a rank value from the matchinfo array 
final resultOne = rank(matchinfoOne);

/// If you're querying more than one column, you can specify a [columnWeight] weight for each column
final resultTwo = rank(matchinfoTwo, [0.2, 0.7]);


