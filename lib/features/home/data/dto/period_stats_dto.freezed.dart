// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'period_stats_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PeriodStatDto {

 String get label; int get opens;@JsonKey(name: 'previous_opens') int get previousOpens;
/// Create a copy of PeriodStatDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PeriodStatDtoCopyWith<PeriodStatDto> get copyWith => _$PeriodStatDtoCopyWithImpl<PeriodStatDto>(this as PeriodStatDto, _$identity);

  /// Serializes this PeriodStatDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PeriodStatDto&&(identical(other.label, label) || other.label == label)&&(identical(other.opens, opens) || other.opens == opens)&&(identical(other.previousOpens, previousOpens) || other.previousOpens == previousOpens));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,label,opens,previousOpens);

@override
String toString() {
  return 'PeriodStatDto(label: $label, opens: $opens, previousOpens: $previousOpens)';
}


}

/// @nodoc
abstract mixin class $PeriodStatDtoCopyWith<$Res>  {
  factory $PeriodStatDtoCopyWith(PeriodStatDto value, $Res Function(PeriodStatDto) _then) = _$PeriodStatDtoCopyWithImpl;
@useResult
$Res call({
 String label, int opens,@JsonKey(name: 'previous_opens') int previousOpens
});




}
/// @nodoc
class _$PeriodStatDtoCopyWithImpl<$Res>
    implements $PeriodStatDtoCopyWith<$Res> {
  _$PeriodStatDtoCopyWithImpl(this._self, this._then);

  final PeriodStatDto _self;
  final $Res Function(PeriodStatDto) _then;

/// Create a copy of PeriodStatDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? label = null,Object? opens = null,Object? previousOpens = null,}) {
  return _then(_self.copyWith(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,opens: null == opens ? _self.opens : opens // ignore: cast_nullable_to_non_nullable
as int,previousOpens: null == previousOpens ? _self.previousOpens : previousOpens // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PeriodStatDto].
extension PeriodStatDtoPatterns on PeriodStatDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PeriodStatDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PeriodStatDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PeriodStatDto value)  $default,){
final _that = this;
switch (_that) {
case _PeriodStatDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PeriodStatDto value)?  $default,){
final _that = this;
switch (_that) {
case _PeriodStatDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String label,  int opens, @JsonKey(name: 'previous_opens')  int previousOpens)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PeriodStatDto() when $default != null:
return $default(_that.label,_that.opens,_that.previousOpens);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String label,  int opens, @JsonKey(name: 'previous_opens')  int previousOpens)  $default,) {final _that = this;
switch (_that) {
case _PeriodStatDto():
return $default(_that.label,_that.opens,_that.previousOpens);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String label,  int opens, @JsonKey(name: 'previous_opens')  int previousOpens)?  $default,) {final _that = this;
switch (_that) {
case _PeriodStatDto() when $default != null:
return $default(_that.label,_that.opens,_that.previousOpens);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PeriodStatDto implements PeriodStatDto {
  const _PeriodStatDto({required this.label, required this.opens, @JsonKey(name: 'previous_opens') required this.previousOpens});
  factory _PeriodStatDto.fromJson(Map<String, dynamic> json) => _$PeriodStatDtoFromJson(json);

@override final  String label;
@override final  int opens;
@override@JsonKey(name: 'previous_opens') final  int previousOpens;

/// Create a copy of PeriodStatDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PeriodStatDtoCopyWith<_PeriodStatDto> get copyWith => __$PeriodStatDtoCopyWithImpl<_PeriodStatDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PeriodStatDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PeriodStatDto&&(identical(other.label, label) || other.label == label)&&(identical(other.opens, opens) || other.opens == opens)&&(identical(other.previousOpens, previousOpens) || other.previousOpens == previousOpens));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,label,opens,previousOpens);

@override
String toString() {
  return 'PeriodStatDto(label: $label, opens: $opens, previousOpens: $previousOpens)';
}


}

/// @nodoc
abstract mixin class _$PeriodStatDtoCopyWith<$Res> implements $PeriodStatDtoCopyWith<$Res> {
  factory _$PeriodStatDtoCopyWith(_PeriodStatDto value, $Res Function(_PeriodStatDto) _then) = __$PeriodStatDtoCopyWithImpl;
@override @useResult
$Res call({
 String label, int opens,@JsonKey(name: 'previous_opens') int previousOpens
});




}
/// @nodoc
class __$PeriodStatDtoCopyWithImpl<$Res>
    implements _$PeriodStatDtoCopyWith<$Res> {
  __$PeriodStatDtoCopyWithImpl(this._self, this._then);

  final _PeriodStatDto _self;
  final $Res Function(_PeriodStatDto) _then;

/// Create a copy of PeriodStatDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? label = null,Object? opens = null,Object? previousOpens = null,}) {
  return _then(_PeriodStatDto(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,opens: null == opens ? _self.opens : opens // ignore: cast_nullable_to_non_nullable
as int,previousOpens: null == previousOpens ? _self.previousOpens : previousOpens // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$PeriodBreakdownDto {

 PeriodStatDto get daily; PeriodStatDto get weekly; PeriodStatDto get monthly;
/// Create a copy of PeriodBreakdownDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PeriodBreakdownDtoCopyWith<PeriodBreakdownDto> get copyWith => _$PeriodBreakdownDtoCopyWithImpl<PeriodBreakdownDto>(this as PeriodBreakdownDto, _$identity);

  /// Serializes this PeriodBreakdownDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PeriodBreakdownDto&&(identical(other.daily, daily) || other.daily == daily)&&(identical(other.weekly, weekly) || other.weekly == weekly)&&(identical(other.monthly, monthly) || other.monthly == monthly));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,daily,weekly,monthly);

@override
String toString() {
  return 'PeriodBreakdownDto(daily: $daily, weekly: $weekly, monthly: $monthly)';
}


}

/// @nodoc
abstract mixin class $PeriodBreakdownDtoCopyWith<$Res>  {
  factory $PeriodBreakdownDtoCopyWith(PeriodBreakdownDto value, $Res Function(PeriodBreakdownDto) _then) = _$PeriodBreakdownDtoCopyWithImpl;
@useResult
$Res call({
 PeriodStatDto daily, PeriodStatDto weekly, PeriodStatDto monthly
});


$PeriodStatDtoCopyWith<$Res> get daily;$PeriodStatDtoCopyWith<$Res> get weekly;$PeriodStatDtoCopyWith<$Res> get monthly;

}
/// @nodoc
class _$PeriodBreakdownDtoCopyWithImpl<$Res>
    implements $PeriodBreakdownDtoCopyWith<$Res> {
  _$PeriodBreakdownDtoCopyWithImpl(this._self, this._then);

  final PeriodBreakdownDto _self;
  final $Res Function(PeriodBreakdownDto) _then;

/// Create a copy of PeriodBreakdownDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? daily = null,Object? weekly = null,Object? monthly = null,}) {
  return _then(_self.copyWith(
daily: null == daily ? _self.daily : daily // ignore: cast_nullable_to_non_nullable
as PeriodStatDto,weekly: null == weekly ? _self.weekly : weekly // ignore: cast_nullable_to_non_nullable
as PeriodStatDto,monthly: null == monthly ? _self.monthly : monthly // ignore: cast_nullable_to_non_nullable
as PeriodStatDto,
  ));
}
/// Create a copy of PeriodBreakdownDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PeriodStatDtoCopyWith<$Res> get daily {
  
  return $PeriodStatDtoCopyWith<$Res>(_self.daily, (value) {
    return _then(_self.copyWith(daily: value));
  });
}/// Create a copy of PeriodBreakdownDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PeriodStatDtoCopyWith<$Res> get weekly {
  
  return $PeriodStatDtoCopyWith<$Res>(_self.weekly, (value) {
    return _then(_self.copyWith(weekly: value));
  });
}/// Create a copy of PeriodBreakdownDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PeriodStatDtoCopyWith<$Res> get monthly {
  
  return $PeriodStatDtoCopyWith<$Res>(_self.monthly, (value) {
    return _then(_self.copyWith(monthly: value));
  });
}
}


