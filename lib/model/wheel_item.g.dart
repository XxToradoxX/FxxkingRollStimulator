// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wheel_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WheelItem _$WheelItemFromJson(Map<String, dynamic> json) => WheelItem(
      name: json['name'] as String,
      ratio: (json['ratio'] as num).toDouble(),
      color: WheelItem._colorFromJson((json['color'] as num).toInt()),
    );

Map<String, dynamic> _$WheelItemToJson(WheelItem instance) => <String, dynamic>{
      'name': instance.name,
      'ratio': instance.ratio,
      'color': WheelItem._colorToJson(instance.color),
    };
