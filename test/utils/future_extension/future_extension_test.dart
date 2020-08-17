import 'package:funcy/funcy.dart';
import 'package:test/test.dart';

void main() {
  group('FutureOptionTransformerExtension:', () {
    group('*map*', () {
      test('performs map on inner Option', () async {
        final option = Option.fromNullable(7);
        final f = (num x) => x * 2;
        final toFuture = (Option<num> x) => Future.value(x);
        expect(await toFuture(option).map(f), await toFuture(option.map(f)));
      });

      test('if [f] is null throws ArgumentError', () {
        final future = Future.value(const Some(7));
        expect(() => future.map<bool>(null), throwsArgumentError);
      });
    });

    group('*bind*', () {
      test('performs bind on inner Option', () async {
        final option = Option.fromNullable(7);
        final f = (num x) => Some(x * 2);
        final toFuture = (Option<num> x) => Future.value(x);
        expect(await toFuture(option).bind(f), await toFuture(option.bind(f)));
      });

      test('if [f] is null throws ArgumentError', () {
        final future = Future.value(const Some(7));
        expect(() => future.bind<bool>(null), throwsArgumentError);
      });
    });
  });

  group('FutureEitherTransformerExtension:', () {
    group('*map*', () {
      test('performs map on inner Either', () async {
        const either = const Right<String, int>(7);
        final f = (num x) => x * 2;
        final toFuture = (Either<String, num> x) => Future.value(x);
        expect(await toFuture(either).map(f), await toFuture(either.map(f)));
      });

      test('if [f] is null throws ArgumentError', () {
        final future = Future.value(const Right<String, int>(7));
        expect(() => future.map<bool>(null), throwsArgumentError);
      });
    });

    group('*bind*', () {
      test('performs bind on inner Either', () async {
        const either = const Right<String, int>(7);
        final f = (num x) => Left<String, int>(x.toString());
        final toFuture = (Either<String, int> x) => Future.value(x);
        expect(await toFuture(either).bind(f), await toFuture(either.bind(f)));
      });

      test('if [f] is null throws ArgumentError', () {
        final future = Future.value(const Right<String, int>(7));
        expect(() => future.bind<bool>(null), throwsArgumentError);
      });
    });
  });

  group('FutureLoadableTransformerExtension:', () {
    group('*map*', () {
      test('performs map on inner Loadable', () async {
        const loadable = const Loadable.success(7);
        final f = (num x) => x * 2;
        final toFuture = (Loadable<num> x) => Future.value(x);
        expect(
            await toFuture(loadable).map(f), await toFuture(loadable.map(f)));
      });

      test('if [f] is null throws ArgumentError', () {
        final future = Future.value(const Success<int>(7));
        expect(() => future.map<bool>(null), throwsArgumentError);
      });
    });

    group('*bind*', () {
      test('performs bind on inner Loadable', () async {
        const loadable = const Loadable.success(7);
        final f = (num x) => const Loadable<int>.failed();
        final toFuture = (Loadable<int> x) => Future.value(x);
        expect(
            await toFuture(loadable).bind(f), await toFuture(loadable.bind(f)));
      });

      test('if [f] is null throws ArgumentError', () {
        final future = Future.value(const Success<int>(7));
        expect(() => future.bind<bool>(null), throwsArgumentError);
      });
    });
  });
}
