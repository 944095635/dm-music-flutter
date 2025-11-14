import 'package:json_annotation/json_annotation.dart';

part 'navidrome_data.g.dart';

/// Navidrome 验证数据
@JsonSerializable()
class NavidromeData {
  final String server;
  final String user;
  final String password;

  const NavidromeData({
    required this.server,
    required this.user,
    required this.password,
  });

  factory NavidromeData.fromJson(Map<String, dynamic> json) =>
      _$NavidromeDataFromJson(json);

  Map<String, dynamic> toJson() => _$NavidromeDataToJson(this);
}
