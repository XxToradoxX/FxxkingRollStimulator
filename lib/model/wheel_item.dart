import 'dart:ui';
import 'package:json_annotation/json_annotation.dart';

// 导入json_annotation包
part 'wheel_item.g.dart';

// 使用@JsonSerializable注解
@JsonSerializable()
class WheelItem {
  final String name; // 项目名称
  final double ratio; // 项目所占比例

  @JsonKey(
    fromJson: _colorFromJson, // 自定义的fromJson函数
    toJson: _colorToJson,   // 自定义的toJson函数
  )
  final Color color; // 项目颜色

  WheelItem({required this.name, required this.ratio, required this.color});

  // 自定义的fromJson函数
  static Color _colorFromJson(int json) => Color(json);

  // 自定义的toJson函数
  static int _colorToJson(Color color) => color.value;

  // 生成的fromJson和toJson方法
  factory WheelItem.fromJson(Map<String, dynamic> json) => _$WheelItemFromJson(json);
  Map<String, dynamic> toJson() => _$WheelItemToJson(this);
}