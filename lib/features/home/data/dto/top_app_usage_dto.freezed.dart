// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'top_app_usage_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TopAppUsageDto {

@JsonKey(name: 'package_name') String get packageName;@JsonKey(name: 'app_name') String get appName;@JsonKey(name: 'screen_time_minutes') int get screenTimeMinutes;@JsonKey(name: 'session_count') int get sessionCount;@JsonKey(name: 'is_limited') bool get isLimited;
/// Create a copy of TopAppUsageDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TopAppUsageDtoCopyWith<TopAppUsageDto> get copyWith => _$TopAppUsageDtoCopyWithImpl<TopAppUsageDto>(this as TopAppUsageDto, _$identity);

  /// Serializes this TopAppUsageDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TopAppUsageDto&&(identical(other.packageName, packageName) || other.packageName == packageName)&&(identical(other.appName, appName) || other.appName == appName)&&(identical(other.screenTimeMinutes, screenTimeMinutes) || other.screenTimeMinutes == screenTimeMinutes)&&(identical(other.sessionCount, sessionCount) || other.sessionCount == sessionCount)&&(identical(other.isLimited, isLimited) || other.isLimited == isLimited));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,packageName,appName,screenTimeMinutes,sessionCount,isLimited);

@override
String toString() {
  return 'TopAppUsageDto(packageName: $packageName, appName: $appName, screenTimeMinutes: $screenTimeMinutes, sessionCount: $sessionCount, isLimited: $isLimited)';
}


}

