// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'daily_summary_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DailySummaryDto {

@JsonKey(name: 'date') String get date;@JsonKey(name: 'videos_opened') int get videosOpened;@JsonKey(name: 'videos_opened_yesterday') int get videosOpenedYesterday;@JsonKey(name: 'social_opens') int get socialOpens;@JsonKey(name: 'social_opens_yesterday') int get socialOpensYesterday;@JsonKey(name: 'screen_time_minutes') int get screenTimeMinutes;@JsonKey(name: 'screen_time_minutes_yesterday') int get screenTimeMinutesYesterday;
/// Create a copy of DailySummaryDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DailySummaryDtoCopyWith<DailySummaryDto> get copyWith => _$DailySummaryDtoCopyWithImpl<DailySummaryDto>(this as DailySummaryDto, _$identity);

  /// Serializes this DailySummaryDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DailySummaryDto&&(identical(other.date, date) || other.date == date)&&(identical(other.videosOpened, videosOpened) || other.videosOpened == videosOpened)&&(identical(other.videosOpenedYesterday, videosOpenedYesterday) || other.videosOpenedYesterday == videosOpenedYesterday)&&(identical(other.socialOpens, socialOpens) || other.socialOpens == socialOpens)&&(identical(other.socialOpensYesterday, socialOpensYesterday) || other.socialOpensYesterday == socialOpensYesterday)&&(identical(other.screenTimeMinutes, screenTimeMinutes) || other.screenTimeMinutes == screenTimeMinutes)&&(identical(other.screenTimeMinutesYesterday, screenTimeMinutesYesterday) || other.screenTimeMinutesYesterday == screenTimeMinutesYesterday));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,videosOpened,videosOpenedYesterday,socialOpens,socialOpensYesterday,screenTimeMinutes,screenTimeMinutesYesterday);

@override
String toString() {
  return 'DailySummaryDto(date: $date, videosOpened: $videosOpened, videosOpenedYesterday: $videosOpenedYesterday, socialOpens: $socialOpens, socialOpensYesterday: $socialOpensYesterday, screenTimeMinutes: $screenTimeMinutes, screenTimeMinutesYesterday: $screenTimeMinutesYesterday)';
}


}

