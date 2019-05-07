library sqlite_rank;

import 'dart:typed_data';

List<int> toUint32List(Uint8List matchinfo) {
  if(matchinfo.length == 0){
    throw ArgumentError("empty matchinfo");
  }

  if(matchinfo.length % 4 != 0){
    throw ArgumentError("matchinfo length should be divisible by four but it is ${matchinfo.length}");
  }

  var uint32ListLength = matchinfo.length ~/ 4;
  var uint32List = Uint32List(uint32ListLength);
  var data = ByteData.view(
      matchinfo.buffer, matchinfo.offsetInBytes, matchinfo.length);

  for (int i = 0; i < uint32ListLength; i++) {
    uint32List[i] = data.getUint32(i * 4, Endian.host);
  }

  return uint32List;
}
