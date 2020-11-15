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
        final toFuture = (Option<num> x) => Future.value(x);
        final f = (num x) => Some(x * 2);
        final actual = await toFuture(option).bind(f.then(toFuture));
        expect(actual, option.bind(f));
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
        final f = (num x) => Left<String, int>(x.toString());
        final toFuture = (Either<String, int> x) => Future.value(x);
        const either = const Right<String, int>(7);
        final actual = await toFuture(either).bind(f.then(toFuture));
        expect(actual, either.bind(f));
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
        const loadable = const Success<String, int>(7);
        final f = (num x) => x * 2;
        final toFuture = (Loadable<String, num> x) => Future.value(x);
        expect(
            await toFuture(loadable).map(f), await toFuture(loadable.map(f)));
      });

      test('if [f] is null throws ArgumentError', () {
        final future = Future.value(const Success<String, int>(7));
        expect(() => future.map<bool>(null), throwsArgumentError);
      });
    });

    group('*bind*', () {
      test('performs bind on inner Loadable', () async {
        const loadable = const Success<String, int>(7);
        final f = (num x) => const Failed<String, int>('boop');
        final toFuture = (Loadable<String, int> x) => Future.value(x);
        final actual = await toFuture(loadable).bind(f.then(toFuture));
        expect(actual, loadable.bind(f));
      });

      test('if [f] is null throws ArgumentError', () {
        final future = Future.value(const Success<String, int>(7));
        expect(() => future.bind<bool>(null), throwsArgumentError);
      });
    });
  });
}
