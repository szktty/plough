// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'id.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GraphId _$GraphIdFromJson(Map<String, dynamic> json) => _GraphId(
      type: $enumDecode(_$GraphIdTypeEnumMap, json['type']),
      value: json['value'] as String,
    );

Map<String, dynamic> _$GraphIdToJson(_GraphId instance) => <String, dynamic>{
      'type': _$GraphIdTypeEnumMap[instance.type]!,
      'value': instance.value,
    };

const _$GraphIdTypeEnumMap = {
  GraphIdType.graph: 'graph',
  GraphIdType.node: 'node',
  GraphIdType.link: 'link',
};
