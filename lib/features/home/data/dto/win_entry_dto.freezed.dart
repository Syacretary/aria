// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'win_entry_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WinEntryDto {

 String get id; String get label; String get detail;@JsonKey(name: 'occurred_at') String get occurredAt;@JsonKey(name: 'kind') String get kind;
/// Create a copy of WinEntryDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WinEntryDtoCopyWith<WinEntryDto> get copyWith => _$WinEntryDtoCopyWithImpl<WinEntryDto>(this as WinEntryDto, _$identity);

  /// Serializes this WinEntryDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WinEntryDto&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.detail, detail) || other.detail == detail)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt)&&(identical(other.kind, kind) || other.kind == kind));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,detail,occurredAt,kind);

@override
String toString() {
  return 'WinEntryDto(id: $id, label: $label, detail: $detail, occurredAt: $occurredAt, kind: $kind)';
}


}

/// @nodoc
abstract mixin class $WinEntryDtoCopyWith<$Res>  {
  factory $WinEntryDtoCopyWith(WinEntryDto value, $Res Function(WinEntryDto) _then) = _$WinEntryDtoCopyWithImpl;
@useResult
$Res call({
 String id, String label, String detail,@JsonKey(name: 'occurred_at') String occurredAt,@JsonKey(name: 'kind') String kind
});




}
/// @nodoc
class _$WinEntryDtoCopyWithImpl<$Res>
    implements $WinEntryDtoCopyWith<$Res> {
  _$WinEntryDtoCopyWithImpl(this._self, this._then);

  final WinEntryDto _self;
  final $Res Function(WinEntryDto) _then;

/// Create a copy of WinEntryDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? label = null,Object? detail = null,Object? occurredAt = null,Object? kind = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,detail: null == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as String,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [WinEntryDto].
extension WinEntryDtoPatterns on WinEntryDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WinEntryDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WinEntryDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WinEntryDto value)  $default,){
final _that = this;
switch (_that) {
case _WinEntryDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WinEntryDto value)?  $default,){
final _that = this;
switch (_that) {
case _WinEntryDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String label,  String detail, @JsonKey(name: 'occurred_at')  String occurredAt, @JsonKey(name: 'kind')  String kind)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WinEntryDto() when $default != null:
return $default(_that.id,_that.label,_that.detail,_that.occurredAt,_that.kind);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String label,  String detail, @JsonKey(name: 'occurred_at')  String occurredAt, @JsonKey(name: 'kind')  String kind)  $default,) {final _that = this;
switch (_that) {
case _WinEntryDto():
return $default(_that.id,_that.label,_that.detail,_that.occurredAt,_that.kind);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String label,  String detail, @JsonKey(name: 'occurred_at')  String occurredAt, @JsonKey(name: 'kind')  String kind)?  $default,) {final _that = this;
switch (_that) {
case _WinEntryDto() when $default != null:
return $default(_that.id,_that.label,_that.detail,_that.occurredAt,_that.kind);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WinEntryDto implements WinEntryDto {
  const _WinEntryDto({required this.id, required this.label, required this.detail, @JsonKey(name: 'occurred_at') required this.occurredAt, @JsonKey(name: 'kind') this.kind = 'delay'});
  factory _WinEntryDto.fromJson(Map<String, dynamic> json) => _$WinEntryDtoFromJson(json);

@override final  String id;
@override final  String label;
@override final  String detail;
@override@JsonKey(name: 'occurred_at') final  String occurredAt;
@override@JsonKey(name: 'kind') final  String kind;

/// Create a copy of WinEntryDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WinEntryDtoCopyWith<_WinEntryDto> get copyWith => __$WinEntryDtoCopyWithImpl<_WinEntryDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WinEntryDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WinEntryDto&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.detail, detail) || other.detail == detail)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt)&&(identical(other.kind, kind) || other.kind == kind));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,detail,occurredAt,kind);

@override
String toString() {
  return 'WinEntryDto(id: $id, label: $label, detail: $detail, occurredAt: $occurredAt, kind: $kind)';
}


}

/// @nodoc
abstract mixin class _$WinEntryDtoCopyWith<$Res> implements $WinEntryDtoCopyWith<$Res> {
  factory _$WinEntryDtoCopyWith(_WinEntryDto value, $Res Function(_WinEntryDto) _then) = __$WinEntryDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String label, String detail,@JsonKey(name: 'occurred_at') String occurredAt,@JsonKey(name: 'kind') String kind
});




}
/// @nodoc
class __$WinEntryDtoCopyWithImpl<$Res>
    implements _$WinEntryDtoCopyWith<$Res> {
  __$WinEntryDtoCopyWithImpl(this._self, this._then);

  final _WinEntryDto _self;
  final $Res Function(_WinEntryDto) _then;

/// Create a copy of WinEntryDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? label = null,Object? detail = null,Object? occurredAt = null,Object? kind = null,}) {
  return _then(_WinEntryDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,detail: null == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as String,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
