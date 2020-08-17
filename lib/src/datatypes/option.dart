import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../typeclasses/functor.dart';
import 'either.dart';

// NOTICE
// Constant constructors return values with dynamic parameter types
// instead of set generic ones.
// That is why there are some *ingore* pragmas.
// NOTICE

/// Safely represents optional data.
///
/// [None] - has no data (or value).
///
/// [Some] - has data (or value).
@immutable
abstract class Option<T> extends Equatable implements Monad<T>, Alternative<T> {
  const Option._();

  /// Creates [Some] if [nullableValue] is not `null`, creates [None] otherwise.
  factory Option.fromNullable(T nullableValue) =>
      // ignore: prefer_const_constructors
      nullableValue == null ? None() : Some(nullableValue);

  /// Creates [Some] if [either] is [Right], creates [None] otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Option<R> fromEither<L, R>(Either<L, R> either) =>
      Option.fromNullable(either.rightOr(null));

  /// Creates [Some] if [either] is [Left], creates [None] otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Option<L> fromLeftEither<L, R>(Either<L, R> either) =>
      Option.fromNullable(either.leftOr(null));

  @override
  bool get stringify => true;

  /// If has value, meaning is [Some].
  ///
  /// `option is Some<T>` may be more useful as it casts
  /// variable to [Some] so you can get data directly via [Some.value].
  ///
  /// ```
  /// final optSeven = Option.fromNullable(7);
  ///
  /// if (optSeven.isSome) {
  ///   // Can't use Some.value here.
  ///   // But we checked that it is Some,
  ///   // so using .valueOr(null) will never result in null.
  ///   final seven = optSeven.valueOr(null); // 7
  /// }
  ///
  /// if (optSeven is Some<int>) {
  ///   // optSeven is treated as Some<int> here.
  ///   // So we can use [Some.value] directly.
  ///   final seven = optSeven.value; // 7
  /// }
  /// ```
  bool get isSome;

  /// If does not have value, meaning is [None].
  bool get isNone => !isSome;

  /// If is [Some] - returns value, otherwise returns [ifNone].
  T valueOr(T ifNone);

  /// If is [Some] - returns value, otherwise calls [ifNone].
  ///
  /// If [ifNone] is null - throws [ArgumentError].
  T valueOrDo(T Function() ifNone);

  /// If is [Some] - applies [f] to data, otherwise calls [ifNone].
  ///
  ///```
  /// final json = retrieveData();
  /// int nameLength = json
  ///     .tryGet<String>('name')
  ///     .option(getDefaultLength, (name) => name.length);
  ///```
  ///
  /// If [ifNone] and/or [f] is null - throws [ArgumentError].
  R option<R>(R Function() ifNone, R Function(T) f);

  /// Only performs [action] if is [Some].
  ///
  /// If [action] is null - throws [ArgumentError].
  void doIfSome(void Function(T) action);

  /// Functor map.
  ///
  /// If is [Some] - applies [f] to the data and returns the result in [Some].
  /// Otherwise does nothing.
  ///
  /// ```
  /// final json = retrieveData();
  /// Option<int> optNameLength =
  ///     json.tryGet<String>('name').map((name) => name.length);
  /// ```
  ///
  /// If [f] is null - throws [ArgumentError].
  @override
  Option<R> map<R>(R Function(T) f);

  /// Monad bind.
  ///
  /// If is [Some] - applies [f] to the data. Otherwise does nothing.
  ///
  /// Similar to [map], but allows [f] to return [Option].
  ///
  /// ```
  /// final json = retrieveData();
  /// Option<int> optAge =
  ///     json.tryGet<String>('age').bind((ageStr) => ageStr.tryParseInt());
  /// ```
  ///
  /// If [f] is null - throws [ArgumentError].
  @override
  Option<R> bind<R>(Option<R> Function(T) f);

  /// Alternative choice.
  ///
  /// If is [Some] - returns self. Otherwise returns [another].
  ///
  /// ```
  /// Option<String> tryPhoneSource1() {...}
  /// Option<String> tryPhoneSource2() {...}
  /// Option<String> optPhone = tryPhoneSource1().or(tryPhoneSource2());
  /// ```
  @override
  Option<T> or(Option<T> another);

