// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'board_drop.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BoardDrop {

 Board get board;
/// Create a copy of BoardDrop
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BoardDropCopyWith<BoardDrop> get copyWith => _$BoardDropCopyWithImpl<BoardDrop>(this as BoardDrop, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as BoardDrop;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BoardDrop&&(identical(other.board, _this.board) || other.board == _this.board));
}


@override
int get hashCode {
  final _this = this as BoardDrop;
  return Object.hash(runtimeType,_this.board);
}

@override
String toString() {
  final _this = this as BoardDrop;
  return 'BoardDrop(board: ${_this.board})';
}


}

/// @nodoc
abstract mixin class $BoardDropCopyWith<$Res>  {
  factory $BoardDropCopyWith(BoardDrop value, $Res Function(BoardDrop) _then) = _$BoardDropCopyWithImpl;
@useResult
$Res call({
 Board board
});


$BoardCopyWith<$Res> get board;

}
/// @nodoc
class _$BoardDropCopyWithImpl<$Res>
    implements $BoardDropCopyWith<$Res> {
  _$BoardDropCopyWithImpl(this._self, this._then);

  final BoardDrop _self;
  final $Res Function(BoardDrop) _then;

/// Create a copy of BoardDrop
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? board = null,}) {
  return _then(_self.copyWith(
board: null == board ? _self.board : board // ignore: cast_nullable_to_non_nullable
as Board,
  ));
}
/// Create a copy of BoardDrop
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BoardCopyWith<$Res> get board {
  
  return $BoardCopyWith<$Res>(_self.board, (value) {
    return _then(_self.copyWith(board: value));
  });
}
}


/// Adds pattern-matching-related methods to [BoardDrop].
extension BoardDropPatterns on BoardDrop {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ItemMoved value)?  moved,TResult Function( ItemsSwapped value)?  swapped,TResult Function( BeeHoused value)?  housed,TResult Function( ItemsMerged value)?  merged,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ItemMoved() when moved != null:
return moved(_that);case ItemsSwapped() when swapped != null:
return swapped(_that);case BeeHoused() when housed != null:
return housed(_that);case ItemsMerged() when merged != null:
return merged(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ItemMoved value)  moved,required TResult Function( ItemsSwapped value)  swapped,required TResult Function( BeeHoused value)  housed,required TResult Function( ItemsMerged value)  merged,}){
final _that = this;
switch (_that) {
case ItemMoved():
return moved(_that);case ItemsSwapped():
return swapped(_that);case BeeHoused():
return housed(_that);case ItemsMerged():
return merged(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ItemMoved value)?  moved,TResult? Function( ItemsSwapped value)?  swapped,TResult? Function( BeeHoused value)?  housed,TResult? Function( ItemsMerged value)?  merged,}){
final _that = this;
switch (_that) {
case ItemMoved() when moved != null:
return moved(_that);case ItemsSwapped() when swapped != null:
return swapped(_that);case BeeHoused() when housed != null:
return housed(_that);case ItemsMerged() when merged != null:
return merged(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( Board board)?  moved,TResult Function( Board board)?  swapped,TResult Function( Board board)?  housed,TResult Function( Board board)?  merged,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ItemMoved() when moved != null:
return moved(_that.board);case ItemsSwapped() when swapped != null:
return swapped(_that.board);case BeeHoused() when housed != null:
return housed(_that.board);case ItemsMerged() when merged != null:
return merged(_that.board);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( Board board)  moved,required TResult Function( Board board)  swapped,required TResult Function( Board board)  housed,required TResult Function( Board board)  merged,}) {final _that = this;
switch (_that) {
case ItemMoved():
return moved(_that.board);case ItemsSwapped():
return swapped(_that.board);case BeeHoused():
return housed(_that.board);case ItemsMerged():
return merged(_that.board);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( Board board)?  moved,TResult? Function( Board board)?  swapped,TResult? Function( Board board)?  housed,TResult? Function( Board board)?  merged,}) {final _that = this;
switch (_that) {
case ItemMoved() when moved != null:
return moved(_that.board);case ItemsSwapped() when swapped != null:
return swapped(_that.board);case BeeHoused() when housed != null:
return housed(_that.board);case ItemsMerged() when merged != null:
return merged(_that.board);case _:
  return null;

}
}

}

/// @nodoc


class ItemMoved implements BoardDrop {
  const ItemMoved({required this.board});
  

@override final  Board board;

/// Create a copy of BoardDrop
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ItemMovedCopyWith<ItemMoved> get copyWith => _$ItemMovedCopyWithImpl<ItemMoved>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ItemMoved&&(identical(other.board, board) || other.board == board));
}


@override
int get hashCode {
    return Object.hash(runtimeType,board);
}

@override
String toString() {
    return 'BoardDrop.moved(board: $board)';
}


}

/// @nodoc
abstract mixin class $ItemMovedCopyWith<$Res> implements $BoardDropCopyWith<$Res> {
  factory $ItemMovedCopyWith(ItemMoved value, $Res Function(ItemMoved) _then) = _$ItemMovedCopyWithImpl;
@override @useResult
$Res call({
 Board board
});


@override $BoardCopyWith<$Res> get board;

}
/// @nodoc
class _$ItemMovedCopyWithImpl<$Res>
    implements $ItemMovedCopyWith<$Res> {
  _$ItemMovedCopyWithImpl(this._self, this._then);

  final ItemMoved _self;
  final $Res Function(ItemMoved) _then;

/// Create a copy of BoardDrop
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? board = null,}) {
  return _then(ItemMoved(
board: null == board ? _self.board : board // ignore: cast_nullable_to_non_nullable
as Board,
  ));
}

