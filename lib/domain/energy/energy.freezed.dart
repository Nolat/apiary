// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'energy.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Energy {

 int get value;/// The trusted instant the next unit is counted from; `null` while the
/// gauge is full, or while no trusted time has been known since it left
/// full (the count then starts at the next [recharged]).
 DateTime? get countedFrom;
/// Create a copy of Energy
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EnergyCopyWith<Energy> get copyWith => _$EnergyCopyWithImpl<Energy>(this as Energy, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Energy;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Energy&&(identical(other.value, _this.value) || other.value == _this.value)&&(identical(other.countedFrom, _this.countedFrom) || other.countedFrom == _this.countedFrom));
}


@override
int get hashCode {
  final _this = this as Energy;
  return Object.hash(runtimeType,_this.value,_this.countedFrom);
}

@override
String toString() {
  final _this = this as Energy;
  return 'Energy(value: ${_this.value}, countedFrom: ${_this.countedFrom})';
}


}

/// @nodoc
abstract mixin class $EnergyCopyWith<$Res>  {
  factory $EnergyCopyWith(Energy value, $Res Function(Energy) _then) = _$EnergyCopyWithImpl;
@useResult
$Res call({
 int value, DateTime? countedFrom
});




}
/// @nodoc
class _$EnergyCopyWithImpl<$Res>
    implements $EnergyCopyWith<$Res> {
  _$EnergyCopyWithImpl(this._self, this._then);

  final Energy _self;
  final $Res Function(Energy) _then;

/// Create a copy of Energy
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? value = null,Object? countedFrom = freezed,}) {
  return _then(Energy(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as int,countedFrom: freezed == countedFrom ? _self.countedFrom : countedFrom // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Energy].
extension EnergyPatterns on Energy {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Energy value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Energy() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Energy value)  $default,){
final _that = this;
switch (_that) {
case _Energy():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Energy value)?  $default,){
final _that = this;
switch (_that) {
case _Energy() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int value,  DateTime? countedFrom)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Energy() when $default != null:
return $default(_that.value,_that.countedFrom);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int value,  DateTime? countedFrom)  $default,) {final _that = this;
switch (_that) {
case _Energy():
return $default(_that.value,_that.countedFrom);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int value,  DateTime? countedFrom)?  $default,) {final _that = this;
switch (_that) {
case _Energy() when $default != null:
return $default(_that.value,_that.countedFrom);case _:
  return null;

}
}

}

/// @nodoc


class _Energy extends Energy {
  const _Energy({required this.value, this.countedFrom}): super._();
  

@override final  int value;
/// The trusted instant the next unit is counted from; `null` while the
/// gauge is full, or while no trusted time has been known since it left
/// full (the count then starts at the next [recharged]).
@override final  DateTime? countedFrom;

/// Create a copy of Energy
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EnergyCopyWith<_Energy> get copyWith => __$EnergyCopyWithImpl<_Energy>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Energy&&(identical(other.value, value) || other.value == value)&&(identical(other.countedFrom, countedFrom) || other.countedFrom == countedFrom));
}


@override
int get hashCode {
    return Object.hash(runtimeType,value,countedFrom);
}

@override
String toString() {
    return 'Energy(value: $value, countedFrom: $countedFrom)';
}


}

/// @nodoc
abstract mixin class _$EnergyCopyWith<$Res> implements $EnergyCopyWith<$Res> {
  factory _$EnergyCopyWith(_Energy value, $Res Function(_Energy) _then) = __$EnergyCopyWithImpl;
@override @useResult
$Res call({
 int value, DateTime? countedFrom
});




}
/// @nodoc
class __$EnergyCopyWithImpl<$Res>
    implements _$EnergyCopyWith<$Res> {
  __$EnergyCopyWithImpl(this._self, this._then);

  final _Energy _self;
  final $Res Function(_Energy) _then;

/// Create a copy of Energy
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? value = null,Object? countedFrom = freezed,}) {
  return _then(_Energy(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as int,countedFrom: freezed == countedFrom ? _self.countedFrom : countedFrom // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
