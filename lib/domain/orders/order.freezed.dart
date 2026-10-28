// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Order {

 Customer get customer; List<Resource> get resources; int get coins;/// How many of a resource the order asks for, when it is not just one.
 Map<Resource, int> get quantities;
/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderCopyWith<Order> get copyWith => _$OrderCopyWithImpl<Order>(this as Order, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Order;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Order&&(identical(other.customer, _this.customer) || other.customer == _this.customer)&&const DeepCollectionEquality().equals(other.resources, _this.resources)&&(identical(other.coins, _this.coins) || other.coins == _this.coins)&&const DeepCollectionEquality().equals(other.quantities, _this.quantities));
}


@override
int get hashCode {
  final _this = this as Order;
  return Object.hash(runtimeType,_this.customer,const DeepCollectionEquality().hash(_this.resources),_this.coins,const DeepCollectionEquality().hash(_this.quantities));
}

@override
String toString() {
  final _this = this as Order;
  return 'Order(customer: ${_this.customer}, resources: ${_this.resources}, coins: ${_this.coins}, quantities: ${_this.quantities})';
}


}

/// @nodoc
abstract mixin class $OrderCopyWith<$Res>  {
  factory $OrderCopyWith(Order value, $Res Function(Order) _then) = _$OrderCopyWithImpl;
@useResult
$Res call({
 Customer customer, List<Resource> resources, int coins, Map<Resource, int> quantities
});




}
/// @nodoc
class _$OrderCopyWithImpl<$Res>
    implements $OrderCopyWith<$Res> {
  _$OrderCopyWithImpl(this._self, this._then);

  final Order _self;
  final $Res Function(Order) _then;

/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? customer = null,Object? resources = null,Object? coins = null,Object? quantities = null,}) {
  return _then(Order(
customer: null == customer ? _self.customer : customer // ignore: cast_nullable_to_non_nullable
as Customer,resources: null == resources ? _self.resources : resources // ignore: cast_nullable_to_non_nullable
as List<Resource>,coins: null == coins ? _self.coins : coins // ignore: cast_nullable_to_non_nullable
as int,quantities: null == quantities ? _self.quantities : quantities // ignore: cast_nullable_to_non_nullable
as Map<Resource, int>,
  ));
}

}


/// Adds pattern-matching-related methods to [Order].
extension OrderPatterns on Order {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Order value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Order() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Order value)  $default,){
final _that = this;
switch (_that) {
case _Order():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Order value)?  $default,){
final _that = this;
switch (_that) {
case _Order() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Customer customer,  List<Resource> resources,  int coins,  Map<Resource, int> quantities)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Order() when $default != null:
return $default(_that.customer,_that.resources,_that.coins,_that.quantities);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Customer customer,  List<Resource> resources,  int coins,  Map<Resource, int> quantities)  $default,) {final _that = this;
switch (_that) {
case _Order():
return $default(_that.customer,_that.resources,_that.coins,_that.quantities);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Customer customer,  List<Resource> resources,  int coins,  Map<Resource, int> quantities)?  $default,) {final _that = this;
switch (_that) {
case _Order() when $default != null:
return $default(_that.customer,_that.resources,_that.coins,_that.quantities);case _:
  return null;

}
}

}

/// @nodoc


class _Order extends Order {
   _Order({required this.customer, required  List<Resource> resources, required this.coins,  Map<Resource, int> quantities = const {}}): assert(resources.length >= 1 && resources.length <= 2, 'an order asks for one or two resources'),assert(resources.toSet().length == resources.length, 'an order never asks for the same resource twice'),assert(quantities.keys.every(resources.contains), 'a quantity belongs to a resource the order asks for'),assert(quantities.values.every((quantity) => quantity >= 1), 'an order asks for at least one of each resource'),assert(coins >= 0, 'coins cannot be negative'),_resources = resources,_quantities = quantities,super._();
  

@override final  Customer customer;
 final  List<Resource> _resources;
@override List<Resource> get resources {
  if (_resources is EqualUnmodifiableListView) return _resources;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_resources);
}

@override final  int coins;
/// How many of a resource the order asks for, when it is not just one.
 final  Map<Resource, int> _quantities;
/// How many of a resource the order asks for, when it is not just one.
@override@JsonKey() Map<Resource, int> get quantities {
  if (_quantities is EqualUnmodifiableMapView) return _quantities;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_quantities);
}


/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderCopyWith<_Order> get copyWith => __$OrderCopyWithImpl<_Order>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Order&&(identical(other.customer, customer) || other.customer == customer)&&const DeepCollectionEquality().equals(other.resources, _resources)&&(identical(other.coins, coins) || other.coins == coins)&&const DeepCollectionEquality().equals(other.quantities, _quantities));
}


@override
int get hashCode {
    return Object.hash(runtimeType,customer,const DeepCollectionEquality().hash(_resources),coins,const DeepCollectionEquality().hash(_quantities));
}

@override
String toString() {
    return 'Order(customer: $customer, resources: $resources, coins: $coins, quantities: $quantities)';
}


}

/// @nodoc
abstract mixin class _$OrderCopyWith<$Res> implements $OrderCopyWith<$Res> {
  factory _$OrderCopyWith(_Order value, $Res Function(_Order) _then) = __$OrderCopyWithImpl;
@override @useResult
$Res call({
 Customer customer, List<Resource> resources, int coins, Map<Resource, int> quantities
});




}
/// @nodoc
class __$OrderCopyWithImpl<$Res>
    implements _$OrderCopyWith<$Res> {
  __$OrderCopyWithImpl(this._self, this._then);

  final _Order _self;
  final $Res Function(_Order) _then;

/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? customer = null,Object? resources = null,Object? coins = null,Object? quantities = null,}) {
  return _then(_Order(
customer: null == customer ? _self.customer : customer // ignore: cast_nullable_to_non_nullable
as Customer,resources: null == resources ? _self._resources : resources // ignore: cast_nullable_to_non_nullable
as List<Resource>,coins: null == coins ? _self.coins : coins // ignore: cast_nullable_to_non_nullable
as int,quantities: null == quantities ? _self._quantities : quantities // ignore: cast_nullable_to_non_nullable
as Map<Resource, int>,
  ));
}


}

// dart format on
