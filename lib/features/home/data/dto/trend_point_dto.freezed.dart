// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trend_point_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TrendPointDto {

 String get date;@JsonKey(name: 'screen_time_minutes') int get screenTimeMinutes;@JsonKey(name: 'target_minutes') int get targetMinutes;
/// Create a copy of TrendPointDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrendPointDtoCopyWith<TrendPointDto> get copyWith => _$TrendPointDtoCopyWithImpl<TrendPointDto>(this as TrendPointDto, _$identity);

  /// Serializes this TrendPointDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrendPointDto&&(identical(other.date, date) || other.date == date)&&(identical(other.screenTimeMinutes, screenTimeMinutes) || other.screenTimeMinutes == screenTimeMinutes)&&(identical(other.targetMinutes, targetMinutes) || other.targetMinutes == targetMinutes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,screenTimeMinutes,targetMinutes);

@override
String toString() {
  return 'TrendPointDto(date: $date, screenTimeMinutes: $screenTimeMinutes, targetMinutes: $targetMinutes)';
}


}

/// @nodoc
abstract mixin class $TrendPointDtoCopyWith<$Res>  {
  factory $TrendPointDtoCopyWith(TrendPointDto value, $Res Function(TrendPointDto) _then) = _$TrendPointDtoCopyWithImpl;
@useResult
$Res call({
 String date,@JsonKey(name: 'screen_time_minutes') int screenTimeMinutes,@JsonKey(name: 'target_minutes') int targetMinutes
});




}
/// @nodoc
class _$TrendPointDtoCopyWithImpl<$Res>
    implements $TrendPointDtoCopyWith<$Res> {
  _$TrendPointDtoCopyWithImpl(this._self, this._then);

  final TrendPointDto _self;
  final $Res Function(TrendPointDto) _then;

/// Create a copy of TrendPointDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? screenTimeMinutes = null,Object? targetMinutes = null,}) {
  return _then(_self.copyWith(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,screenTimeMinutes: null == screenTimeMinutes ? _self.screenTimeMinutes : screenTimeMinutes // ignore: cast_nullable_to_non_nullable
as int,targetMinutes: null == targetMinutes ? _self.targetMinutes : targetMinutes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TrendPointDto].
extension TrendPointDtoPatterns on TrendPointDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrendPointDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrendPointDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrendPointDto value)  $default,){
final _that = this;
switch (_that) {
case _TrendPointDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrendPointDto value)?  $default,){
final _that = this;
switch (_that) {
case _TrendPointDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String date, @JsonKey(name: 'screen_time_minutes')  int screenTimeMinutes, @JsonKey(name: 'target_minutes')  int targetMinutes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrendPointDto() when $default != null:
return $default(_that.date,_that.screenTimeMinutes,_that.targetMinutes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String date, @JsonKey(name: 'screen_time_minutes')  int screenTimeMinutes, @JsonKey(name: 'target_minutes')  int targetMinutes)  $default,) {final _that = this;
switch (_that) {
case _TrendPointDto():
return $default(_that.date,_that.screenTimeMinutes,_that.targetMinutes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String date, @JsonKey(name: 'screen_time_minutes')  int screenTimeMinutes, @JsonKey(name: 'target_minutes')  int targetMinutes)?  $default,) {final _that = this;
switch (_that) {
case _TrendPointDto() when $default != null:
return $default(_that.date,_that.screenTimeMinutes,_that.targetMinutes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TrendPointDto implements TrendPointDto {
  const _TrendPointDto({required this.date, @JsonKey(name: 'screen_time_minutes') required this.screenTimeMinutes, @JsonKey(name: 'target_minutes') required this.targetMinutes});
  factory _TrendPointDto.fromJson(Map<String, dynamic> json) => _$TrendPointDtoFromJson(json);

@override final  String date;
@override@JsonKey(name: 'screen_time_minutes') final  int screenTimeMinutes;
@override@JsonKey(name: 'target_minutes') final  int targetMinutes;

/// Create a copy of TrendPointDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrendPointDtoCopyWith<_TrendPointDto> get copyWith => __$TrendPointDtoCopyWithImpl<_TrendPointDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TrendPointDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrendPointDto&&(identical(other.date, date) || other.date == date)&&(identical(other.screenTimeMinutes, screenTimeMinutes) || other.screenTimeMinutes == screenTimeMinutes)&&(identical(other.targetMinutes, targetMinutes) || other.targetMinutes == targetMinutes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,screenTimeMinutes,targetMinutes);

@override
String toString() {
  return 'TrendPointDto(date: $date, screenTimeMinutes: $screenTimeMinutes, targetMinutes: $targetMinutes)';
}


}

/// @nodoc
abstract mixin class _$TrendPointDtoCopyWith<$Res> implements $TrendPointDtoCopyWith<$Res> {
  factory _$TrendPointDtoCopyWith(_TrendPointDto value, $Res Function(_TrendPointDto) _then) = __$TrendPointDtoCopyWithImpl;
@override @useResult
$Res call({
 String date,@JsonKey(name: 'screen_time_minutes') int screenTimeMinutes,@JsonKey(name: 'target_minutes') int targetMinutes
});




}
/// @nodoc
class __$TrendPointDtoCopyWithImpl<$Res>
    implements _$TrendPointDtoCopyWith<$Res> {
  __$TrendPointDtoCopyWithImpl(this._self, this._then);

  final _TrendPointDto _self;
  final $Res Function(_TrendPointDto) _then;

/// Create a copy of TrendPointDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? screenTimeMinutes = null,Object? targetMinutes = null,}) {
  return _then(_TrendPointDto(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,screenTimeMinutes: null == screenTimeMinutes ? _self.screenTimeMinutes : screenTimeMinutes // ignore: cast_nullable_to_non_nullable
as int,targetMinutes: null == targetMinutes ? _self.targetMinutes : targetMinutes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
