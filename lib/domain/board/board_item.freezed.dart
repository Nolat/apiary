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





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is BoardItem);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'BoardItem()';
}


}

/// @nodoc
class $BoardItemCopyWith<$Res>  {
$BoardItemCopyWith(BoardItem _, $Res Function(BoardItem) __);
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( Queen value)?  queen,TResult Function( Larva value)?  larva,TResult Function( Bee value)?  bee,TResult Function( Hive value)?  hive,TResult Function( Resource value)?  resource,required TResult orElse(),}){
final _that = this;
switch (_that) {
case Queen() when queen != null:
return queen(_that);case Larva() when larva != null:
return larva(_that);case Bee() when bee != null:
return bee(_that);case Hive() when hive != null:
return hive(_that);case Resource() when resource != null:
return resource(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( Queen value)  queen,required TResult Function( Larva value)  larva,required TResult Function( Bee value)  bee,required TResult Function( Hive value)  hive,required TResult Function( Resource value)  resource,}){
final _that = this;
switch (_that) {
case Queen():
return queen(_that);case Larva():
return larva(_that);case Bee():
return bee(_that);case Hive():
return hive(_that);case Resource():
return resource(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( Queen value)?  queen,TResult? Function( Larva value)?  larva,TResult? Function( Bee value)?  bee,TResult? Function( Hive value)?  hive,TResult? Function( Resource value)?  resource,}){
final _that = this;
switch (_that) {
case Queen() when queen != null:
return queen(_that);case Larva() when larva != null:
return larva(_that);case Bee() when bee != null:
return bee(_that);case Hive() when hive != null:
return hive(_that);case Resource() when resource != null:
return resource(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( Family family)?  queen,TResult Function( Family family)?  larva,TResult Function( Family family,  int level)?  bee,TResult Function( Bee? bee,  int remainingLife)?  hive,TResult Function( ResourceBranch branch,  int tier)?  resource,required TResult orElse(),}) {final _that = this;
switch (_that) {
case Queen() when queen != null:
return queen(_that.family);case Larva() when larva != null:
return larva(_that.family);case Bee() when bee != null:
return bee(_that.family,_that.level);case Hive() when hive != null:
return hive(_that.bee,_that.remainingLife);case Resource() when resource != null:
return resource(_that.branch,_that.tier);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( Family family)  queen,required TResult Function( Family family)  larva,required TResult Function( Family family,  int level)  bee,required TResult Function( Bee? bee,  int remainingLife)  hive,required TResult Function( ResourceBranch branch,  int tier)  resource,}) {final _that = this;
switch (_that) {
case Queen():
return queen(_that.family);case Larva():
return larva(_that.family);case Bee():
return bee(_that.family,_that.level);case Hive():
return hive(_that.bee,_that.remainingLife);case Resource():
return resource(_that.branch,_that.tier);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( Family family)?  queen,TResult? Function( Family family)?  larva,TResult? Function( Family family,  int level)?  bee,TResult? Function( Bee? bee,  int remainingLife)?  hive,TResult? Function( ResourceBranch branch,  int tier)?  resource,}) {final _that = this;
switch (_that) {
case Queen() when queen != null:
return queen(_that.family);case Larva() when larva != null:
return larva(_that.family);case Bee() when bee != null:
return bee(_that.family,_that.level);case Hive() when hive != null:
return hive(_that.bee,_that.remainingLife);case Resource() when resource != null:
return resource(_that.branch,_that.tier);case _:
  return null;

}
}

}

/// @nodoc


class Queen implements BoardItem {
  const Queen({required this.family});
  

 final  Family family;

/// Create a copy of BoardItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
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
@useResult
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
@pragma('vm:prefer-inline') $Res call({Object? family = null,}) {
  return _then(Queen(
family: null == family ? _self.family : family // ignore: cast_nullable_to_non_nullable
as Family,
  ));
}


}

/// @nodoc


class Larva implements BoardItem {
  const Larva({required this.family});
  

 final  Family family;

/// Create a copy of BoardItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LarvaCopyWith<Larva> get copyWith => _$LarvaCopyWithImpl<Larva>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Larva&&(identical(other.family, family) || other.family == family));
}


@override
int get hashCode {
    return Object.hash(runtimeType,family);
}

@override
String toString() {
    return 'BoardItem.larva(family: $family)';
}


}

/// @nodoc
abstract mixin class $LarvaCopyWith<$Res> implements $BoardItemCopyWith<$Res> {
  factory $LarvaCopyWith(Larva value, $Res Function(Larva) _then) = _$LarvaCopyWithImpl;
@useResult
$Res call({
 Family family
});




}
/// @nodoc
class _$LarvaCopyWithImpl<$Res>
    implements $LarvaCopyWith<$Res> {
  _$LarvaCopyWithImpl(this._self, this._then);

  final Larva _self;
  final $Res Function(Larva) _then;

/// Create a copy of BoardItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? family = null,}) {
  return _then(Larva(
family: null == family ? _self.family : family // ignore: cast_nullable_to_non_nullable
as Family,
  ));
}


}

