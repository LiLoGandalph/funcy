import 'package:funcy/funcy.dart';
import 'package:test/test.dart';

void main() {
  const data = 'test data';
  const loading = Loadable<String>.loading();
  const failed = Loadable<String>.failed();
  const success = Loadable.success(data);

  group('*isLoaded* if', () {
    test('Loading, returns false', () {
      expect(loading.isLoaded, isFalse);
    });
    test('Failed, returns true', () {
      expect(failed.isLoaded, isTrue);
    });
    test('Success, returns true', () {
      expect(success.isLoaded, isTrue);
    });
  });

  group('*isLoading* if', () {
    test('Loading, returns true', () {
      expect(loading.isLoading, isTrue);
    });
    test('Failed, returns false', () {
      expect(failed.isLoading, isFalse);
    });
    test('Success, returns false', () {
      expect(success.isLoading, isFalse);
    });
  });

  group('*map* if', () {
    group('Success', () {
      test('applies [f] to data and returns it in Success', () {
        final f = (String s) => s.split(' ').first.length;
        final mappedSuccess = success.map(f);
        expect(mappedSuccess, Success(f(data)));
      });
      test('and [f] is null throws ArgumentError', () {
        expect(() => success.map<bool>(null), throwsArgumentError);
      });
    });

    group('Failed', () {
      test('returns Failed', () {
        final f = (String s) => s.split(' ').first.length;
        final mappedFailed = failed.map(f);
        expect(mappedFailed, const Failed<int>());
      });
      test('and [f] is null throws ArgumentError', () {
        expect(() => failed.map<bool>(null), throwsArgumentError);
      });
    });

    group('Loading', () {
      test('returns Loading', () {
        final f = (String s) => s.split(' ').first.length;
        final mappedLoading = loading.map(f);
        expect(mappedLoading, const Loading<int>());
      });
      test('and [f] is null throws ArgumentError', () {
        expect(() => loading.map<bool>(null), throwsArgumentError);
      });
    });
  });

  group('*bind* if', () {
    group('Success', () {
      test('applies [f] to data', () {
        final f =
            (String s) => s.isNotEmpty ? Success(s) : const Failed<String>();
        final bindedSuccess = success.bind(f);
        expect(bindedSuccess, f(data));
      });
      test('and [f] is null throws ArgumentError', () {
        expect(() => success.bind<bool>(null), throwsArgumentError);
      });
    });

    group('Failed', () {
      test('returns Failed', () {
        final f = (String s) => Success(s.length / 2);
        final bindedFailed = failed.bind(f);
        expect(bindedFailed, const Failed<double>());
      });
      test('and [f] is null throws ArgumentError', () {
        expect(() => failed.bind<bool>(null), throwsArgumentError);
      });
    });

    group('Loading', () {
      test('returns Loading', () {
        final f = (String s) => Success(s.length / 2);
        final bindedLoading = loading.bind(f);
        expect(bindedLoading, const Loading<double>());
      });

      test('and [f] is null throws ArgumentError', () {
        expect(() => loading.bind<bool>(null), throwsArgumentError);
      });
    });
  });

  group('*or* if', () {
    group('Success', () {
      test('returns self', () {
        const another = Loadable.success('boop');
        expect(success.or(another), success);
      });
    });

    group('Failed', () {
      test('returns [another]', () {
        const another = Loadable.success('boop');
        expect(failed.or(another), another);
      });
    });

    group('Loading', () {
      test('returns [another]', () {
        const another = Loadable.success('boop');
        expect(loading.or(another), another);
      });
    });
  });

  group('*|*', () {
    group('Success', () {
      test('returns self', () {
        const another = Loadable.success('boop');
        expect(success | another, success);
      });
    });

    group('Failed', () {
      test('returns [another]', () {
        const another = Loadable.success('boop');
        expect(failed | another, another);
      });
    });

    group('Loading', () {
      test('returns [another]', () {
        const another = Loadable.success('boop');
        expect(loading | another, another);
      });
    });
  });

  group('*guard* if', () {
    group('Success and predicate is', () {
      test('true returns self', () {
        expect(success.guard((_) => true), success);
      });

      test('false returns Failed', () {
        expect(success.guard((_) => false), failed);
      });

      test('null throws ArgumentError', () {
        expect(() => success.guard(null), throwsArgumentError);
      });
    });

    group('Failed and predicate is', () {
      test('true returns self', () {
        expect(failed.guard((_) => true), failed);
      });

      test('false returns self', () {
        expect(failed.guard((_) => false), failed);
      });

      test('null throws ArgumentError', () {
        expect(() => failed.guard(null), throwsArgumentError);
      });
    });

    group('Loading and predicate is', () {
      test('true returns Failed', () {
        expect(loading.guard((_) => true), failed);
      });

      test('false returns Failed', () {
        expect(loading.guard((_) => false), failed);
      });

      test('null throws ArgumentError', () {
        expect(() => loading.guard(null), throwsArgumentError);
      });
    });
  });

  group('*branch* if', () {
    group('Success', () {
      test('applies [ifSuccess] to data', () {
        final result = success.branch<int>(
          ifSuccess: (s) => s.length,
          ifFailed: () => 7,
          ifLoading: () => 17,
        );
        expect(result, data.length);
      });

      test('and [ifSuccess] is null throws ArgumentError', () {
        expect(
            () => success.branch<int>(
                  ifSuccess: null,
                  ifFailed: () => 7,
                  ifLoading: () => 17,
                ),
            throwsArgumentError);
      });
      test('and [ifFailed] is null throws ArgumentError', () {
        expect(
            () => success.branch<int>(
                  ifSuccess: (s) => s.length,
                  ifFailed: null,
                  ifLoading: () => 17,
                ),
            throwsArgumentError);
      });
      test('and [ifLoading] is null throws ArgumentError', () {
        expect(
            () => success.branch<int>(
                  ifSuccess: (s) => s.length,
                  ifFailed: () => 7,
                  ifLoading: null,
                ),
            throwsArgumentError);
      });
    });

    group('Failed', () {
      test('calls [ifFailed]', () {
        final result = failed.branch<int>(
          ifSuccess: (s) => s.length,
          ifFailed: () => 7,
          ifLoading: () => 17,
        );
        expect(result, 7);
      });

      test('and [ifSuccess] is null throws ArgumentError', () {
        expect(
            () => failed.branch<int>(
                  ifSuccess: null,
                  ifFailed: () => 7,
                  ifLoading: () => 17,
                ),
            throwsArgumentError);
      });
      test('and [ifFailed] is null throws ArgumentError', () {
        expect(
            () => failed.branch<int>(
                  ifSuccess: (s) => s.length,
                  ifFailed: null,
                  ifLoading: () => 17,
                ),
            throwsArgumentError);
      });
      test('and [ifLoading] is null throws ArgumentError', () {
        expect(
            () => failed.branch<int>(
                  ifSuccess: (s) => s.length,
                  ifFailed: () => 7,
                  ifLoading: null,
                ),
            throwsArgumentError);
      });
    });
    group('Loading', () {
      test('calls [ifLoading]', () {
        final result = loading.branch<int>(
          ifSuccess: (s) => s.length,
          ifFailed: () => 7,
          ifLoading: () => 17,
        );
        expect(result, 17);
      });

      test('and [ifSuccess] is null throws ArgumentError', () {
        expect(
            () => loading.branch<int>(
                  ifSuccess: null,
                  ifFailed: () => 7,
                  ifLoading: () => 17,
                ),
            throwsArgumentError);
      });
      test('and [ifFailed] is null throws ArgumentError', () {
        expect(
            () => loading.branch<int>(
                  ifSuccess: (s) => s.length,
                  ifFailed: null,
                  ifLoading: () => 17,
                ),
            throwsArgumentError);
      });
      test('and [ifLoading] is null throws ArgumentError', () {
        expect(
            () => loading.branch<int>(
                  ifSuccess: (s) => s.length,
                  ifFailed: () => 7,
                  ifLoading: null,
                ),
            throwsArgumentError);
      });
    });
  });
}
