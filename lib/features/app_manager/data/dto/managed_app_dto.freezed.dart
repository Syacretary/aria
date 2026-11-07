// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'managed_app_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ManagedAppDto {

@JsonKey(name: 'package_name') String get packageName;@JsonKey(name: 'app_name') String get appName;@JsonKey(name: 'used_minutes') int get usedMinutes;@JsonKey(name: 'session_count') int get sessionCount;@JsonKey(name: 'category') String get category;@JsonKey(name: 'is_installed') bool get isInstalled;
/// Create a copy of ManagedAppDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ManagedAppDtoCopyWith<ManagedAppDto> get copyWith => _$ManagedAppDtoCopyWithImpl<ManagedAppDto>(this as ManagedAppDto, _$identity);

  /// Serializes this ManagedAppDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ManagedAppDto&&(identical(other.packageName, packageName) || other.packageName == packageName)&&(identical(other.appName, appName) || other.appName == appName)&&(identical(other.usedMinutes, usedMinutes) || other.usedMinutes == usedMinutes)&&(identical(other.sessionCount, sessionCount) || other.sessionCount == sessionCount)&&(identical(other.category, category) || other.category == category)&&(identical(other.isInstalled, isInstalled) || other.isInstalled == isInstalled));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,packageName,appName,usedMinutes,sessionCount,category,isInstalled);

@override
String toString() {
  return 'ManagedAppDto(packageName: $packageName, appName: $appName, usedMinutes: $usedMinutes, sessionCount: $sessionCount, category: $category, isInstalled: $isInstalled)';
}


}