/// @nodoc
abstract mixin class $DailySummaryDtoCopyWith<$Res>  {
  factory $DailySummaryDtoCopyWith(DailySummaryDto value, $Res Function(DailySummaryDto) _then) = _$DailySummaryDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'date') String date,@JsonKey(name: 'videos_opened') int videosOpened,@JsonKey(name: 'videos_opened_yesterday') int videosOpenedYesterday,@JsonKey(name: 'social_opens') int socialOpens,@JsonKey(name: 'social_opens_yesterday') int socialOpensYesterday,@JsonKey(name: 'screen_time_minutes') int screenTimeMinutes,@JsonKey(name: 'screen_time_minutes_yesterday') int screenTimeMinutesYesterday
});




}
/// @nodoc
class _$DailySummaryDtoCopyWithImpl<$Res>
    implements $DailySummaryDtoCopyWith<$Res> {
  _$DailySummaryDtoCopyWithImpl(this._self, this._then);

  final DailySummaryDto _self;
  final $Res Function(DailySummaryDto) _then;

/// Create a copy of DailySummaryDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? videosOpened = null,Object? videosOpenedYesterday = null,Object? socialOpens = null,Object? socialOpensYesterday = null,Object? screenTimeMinutes = null,Object? screenTimeMinutesYesterday = null,}) {
  return _then(_self.copyWith(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,videosOpened: null == videosOpened ? _self.videosOpened : videosOpened // ignore: cast_nullable_to_non_nullable
as int,videosOpenedYesterday: null == videosOpenedYesterday ? _self.videosOpenedYesterday : videosOpenedYesterday // ignore: cast_nullable_to_non_nullable
as int,socialOpens: null == socialOpens ? _self.socialOpens : socialOpens // ignore: cast_nullable_to_non_nullable
as int,socialOpensYesterday: null == socialOpensYesterday ? _self.socialOpensYesterday : socialOpensYesterday // ignore: cast_nullable_to_non_nullable
as int,screenTimeMinutes: null == screenTimeMinutes ? _self.screenTimeMinutes : screenTimeMinutes // ignore: cast_nullable_to_non_nullable
as int,screenTimeMinutesYesterday: null == screenTimeMinutesYesterday ? _self.screenTimeMinutesYesterday : screenTimeMinutesYesterday // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [DailySummaryDto].
extension DailySummaryDtoPatterns on DailySummaryDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DailySummaryDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DailySummaryDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DailySummaryDto value)  $default,){
final _that = this;
switch (_that) {
case _DailySummaryDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DailySummaryDto value)?  $default,){
final _that = this;
switch (_that) {
case _DailySummaryDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'date')  String date, @JsonKey(name: 'videos_opened')  int videosOpened, @JsonKey(name: 'videos_opened_yesterday')  int videosOpenedYesterday, @JsonKey(name: 'social_opens')  int socialOpens, @JsonKey(name: 'social_opens_yesterday')  int socialOpensYesterday, @JsonKey(name: 'screen_time_minutes')  int screenTimeMinutes, @JsonKey(name: 'screen_time_minutes_yesterday')  int screenTimeMinutesYesterday)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DailySummaryDto() when $default != null:
return $default(_that.date,_that.videosOpened,_that.videosOpenedYesterday,_that.socialOpens,_that.socialOpensYesterday,_that.screenTimeMinutes,_that.screenTimeMinutesYesterday);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'date')  String date, @JsonKey(name: 'videos_opened')  int videosOpened, @JsonKey(name: 'videos_opened_yesterday')  int videosOpenedYesterday, @JsonKey(name: 'social_opens')  int socialOpens, @JsonKey(name: 'social_opens_yesterday')  int socialOpensYesterday, @JsonKey(name: 'screen_time_minutes')  int screenTimeMinutes, @JsonKey(name: 'screen_time_minutes_yesterday')  int screenTimeMinutesYesterday)  $default,) {final _that = this;
switch (_that) {
case _DailySummaryDto():
return $default(_that.date,_that.videosOpened,_that.videosOpenedYesterday,_that.socialOpens,_that.socialOpensYesterday,_that.screenTimeMinutes,_that.screenTimeMinutesYesterday);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'date')  String date, @JsonKey(name: 'videos_opened')  int videosOpened, @JsonKey(name: 'videos_opened_yesterday')  int videosOpenedYesterday, @JsonKey(name: 'social_opens')  int socialOpens, @JsonKey(name: 'social_opens_yesterday')  int socialOpensYesterday, @JsonKey(name: 'screen_time_minutes')  int screenTimeMinutes, @JsonKey(name: 'screen_time_minutes_yesterday')  int screenTimeMinutesYesterday)?  $default,) {final _that = this;
switch (_that) {
case _DailySummaryDto() when $default != null:
return $default(_that.date,_that.videosOpened,_that.videosOpenedYesterday,_that.socialOpens,_that.socialOpensYesterday,_that.screenTimeMinutes,_that.screenTimeMinutesYesterday);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DailySummaryDto implements DailySummaryDto {
  const _DailySummaryDto({@JsonKey(name: 'date') required this.date, @JsonKey(name: 'videos_opened') required this.videosOpened, @JsonKey(name: 'videos_opened_yesterday') required this.videosOpenedYesterday, @JsonKey(name: 'social_opens') required this.socialOpens, @JsonKey(name: 'social_opens_yesterday') required this.socialOpensYesterday, @JsonKey(name: 'screen_time_minutes') required this.screenTimeMinutes, @JsonKey(name: 'screen_time_minutes_yesterday') required this.screenTimeMinutesYesterday});
  factory _DailySummaryDto.fromJson(Map<String, dynamic> json) => _$DailySummaryDtoFromJson(json);

@override@JsonKey(name: 'date') final  String date;
@override@JsonKey(name: 'videos_opened') final  int videosOpened;
@override@JsonKey(name: 'videos_opened_yesterday') final  int videosOpenedYesterday;
@override@JsonKey(name: 'social_opens') final  int socialOpens;
@override@JsonKey(name: 'social_opens_yesterday') final  int socialOpensYesterday;
@override@JsonKey(name: 'screen_time_minutes') final  int screenTimeMinutes;
@override@JsonKey(name: 'screen_time_minutes_yesterday') final  int screenTimeMinutesYesterday;

/// Create a copy of DailySummaryDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DailySummaryDtoCopyWith<_DailySummaryDto> get copyWith => __$DailySummaryDtoCopyWithImpl<_DailySummaryDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DailySummaryDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DailySummaryDto&&(identical(other.date, date) || other.date == date)&&(identical(other.videosOpened, videosOpened) || other.videosOpened == videosOpened)&&(identical(other.videosOpenedYesterday, videosOpenedYesterday) || other.videosOpenedYesterday == videosOpenedYesterday)&&(identical(other.socialOpens, socialOpens) || other.socialOpens == socialOpens)&&(identical(other.socialOpensYesterday, socialOpensYesterday) || other.socialOpensYesterday == socialOpensYesterday)&&(identical(other.screenTimeMinutes, screenTimeMinutes) || other.screenTimeMinutes == screenTimeMinutes)&&(identical(other.screenTimeMinutesYesterday, screenTimeMinutesYesterday) || other.screenTimeMinutesYesterday == screenTimeMinutesYesterday));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,videosOpened,videosOpenedYesterday,socialOpens,socialOpensYesterday,screenTimeMinutes,screenTimeMinutesYesterday);

@override
String toString() {
  return 'DailySummaryDto(date: $date, videosOpened: $videosOpened, videosOpenedYesterday: $videosOpenedYesterday, socialOpens: $socialOpens, socialOpensYesterday: $socialOpensYesterday, screenTimeMinutes: $screenTimeMinutes, screenTimeMinutesYesterday: $screenTimeMinutesYesterday)';
}


}

/// @nodoc
abstract mixin class _$DailySummaryDtoCopyWith<$Res> implements $DailySummaryDtoCopyWith<$Res> {
  factory _$DailySummaryDtoCopyWith(_DailySummaryDto value, $Res Function(_DailySummaryDto) _then) = __$DailySummaryDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'date') String date,@JsonKey(name: 'videos_opened') int videosOpened,@JsonKey(name: 'videos_opened_yesterday') int videosOpenedYesterday,@JsonKey(name: 'social_opens') int socialOpens,@JsonKey(name: 'social_opens_yesterday') int socialOpensYesterday,@JsonKey(name: 'screen_time_minutes') int screenTimeMinutes,@JsonKey(name: 'screen_time_minutes_yesterday') int screenTimeMinutesYesterday
});




}
/// @nodoc
class __$DailySummaryDtoCopyWithImpl<$Res>
    implements _$DailySummaryDtoCopyWith<$Res> {
  __$DailySummaryDtoCopyWithImpl(this._self, this._then);

  final _DailySummaryDto _self;
  final $Res Function(_DailySummaryDto) _then;

/// Create a copy of DailySummaryDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? videosOpened = null,Object? videosOpenedYesterday = null,Object? socialOpens = null,Object? socialOpensYesterday = null,Object? screenTimeMinutes = null,Object? screenTimeMinutesYesterday = null,}) {
  return _then(_DailySummaryDto(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,videosOpened: null == videosOpened ? _self.videosOpened : videosOpened // ignore: cast_nullable_to_non_nullable
as int,videosOpenedYesterday: null == videosOpenedYesterday ? _self.videosOpenedYesterday : videosOpenedYesterday // ignore: cast_nullable_to_non_nullable
as int,socialOpens: null == socialOpens ? _self.socialOpens : socialOpens // ignore: cast_nullable_to_non_nullable
as int,socialOpensYesterday: null == socialOpensYesterday ? _self.socialOpensYesterday : socialOpensYesterday // ignore: cast_nullable_to_non_nullable
as int,screenTimeMinutes: null == screenTimeMinutes ? _self.screenTimeMinutes : screenTimeMinutes // ignore: cast_nullable_to_non_nullable
as int,screenTimeMinutesYesterday: null == screenTimeMinutesYesterday ? _self.screenTimeMinutesYesterday : screenTimeMinutesYesterday // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
