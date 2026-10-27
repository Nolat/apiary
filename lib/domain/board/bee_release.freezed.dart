// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bee_release.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BeeRelease {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is BeeRelease);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'BeeRelease()';
}


}

/// @nodoc
class $BeeReleaseCopyWith<$Res>  {
$BeeReleaseCopyWith(BeeRelease _, $Res Function(BeeRelease) __);
}


/// Adds pattern-matching-related methods to [BeeRelease].
extension BeeReleasePatterns on BeeRelease {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( BeeReleased value)?  released,TResult Function( BeeReleaseBoardFull value)?  boardFull,required TResult orElse(),}){
final _that = this;
switch (_that) {
case BeeReleased() when released != null:
return released(_that);case BeeReleaseBoardFull() when boardFull != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( BeeReleased value)  released,required TResult Function( BeeReleaseBoardFull value)  boardFull,}){
final _that = this;
switch (_that) {
case BeeReleased():
return released(_that);case BeeReleaseBoardFull():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( BeeReleased value)?  released,TResult? Function( BeeReleaseBoardFull value)?  boardFull,}){
final _that = this;
switch (_that) {
case BeeReleased() when released != null:
return released(_that);case BeeReleaseBoardFull() when boardFull != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( Board board,  BoardPosition position)?  released,TResult Function()?  boardFull,required TResult orElse(),}) {final _that = this;
switch (_that) {
case BeeReleased() when released != null:
return released(_that.board,_that.position);case BeeReleaseBoardFull() when boardFull != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( Board board,  BoardPosition position)  released,required TResult Function()  boardFull,}) {final _that = this;
switch (_that) {
case BeeReleased():
return released(_that.board,_that.position);case BeeReleaseBoardFull():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( Board board,  BoardPosition position)?  released,TResult? Function()?  boardFull,}) {final _that = this;
switch (_that) {
case BeeReleased() when released != null:
return released(_that.board,_that.position);case BeeReleaseBoardFull() when boardFull != null:
return boardFull();case _:
  return null;

}
}

}

/// @nodoc


class BeeReleased implements BeeRelease {
  const BeeReleased({required this.board, required this.position});
  

 final  Board board;
 final  BoardPosition position;

/// Create a copy of BeeRelease
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BeeReleasedCopyWith<BeeReleased> get copyWith => _$BeeReleasedCopyWithImpl<BeeReleased>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is BeeReleased&&(identical(other.board, board) || other.board == board)&&(identical(other.position, position) || other.position == position));
}


@override
int get hashCode {
    return Object.hash(runtimeType,board,position);
}

@override
String toString() {
    return 'BeeRelease.released(board: $board, position: $position)';
}


}

/// @nodoc
abstract mixin class $BeeReleasedCopyWith<$Res> implements $BeeReleaseCopyWith<$Res> {
  factory $BeeReleasedCopyWith(BeeReleased value, $Res Function(BeeReleased) _then) = _$BeeReleasedCopyWithImpl;
@useResult
$Res call({
 Board board, BoardPosition position
});


$BoardCopyWith<$Res> get board;$BoardPositionCopyWith<$Res> get position;

}
/// @nodoc
class _$BeeReleasedCopyWithImpl<$Res>
    implements $BeeReleasedCopyWith<$Res> {
  _$BeeReleasedCopyWithImpl(this._self, this._then);

  final BeeReleased _self;
  final $Res Function(BeeReleased) _then;

/// Create a copy of BeeRelease
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? board = null,Object? position = null,}) {
  return _then(BeeReleased(
board: null == board ? _self.board : board // ignore: cast_nullable_to_non_nullable
as Board,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as BoardPosition,
  ));
}

/// Create a copy of BeeRelease
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BoardCopyWith<$Res> get board {
  
  return $BoardCopyWith<$Res>(_self.board, (value) {
    return _then(_self.copyWith(board: value));
  });
}/// Create a copy of BeeRelease
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


class BeeReleaseBoardFull implements BeeRelease {
  const BeeReleaseBoardFull();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is BeeReleaseBoardFull);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'BeeRelease.boardFull()';
}


}




// dart format on
