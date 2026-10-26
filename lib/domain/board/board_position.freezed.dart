// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'board_position.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BoardPosition {

 int get column; int get row;
/// Create a copy of BoardPosition
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BoardPositionCopyWith<BoardPosition> get copyWith => _$BoardPositionCopyWithImpl<BoardPosition>(this as BoardPosition, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as BoardPosition;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BoardPosition&&(identical(other.column, _this.column) || other.column == _this.column)&&(identical(other.row, _this.row) || other.row == _this.row));
}


@override
int get hashCode {
  final _this = this as BoardPosition;
  return Object.hash(runtimeType,_this.column,_this.row);
}

@override
String toString() {
  final _this = this as BoardPosition;
  return 'BoardPosition(column: ${_this.column}, row: ${_this.row})';
}


}

/// @nodoc
abstract mixin class $BoardPositionCopyWith<$Res>  {
  factory $BoardPositionCopyWith(BoardPosition value, $Res Function(BoardPosition) _then) = _$BoardPositionCopyWithImpl;
@useResult
$Res call({
 int column, int row
});




}
/// @nodoc
class _$BoardPositionCopyWithImpl<$Res>
    implements $BoardPositionCopyWith<$Res> {
  _$BoardPositionCopyWithImpl(this._self, this._then);

  final BoardPosition _self;
  final $Res Function(BoardPosition) _then;

/// Create a copy of BoardPosition
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? column = null,Object? row = null,}) {
  return _then(BoardPosition(
column: null == column ? _self.column : column // ignore: cast_nullable_to_non_nullable
as int,row: null == row ? _self.row : row // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [BoardPosition].
extension BoardPositionPatterns on BoardPosition {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BoardPosition value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BoardPosition() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BoardPosition value)  $default,){
final _that = this;
switch (_that) {
case _BoardPosition():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BoardPosition value)?  $default,){
final _that = this;
switch (_that) {
case _BoardPosition() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int column,  int row)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BoardPosition() when $default != null:
return $default(_that.column,_that.row);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int column,  int row)  $default,) {final _that = this;
switch (_that) {
case _BoardPosition():
return $default(_that.column,_that.row);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int column,  int row)?  $default,) {final _that = this;
switch (_that) {
case _BoardPosition() when $default != null:
return $default(_that.column,_that.row);case _:
  return null;

}
}

}

/// @nodoc


class _BoardPosition extends BoardPosition {
  const _BoardPosition({required this.column, required this.row}): super._();
  

@override final  int column;
@override final  int row;

/// Create a copy of BoardPosition
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BoardPositionCopyWith<_BoardPosition> get copyWith => __$BoardPositionCopyWithImpl<_BoardPosition>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BoardPosition&&(identical(other.column, column) || other.column == column)&&(identical(other.row, row) || other.row == row));
}


@override
int get hashCode {
    return Object.hash(runtimeType,column,row);
}

@override
String toString() {
    return 'BoardPosition(column: $column, row: $row)';
}


}

/// @nodoc
abstract mixin class _$BoardPositionCopyWith<$Res> implements $BoardPositionCopyWith<$Res> {
  factory _$BoardPositionCopyWith(_BoardPosition value, $Res Function(_BoardPosition) _then) = __$BoardPositionCopyWithImpl;
@override @useResult
$Res call({
 int column, int row
});




}
/// @nodoc
class __$BoardPositionCopyWithImpl<$Res>
    implements _$BoardPositionCopyWith<$Res> {
  __$BoardPositionCopyWithImpl(this._self, this._then);

  final _BoardPosition _self;
  final $Res Function(_BoardPosition) _then;

/// Create a copy of BoardPosition
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? column = null,Object? row = null,}) {
  return _then(_BoardPosition(
column: null == column ? _self.column : column // ignore: cast_nullable_to_non_nullable
as int,row: null == row ? _self.row : row // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
