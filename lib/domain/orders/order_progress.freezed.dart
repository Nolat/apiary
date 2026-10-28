// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_progress.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ResourceProgress {

 Resource get resource;/// How many the order asks for.
 int get needed;/// The cells whose resource would go to the delivery: those of the
/// identical resources the board holds, at most [needed] of them.
 List<BoardPosition> get positions;
/// Create a copy of ResourceProgress
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResourceProgressCopyWith<ResourceProgress> get copyWith => _$ResourceProgressCopyWithImpl<ResourceProgress>(this as ResourceProgress, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ResourceProgress;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResourceProgress&&const DeepCollectionEquality().equals(other.resource, _this.resource)&&(identical(other.needed, _this.needed) || other.needed == _this.needed)&&const DeepCollectionEquality().equals(other.positions, _this.positions));
}


@override
int get hashCode {
  final _this = this as ResourceProgress;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.resource),_this.needed,const DeepCollectionEquality().hash(_this.positions));
}

@override
String toString() {
  final _this = this as ResourceProgress;
  return 'ResourceProgress(resource: ${_this.resource}, needed: ${_this.needed}, positions: ${_this.positions})';
}


}

/// @nodoc
abstract mixin class $ResourceProgressCopyWith<$Res>  {
  factory $ResourceProgressCopyWith(ResourceProgress value, $Res Function(ResourceProgress) _then) = _$ResourceProgressCopyWithImpl;
@useResult
$Res call({
 Resource resource, int needed, List<BoardPosition> positions
});




}
/// @nodoc
class _$ResourceProgressCopyWithImpl<$Res>
    implements $ResourceProgressCopyWith<$Res> {
  _$ResourceProgressCopyWithImpl(this._self, this._then);

  final ResourceProgress _self;
  final $Res Function(ResourceProgress) _then;

/// Create a copy of ResourceProgress
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? resource = freezed,Object? needed = null,Object? positions = null,}) {
  return _then(ResourceProgress(
resource: freezed == resource ? _self.resource : resource // ignore: cast_nullable_to_non_nullable
as Resource,needed: null == needed ? _self.needed : needed // ignore: cast_nullable_to_non_nullable
as int,positions: null == positions ? _self.positions : positions // ignore: cast_nullable_to_non_nullable
as List<BoardPosition>,
  ));
}

}


/// Adds pattern-matching-related methods to [ResourceProgress].
extension ResourceProgressPatterns on ResourceProgress {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ResourceProgress value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ResourceProgress() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ResourceProgress value)  $default,){
final _that = this;
switch (_that) {
case _ResourceProgress():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ResourceProgress value)?  $default,){
final _that = this;
switch (_that) {
case _ResourceProgress() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Resource resource,  int needed,  List<BoardPosition> positions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ResourceProgress() when $default != null:
return $default(_that.resource,_that.needed,_that.positions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Resource resource,  int needed,  List<BoardPosition> positions)  $default,) {final _that = this;
switch (_that) {
case _ResourceProgress():
return $default(_that.resource,_that.needed,_that.positions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Resource resource,  int needed,  List<BoardPosition> positions)?  $default,) {final _that = this;
switch (_that) {
case _ResourceProgress() when $default != null:
return $default(_that.resource,_that.needed,_that.positions);case _:
  return null;

}
}

}

/// @nodoc


class _ResourceProgress extends ResourceProgress {
  const _ResourceProgress({required this.resource, required this.needed, required  List<BoardPosition> positions}): assert(needed >= 1, 'an order asks for at least one'),assert(positions.length <= needed, 'no more cells than asked for'),_positions = positions,super._();
  

@override final  Resource resource;
/// How many the order asks for.
@override final  int needed;
/// The cells whose resource would go to the delivery: those of the
/// identical resources the board holds, at most [needed] of them.
 final  List<BoardPosition> _positions;
/// The cells whose resource would go to the delivery: those of the
/// identical resources the board holds, at most [needed] of them.
@override List<BoardPosition> get positions {
  if (_positions is EqualUnmodifiableListView) return _positions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_positions);
}


/// Create a copy of ResourceProgress
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ResourceProgressCopyWith<_ResourceProgress> get copyWith => __$ResourceProgressCopyWithImpl<_ResourceProgress>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ResourceProgress&&const DeepCollectionEquality().equals(other.resource, resource)&&(identical(other.needed, needed) || other.needed == needed)&&const DeepCollectionEquality().equals(other.positions, _positions));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(resource),needed,const DeepCollectionEquality().hash(_positions));
}

@override
String toString() {
    return 'ResourceProgress(resource: $resource, needed: $needed, positions: $positions)';
}


}

