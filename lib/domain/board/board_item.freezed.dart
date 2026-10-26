// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'board_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BoardItem {

 Family get family;
/// Create a copy of BoardItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BoardItemCopyWith<BoardItem> get copyWith => _$BoardItemCopyWithImpl<BoardItem>(this as BoardItem, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as BoardItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BoardItem&&(identical(other.family, _this.family) || other.family == _this.family));
}


@override
int get hashCode {
  final _this = this as BoardItem;
  return Object.hash(runtimeType,_this.family);
}

@override
String toString() {
  final _this = this as BoardItem;
  return 'BoardItem(family: ${_this.family})';
}


}

/// @nodoc
abstract mixin class $BoardItemCopyWith<$Res>  {
  factory $BoardItemCopyWith(BoardItem value, $Res Function(BoardItem) _then) = _$BoardItemCopyWithImpl;
@useResult
$Res call({
 Family family
});




}
/// @nodoc
class _$BoardItemCopyWithImpl<$Res>
    implements $BoardItemCopyWith<$Res> {
  _$BoardItemCopyWithImpl(this._self, this._then);

  final BoardItem _self;
  final $Res Function(BoardItem) _then;

/// Create a copy of BoardItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? family = null,}) {
  return _then(BoardItem.queen(
family: null == family ? _self.family : family // ignore: cast_nullable_to_non_nullable
as Family,
  ));
}

}


/// Adds pattern-matching-related methods to [BoardItem].
extension BoardItemPatterns on BoardItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( Queen value)?  queen,required TResult orElse(),}){
final _that = this;
switch (_that) {
case Queen() when queen != null:
return queen(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( Queen value)  queen,}){
final _that = this;
switch (_that) {
case Queen():
return queen(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( Queen value)?  queen,}){
final _that = this;
switch (_that) {
case Queen() when queen != null:
return queen(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( Family family)?  queen,required TResult orElse(),}) {final _that = this;
switch (_that) {
case Queen() when queen != null:
return queen(_that.family);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( Family family)  queen,}) {final _that = this;
switch (_that) {
case Queen():
return queen(_that.family);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( Family family)?  queen,}) {final _that = this;
switch (_that) {
case Queen() when queen != null:
return queen(_that.family);case _:
  return null;

}
}

}

/// @nodoc


class Queen implements BoardItem {
  const Queen({required this.family});
  

@override final  Family family;

/// Create a copy of BoardItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QueenCopyWith<Queen> get copyWith => _$QueenCopyWithImpl<Queen>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Queen&&(identical(other.family, family) || other.family == family));
}


@override
int get hashCode {
    return Object.hash(runtimeType,family);
}

@override
String toString() {
    return 'BoardItem.queen(family: $family)';
}


}

/// @nodoc
abstract mixin class $QueenCopyWith<$Res> implements $BoardItemCopyWith<$Res> {
  factory $QueenCopyWith(Queen value, $Res Function(Queen) _then) = _$QueenCopyWithImpl;
@override @useResult
$Res call({
 Family family
});




}
/// @nodoc
class _$QueenCopyWithImpl<$Res>
    implements $QueenCopyWith<$Res> {
  _$QueenCopyWithImpl(this._self, this._then);

  final Queen _self;
  final $Res Function(Queen) _then;

/// Create a copy of BoardItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? family = null,}) {
  return _then(Queen(
family: null == family ? _self.family : family // ignore: cast_nullable_to_non_nullable
as Family,
  ));
}


}

// dart format on