/// @nodoc
abstract mixin class $ManagedAppDtoCopyWith<$Res>  {
  factory $ManagedAppDtoCopyWith(ManagedAppDto value, $Res Function(ManagedAppDto) _then) = _$ManagedAppDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'package_name') String packageName,@JsonKey(name: 'app_name') String appName,@JsonKey(name: 'used_minutes') int usedMinutes,@JsonKey(name: 'session_count') int sessionCount,@JsonKey(name: 'category') String category,@JsonKey(name: 'is_installed') bool isInstalled
});




}
/// @nodoc
class _$ManagedAppDtoCopyWithImpl<$Res>
    implements $ManagedAppDtoCopyWith<$Res> {
  _$ManagedAppDtoCopyWithImpl(this._self, this._then);

  final ManagedAppDto _self;
  final $Res Function(ManagedAppDto) _then;

/// Create a copy of ManagedAppDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? packageName = null,Object? appName = null,Object? usedMinutes = null,Object? sessionCount = null,Object? category = null,Object? isInstalled = null,}) {
  return _then(_self.copyWith(
packageName: null == packageName ? _self.packageName : packageName // ignore: cast_nullable_to_non_nullable
as String,appName: null == appName ? _self.appName : appName // ignore: cast_nullable_to_non_nullable
as String,usedMinutes: null == usedMinutes ? _self.usedMinutes : usedMinutes // ignore: cast_nullable_to_non_nullable
as int,sessionCount: null == sessionCount ? _self.sessionCount : sessionCount // ignore: cast_nullable_to_non_nullable
as int,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,isInstalled: null == isInstalled ? _self.isInstalled : isInstalled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ManagedAppDto].
extension ManagedAppDtoPatterns on ManagedAppDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ManagedAppDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ManagedAppDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ManagedAppDto value)  $default,){
final _that = this;
switch (_that) {
case _ManagedAppDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ManagedAppDto value)?  $default,){
final _that = this;
switch (_that) {
case _ManagedAppDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'package_name')  String packageName, @JsonKey(name: 'app_name')  String appName, @JsonKey(name: 'used_minutes')  int usedMinutes, @JsonKey(name: 'session_count')  int sessionCount, @JsonKey(name: 'category')  String category, @JsonKey(name: 'is_installed')  bool isInstalled)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ManagedAppDto() when $default != null:
return $default(_that.packageName,_that.appName,_that.usedMinutes,_that.sessionCount,_that.category,_that.isInstalled);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'package_name')  String packageName, @JsonKey(name: 'app_name')  String appName, @JsonKey(name: 'used_minutes')  int usedMinutes, @JsonKey(name: 'session_count')  int sessionCount, @JsonKey(name: 'category')  String category, @JsonKey(name: 'is_installed')  bool isInstalled)  $default,) {final _that = this;
switch (_that) {
case _ManagedAppDto():
return $default(_that.packageName,_that.appName,_that.usedMinutes,_that.sessionCount,_that.category,_that.isInstalled);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'package_name')  String packageName, @JsonKey(name: 'app_name')  String appName, @JsonKey(name: 'used_minutes')  int usedMinutes, @JsonKey(name: 'session_count')  int sessionCount, @JsonKey(name: 'category')  String category, @JsonKey(name: 'is_installed')  bool isInstalled)?  $default,) {final _that = this;
switch (_that) {
case _ManagedAppDto() when $default != null:
return $default(_that.packageName,_that.appName,_that.usedMinutes,_that.sessionCount,_that.category,_that.isInstalled);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ManagedAppDto implements ManagedAppDto {
  const _ManagedAppDto({@JsonKey(name: 'package_name') required this.packageName, @JsonKey(name: 'app_name') required this.appName, @JsonKey(name: 'used_minutes') this.usedMinutes = 0, @JsonKey(name: 'session_count') this.sessionCount = 0, @JsonKey(name: 'category') this.category = 'other', @JsonKey(name: 'is_installed') this.isInstalled = true});
  factory _ManagedAppDto.fromJson(Map<String, dynamic> json) => _$ManagedAppDtoFromJson(json);

@override@JsonKey(name: 'package_name') final  String packageName;
@override@JsonKey(name: 'app_name') final  String appName;
@override@JsonKey(name: 'used_minutes') final  int usedMinutes;
@override@JsonKey(name: 'session_count') final  int sessionCount;
@override@JsonKey(name: 'category') final  String category;
@override@JsonKey(name: 'is_installed') final  bool isInstalled;

/// Create a copy of ManagedAppDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ManagedAppDtoCopyWith<_ManagedAppDto> get copyWith => __$ManagedAppDtoCopyWithImpl<_ManagedAppDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ManagedAppDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ManagedAppDto&&(identical(other.packageName, packageName) || other.packageName == packageName)&&(identical(other.appName, appName) || other.appName == appName)&&(identical(other.usedMinutes, usedMinutes) || other.usedMinutes == usedMinutes)&&(identical(other.sessionCount, sessionCount) || other.sessionCount == sessionCount)&&(identical(other.category, category) || other.category == category)&&(identical(other.isInstalled, isInstalled) || other.isInstalled == isInstalled));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,packageName,appName,usedMinutes,sessionCount,category,isInstalled);

@override
String toString() {
  return 'ManagedAppDto(packageName: $packageName, appName: $appName, usedMinutes: $usedMinutes, sessionCount: $sessionCount, category: $category, isInstalled: $isInstalled)';
}


}

/// @nodoc
abstract mixin class _$ManagedAppDtoCopyWith<$Res> implements $ManagedAppDtoCopyWith<$Res> {
  factory _$ManagedAppDtoCopyWith(_ManagedAppDto value, $Res Function(_ManagedAppDto) _then) = __$ManagedAppDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'package_name') String packageName,@JsonKey(name: 'app_name') String appName,@JsonKey(name: 'used_minutes') int usedMinutes,@JsonKey(name: 'session_count') int sessionCount,@JsonKey(name: 'category') String category,@JsonKey(name: 'is_installed') bool isInstalled
});




}
/// @nodoc
class __$ManagedAppDtoCopyWithImpl<$Res>
    implements _$ManagedAppDtoCopyWith<$Res> {
  __$ManagedAppDtoCopyWithImpl(this._self, this._then);

  final _ManagedAppDto _self;
  final $Res Function(_ManagedAppDto) _then;

/// Create a copy of ManagedAppDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? packageName = null,Object? appName = null,Object? usedMinutes = null,Object? sessionCount = null,Object? category = null,Object? isInstalled = null,}) {
  return _then(_ManagedAppDto(
packageName: null == packageName ? _self.packageName : packageName // ignore: cast_nullable_to_non_nullable
as String,appName: null == appName ? _self.appName : appName // ignore: cast_nullable_to_non_nullable
as String,usedMinutes: null == usedMinutes ? _self.usedMinutes : usedMinutes // ignore: cast_nullable_to_non_nullable
as int,sessionCount: null == sessionCount ? _self.sessionCount : sessionCount // ignore: cast_nullable_to_non_nullable
as int,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,isInstalled: null == isInstalled ? _self.isInstalled : isInstalled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
