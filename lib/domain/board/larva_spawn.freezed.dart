// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'larva_spawn.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LarvaSpawn {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is LarvaSpawn);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'LarvaSpawn()';
}


}

/// @nodoc
class $LarvaSpawnCopyWith<$Res>  {
$LarvaSpawnCopyWith(LarvaSpawn _, $Res Function(LarvaSpawn) __);
}


/// Adds pattern-matching-related methods to [LarvaSpawn].
extension LarvaSpawnPatterns on LarvaSpawn {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( LarvaCreated value)?  created,TResult Function( BoardFull value)?  boardFull,required TResult orElse(),}){
final _that = this;
switch (_that) {
case LarvaCreated() when created != null:
return created(_that);case BoardFull() when boardFull != null:
return boardFull(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( LarvaCreated value)  created,required TResult Function( BoardFull value)  boardFull,}){
final _that = this;
switch (_that) {
case LarvaCreated():
return created(_that);case BoardFull():
return boardFull(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( LarvaCreated value)?  created,TResult? Function( BoardFull value)?  boardFull,}){
final _that = this;
switch (_that) {
case LarvaCreated() when created != null:
return created(_that);case BoardFull() when boardFull != null:
return boardFull(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( Board board,  BoardPosition position)?  created,TResult Function()?  boardFull,required TResult orElse(),}) {final _that = this;
switch (_that) {
case LarvaCreated() when created != null:
return created(_that.board,_that.position);case BoardFull() when boardFull != null:
return boardFull();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( Board board,  BoardPosition position)  created,required TResult Function()  boardFull,}) {final _that = this;
switch (_that) {
case LarvaCreated():
return created(_that.board,_that.position);case BoardFull():
return boardFull();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( Board board,  BoardPosition position)?  created,TResult? Function()?  boardFull,}) {final _that = this;
switch (_that) {
case LarvaCreated() when created != null:
return created(_that.board,_that.position);case BoardFull() when boardFull != null:
return boardFull();case _:
  return null;

}
}

}

/// @nodoc


class LarvaCreated implements LarvaSpawn {
  const LarvaCreated({required this.board, required this.position});
  

 final  Board board;
 final  BoardPosition position;

/// Create a copy of LarvaSpawn
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LarvaCreatedCopyWith<LarvaCreated> get copyWith => _$LarvaCreatedCopyWithImpl<LarvaCreated>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is LarvaCreated&&(identical(other.board, board) || other.board == board)&&(identical(other.position, position) || other.position == position));
}


@override
int get hashCode {
    return Object.hash(runtimeType,board,position);
}

@override
String toString() {
    return 'LarvaSpawn.created(board: $board, position: $position)';
}


}

/// @nodoc
abstract mixin class $LarvaCreatedCopyWith<$Res> implements $LarvaSpawnCopyWith<$Res> {
  factory $LarvaCreatedCopyWith(LarvaCreated value, $Res Function(LarvaCreated) _then) = _$LarvaCreatedCopyWithImpl;
@useResult
$Res call({
 Board board, BoardPosition position
});


$BoardCopyWith<$Res> get board;$BoardPositionCopyWith<$Res> get position;

}
/// @nodoc
class _$LarvaCreatedCopyWithImpl<$Res>
    implements $LarvaCreatedCopyWith<$Res> {
  _$LarvaCreatedCopyWithImpl(this._self, this._then);

  final LarvaCreated _self;
  final $Res Function(LarvaCreated) _then;

/// Create a copy of LarvaSpawn
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? board = null,Object? position = null,}) {
  return _then(LarvaCreated(
board: null == board ? _self.board : board // ignore: cast_nullable_to_non_nullable
as Board,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as BoardPosition,
  ));
}

/// Create a copy of LarvaSpawn
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BoardCopyWith<$Res> get board {
  
  return $BoardCopyWith<$Res>(_self.board, (value) {
    return _then(_self.copyWith(board: value));
  });
}/// Create a copy of LarvaSpawn
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BoardPositionCopyWith<$Res> get position {
  
  return $BoardPositionCopyWith<$Res>(_self.position, (value) {
    return _then(_self.copyWith(position: value));
  });
}
}

/// @nodoc


class BoardFull implements LarvaSpawn {
  const BoardFull();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is BoardFull);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'LarvaSpawn.boardFull()';
}


}




// dart format on
