import 'package:funcy/funcy.dart';
import 'package:test/test.dart';

void main() {
  const data = 'test data';
  const failure = 7;
  final loading = Loadable.loading<int, String>();
  final failed = Loadable.failed<int, String>(failure);
  final success = Loadable.success<int, String>(data);

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

  group('*isSuccess* if', () {
    test('Loading, returns false', () {
      expect(loading.isSuccess, isFalse);
    });
    test('Failed, returns false', () {
      expect(failed.isSuccess, isFalse);
    });
    test('Success, returns true', () {
      expect(success.isSuccess, isTrue);
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
        expect(mappedSuccess, Success<int, int>(f(data)));
      });
      test('and [f] is null throws ArgumentError', () {
        expect(() => success.map<bool>(null), throwsArgumentError);
      });
    });

    group('Failed', () {
      test('returns Failed', () {
        final f = (String s) => s.split(' ').first.length;
        final mappedFailed = failed.map(f);
        expect(mappedFailed, const Failed<int, int>(failure));
      });
      test('and [f] is null throws ArgumentError', () {
        expect(() => failed.map<bool>(null), throwsArgumentError);
      });
    });

    group('Loading', () {
      test('returns Loading', () {
        final f = (String s) => s.split(' ').first.length;
        final mappedLoading = loading.map(f);
        expect(mappedLoading, const Loading<int, int>());
      });
      test('and [f] is null throws ArgumentError', () {
        expect(() => loading.map<bool>(null), throwsArgumentError);
      });
    });
  });

  group('*bind* if', () {
    group('Success', () {
      test('applies [f] to data', () {
        final f = (String s) => s.isNotEmpty
            ? Success<int, String>(s)
            : const Failed<int, String>(17);
        final bindedSuccess = success.bind(f);
        expect(bindedSuccess, f(data));
      });
      test('and [f] is null throws ArgumentError', () {
        expect(() => success.bind<bool>(null), throwsArgumentError);
      });
    });

    group('Failed', () {
      test('returns Failed', () {
        final f = (String s) => Success<int, double>(s.length / 2);
        final bindedFailed = failed.bind(f);
        expect(bindedFailed, const Failed<int, double>(failure));
      });
      test('and [f] is null throws ArgumentError', () {
        expect(() => failed.bind<bool>(null), throwsArgumentError);
      });
    });

    group('Loading', () {
      test('returns Loading', () {
        final f = (String s) => Success<int, double>(s.length / 2);
        final bindedLoading = loading.bind(f);
        expect(bindedLoading, const Loading<int, double>());
      });

      test('and [f] is null throws ArgumentError', () {
        expect(() => loading.bind<bool>(null), throwsArgumentError);
      });
    });
  });

  group('*branch* if', () {
    group('Success', () {
      test('applies [ifSuccess] to data', () {
        final result = success.branch<int>(
          ifSuccess: (s) => s.length,
          ifFailed: (f) => f,
          ifLoading: () => 17,
        );
        expect(result, data.length);
      });

      test('and [ifSuccess] is null throws ArgumentError', () {
        expect(
            () => success.branch<int>(
                  ifSuccess: null,
                  ifFailed: (f) => f,
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
                  ifFailed: (f) => f,
                  ifLoading: null,
                ),
            throwsArgumentError);
      });
    });

    group('Failed', () {
      test('applies [ifFailed] to failure', () {
        final result = failed.branch<int>(
          ifSuccess: (s) => s.length,
          ifFailed: (f) => f * 3,
          ifLoading: () => 17,
        );
        expect(result, failure * 3);
      });

      test('and [ifSuccess] is null throws ArgumentError', () {
        expect(
            () => failed.branch<int>(
                  ifSuccess: null,
                  ifFailed: (f) => f,
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
                  ifFailed: (f) => f,
                  ifLoading: null,
                ),
            throwsArgumentError);
      });
    });
    group('Loading', () {
      test('calls [ifLoading]', () {
        final result = loading.branch<int>(
          ifSuccess: (s) => s.length,
          ifFailed: (f) => f,
          ifLoading: () => 17,
        );
        expect(result, 17);
      });

      test('and [ifSuccess] is null throws ArgumentError', () {
        expect(
            () => loading.branch<int>(
                  ifSuccess: null,
                  ifFailed: (f) => f,
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
                  ifFailed: (f) => f,
                  ifLoading: null,
                ),
            throwsArgumentError);
      });
    });
  });

  group('*dataOr* if', () {
    test('Loading returns [ifNotSuccess]', () {
      const notSuccess = 'not success';
      expect(loading.dataOr(notSuccess), notSuccess);
    });

    test('Failed retursn [ifNotSuccess]', () {
      const notSuccess = 'not success';
      expect(failed.dataOr(notSuccess), notSuccess);
    });

    test('Success retursn [Success.data]', () {
      const notSuccess = 'not success';
      expect(success.dataOr(notSuccess), data);
    });
  });

  group(
    '"Loaded"',
    () {
      group(
        '*branchLoaded*',
        () {
          group(
            'if Failed',
            () {
              const failure = 'failure string';
              const Loaded<String, int> failed = Failed(failure);

              test(
                'returns ifFailed(failure)',
                () {
                  // ignore: prefer_const_declarations, omit_local_variable_types
                  final int Function(String) ifFailed = (s) => s.length;
                  // ignore: prefer_const_declarations, omit_local_variable_types
                  final int Function(int) ifSuccess = identity;
                  expect(
                    failed.branchLoaded(
                      ifFailed: ifFailed,
                      ifSuccess: ifSuccess,
                    ),
                    ifFailed(failure),
                  );
                },
              );

              test(
                'and [ifFailed] is null throws ArgumentError',
                () {
                  // ignore: omit_local_variable_types, prefer_const_declarations
                  final int Function(String) nullIfFailed = null;
                  // ignore: prefer_const_declarations, omit_local_variable_types
                  final int Function(int) ifSuccess = identity;
                  expect(
                    () => failed.branchLoaded(
                      ifFailed: nullIfFailed,
                      ifSuccess: ifSuccess,
                    ),
                    throwsArgumentError,
                  );
                },
              );

              test(
                'and [ifSuccess] is null throws ArgumentError',
                () {
                  // ignore: omit_local_variable_types, prefer_const_declarations
                  final int Function(String) ifFailed = (s) => s.length;
                  // ignore: prefer_const_declarations, omit_local_variable_types
                  final int Function(int) nullIfSuccess = null;
                  expect(
                    () => failed.branchLoaded(
                      ifFailed: ifFailed,
                      ifSuccess: nullIfSuccess,
                    ),
                    throwsArgumentError,
                  );
                },
              );
            },
          );

          group(
            'if Success',
            () {
              const successValue = 11;
              const Loaded<String, int> success = Success(successValue);

              test(
                'returns ifSuccess(success)',
                () {
                  // ignore: prefer_const_declarations, omit_local_variable_types
                  final String Function(String) ifFailed = identity;
                  // ignore: prefer_const_declarations, omit_local_variable_types
                  final String Function(int) ifSuccess = (n) => n.toString();
                  expect(
                    success.branchLoaded(
                      ifFailed: ifFailed,
                      ifSuccess: ifSuccess,
                    ),
                    ifSuccess(successValue),
                  );
                },
              );

              test(
                'and [ifFailed] is null throws ArgumentError',
                () {
                  // ignore: omit_local_variable_types, prefer_const_declarations
                  final String Function(String) nullIfFailed = null;
                  // ignore: prefer_const_declarations, omit_local_variable_types
                  final String Function(int) ifSuccess = (n) => n.toString();
                  expect(
                    () => success.branchLoaded(
                      ifFailed: nullIfFailed,
                      ifSuccess: ifSuccess,
                    ),
                    throwsArgumentError,
                  );
                },
              );

              test(
                'and [ifSuccess] is null throws ArgumentError',
                () {
                  // ignore: omit_local_variable_types, prefer_const_declarations
                  final String Function(String) ifFailed = identity;
                  // ignore: prefer_const_declarations, omit_local_variable_types
                  final String Function(int) nullIfSuccess = null;
                  expect(
                    () => success.branchLoaded(
                      ifFailed: ifFailed,
                      ifSuccess: nullIfSuccess,
                    ),
                    throwsArgumentError,
                  );
                },
              );
            },
          );
        },
      );
    },
  );
}