/// @nodoc
abstract mixin class _$ResourceProgressCopyWith<$Res> implements $ResourceProgressCopyWith<$Res> {
  factory _$ResourceProgressCopyWith(_ResourceProgress value, $Res Function(_ResourceProgress) _then) = __$ResourceProgressCopyWithImpl;
@override @useResult
$Res call({
 Resource resource, int needed, List<BoardPosition> positions
});




}
/// @nodoc
class __$ResourceProgressCopyWithImpl<$Res>
    implements _$ResourceProgressCopyWith<$Res> {
  __$ResourceProgressCopyWithImpl(this._self, this._then);

  final _ResourceProgress _self;
  final $Res Function(_ResourceProgress) _then;

/// Create a copy of ResourceProgress
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? resource = freezed,Object? needed = null,Object? positions = null,}) {
  return _then(_ResourceProgress(
resource: freezed == resource ? _self.resource : resource // ignore: cast_nullable_to_non_nullable
as Resource,needed: null == needed ? _self.needed : needed // ignore: cast_nullable_to_non_nullable
as int,positions: null == positions ? _self._positions : positions // ignore: cast_nullable_to_non_nullable
as List<BoardPosition>,
  ));
}


}

/// @nodoc
mixin _$OrderProgress {

 List<ResourceProgress> get resources;
/// Create a copy of OrderProgress
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderProgressCopyWith<OrderProgress> get copyWith => _$OrderProgressCopyWithImpl<OrderProgress>(this as OrderProgress, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as OrderProgress;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderProgress&&const DeepCollectionEquality().equals(other.resources, _this.resources));
}


@override
int get hashCode {
  final _this = this as OrderProgress;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.resources));
}

@override
String toString() {
  final _this = this as OrderProgress;
  return 'OrderProgress(resources: ${_this.resources})';
}


}

/// @nodoc
abstract mixin class $OrderProgressCopyWith<$Res>  {
  factory $OrderProgressCopyWith(OrderProgress value, $Res Function(OrderProgress) _then) = _$OrderProgressCopyWithImpl;
@useResult
$Res call({
 List<ResourceProgress> resources
});




}
/// @nodoc
class _$OrderProgressCopyWithImpl<$Res>
    implements $OrderProgressCopyWith<$Res> {
  _$OrderProgressCopyWithImpl(this._self, this._then);

  final OrderProgress _self;
  final $Res Function(OrderProgress) _then;

/// Create a copy of OrderProgress
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? resources = null,}) {
  return _then(OrderProgress(
resources: null == resources ? _self.resources : resources // ignore: cast_nullable_to_non_nullable
as List<ResourceProgress>,
  ));
}

}


/// Adds pattern-matching-related methods to [OrderProgress].
extension OrderProgressPatterns on OrderProgress {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderProgress value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderProgress() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderProgress value)  $default,){
final _that = this;
switch (_that) {
case _OrderProgress():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderProgress value)?  $default,){
final _that = this;
switch (_that) {
case _OrderProgress() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<ResourceProgress> resources)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderProgress() when $default != null:
return $default(_that.resources);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<ResourceProgress> resources)  $default,) {final _that = this;
switch (_that) {
case _OrderProgress():
return $default(_that.resources);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<ResourceProgress> resources)?  $default,) {final _that = this;
switch (_that) {
case _OrderProgress() when $default != null:
return $default(_that.resources);case _:
  return null;

}
}

}

/// @nodoc


class _OrderProgress extends OrderProgress {
  const _OrderProgress({required  List<ResourceProgress> resources}): _resources = resources,super._();
  

 final  List<ResourceProgress> _resources;
@override List<ResourceProgress> get resources {
  if (_resources is EqualUnmodifiableListView) return _resources;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_resources);
}


/// Create a copy of OrderProgress
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderProgressCopyWith<_OrderProgress> get copyWith => __$OrderProgressCopyWithImpl<_OrderProgress>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderProgress&&const DeepCollectionEquality().equals(other.resources, _resources));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_resources));
}

@override
String toString() {
    return 'OrderProgress(resources: $resources)';
}


}

/// @nodoc
abstract mixin class _$OrderProgressCopyWith<$Res> implements $OrderProgressCopyWith<$Res> {
  factory _$OrderProgressCopyWith(_OrderProgress value, $Res Function(_OrderProgress) _then) = __$OrderProgressCopyWithImpl;
@override @useResult
$Res call({
 List<ResourceProgress> resources
});




}
/// @nodoc
class __$OrderProgressCopyWithImpl<$Res>
    implements _$OrderProgressCopyWith<$Res> {
  __$OrderProgressCopyWithImpl(this._self, this._then);

  final _OrderProgress _self;
  final $Res Function(_OrderProgress) _then;

/// Create a copy of OrderProgress
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? resources = null,}) {
  return _then(_OrderProgress(
resources: null == resources ? _self._resources : resources // ignore: cast_nullable_to_non_nullable
as List<ResourceProgress>,
  ));
}


}

// dart format on
