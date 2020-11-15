/// Functor typeclass.
///
/// Google *'typeclassopedia'*, if you are interested ^)
///
/// Basically, a box with magic sauce.
abstract class Functor<T> {
  /// Functor map.
  Functor<R> map<R>(R Function(T value) f);
}

/// Monad typeclass.
///
/// Google *'typeclassopedia'*, if you are interested ^)
///
/// Cooler functor. A box with magic sauce
/// that can be combined with other such boxes.
abstract class Monad<T> extends Functor<T> {
  /// Monad bind.
  Monad<R> bind<R>(covariant Monad<R> Function(T value) f);
}

/// Alternative typeclass.
///
/// Google *'typeclassopedia'*, if you are interested ^)
///
/// A functor that has a concept of choice between "success" and "failure".
abstract class Alternative<T> extends Functor<T> {
  /// Alternative choice.
  ///
  /// If it is "success" - returns itself. Otherwise, returns [another].
  Alternative<T> or(covariant Alternative<T> another);

  /// Alternative choice. [or] as an operator.
  ///
  /// If left argument is "success" - returns left argument.
  /// Otherwise, returns right argument.
  Alternative<T> operator |(covariant Alternative<T> another) => or(another);

  /// Alternative guard. If predicate returns false,
  /// returns a value representing *failure*.
  Alternative<T> guard(bool Function(T value) predicate);
}
