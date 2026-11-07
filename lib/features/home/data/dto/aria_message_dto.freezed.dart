// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'aria_message_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AriaMessageDto {

 String get id; String get text;@JsonKey(name: 'created_at') String get createdAt;@JsonKey(name: 'action') String get action;@JsonKey(name: 'action_label') String? get actionLabel;@JsonKey(name: 'tone') String get tone;
/// Create a copy of AriaMessageDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AriaMessageDtoCopyWith<AriaMessageDto> get copyWith => _$AriaMessageDtoCopyWithImpl<AriaMessageDto>(this as AriaMessageDto, _$identity);

  /// Serializes this AriaMessageDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AriaMessageDto&&(identical(other.id, id) || other.id == id)&&(identical(other.text, text) || other.text == text)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.action, action) || other.action == action)&&(identical(other.actionLabel, actionLabel) || other.actionLabel == actionLabel)&&(identical(other.tone, tone) || other.tone == tone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,text,createdAt,action,actionLabel,tone);

@override
String toString() {
  return 'AriaMessageDto(id: $id, text: $text, createdAt: $createdAt, action: $action, actionLabel: $actionLabel, tone: $tone)';
}


}

/// @nodoc
abstract mixin class $AriaMessageDtoCopyWith<$Res>  {
  factory $AriaMessageDtoCopyWith(AriaMessageDto value, $Res Function(AriaMessageDto) _then) = _$AriaMessageDtoCopyWithImpl;
@useResult
$Res call({
 String id, String text,@JsonKey(name: 'created_at') String createdAt,@JsonKey(name: 'action') String action,@JsonKey(name: 'action_label') String? actionLabel,@JsonKey(name: 'tone') String tone
});




}
/// @nodoc
class _$AriaMessageDtoCopyWithImpl<$Res>
    implements $AriaMessageDtoCopyWith<$Res> {
  _$AriaMessageDtoCopyWithImpl(this._self, this._then);

  final AriaMessageDto _self;
  final $Res Function(AriaMessageDto) _then;

/// Create a copy of AriaMessageDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? text = null,Object? createdAt = null,Object? action = null,Object? actionLabel = freezed,Object? tone = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as String,actionLabel: freezed == actionLabel ? _self.actionLabel : actionLabel // ignore: cast_nullable_to_non_nullable
as String?,tone: null == tone ? _self.tone : tone // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AriaMessageDto].
extension AriaMessageDtoPatterns on AriaMessageDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AriaMessageDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AriaMessageDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AriaMessageDto value)  $default,){
final _that = this;
switch (_that) {
case _AriaMessageDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AriaMessageDto value)?  $default,){
final _that = this;
switch (_that) {
case _AriaMessageDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String text, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'action')  String action, @JsonKey(name: 'action_label')  String? actionLabel, @JsonKey(name: 'tone')  String tone)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AriaMessageDto() when $default != null:
return $default(_that.id,_that.text,_that.createdAt,_that.action,_that.actionLabel,_that.tone);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String text, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'action')  String action, @JsonKey(name: 'action_label')  String? actionLabel, @JsonKey(name: 'tone')  String tone)  $default,) {final _that = this;
switch (_that) {
case _AriaMessageDto():
return $default(_that.id,_that.text,_that.createdAt,_that.action,_that.actionLabel,_that.tone);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String text, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'action')  String action, @JsonKey(name: 'action_label')  String? actionLabel, @JsonKey(name: 'tone')  String tone)?  $default,) {final _that = this;
switch (_that) {
case _AriaMessageDto() when $default != null:
return $default(_that.id,_that.text,_that.createdAt,_that.action,_that.actionLabel,_that.tone);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AriaMessageDto implements AriaMessageDto {
  const _AriaMessageDto({required this.id, required this.text, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'action') this.action = 'chat', @JsonKey(name: 'action_label') this.actionLabel, @JsonKey(name: 'tone') this.tone = 'gentle'});
  factory _AriaMessageDto.fromJson(Map<String, dynamic> json) => _$AriaMessageDtoFromJson(json);

@override final  String id;
@override final  String text;
@override@JsonKey(name: 'created_at') final  String createdAt;
@override@JsonKey(name: 'action') final  String action;
@override@JsonKey(name: 'action_label') final  String? actionLabel;
@override@JsonKey(name: 'tone') final  String tone;

/// Create a copy of AriaMessageDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AriaMessageDtoCopyWith<_AriaMessageDto> get copyWith => __$AriaMessageDtoCopyWithImpl<_AriaMessageDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AriaMessageDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AriaMessageDto&&(identical(other.id, id) || other.id == id)&&(identical(other.text, text) || other.text == text)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.action, action) || other.action == action)&&(identical(other.actionLabel, actionLabel) || other.actionLabel == actionLabel)&&(identical(other.tone, tone) || other.tone == tone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,text,createdAt,action,actionLabel,tone);

@override
String toString() {
  return 'AriaMessageDto(id: $id, text: $text, createdAt: $createdAt, action: $action, actionLabel: $actionLabel, tone: $tone)';
}


}

/// @nodoc
abstract mixin class _$AriaMessageDtoCopyWith<$Res> implements $AriaMessageDtoCopyWith<$Res> {
  factory _$AriaMessageDtoCopyWith(_AriaMessageDto value, $Res Function(_AriaMessageDto) _then) = __$AriaMessageDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String text,@JsonKey(name: 'created_at') String createdAt,@JsonKey(name: 'action') String action,@JsonKey(name: 'action_label') String? actionLabel,@JsonKey(name: 'tone') String tone
});




}
/// @nodoc
class __$AriaMessageDtoCopyWithImpl<$Res>
    implements _$AriaMessageDtoCopyWith<$Res> {
  __$AriaMessageDtoCopyWithImpl(this._self, this._then);

  final _AriaMessageDto _self;
  final $Res Function(_AriaMessageDto) _then;

/// Create a copy of AriaMessageDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? text = null,Object? createdAt = null,Object? action = null,Object? actionLabel = freezed,Object? tone = null,}) {
  return _then(_AriaMessageDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as String,actionLabel: freezed == actionLabel ? _self.actionLabel : actionLabel // ignore: cast_nullable_to_non_nullable
as String?,tone: null == tone ? _self.tone : tone // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
