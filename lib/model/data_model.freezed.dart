// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'data_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DataModel {

 int get id; int get inout; DateTime get dateTime;
/// Create a copy of DataModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DataModelCopyWith<DataModel> get copyWith => _$DataModelCopyWithImpl<DataModel>(this as DataModel, _$identity);

  /// Serializes this DataModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DataModel&&(identical(other.id, id) || other.id == id)&&(identical(other.inout, inout) || other.inout == inout)&&(identical(other.dateTime, dateTime) || other.dateTime == dateTime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,inout,dateTime);

@override
String toString() {
  return 'DataModel(id: $id, inout: $inout, dateTime: $dateTime)';
}


}

/// @nodoc
abstract mixin class $DataModelCopyWith<$Res>  {
  factory $DataModelCopyWith(DataModel value, $Res Function(DataModel) _then) = _$DataModelCopyWithImpl;
@useResult
$Res call({
 int id, int inout, DateTime dateTime
});




}
/// @nodoc
class _$DataModelCopyWithImpl<$Res>
    implements $DataModelCopyWith<$Res> {
  _$DataModelCopyWithImpl(this._self, this._then);

  final DataModel _self;
  final $Res Function(DataModel) _then;

/// Create a copy of DataModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? inout = null,Object? dateTime = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,inout: null == inout ? _self.inout : inout // ignore: cast_nullable_to_non_nullable
as int,dateTime: null == dateTime ? _self.dateTime : dateTime // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [DataModel].
extension DataModelPatterns on DataModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DataModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DataModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DataModel value)  $default,){
final _that = this;
switch (_that) {
case _DataModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DataModel value)?  $default,){
final _that = this;
switch (_that) {
case _DataModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int inout,  DateTime dateTime)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DataModel() when $default != null:
return $default(_that.id,_that.inout,_that.dateTime);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int inout,  DateTime dateTime)  $default,) {final _that = this;
switch (_that) {
case _DataModel():
return $default(_that.id,_that.inout,_that.dateTime);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int inout,  DateTime dateTime)?  $default,) {final _that = this;
switch (_that) {
case _DataModel() when $default != null:
return $default(_that.id,_that.inout,_that.dateTime);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DataModel implements DataModel {
  const _DataModel({required this.id, required this.inout, required this.dateTime});
  factory _DataModel.fromJson(Map<String, dynamic> json) => _$DataModelFromJson(json);

@override final  int id;
@override final  int inout;
@override final  DateTime dateTime;

/// Create a copy of DataModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DataModelCopyWith<_DataModel> get copyWith => __$DataModelCopyWithImpl<_DataModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DataModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DataModel&&(identical(other.id, id) || other.id == id)&&(identical(other.inout, inout) || other.inout == inout)&&(identical(other.dateTime, dateTime) || other.dateTime == dateTime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,inout,dateTime);

@override
String toString() {
  return 'DataModel(id: $id, inout: $inout, dateTime: $dateTime)';
}


}

/// @nodoc
abstract mixin class _$DataModelCopyWith<$Res> implements $DataModelCopyWith<$Res> {
  factory _$DataModelCopyWith(_DataModel value, $Res Function(_DataModel) _then) = __$DataModelCopyWithImpl;
@override @useResult
$Res call({
 int id, int inout, DateTime dateTime
});




}
/// @nodoc
class __$DataModelCopyWithImpl<$Res>
    implements _$DataModelCopyWith<$Res> {
  __$DataModelCopyWithImpl(this._self, this._then);

  final _DataModel _self;
  final $Res Function(_DataModel) _then;

/// Create a copy of DataModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? inout = null,Object? dateTime = null,}) {
  return _then(_DataModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,inout: null == inout ? _self.inout : inout // ignore: cast_nullable_to_non_nullable
as int,dateTime: null == dateTime ? _self.dateTime : dateTime // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
