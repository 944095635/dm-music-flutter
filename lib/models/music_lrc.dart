import 'package:json_annotation/json_annotation.dart';

part 'music_lrc.g.dart';

@JsonSerializable()
class MusicLrc {
  late String lang;
  late List<MusicLrcLine> line;
  late bool synced;

  MusicLrc();

  factory MusicLrc.fromJson(Map<String, dynamic> json) =>
      _$MusicLrcFromJson(json);

  Map<String, dynamic> toJson() => _$MusicLrcToJson(this);
}

@JsonSerializable()
class MusicLrcLine {
  late int start;
  late String value;

  MusicLrcLine();

  factory MusicLrcLine.fromJson(Map<String, dynamic> json) =>
      _$MusicLrcLineFromJson(json);

  Map<String, dynamic> toJson() => _$MusicLrcLineToJson(this);
}