/// Adds pattern-matching-related methods to [PeriodBreakdownDto].
extension PeriodBreakdownDtoPatterns on PeriodBreakdownDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PeriodBreakdownDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PeriodBreakdownDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PeriodBreakdownDto value)  $default,){
final _that = this;
switch (_that) {
case _PeriodBreakdownDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PeriodBreakdownDto value)?  $default,){
final _that = this;
switch (_that) {
case _PeriodBreakdownDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PeriodStatDto daily,  PeriodStatDto weekly,  PeriodStatDto monthly)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PeriodBreakdownDto() when $default != null:
return $default(_that.daily,_that.weekly,_that.monthly);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PeriodStatDto daily,  PeriodStatDto weekly,  PeriodStatDto monthly)  $default,) {final _that = this;
switch (_that) {
case _PeriodBreakdownDto():
return $default(_that.daily,_that.weekly,_that.monthly);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PeriodStatDto daily,  PeriodStatDto weekly,  PeriodStatDto monthly)?  $default,) {final _that = this;
switch (_that) {
case _PeriodBreakdownDto() when $default != null:
return $default(_that.daily,_that.weekly,_that.monthly);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PeriodBreakdownDto implements PeriodBreakdownDto {
  const _PeriodBreakdownDto({required this.daily, required this.weekly, required this.monthly});
  factory _PeriodBreakdownDto.fromJson(Map<String, dynamic> json) => _$PeriodBreakdownDtoFromJson(json);

@override final  PeriodStatDto daily;
@override final  PeriodStatDto weekly;
@override final  PeriodStatDto monthly;

/// Create a copy of PeriodBreakdownDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PeriodBreakdownDtoCopyWith<_PeriodBreakdownDto> get copyWith => __$PeriodBreakdownDtoCopyWithImpl<_PeriodBreakdownDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PeriodBreakdownDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PeriodBreakdownDto&&(identical(other.daily, daily) || other.daily == daily)&&(identical(other.weekly, weekly) || other.weekly == weekly)&&(identical(other.monthly, monthly) || other.monthly == monthly));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,daily,weekly,monthly);

@override
String toString() {
  return 'PeriodBreakdownDto(daily: $daily, weekly: $weekly, monthly: $monthly)';
}


}

/// @nodoc
abstract mixin class _$PeriodBreakdownDtoCopyWith<$Res> implements $PeriodBreakdownDtoCopyWith<$Res> {
  factory _$PeriodBreakdownDtoCopyWith(_PeriodBreakdownDto value, $Res Function(_PeriodBreakdownDto) _then) = __$PeriodBreakdownDtoCopyWithImpl;
@override @useResult
$Res call({
 PeriodStatDto daily, PeriodStatDto weekly, PeriodStatDto monthly
});


@override $PeriodStatDtoCopyWith<$Res> get daily;@override $PeriodStatDtoCopyWith<$Res> get weekly;@override $PeriodStatDtoCopyWith<$Res> get monthly;

}
/// @nodoc
class __$PeriodBreakdownDtoCopyWithImpl<$Res>
    implements _$PeriodBreakdownDtoCopyWith<$Res> {
  __$PeriodBreakdownDtoCopyWithImpl(this._self, this._then);

  final _PeriodBreakdownDto _self;
  final $Res Function(_PeriodBreakdownDto) _then;

/// Create a copy of PeriodBreakdownDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? daily = null,Object? weekly = null,Object? monthly = null,}) {
  return _then(_PeriodBreakdownDto(
daily: null == daily ? _self.daily : daily // ignore: cast_nullable_to_non_nullable
as PeriodStatDto,weekly: null == weekly ? _self.weekly : weekly // ignore: cast_nullable_to_non_nullable
as PeriodStatDto,monthly: null == monthly ? _self.monthly : monthly // ignore: cast_nullable_to_non_nullable
as PeriodStatDto,
  ));
}

/// Create a copy of PeriodBreakdownDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PeriodStatDtoCopyWith<$Res> get daily {
  
  return $PeriodStatDtoCopyWith<$Res>(_self.daily, (value) {
    return _then(_self.copyWith(daily: value));
  });
}/// Create a copy of PeriodBreakdownDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PeriodStatDtoCopyWith<$Res> get weekly {
  
  return $PeriodStatDtoCopyWith<$Res>(_self.weekly, (value) {
    return _then(_self.copyWith(weekly: value));
  });
}/// Create a copy of PeriodBreakdownDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PeriodStatDtoCopyWith<$Res> get monthly {
  
  return $PeriodStatDtoCopyWith<$Res>(_self.monthly, (value) {
    return _then(_self.copyWith(monthly: value));
  });
}
}

// dart format on
