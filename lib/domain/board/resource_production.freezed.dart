// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'resource_production.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ResourceProduction {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ResourceProduction);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ResourceProduction()';
}


}

/// @nodoc
class $ResourceProductionCopyWith<$Res>  {
$ResourceProductionCopyWith(ResourceProduction _, $Res Function(ResourceProduction) __);
}


/// Adds pattern-matching-related methods to [ResourceProduction].
extension ResourceProductionPatterns on ResourceProduction {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ResourceCreated value)?  created,TResult Function( ResourceBoardFull value)?  boardFull,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ResourceCreated() when created != null:
return created(_that);case ResourceBoardFull() when boardFull != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ResourceCreated value)  created,required TResult Function( ResourceBoardFull value)  boardFull,}){
final _that = this;
switch (_that) {
case ResourceCreated():
return created(_that);case ResourceBoardFull():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ResourceCreated value)?  created,TResult? Function( ResourceBoardFull value)?  boardFull,}){
final _that = this;
switch (_that) {
case ResourceCreated() when created != null:
return created(_that);case ResourceBoardFull() when boardFull != null:
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
case ResourceCreated() when created != null:
return created(_that.board,_that.position);case ResourceBoardFull() when boardFull != null:
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
case ResourceCreated():
return created(_that.board,_that.position);case ResourceBoardFull():
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
case ResourceCreated() when created != null:
return created(_that.board,_that.position);case ResourceBoardFull() when boardFull != null:
return boardFull();case _:
  return null;

}
}

}

/// @nodoc


class ResourceCreated implements ResourceProduction {
  const ResourceCreated({required this.board, required this.position});
  

 final  Board board;
 final  BoardPosition position;

/// Create a copy of ResourceProduction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResourceCreatedCopyWith<ResourceCreated> get copyWith => _$ResourceCreatedCopyWithImpl<ResourceCreated>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ResourceCreated&&(identical(other.board, board) || other.board == board)&&(identical(other.position, position) || other.position == position));
}


@override
int get hashCode {
    return Object.hash(runtimeType,board,position);
}

@override
String toString() {
    return 'ResourceProduction.created(board: $board, position: $position)';
}


}

/// @nodoc
abstract mixin class $ResourceCreatedCopyWith<$Res> implements $ResourceProductionCopyWith<$Res> {
  factory $ResourceCreatedCopyWith(ResourceCreated value, $Res Function(ResourceCreated) _then) = _$ResourceCreatedCopyWithImpl;
@useResult
$Res call({
 Board board, BoardPosition position
});


$BoardCopyWith<$Res> get board;$BoardPositionCopyWith<$Res> get position;

}
/// @nodoc
class _$ResourceCreatedCopyWithImpl<$Res>
    implements $ResourceCreatedCopyWith<$Res> {
  _$ResourceCreatedCopyWithImpl(this._self, this._then);

  final ResourceCreated _self;
  final $Res Function(ResourceCreated) _then;

/// Create a copy of ResourceProduction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? board = null,Object? position = null,}) {
  return _then(ResourceCreated(
board: null == board ? _self.board : board // ignore: cast_nullable_to_non_nullable
as Board,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as BoardPosition,
  ));
}

/// Create a copy of ResourceProduction
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BoardCopyWith<$Res> get board {
  
  return $BoardCopyWith<$Res>(_self.board, (value) {
    return _then(_self.copyWith(board: value));
  });
}/// Create a copy of ResourceProduction
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


class ResourceBoardFull implements ResourceProduction {
  const ResourceBoardFull();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ResourceBoardFull);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ResourceProduction.boardFull()';
}


}




// dart format on