/// Create a copy of BoardDrop
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BoardCopyWith<$Res> get board {
  
  return $BoardCopyWith<$Res>(_self.board, (value) {
    return _then(_self.copyWith(board: value));
  });
}
}

/// @nodoc


class ItemsSwapped implements BoardDrop {
  const ItemsSwapped({required this.board});
  

@override final  Board board;

/// Create a copy of BoardDrop
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ItemsSwappedCopyWith<ItemsSwapped> get copyWith => _$ItemsSwappedCopyWithImpl<ItemsSwapped>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ItemsSwapped&&(identical(other.board, board) || other.board == board));
}


@override
int get hashCode {
    return Object.hash(runtimeType,board);
}

@override
String toString() {
    return 'BoardDrop.swapped(board: $board)';
}


}

/// @nodoc
abstract mixin class $ItemsSwappedCopyWith<$Res> implements $BoardDropCopyWith<$Res> {
  factory $ItemsSwappedCopyWith(ItemsSwapped value, $Res Function(ItemsSwapped) _then) = _$ItemsSwappedCopyWithImpl;
@override @useResult
$Res call({
 Board board
});


@override $BoardCopyWith<$Res> get board;

}
/// @nodoc
class _$ItemsSwappedCopyWithImpl<$Res>
    implements $ItemsSwappedCopyWith<$Res> {
  _$ItemsSwappedCopyWithImpl(this._self, this._then);

  final ItemsSwapped _self;
  final $Res Function(ItemsSwapped) _then;

/// Create a copy of BoardDrop
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? board = null,}) {
  return _then(ItemsSwapped(
board: null == board ? _self.board : board // ignore: cast_nullable_to_non_nullable
as Board,
  ));
}

/// Create a copy of BoardDrop
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BoardCopyWith<$Res> get board {
  
  return $BoardCopyWith<$Res>(_self.board, (value) {
    return _then(_self.copyWith(board: value));
  });
}
}

/// @nodoc


class BeeHoused implements BoardDrop {
  const BeeHoused({required this.board});
  

@override final  Board board;

/// Create a copy of BoardDrop
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BeeHousedCopyWith<BeeHoused> get copyWith => _$BeeHousedCopyWithImpl<BeeHoused>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is BeeHoused&&(identical(other.board, board) || other.board == board));
}


@override
int get hashCode {
    return Object.hash(runtimeType,board);
}

@override
String toString() {
    return 'BoardDrop.housed(board: $board)';
}


}

/// @nodoc
abstract mixin class $BeeHousedCopyWith<$Res> implements $BoardDropCopyWith<$Res> {
  factory $BeeHousedCopyWith(BeeHoused value, $Res Function(BeeHoused) _then) = _$BeeHousedCopyWithImpl;
@override @useResult
$Res call({
 Board board
});


@override $BoardCopyWith<$Res> get board;

}
/// @nodoc
class _$BeeHousedCopyWithImpl<$Res>
    implements $BeeHousedCopyWith<$Res> {
  _$BeeHousedCopyWithImpl(this._self, this._then);

  final BeeHoused _self;
  final $Res Function(BeeHoused) _then;

/// Create a copy of BoardDrop
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? board = null,}) {
  return _then(BeeHoused(
board: null == board ? _self.board : board // ignore: cast_nullable_to_non_nullable
as Board,
  ));
}

/// Create a copy of BoardDrop
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BoardCopyWith<$Res> get board {
  
  return $BoardCopyWith<$Res>(_self.board, (value) {
    return _then(_self.copyWith(board: value));
  });
}
}

/// @nodoc


class ItemsMerged implements BoardDrop {
  const ItemsMerged({required this.board});
  

@override final  Board board;

/// Create a copy of BoardDrop
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ItemsMergedCopyWith<ItemsMerged> get copyWith => _$ItemsMergedCopyWithImpl<ItemsMerged>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ItemsMerged&&(identical(other.board, board) || other.board == board));
}


@override
int get hashCode {
    return Object.hash(runtimeType,board);
}

@override
String toString() {
    return 'BoardDrop.merged(board: $board)';
}


}

/// @nodoc
abstract mixin class $ItemsMergedCopyWith<$Res> implements $BoardDropCopyWith<$Res> {
  factory $ItemsMergedCopyWith(ItemsMerged value, $Res Function(ItemsMerged) _then) = _$ItemsMergedCopyWithImpl;
@override @useResult
$Res call({
 Board board
});


@override $BoardCopyWith<$Res> get board;

}
/// @nodoc
class _$ItemsMergedCopyWithImpl<$Res>
    implements $ItemsMergedCopyWith<$Res> {
  _$ItemsMergedCopyWithImpl(this._self, this._then);

  final ItemsMerged _self;
  final $Res Function(ItemsMerged) _then;

/// Create a copy of BoardDrop
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? board = null,}) {
  return _then(ItemsMerged(
board: null == board ? _self.board : board // ignore: cast_nullable_to_non_nullable
as Board,
  ));
}

/// Create a copy of BoardDrop
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BoardCopyWith<$Res> get board {
  
  return $BoardCopyWith<$Res>(_self.board, (value) {
    return _then(_self.copyWith(board: value));
  });
}
}

// dart format on
