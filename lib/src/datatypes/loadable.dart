import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../funcy.dart';

/// Safely represents data, that is being loaded.
///
/// * [Loading] - loading is in progress, no data;
/// * [Loaded] - loading is done:
///   - [Failed]: loading failed, no data;
///   - [Success]: [Success.data] is loaded successfully.
@immutable
abstract class Loadable<T> extends Equatable
    implements Monad<T>, Alternative<T> {
  const Loadable._();

  /// Loading is in progress, no data.
  const factory Loadable.loading() = Loading<T>;

  /// Loading failed, no data.
  const factory Loadable.failed() = Failed<T>;

  /// [data] is loaded successfully.
  const factory Loadable.success(T data) = Success<T>;

  /// If loading is done (either successfully or not).
  bool get isLoaded;

  /// If loading is in progress.
  bool get isLoading;

  /// If [Success] - returns [Success] with `f(data)`.
  /// Otherwise, returns the same object.
  ///
  /// Throws [ArgumentError], if [f] is null.
  @override
  Loadable<R> map<R>(R Function(T) f);

  /// If [Success] - returns `f(data)`.
  /// Otherwise, returns the same object.
  ///
  /// Throws [ArgumentError], if [f] is null.
  @override
  Loadable<R> bind<R>(Loadable<R> Function(T) f);

  /// If [Success] - returns the same object.
  /// Otherwise, returns [another].
  @override
  Loadable<T> or(Loadable<T> another);

  /// If left argument is [Success] - returns left argument.
  /// Otherwise, returns right argument.
  @override
  Loadable<T> operator |(Loadable<T> another) => or(another);

  /// If [Success] and [predicate] with [Success.data] evaluates to true -
  /// returns the same object.
  /// Otherwise, returns [Failed].
  @override
  Loadable<T> guard(bool Function(T) predicate);

  /// Branches the execution.
  R branch<R>({
    @required R Function() ifLoading,
    @required R Function() ifFailed,
    @required R Function(T) ifSuccess,
  });

  @override
  bool get stringify => true;

  // I don't know what is that,
  // probably a bug because of some sort of type system optimizations.
  // If there is no static method on this class, constant factory constructors
  // become broken. It seems like it can infer the correct type of variable
  // you are assigning to, but considers a type of assignable value to be wrong.
  // ignore: unused_element
  static void _useless() {}
}

/// Loading is in progress, no data.
class Loading<T> extends Loadable<T> {
  /// Loading is in progress, no data.
  const Loading() : super._();

  @override
  bool get isLoaded => false;

  @override
  bool get isLoading => true;

  @override
  Loadable<R> map<R>(R Function(T) f) {
    ArgumentError.checkNotNull(f, 'f');
    return Loading<R>();
  }

  @override
  Loadable<R> bind<R>(Loadable<R> Function(T) f) {
    ArgumentError.checkNotNull(f, 'f');
    return Loading<R>();
  }

  @override
  Loadable<T> or(Loadable<T> another) => another;

  @override
  Loadable<T> guard(bool Function(T) predicate) {
    ArgumentError.checkNotNull(predicate, 'predicate');
    return Failed<T>();
  }

  @override
  R branch<R>({
    R Function() ifLoading,
    R Function() ifFailed,
    R Function(T p1) ifSuccess,
  }) {
    ArgumentError.checkNotNull(ifLoading, 'ifLoading');
    ArgumentError.checkNotNull(ifFailed, 'ifFailed');
    ArgumentError.checkNotNull(ifSuccess, 'ifSuccess');
    return ifLoading();
  }

  @override
  List<Object> get props => [];

  @override
  String toString() => 'Loading';
}

/// [Loadable] when loading is done
/// (either successfully ([Success]) or not ([Failed])).
abstract class Loaded<T> extends Loadable<T> {
  const Loaded._() : super._();

  /// Loading failed, no data.
  const factory Loaded.failed() = Failed;

  /// [data] is loaded successfully.
  const factory Loaded.success(T data) = Success;

  /// Creates [Loaded] from [Option]:
  /// * [Some] -> [Success]
  /// * [None] -> [Failed]
  factory Loaded.fromOption(Option<T> option) => option.option(
        () => Failed<T>(),
        (data) => Success(data),
      );

  /// Creates [Loaded] from [Either]:
  /// * [Right] -> [Success]
  /// * [Left]  -> [Failed]
  factory Loaded.fromEither(Either<dynamic, T> either) => either.fromRight(
        Failed<T>(),
        (right) => Success(right),
      );

  @override
  bool get isLoaded => true;
  @override
  bool get isLoading => false;

  /// If data is loaded successfully ([Success]).
  bool get isSuccess;
}

/// [Loadable] when loading failed, no data.
class Failed<T> extends Loaded<T> {
  /// [Loadable] when loading failed, no data.
  const Failed() : super._();

  @override
  bool get isSuccess => false;

  @override
  Loadable<R> map<R>(R Function(T) f) {
    ArgumentError.checkNotNull(f, 'f');
    return Failed<R>();
  }

  @override
  Loadable<R> bind<R>(Loadable<R> Function(T) f) {
    ArgumentError.checkNotNull(f, 'f');
    return Failed<R>();
  }

  @override
  Loadable<T> or(Loadable<T> another) => another;
  @override
  Loadable<T> guard(bool Function(T) predicate) {
    ArgumentError.checkNotNull(predicate, 'predicate');
    return this;
  }

  @override
  R branch<R>({
    R Function() ifLoading,
    R Function() ifFailed,
    R Function(T p1) ifSuccess,
  }) {
    ArgumentError.checkNotNull(ifLoading, 'ifLoading');
    ArgumentError.checkNotNull(ifFailed, 'ifFailed');
    ArgumentError.checkNotNull(ifSuccess, 'ifSuccess');
    return ifFailed();
  }

  @override
  List<Object> get props => [];

  @override
  String toString() => 'Failed';
}

/// [Loadable] when [data] is loaded successfully.
class Success<T> extends Loaded<T> {
  /// [Loadable] when [data] is loaded successfully.
  const Success(this.data) : super._();

  /// Loaded data.
  final T data;

  @override
  bool get isSuccess => true;

  @override
  Loadable<R> map<R>(R Function(T) f) {
    ArgumentError.checkNotNull(f, 'f');
    return Success(f(data));
  }

  @override
  Loadable<R> bind<R>(Loadable<R> Function(T) f) {
    ArgumentError.checkNotNull(f, 'f');
    return f(data);
  }

  @override
  Loadable<T> or(Loadable<T> another) => this;

  @override
  Loadable<T> guard(bool Function(T) predicate) {
    ArgumentError.checkNotNull(predicate, 'predicate');
    return predicate(data) ? this : Failed<T>();
  }

  @override
  R branch<R>({
    R Function() ifLoading,
    R Function() ifFailed,
    R Function(T p1) ifSuccess,
  }) {
    ArgumentError.checkNotNull(ifLoading, 'ifLoading');
    ArgumentError.checkNotNull(ifFailed, 'ifFailed');
    ArgumentError.checkNotNull(ifSuccess, 'ifSuccess');
    return ifSuccess(data);
  }

  @override
  List<Object> get props => [data];

  @override
  String toString() => 'Success($data)';
}
