// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_limit_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppLimitDto {

@JsonKey(name: 'package_name') String get packageName;@JsonKey(name: 'quota_minutes') int get quotaMinutes; bool get enabled;@JsonKey(name: 'enforcement') String get enforcement;@JsonKey(name: 'remind_on_open') bool get remindOnOpen;@JsonKey(name: 'active_weekdays') String get activeWeekdays;@JsonKey(name: 'active_from_minutes') int? get activeFromMinutes;@JsonKey(name: 'active_until_minutes') int? get activeUntilMinutes;
/// Create a copy of AppLimitDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppLimitDtoCopyWith<AppLimitDto> get copyWith => _$AppLimitDtoCopyWithImpl<AppLimitDto>(this as AppLimitDto, _$identity);

  /// Serializes this AppLimitDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppLimitDto&&(identical(other.packageName, packageName) || other.packageName == packageName)&&(identical(other.quotaMinutes, quotaMinutes) || other.quotaMinutes == quotaMinutes)&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.enforcement, enforcement) || other.enforcement == enforcement)&&(identical(other.remindOnOpen, remindOnOpen) || other.remindOnOpen == remindOnOpen)&&(identical(other.activeWeekdays, activeWeekdays) || other.activeWeekdays == activeWeekdays)&&(identical(other.activeFromMinutes, activeFromMinutes) || other.activeFromMinutes == activeFromMinutes)&&(identical(other.activeUntilMinutes, activeUntilMinutes) || other.activeUntilMinutes == activeUntilMinutes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,packageName,quotaMinutes,enabled,enforcement,remindOnOpen,activeWeekdays,activeFromMinutes,activeUntilMinutes);

@override
String toString() {
  return 'AppLimitDto(packageName: $packageName, quotaMinutes: $quotaMinutes, enabled: $enabled, enforcement: $enforcement, remindOnOpen: $remindOnOpen, activeWeekdays: $activeWeekdays, activeFromMinutes: $activeFromMinutes, activeUntilMinutes: $activeUntilMinutes)';
}


}

