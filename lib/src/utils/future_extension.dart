import 'dart:async';

import '../../funcy.dart';

/// [Future]-[Option] monad transformer extension.
extension FutureOptionTransformerExtension<T> on Future<Option<T>> {
  /// Gets "inside" the future and performs [map] on inner [Option].
  Future<Option<R>> map<R>(R Function(T) f) => then((opt) => opt.map(f));

  /// Gets "inside" the future and performs [bind] on inner [Option].
  Future<Option<R>> bind<R>(FutureOr<Option<R>> Function(T) f) async {
    ArgumentError.checkNotNull(f, 'f');
    final maybeT = await this;
    if (maybeT is Some<T>) {
      return f(maybeT.value);
    } else {
      // ignore: prefer_const_constructors
      return None();
    }
  }
}

/// [Future]-[Either] monad transformer extension.
extension FutureEitherTransformerExtension<L, R> on Future<Either<L, R>> {
  /// Gets "inside" the future and performs [map] on inner [Either].
  Future<Either<L, R2>> map<R2>(R2 Function(R) f) =>
      then((either) => either.map(f));

  /// Gets "inside" the future and performs [bind] on inner [Either].
  Future<Either<L, R2>> bind<R2>(FutureOr<Either<L, R2>> Function(R) f) async {
    ArgumentError.checkNotNull(f, 'f');
    final lOrR = await this;
    if (lOrR is Right<L, R>) {
      return f(lOrR.right);
    } else {
      return Left(lOrR.leftOr(null));
    }
  }
}

/// [Future]-[Loadable] monad transformer extension.
extension FutureLoadableTransformerExtension<F, S> on Future<Loadable<F, S>> {
  /// Gets "inside" the future and performs [map] on inner [Loadable].
  Future<Loadable<F, R>> map<R>(R Function(S data) f) =>
      then((loadable) => loadable.map(f));

  /// Gets "inside" the future and performs [bind] on inner [Loadable].
  Future<Loadable<F, R>> bind<R>(
      FutureOr<Loadable<F, R>> Function(S data) f) async {
    ArgumentError.checkNotNull(f, 'f');
    final loadableS = await this;
    if (loadableS is Success<F, S>) {
      return f(loadableS.data);
    } else if (loadableS is Failed<F, S>) {
      return Failed(loadableS.failure);
    } else {
      return const Loading();
    }
  }
}