  /// [or] as an operator.
  ///
  /// If is [Some] - returns self. Otherwise returns [another].
  ///
  ///  ```
  /// Option<String> tryPhoneSource1() {...}
  /// Option<String> tryPhoneSource2() {...}
  /// Option<String> optPhone = tryPhoneSource1() | tryPhoneSource2();
  /// ```
  @override
  Option<T> operator |(Option<T> another) => or(another);

  /// If predicate returns false, returns [None].
  ///
  /// ```
  /// String monthStr = '17';
  /// int month = monthStr
  ///     .tryParseInt()
  ///     .guard((m) => 1 <= m && m <= 12)
  ///     .valueOr(1);
  ///
  /// ```
  @override
  Option<T> guard(bool Function(T) predicate);

  T get _unsafeValue;
}

/// Represents absence of data.
class None<T> extends Option<T> {
  /// Represents absence of data.
  const None() : super._();

  @override
  List<Object> get props => [];

  @override
  T get _unsafeValue =>
      throw UnsupportedError("Can't get value from Option.None");

  @override
  bool get isSome => false;

  @override
  R option<R>(R Function() ifNone, R Function(T) f) {
    ArgumentError.checkNotNull(ifNone, 'ifNone');
    ArgumentError.checkNotNull(f, 'f');
    return ifNone();
  }

  @override
  void doIfSome(void Function(T) action) {
    ArgumentError.checkNotNull(action, 'action');
  }

  @override
  T valueOr(T ifNone) => ifNone;

  @override
  T valueOrDo(T Function() ifNone) {
    ArgumentError.checkNotNull(ifNone, 'ifNone');
    return ifNone();
  }

  @override
  Option<R> map<R>(R Function(T) f) {
    ArgumentError.checkNotNull(f, 'f');
    // ignore: prefer_const_constructors
    return None();
  }

  @override
  Option<R> bind<R>(Option<R> Function(T) f) {
    ArgumentError.checkNotNull(f, 'f');
    // ignore: prefer_const_constructors
    return None();
  }

  @override
  Option<T> or(Option<T> another) => another;

  @override
  Option<T> guard(bool Function(T) predicate) {
    ArgumentError.checkNotNull(predicate, 'predicate');
    return this;
  }
}

/// Represents presence of data.
class Some<T> extends Option<T> {
  /// Represents presence of data (in form of [value]).
  ///
  /// Better use [Option.fromNullable] if [value] can be null.
  const Some(this.value) : super._();

  /// Stored data.
  final T value;

  @override
  List<Object> get props => [value];

  @override
  T get _unsafeValue => value;

  @override
  bool get isSome => true;

  @override
  R option<R>(R Function() ifNone, R Function(T) f) {
    ArgumentError.checkNotNull(ifNone, 'ifNone');
    ArgumentError.checkNotNull(f, 'f');
    return f(value);
  }

  @override
  void doIfSome(void Function(T) action) {
    ArgumentError.checkNotNull(action, 'action');
    action(value);
  }

  @override
  T valueOr(T ifNone) => value;

  @override
  T valueOrDo(T Function() ifNone) {
    ArgumentError.checkNotNull(ifNone, 'ifNone');
    return value;
  }

  @override
  Option<R> map<R>(R Function(T) f) {
    ArgumentError.checkNotNull(f, 'f');
    return Some(f(value));
  }

  @override
  Option<R> bind<R>(Option<R> Function(T) f) {
    ArgumentError.checkNotNull(f, 'f');
    return f(value);
  }

  @override
  Option<T> or(Option<T> another) => this;

  @override
  Option<T> guard(bool Function(T) predicate) {
    ArgumentError.checkNotNull(predicate, 'predicate');
    // ignore: prefer_const_constructors
    return predicate(value) ? this : None();
  }
}