/// @nodoc
abstract mixin class $AppLimitDtoCopyWith<$Res>  {
  factory $AppLimitDtoCopyWith(AppLimitDto value, $Res Function(AppLimitDto) _then) = _$AppLimitDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'package_name') String packageName,@JsonKey(name: 'quota_minutes') int quotaMinutes, bool enabled,@JsonKey(name: 'enforcement') String enforcement,@JsonKey(name: 'remind_on_open') bool remindOnOpen,@JsonKey(name: 'active_weekdays') String activeWeekdays,@JsonKey(name: 'active_from_minutes') int? activeFromMinutes,@JsonKey(name: 'active_until_minutes') int? activeUntilMinutes
});




}
/// @nodoc
class _$AppLimitDtoCopyWithImpl<$Res>
    implements $AppLimitDtoCopyWith<$Res> {
  _$AppLimitDtoCopyWithImpl(this._self, this._then);

  final AppLimitDto _self;
  final $Res Function(AppLimitDto) _then;

/// Create a copy of AppLimitDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? packageName = null,Object? quotaMinutes = null,Object? enabled = null,Object? enforcement = null,Object? remindOnOpen = null,Object? activeWeekdays = null,Object? activeFromMinutes = freezed,Object? activeUntilMinutes = freezed,}) {
  return _then(_self.copyWith(
packageName: null == packageName ? _self.packageName : packageName // ignore: cast_nullable_to_non_nullable
as String,quotaMinutes: null == quotaMinutes ? _self.quotaMinutes : quotaMinutes // ignore: cast_nullable_to_non_nullable
as int,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,enforcement: null == enforcement ? _self.enforcement : enforcement // ignore: cast_nullable_to_non_nullable
as String,remindOnOpen: null == remindOnOpen ? _self.remindOnOpen : remindOnOpen // ignore: cast_nullable_to_non_nullable
as bool,activeWeekdays: null == activeWeekdays ? _self.activeWeekdays : activeWeekdays // ignore: cast_nullable_to_non_nullable
as String,activeFromMinutes: freezed == activeFromMinutes ? _self.activeFromMinutes : activeFromMinutes // ignore: cast_nullable_to_non_nullable
as int?,activeUntilMinutes: freezed == activeUntilMinutes ? _self.activeUntilMinutes : activeUntilMinutes // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [AppLimitDto].
extension AppLimitDtoPatterns on AppLimitDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppLimitDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppLimitDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppLimitDto value)  $default,){
final _that = this;
switch (_that) {
case _AppLimitDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppLimitDto value)?  $default,){
final _that = this;
switch (_that) {
case _AppLimitDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'package_name')  String packageName, @JsonKey(name: 'quota_minutes')  int quotaMinutes,  bool enabled, @JsonKey(name: 'enforcement')  String enforcement, @JsonKey(name: 'remind_on_open')  bool remindOnOpen, @JsonKey(name: 'active_weekdays')  String activeWeekdays, @JsonKey(name: 'active_from_minutes')  int? activeFromMinutes, @JsonKey(name: 'active_until_minutes')  int? activeUntilMinutes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppLimitDto() when $default != null:
return $default(_that.packageName,_that.quotaMinutes,_that.enabled,_that.enforcement,_that.remindOnOpen,_that.activeWeekdays,_that.activeFromMinutes,_that.activeUntilMinutes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'package_name')  String packageName, @JsonKey(name: 'quota_minutes')  int quotaMinutes,  bool enabled, @JsonKey(name: 'enforcement')  String enforcement, @JsonKey(name: 'remind_on_open')  bool remindOnOpen, @JsonKey(name: 'active_weekdays')  String activeWeekdays, @JsonKey(name: 'active_from_minutes')  int? activeFromMinutes, @JsonKey(name: 'active_until_minutes')  int? activeUntilMinutes)  $default,) {final _that = this;
switch (_that) {
case _AppLimitDto():
return $default(_that.packageName,_that.quotaMinutes,_that.enabled,_that.enforcement,_that.remindOnOpen,_that.activeWeekdays,_that.activeFromMinutes,_that.activeUntilMinutes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'package_name')  String packageName, @JsonKey(name: 'quota_minutes')  int quotaMinutes,  bool enabled, @JsonKey(name: 'enforcement')  String enforcement, @JsonKey(name: 'remind_on_open')  bool remindOnOpen, @JsonKey(name: 'active_weekdays')  String activeWeekdays, @JsonKey(name: 'active_from_minutes')  int? activeFromMinutes, @JsonKey(name: 'active_until_minutes')  int? activeUntilMinutes)?  $default,) {final _that = this;
switch (_that) {
case _AppLimitDto() when $default != null:
return $default(_that.packageName,_that.quotaMinutes,_that.enabled,_that.enforcement,_that.remindOnOpen,_that.activeWeekdays,_that.activeFromMinutes,_that.activeUntilMinutes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppLimitDto implements AppLimitDto {
  const _AppLimitDto({@JsonKey(name: 'package_name') required this.packageName, @JsonKey(name: 'quota_minutes') required this.quotaMinutes, this.enabled = true, @JsonKey(name: 'enforcement') this.enforcement = 'breathe', @JsonKey(name: 'remind_on_open') this.remindOnOpen = false, @JsonKey(name: 'active_weekdays') this.activeWeekdays = '', @JsonKey(name: 'active_from_minutes') this.activeFromMinutes, @JsonKey(name: 'active_until_minutes') this.activeUntilMinutes});
  factory _AppLimitDto.fromJson(Map<String, dynamic> json) => _$AppLimitDtoFromJson(json);

@override@JsonKey(name: 'package_name') final  String packageName;
@override@JsonKey(name: 'quota_minutes') final  int quotaMinutes;
@override@JsonKey() final  bool enabled;
@override@JsonKey(name: 'enforcement') final  String enforcement;
@override@JsonKey(name: 'remind_on_open') final  bool remindOnOpen;
@override@JsonKey(name: 'active_weekdays') final  String activeWeekdays;
@override@JsonKey(name: 'active_from_minutes') final  int? activeFromMinutes;
@override@JsonKey(name: 'active_until_minutes') final  int? activeUntilMinutes;

/// Create a copy of AppLimitDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppLimitDtoCopyWith<_AppLimitDto> get copyWith => __$AppLimitDtoCopyWithImpl<_AppLimitDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppLimitDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppLimitDto&&(identical(other.packageName, packageName) || other.packageName == packageName)&&(identical(other.quotaMinutes, quotaMinutes) || other.quotaMinutes == quotaMinutes)&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.enforcement, enforcement) || other.enforcement == enforcement)&&(identical(other.remindOnOpen, remindOnOpen) || other.remindOnOpen == remindOnOpen)&&(identical(other.activeWeekdays, activeWeekdays) || other.activeWeekdays == activeWeekdays)&&(identical(other.activeFromMinutes, activeFromMinutes) || other.activeFromMinutes == activeFromMinutes)&&(identical(other.activeUntilMinutes, activeUntilMinutes) || other.activeUntilMinutes == activeUntilMinutes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,packageName,quotaMinutes,enabled,enforcement,remindOnOpen,activeWeekdays,activeFromMinutes,activeUntilMinutes);

@override
String toString() {
  return 'AppLimitDto(packageName: $packageName, quotaMinutes: $quotaMinutes, enabled: $enabled, enforcement: $enforcement, remindOnOpen: $remindOnOpen, activeWeekdays: $activeWeekdays, activeFromMinutes: $activeFromMinutes, activeUntilMinutes: $activeUntilMinutes)';
}


}

/// @nodoc
abstract mixin class _$AppLimitDtoCopyWith<$Res> implements $AppLimitDtoCopyWith<$Res> {
  factory _$AppLimitDtoCopyWith(_AppLimitDto value, $Res Function(_AppLimitDto) _then) = __$AppLimitDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'package_name') String packageName,@JsonKey(name: 'quota_minutes') int quotaMinutes, bool enabled,@JsonKey(name: 'enforcement') String enforcement,@JsonKey(name: 'remind_on_open') bool remindOnOpen,@JsonKey(name: 'active_weekdays') String activeWeekdays,@JsonKey(name: 'active_from_minutes') int? activeFromMinutes,@JsonKey(name: 'active_until_minutes') int? activeUntilMinutes
});




}
/// @nodoc
class __$AppLimitDtoCopyWithImpl<$Res>
    implements _$AppLimitDtoCopyWith<$Res> {
  __$AppLimitDtoCopyWithImpl(this._self, this._then);

  final _AppLimitDto _self;
  final $Res Function(_AppLimitDto) _then;

/// Create a copy of AppLimitDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? packageName = null,Object? quotaMinutes = null,Object? enabled = null,Object? enforcement = null,Object? remindOnOpen = null,Object? activeWeekdays = null,Object? activeFromMinutes = freezed,Object? activeUntilMinutes = freezed,}) {
  return _then(_AppLimitDto(
packageName: null == packageName ? _self.packageName : packageName // ignore: cast_nullable_to_non_nullable
as String,quotaMinutes: null == quotaMinutes ? _self.quotaMinutes : quotaMinutes // ignore: cast_nullable_to_non_nullable
as int,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,enforcement: null == enforcement ? _self.enforcement : enforcement // ignore: cast_nullable_to_non_nullable
as String,remindOnOpen: null == remindOnOpen ? _self.remindOnOpen : remindOnOpen // ignore: cast_nullable_to_non_nullable
as bool,activeWeekdays: null == activeWeekdays ? _self.activeWeekdays : activeWeekdays // ignore: cast_nullable_to_non_nullable
as String,activeFromMinutes: freezed == activeFromMinutes ? _self.activeFromMinutes : activeFromMinutes // ignore: cast_nullable_to_non_nullable
as int?,activeUntilMinutes: freezed == activeUntilMinutes ? _self.activeUntilMinutes : activeUntilMinutes // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
