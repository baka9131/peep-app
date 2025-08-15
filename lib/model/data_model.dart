import 'package:freezed_annotation/freezed_annotation.dart';

part 'data_model.freezed.dart';
part 'data_model.g.dart';

@freezed
abstract class DataModel with _$DataModel {
  const factory DataModel({
    required int id,
    required int inout,
    required DateTime dateTime,
  }) = _DataModel;

  factory DataModel.fromJson(Map<String, Object?> json) =>
      _$DataModelFromJson(json);
}