/// Proof of concept type-safe monad join implementation.
extension JoinOptionExtension<T> on Option<Option<T>> {
  /// 'Joins' 2 nested [Option]s.
  ///
  /// Returns [Some] only if both are [Some]. Otherwise returns [None].
  ///
  /// ```
  /// final Option<Option<int>> someSomeSeven = Some(Some(7));
  /// final Option<Option<int>> someNone = Some(None());
  /// final Option<Option<int>> none = None();
  ///
  /// assert(someSomeSeven.join(), Some(7));
  /// assert(someNone.join(), None());
  /// assert(none.join(), None());
  /// ```
  // ignore: prefer_const_constructors
  Option<T> join() => isSome ? _unsafeValue : None();
}

// Extensions.

/// Methods on [Iterable] using [Option].
extension IterableOptionExtension<E> on Iterable<E> {
  /// Applies [f] to elements of [Iterable], leaving only data from [Some]s.
  ///
  /// ```
  /// final oddStrings = [1,2,3,4,5].mapSomes((n) =>
  ///     n.isOdd ? Some(n.toString()) : None());
  /// assert(oddStrings, ['1', '3', '5']);
  /// ```
  Iterable<R> mapSomes<R>(Option<R> Function(E) f) =>
      map(f).where((opt) => opt.isSome).map((some) => some._unsafeValue);
}

/// Methods on [Map] using [Option].
extension MapOptionExtension<K, V> on Map<K, V> {
  /// If Map contains [key] to non-null value - returns [Some] with the value.
  ///
  /// Returns [None] if:
  /// * map does not contain given [key];
  /// * value associated to [key] is null.
  ///
  /// ```
  /// final heights = {'John': 174, 'Sam': null, null: 180};
  /// heights.tryGet('John') // Some(174)
  /// heights.tryGet('Alex') // None()
  /// heights.tryGet('Sam')  // None()
  /// heights.tryGet(null)   // Some(180)
  /// ```
  Option<V> tryGet(K key) => Option.fromNullable(this[key]);
}

/// Methods on JSON([Map<String, dynamic>]) using [Option].
extension JsonOptionExtension on Map<String, dynamic> {
  /// If map contains [key] to non-null value of type [T] -
  /// returns [Some] with the value casted to [T].
  ///
  /// Returns [None] if:
  /// * map does not contain given [key];
  /// * value associated to [key] is null;
  /// * value associated to [key] is not of type [T].
  ///
  /// ```
  /// final json = {
  ///   'int': 7,
  ///   'string': 'hello',
  ///   'double': null,
  ///   null: 'nullField',
  /// };
  /// json.tryGet<int>('int'))      // Some(7)
  /// json.tryGet<double>('absent') // None() - absent key
  /// json.tryGet<double>('double') // None() - null value
  /// json.tryGet<double>('string') // None() - wrong type
  /// json.tryGet<String>(null)     // Some('nullField')
  /// ```
  Option<T> tryGet<T>(String key) {
    final dynamic value = this[key];
    if (value is T) {
      return Some(value);
    } else {
      // ignore: prefer_const_constructors
      return None();
    }
  }
}

/// Methods for parsing [String] using [Option].
extension StringOptionExtension on String {
  /// Parse string as a, possibly signed, integer literal.
  ///
  /// Returns [Some] with parsed int or returns [None] in case of failure.
  ///
  /// ```
  /// final seven = '7'.tryParseInt().valueOr(0); // 7
  /// final five = '101'.tryParseInt(radix: 2).valueOr(0); // 5
  /// final zero = 'not an int'.tryParseInt().valueOr(0); // 0
  /// ```
  Option<int> tryParseInt({int radix = 10}) =>
      Option.fromNullable(int.tryParse(this, radix: radix));

  /// Parse string as a double literal.
  ///
  /// Returns [Some] with parsed double or returns [None] in case of failure.
  ///
  /// ```
  /// final pi = '3.14'.tryParseDouble().valueOr(0); // 3.14
  /// final zero = 'not a double'.tryParseDouble().valueOr(0); // 0
  /// ```
  Option<double> tryParseDouble() {
    ArgumentError.checkNotNull(this);
    return Option.fromNullable(double.tryParse(this));
  }
}
