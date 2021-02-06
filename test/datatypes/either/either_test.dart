import 'package:funcy/funcy.dart';
import 'package:test/test.dart';

void main() {
  const rightValue = 7;
  final right = Either.right<String, int>(rightValue);
  const leftValue = 'seven';
  final left = Either.left<String, int>(leftValue);

  group(
    '*fromOption*',
    () {
      test(
        'if [optionalRight] is Some(right) - returns Right(right)',
        () {
          const Option<int> someRight = Some(rightValue);
          expect(Either.fromOption(someRight, leftValue), right);
        },
      );

      test(
        'if [optionalRight] is None() - returns Left([left])',
        () {
          const Option<int> noneRight = None();
          expect(Either.fromOption(noneRight, leftValue), left);
        },
      );

      test(
        'if [optionalRight] is null - throws ArgumentError',
        () {
          const Option<int> nullOptionalRight = null;
          expect(
            () => Either.fromOption(nullOptionalRight, leftValue),
            throwsArgumentError,
          );
        },
      );
    },
  );

  group(
    '*fromLoaded*',
    () {
      test(
        'if [loaded] is Failed(left) - returns Left(left)',
        () {
          const Loaded<String, int> failed = Failed(leftValue);
          expect(Either.fromLoaded(failed), left);
        },
      );

      test(
        'if [loaded] is Success(right) - returns Right(right)',
        () {
          const Loaded<String, int> success = Success(rightValue);
          expect(Either.fromLoaded(success), right);
        },
      );

      test(
        'if [loaded] is null - throws ArgumentError',
        () {
          const Loaded<String, int> nullLoaded = null;
          expect(() => Either.fromLoaded(nullLoaded), throwsArgumentError);
        },
      );
    },
  );

  group(
    '*fromLoadable*',
    () {
      group(
        'if [loadable] is',
        () {
          test(
            'Failed(left) - returns Left(left)',
            () {
              const Loaded<String, int> failed = Failed(leftValue);
              expect(Either.fromLoaded(failed), left);
            },
          );

          test(
            'Success(right) - returns Right(right)',
            () {
              const Loaded<String, int> success = Success(rightValue);
              expect(Either.fromLoaded(success), right);
            },
          );

          test(
            'null - throws ArgumentError',
            () {
              const Loaded<String, int> nullLoaded = null;
              expect(() => Either.fromLoaded(nullLoaded), throwsArgumentError);
            },
          );
        },
      );
    },
  );

  group(
    '*mirrored*',
    () {
      test(
        'if Left(left) - returns Right(left)',
        () {
          expect(left.mirrored(), const Right<int, String>(leftValue));
        },
      );
      test('if Right(right) - returns Left(right)', () {
        expect(right.mirrored(), const Left<int, String>(rightValue));
      });
    },
  );

  group('equality', () {
    group('is true for', () {
      test('Rights with equal values', () {
        const value = 7;
        const right1 = const Right<String, int>(value);
        const right2 = const Right<String, int>(value);
        expect(right1 == right2, isTrue);
      });

      test('Right and Either that is Right with equal values', () {
        const value = 7;
        const right = const Right<String, int>(value);
        final either = Either.right<String, int>(value);
        expect(right == either, isTrue);
      });

      test('Eithers that are Rights with equal values', () {
        const value = 7;
        final either1 = Either.right<String, int>(value);
        final either2 = Either.right<String, int>(value);
        expect(either1 == either2, isTrue);
      });

      test('Lefts with equal values', () {
        const value = 7;
        const left1 = const Left<int, String>(value);
        const left2 = const Left<int, String>(value);
        expect(left1 == left2, isTrue);
      });

      test('Left and Either that is Left with equal values', () {
        const value = 7;
        const left = const Left<int, String>(value);
        final either = Either.left<int, String>(value);
        expect(left == either, isTrue);
      });

      test('Eithers that are Lefts with equal values', () {
        const value = 7;
        final either1 = Either.left<int, String>(value);
        final either2 = Either.left<int, String>(value);
        expect(either1 == either2, isTrue);
      });
    });

    group('is false for', () {
      test('Rights with non-equal values', () {
        const right1 = const Right<String, int>(7);
        const right2 = const Right<String, int>(0);
        expect(right1 == right2, isFalse);
      });

      test('Lefts with non-equal values', () {
        const left1 = const Left<int, String>(7);
        const left2 = const Left<int, String>(0);
        expect(left1 == left2, isFalse);
      });

      test('Eithers that are Left and Right with any values', () {
        final left = Either.left<int, int>(7);
        final right = Either.right<int, int>(7);
        expect(left == right, isFalse);
      });
    });
  });

  group('*isLeft* is', () {
    test('true, when Left.', () {
      const Either<String, int> strOrInt = const Left('seven');
      expect(strOrInt.isLeft, isTrue);
    });

    test('false, when Right.', () {
      const Either<String, int> strOrInt = const Right(7);
      expect(strOrInt.isLeft, isFalse);
    });
  });

  group('*isRight* is', () {
    test('false, when Left.', () {
      const Either<String, int> strOrInt = const Left('seven');
      expect(strOrInt.isRight, isFalse);
    });

    test('true, when Right.', () {
      const Either<String, int> strOrInt = const Right(7);
      expect(strOrInt.isRight, isTrue);
    });
  });

  group('*map*', () {
    group('if Right', () {
      test('applies [f] to value and returns it in Right', () {
        final f = (int n) => n - 2;
        final rightFive = right.map(f);
        expect(rightFive, Right<String, int>(f(rightValue)));
      });

      test('and [f] is null throws ArgumentError', () {
        expect(() => right.map<bool>(null), throwsArgumentError);
      });
    });

    group('if Left', () {
      test('does not change Left value', () {
        final f = (int n) => n / 2;
        final leftUpd = left.map(f);
        expect(leftUpd, const Left<String, double>(leftValue));
      });

      test('and [f] is null throws ArgumentError', () {
        expect(() => left.map<bool>(null), throwsArgumentError);
      });
    });
  });

  group('*bind*', () {
    group('if Right', () {
      test('applies [f] to value', () {
        final f = (int n) => Either.right<String, bool>(n > 0);
        final result = right.bind(f);
        expect(result, f(rightValue));
      });

      test('and [f] is null throws ArgumentError', () {
        expect(() => right.bind<bool>(null), throwsArgumentError);
      });
    });

    group('if Left', () {
      test('does not change Left value', () {
        final f = (int n) => Either.right<String, double>(n / 2);
        final leftUpd = left.bind(f);
        expect(leftUpd, const Left<String, double>(leftValue));
      });

      test('and [f] is null throws ArgumentError', () {
        expect(() => left.bind<bool>(null), throwsArgumentError);
      });
    });
  });

  group('*either*', () {
    group('if Right', () {
      test('applies [fromRight] to value', () {
        final result = right.either(identity, (n) => n.toString());
        expect(result, rightValue.toString());
      });

      test('and [fromLeft] is null throws ArgumentError', () {
        expect(() => right.either(null, identity), throwsArgumentError);
      });

      test('and [fromRight] is null throws ArgumentError', () {
        expect(() => right.either(identity, null), throwsArgumentError);
      });
    });

    group('if Left', () {
      test('applies [fromLeft] to value', () {
        final result = left.either((s) => s.length, identity);
        expect(result, leftValue.length);
      });

      test('and [fromLeft] is null throws ArgumentError', () {
        expect(() => left.either(null, identity), throwsArgumentError);
      });

      test('and [fromRight] is null throws ArgumentError', () {
        expect(() => left.either(identity, null), throwsArgumentError);
      });
    });
  });

  group('*fromRight*', () {
    group('if Right', () {
      test('applies [fromRight] to value', () {
        final f = (int n) => n * 2;
        final result = right.fromRight(null, f);
        expect(result, f(rightValue));
      });

      test('and [fromRight] is null throws ArgumentError', () {
        expect(() => right.fromRight(7, null), throwsArgumentError);
      });
    });

    group('if Left', () {
      const value = 77;

      test('returns [ifLeft]', () {
        final result = left.fromRight(value, identity);
        expect(result, value);
      });

      test('and [fromRight] is null throws ArgumentError', () {
        expect(() => left.fromRight(value, null), throwsArgumentError);
      });
    });
  });

  group('*rightOr*', () {
    group('if Right', () {
      test('returns value', () {
        expect(right.rightOr(null), rightValue);
      });
    });
    group('if Left', () {
      test('returns [ifLeft]', () {
        const value = 77;
        expect(left.rightOr(value), value);
      });
    });
  });

  group('*fromLeft*', () {
    group('if Right', () {
      const value = 'seventy seven';

      test('returns [ifRight]', () {
        final result = right.fromLeft(value, identity);
        expect(result, value);
      });

      test('and [fromLeft] is null throws ArgumentError', () {
        expect(() => right.fromLeft(value, null), throwsArgumentError);
      });
    });

    group('if Left', () {
      test('applies [fromLeft] to value', () {
        final f = (String s) => s.length;
        final result = left.fromLeft(null, f);
        expect(result, f(leftValue));
      });

      test('and [fromLeft] is null throws ArgumentError', () {
        expect(() => left.fromLeft(7, null), throwsArgumentError);
      });
    });
  });

  group('*leftOr*', () {
    group('if Right', () {
      test('returns [ifRight]', () {
        const value = 'seventy seven';
        expect(right.leftOr(value), value);
      });
    });

    group('if Left', () {
      test('returns value', () {
        expect(left.leftOr(null), leftValue);
      });
    });
  });

  group('*toOption*', () {
    group('if Right', () {
      test('returns Some with value', () {
        expect(right.toOption(), const Some(rightValue));
      });
    });

    group('if Left', () {
      test('returns None', () {
        expect(left.toOption(), const None<int>());
      });
    });
  });
}
