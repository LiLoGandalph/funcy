import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../funcy.dart';

/// Safely represents data, that is being loaded.
///
/// * [Loading] - loading is in progress, no data;
/// * [Loaded] - loading is done:
///   - [Failed]: loading failed, has [Failed.failure];
///   - [Success]: [Success.data] is loaded successfully.
@immutable
abstract class Loadable<F, S> extends Equatable implements Monad<S> {
  const Loadable._();

  /// Loading is in progress, no data.
  const factory Loadable.loading() = Loading;

  /// Loading failed, no data.
  const factory Loadable.failed(F failure) = Failed;

  /// [data] is loaded successfully.
  const factory Loadable.success(S data) = Success;

  /// If loading is done (either successfully or not).
  bool get isLoaded;

  /// If loading is done successfully.
  bool get isSuccess;

  /// If loading is in progress.
  bool get isLoading;

  /// If [Success] - returns [Success] with `f(data)`.
  /// Otherwise, returns the same object.
  ///
  /// Throws [ArgumentError], if [f] is null.
  @override
  Loadable<F, R> map<R>(R Function(S data) f);

  /// If [Success] - returns `f(data)`.
  /// Otherwise, returns the same object.
  ///
  /// Throws [ArgumentError], if [f] is null.
  @override
  Loadable<F, R> bind<R>(Loadable<F, R> Function(S data) f);

  /// Branches the execution.
  R branch<R>({
    @required R Function() ifLoading,
    @required R Function(F failure) ifFailed,
    @required R Function(S data) ifSuccess,
  });

  @override
  bool get stringify => true;
}

/// Loading is in progress, no data.
class Loading<F, S> extends Loadable<F, S> {
  /// Loading is in progress, no data.
  const Loading() : super._();

  @override
  bool get isLoaded => false;

  @override
  bool get isSuccess => false;

  @override
  bool get isLoading => true;

  @override
  Loadable<F, R> map<R>(R Function(S) f) {
    ArgumentError.checkNotNull(f, 'f');
    return Loading<F, R>();
  }

  @override
  Loadable<F, R> bind<R>(Loadable<F, R> Function(S) f) {
    ArgumentError.checkNotNull(f, 'f');
    // ignore: prefer_const_constructors
    return Loading();
  }

  @override
  R branch<R>({
    R Function() ifLoading,
    R Function(F failure) ifFailed,
    R Function(S data) ifSuccess,
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
abstract class Loaded<F, S> extends Loadable<F, S> {
  const Loaded._() : super._();

  /// Loading failed, no data.
  const factory Loaded.failed(F failure) = Failed;

  /// [data] is loaded successfully.
  const factory Loaded.success(S data) = Success;

  /// Creates [Loaded] from [Option]:
  /// * [Some] -> [Success] with [Some.value].
  /// * [None] -> [Failed] with [errorData]
  factory Loaded.fromOption(Option<S> option, F errorData) => option.option(
        () => Failed(errorData),
        (data) => Success(data),
      );

  /// Creates [Loaded] from [Either]:
  /// * [Right] -> [Success]
  /// * [Left]  -> [Failed]
  factory Loaded.fromEither(Either<F, S> either) => either.either(
        (left) => Failed(left),
        (right) => Success(right),
      );

  @override
  bool get isLoaded => true;
  @override
  bool get isLoading => false;
}

/// [Loadable] when loading failed, no data.
class Failed<F, S> extends Loaded<F, S> {
  /// [Loadable] when loading failed, no data.
  const Failed(this.failure) : super._();

  /// Generally, describes why loading has failed (or anything you want).
  final F failure;

  @override
  bool get isSuccess => false;

  @override
  Loadable<F, R> map<R>(R Function(S) f) {
    ArgumentError.checkNotNull(f, 'f');
    return Failed(failure);
  }

  @override
  Loadable<F, R> bind<R>(Loadable<F, R> Function(S) f) {
    ArgumentError.checkNotNull(f, 'f');
    return Failed(failure);
  }

  @override
  R branch<R>({
    R Function() ifLoading,
    R Function(F failure) ifFailed,
    R Function(S data) ifSuccess,
  }) {
    ArgumentError.checkNotNull(ifLoading, 'ifLoading');
    ArgumentError.checkNotNull(ifFailed, 'ifFailed');
    ArgumentError.checkNotNull(ifSuccess, 'ifSuccess');
    return ifFailed(failure);
  }

  @override
  List<Object> get props => [];

  @override
  String toString() => 'Failed';
}

/// [Loadable] when [data] is loaded successfully.
class Success<F, S> extends Loaded<F, S> {
  /// [Loadable] when [data] is loaded successfully.
  const Success(this.data) : super._();

  /// Loaded data.
  final S data;

  @override
  bool get isSuccess => true;

  @override
  Loadable<F, R> map<R>(R Function(S) f) {
    ArgumentError.checkNotNull(f, 'f');
    return Success(f(data));
  }

  @override
  Loadable<F, R> bind<R>(Loadable<F, R> Function(S) f) {
    ArgumentError.checkNotNull(f, 'f');
    return f(data);
  }

  @override
  R branch<R>({
    R Function() ifLoading,
    R Function(F failure) ifFailed,
    R Function(S data) ifSuccess,
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