/// @nodoc
abstract mixin class $TopAppUsageDtoCopyWith<$Res>  {
  factory $TopAppUsageDtoCopyWith(TopAppUsageDto value, $Res Function(TopAppUsageDto) _then) = _$TopAppUsageDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'package_name') String packageName,@JsonKey(name: 'app_name') String appName,@JsonKey(name: 'screen_time_minutes') int screenTimeMinutes,@JsonKey(name: 'session_count') int sessionCount,@JsonKey(name: 'is_limited') bool isLimited
});




}
/// @nodoc
class _$TopAppUsageDtoCopyWithImpl<$Res>
    implements $TopAppUsageDtoCopyWith<$Res> {
  _$TopAppUsageDtoCopyWithImpl(this._self, this._then);

  final TopAppUsageDto _self;
  final $Res Function(TopAppUsageDto) _then;

/// Create a copy of TopAppUsageDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? packageName = null,Object? appName = null,Object? screenTimeMinutes = null,Object? sessionCount = null,Object? isLimited = null,}) {
  return _then(_self.copyWith(
packageName: null == packageName ? _self.packageName : packageName // ignore: cast_nullable_to_non_nullable
as String,appName: null == appName ? _self.appName : appName // ignore: cast_nullable_to_non_nullable
as String,screenTimeMinutes: null == screenTimeMinutes ? _self.screenTimeMinutes : screenTimeMinutes // ignore: cast_nullable_to_non_nullable
as int,sessionCount: null == sessionCount ? _self.sessionCount : sessionCount // ignore: cast_nullable_to_non_nullable
as int,isLimited: null == isLimited ? _self.isLimited : isLimited // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [TopAppUsageDto].
extension TopAppUsageDtoPatterns on TopAppUsageDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TopAppUsageDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TopAppUsageDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TopAppUsageDto value)  $default,){
final _that = this;
switch (_that) {
case _TopAppUsageDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TopAppUsageDto value)?  $default,){
final _that = this;
switch (_that) {
case _TopAppUsageDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'package_name')  String packageName, @JsonKey(name: 'app_name')  String appName, @JsonKey(name: 'screen_time_minutes')  int screenTimeMinutes, @JsonKey(name: 'session_count')  int sessionCount, @JsonKey(name: 'is_limited')  bool isLimited)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TopAppUsageDto() when $default != null:
return $default(_that.packageName,_that.appName,_that.screenTimeMinutes,_that.sessionCount,_that.isLimited);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'package_name')  String packageName, @JsonKey(name: 'app_name')  String appName, @JsonKey(name: 'screen_time_minutes')  int screenTimeMinutes, @JsonKey(name: 'session_count')  int sessionCount, @JsonKey(name: 'is_limited')  bool isLimited)  $default,) {final _that = this;
switch (_that) {
case _TopAppUsageDto():
return $default(_that.packageName,_that.appName,_that.screenTimeMinutes,_that.sessionCount,_that.isLimited);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'package_name')  String packageName, @JsonKey(name: 'app_name')  String appName, @JsonKey(name: 'screen_time_minutes')  int screenTimeMinutes, @JsonKey(name: 'session_count')  int sessionCount, @JsonKey(name: 'is_limited')  bool isLimited)?  $default,) {final _that = this;
switch (_that) {
case _TopAppUsageDto() when $default != null:
return $default(_that.packageName,_that.appName,_that.screenTimeMinutes,_that.sessionCount,_that.isLimited);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TopAppUsageDto implements TopAppUsageDto {
  const _TopAppUsageDto({@JsonKey(name: 'package_name') required this.packageName, @JsonKey(name: 'app_name') required this.appName, @JsonKey(name: 'screen_time_minutes') required this.screenTimeMinutes, @JsonKey(name: 'session_count') required this.sessionCount, @JsonKey(name: 'is_limited') this.isLimited = false});
  factory _TopAppUsageDto.fromJson(Map<String, dynamic> json) => _$TopAppUsageDtoFromJson(json);

@override@JsonKey(name: 'package_name') final  String packageName;
@override@JsonKey(name: 'app_name') final  String appName;
@override@JsonKey(name: 'screen_time_minutes') final  int screenTimeMinutes;
@override@JsonKey(name: 'session_count') final  int sessionCount;
@override@JsonKey(name: 'is_limited') final  bool isLimited;

/// Create a copy of TopAppUsageDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TopAppUsageDtoCopyWith<_TopAppUsageDto> get copyWith => __$TopAppUsageDtoCopyWithImpl<_TopAppUsageDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TopAppUsageDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TopAppUsageDto&&(identical(other.packageName, packageName) || other.packageName == packageName)&&(identical(other.appName, appName) || other.appName == appName)&&(identical(other.screenTimeMinutes, screenTimeMinutes) || other.screenTimeMinutes == screenTimeMinutes)&&(identical(other.sessionCount, sessionCount) || other.sessionCount == sessionCount)&&(identical(other.isLimited, isLimited) || other.isLimited == isLimited));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,packageName,appName,screenTimeMinutes,sessionCount,isLimited);

@override
String toString() {
  return 'TopAppUsageDto(packageName: $packageName, appName: $appName, screenTimeMinutes: $screenTimeMinutes, sessionCount: $sessionCount, isLimited: $isLimited)';
}


}

/// @nodoc
abstract mixin class _$TopAppUsageDtoCopyWith<$Res> implements $TopAppUsageDtoCopyWith<$Res> {
  factory _$TopAppUsageDtoCopyWith(_TopAppUsageDto value, $Res Function(_TopAppUsageDto) _then) = __$TopAppUsageDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'package_name') String packageName,@JsonKey(name: 'app_name') String appName,@JsonKey(name: 'screen_time_minutes') int screenTimeMinutes,@JsonKey(name: 'session_count') int sessionCount,@JsonKey(name: 'is_limited') bool isLimited
});




}
/// @nodoc
class __$TopAppUsageDtoCopyWithImpl<$Res>
    implements _$TopAppUsageDtoCopyWith<$Res> {
  __$TopAppUsageDtoCopyWithImpl(this._self, this._then);

  final _TopAppUsageDto _self;
  final $Res Function(_TopAppUsageDto) _then;

/// Create a copy of TopAppUsageDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? packageName = null,Object? appName = null,Object? screenTimeMinutes = null,Object? sessionCount = null,Object? isLimited = null,}) {
  return _then(_TopAppUsageDto(
packageName: null == packageName ? _self.packageName : packageName // ignore: cast_nullable_to_non_nullable
as String,appName: null == appName ? _self.appName : appName // ignore: cast_nullable_to_non_nullable
as String,screenTimeMinutes: null == screenTimeMinutes ? _self.screenTimeMinutes : screenTimeMinutes // ignore: cast_nullable_to_non_nullable
as int,sessionCount: null == sessionCount ? _self.sessionCount : sessionCount // ignore: cast_nullable_to_non_nullable
as int,isLimited: null == isLimited ? _self.isLimited : isLimited // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
