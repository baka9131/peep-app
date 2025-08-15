// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DataModel _$DataModelFromJson(Map<String, dynamic> json) => _DataModel(
  id: (json['id'] as num).toInt(),
  inout: (json['inout'] as num).toInt(),
  dateTime: DateTime.parse(json['dateTime'] as String),
);

Map<String, dynamic> _$DataModelToJson(_DataModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'inout': instance.inout,
      'dateTime': instance.dateTime.toIso8601String(),
    };
