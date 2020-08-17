import '../../funcy.dart';

/// [Future]-[Option] monad transformer extension.
extension FutureOptionTransformerExtension<T> on Future<Option<T>> {
  /// Gets "inside" the future and performs [map] on inner [Option].
  Future<Option<R>> map<R>(R Function(T) f) => then((opt) => opt.map(f));

  /// Gets "inside" the future and performs [bind] on inner [Option].
  Future<Option<R>> bind<R>(Option<R> Function(T) f) =>
      then((opt) => opt.bind(f));
}

/// [Future]-[Either] monad transformer extension.
extension FutureEitherTransformerExtension<L, R> on Future<Either<L, R>> {
  /// Gets "inside" the future and performs [map] on inner [Either].
  Future<Either<L, R2>> map<R2>(R2 Function(R) f) =>
      then((either) => either.map(f));

  /// Gets "inside" the future and performs [bind] on inner [Either].
  Future<Either<L, R2>> bind<R2>(Either<L, R2> Function(R) f) =>
      then((either) => either.bind(f));
}

/// [Future]-[Loadable] monad transformer extension.
extension FutureLoadableTransformerExtension<T> on Future<Loadable<T>> {
  /// Gets "inside" the future and performs [map] on inner [Loadable].
  Future<Loadable<R>> map<R>(R Function(T) f) =>
      then((loadable) => loadable.map(f));

  /// Gets "inside" the future and performs [bind] on inner [Loadable].
  Future<Loadable<R>> bind<R>(Loadable<R> Function(T) f) =>
      then((loadable) => loadable.bind(f));
}
