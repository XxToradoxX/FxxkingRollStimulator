// 引入json_annotation包
import 'package:json_annotation/json_annotation.dart';

// 指定生成的代码文件
part 'person.g.dart';

// 使用@JsonSerializable注解
@JsonSerializable()
class PersonModel {
  @JsonKey(name: 'first_name') // 自定义JSON键名
  String? firstName;

  @JsonKey(name: 'last_name')
  String? lastName;

  PersonModel({this.firstName, this.lastName});

  // 生成的反序列化方法
  factory PersonModel.fromJson(Map<String, dynamic> json) => _$PersonModelFromJson(json);

  // 生成的序列化方法
  Map<String, dynamic> toJson() => _$PersonModelToJson(this);
}