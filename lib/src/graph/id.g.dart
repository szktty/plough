// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'id.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GraphIdImpl _$$GraphIdImplFromJson(Map<String, dynamic> json) =>
    _$GraphIdImpl(
      type: $enumDecode(_$GraphIdTypeEnumMap, json['type']),
      value: json['value'] as String,
    );

Map<String, dynamic> _$$GraphIdImplToJson(_$GraphIdImpl instance) =>
    <String, dynamic>{
      'type': _$GraphIdTypeEnumMap[instance.type]!,
      'value': instance.value,
    };

const _$GraphIdTypeEnumMap = {
  GraphIdType.graph: 'graph',
  GraphIdType.node: 'node',
  GraphIdType.link: 'link',
};