/// @nodoc


class Bee implements BoardItem {
  const Bee({required this.family, this.level = 1}): assert(level >= 1, 'level must be at least 1');
  

 final  Family family;
@JsonKey() final  int level;

/// Create a copy of BoardItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BeeCopyWith<Bee> get copyWith => _$BeeCopyWithImpl<Bee>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Bee&&(identical(other.family, family) || other.family == family)&&(identical(other.level, level) || other.level == level));
}


@override
int get hashCode {
    return Object.hash(runtimeType,family,level);
}

@override
String toString() {
    return 'BoardItem.bee(family: $family, level: $level)';
}


}

/// @nodoc
abstract mixin class $BeeCopyWith<$Res> implements $BoardItemCopyWith<$Res> {
  factory $BeeCopyWith(Bee value, $Res Function(Bee) _then) = _$BeeCopyWithImpl;
@useResult
$Res call({
 Family family, int level
});




}
/// @nodoc
class _$BeeCopyWithImpl<$Res>
    implements $BeeCopyWith<$Res> {
  _$BeeCopyWithImpl(this._self, this._then);

  final Bee _self;
  final $Res Function(Bee) _then;

/// Create a copy of BoardItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? family = null,Object? level = null,}) {
  return _then(Bee(
family: null == family ? _self.family : family // ignore: cast_nullable_to_non_nullable
as Family,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class Hive implements BoardItem {
  const Hive({this.bee, this.remainingLife = BeeLifespan.provisional}): assert(remainingLife >= 1, 'remainingLife must be at least 1'),assert(bee != null || remainingLife == BeeLifespan.provisional, 'an empty hive keeps the default remainingLife');
  

 final  Bee? bee;
@JsonKey() final  int remainingLife;

/// Create a copy of BoardItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HiveCopyWith<Hive> get copyWith => _$HiveCopyWithImpl<Hive>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Hive&&const DeepCollectionEquality().equals(other.bee, bee)&&(identical(other.remainingLife, remainingLife) || other.remainingLife == remainingLife));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(bee),remainingLife);
}

@override
String toString() {
    return 'BoardItem.hive(bee: $bee, remainingLife: $remainingLife)';
}


}

/// @nodoc
abstract mixin class $HiveCopyWith<$Res> implements $BoardItemCopyWith<$Res> {
  factory $HiveCopyWith(Hive value, $Res Function(Hive) _then) = _$HiveCopyWithImpl;
@useResult
$Res call({
 Bee? bee, int remainingLife
});




}
/// @nodoc
class _$HiveCopyWithImpl<$Res>
    implements $HiveCopyWith<$Res> {
  _$HiveCopyWithImpl(this._self, this._then);

  final Hive _self;
  final $Res Function(Hive) _then;

/// Create a copy of BoardItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? bee = freezed,Object? remainingLife = null,}) {
  return _then(Hive(
bee: freezed == bee ? _self.bee : bee // ignore: cast_nullable_to_non_nullable
as Bee?,remainingLife: null == remainingLife ? _self.remainingLife : remainingLife // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class Resource implements BoardItem {
  const Resource({required this.branch, this.tier = 1}): assert(tier >= 1, 'tier must be at least 1');
  

 final  ResourceBranch branch;
@JsonKey() final  int tier;

/// Create a copy of BoardItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResourceCopyWith<Resource> get copyWith => _$ResourceCopyWithImpl<Resource>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Resource&&(identical(other.branch, branch) || other.branch == branch)&&(identical(other.tier, tier) || other.tier == tier));
}


@override
int get hashCode {
    return Object.hash(runtimeType,branch,tier);
}

@override
String toString() {
    return 'BoardItem.resource(branch: $branch, tier: $tier)';
}


}

/// @nodoc
abstract mixin class $ResourceCopyWith<$Res> implements $BoardItemCopyWith<$Res> {
  factory $ResourceCopyWith(Resource value, $Res Function(Resource) _then) = _$ResourceCopyWithImpl;
@useResult
$Res call({
 ResourceBranch branch, int tier
});




}
/// @nodoc
class _$ResourceCopyWithImpl<$Res>
    implements $ResourceCopyWith<$Res> {
  _$ResourceCopyWithImpl(this._self, this._then);

  final Resource _self;
  final $Res Function(Resource) _then;

/// Create a copy of BoardItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? branch = null,Object? tier = null,}) {
  return _then(Resource(
branch: null == branch ? _self.branch : branch // ignore: cast_nullable_to_non_nullable
as ResourceBranch,tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
