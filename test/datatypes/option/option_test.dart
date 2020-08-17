import 'package:funcy/funcy.dart';
import 'package:test/test.dart';

void main() {
  const value = 7;
  final some = Option.fromNullable(value);
  final none = Option<int>.fromNullable(null);

  group('*equality*', () {
    group('is true for', () {
      test('Somes with equal values', () {
        const some1 = const Some(7);
        const some2 = const Some(7);
        expect(some1 == some2, isTrue);
      });

      test('Some and Option that is Some with equal values', () {
        const some = const Some(7);
        final option = Option.fromNullable(7);
        expect(some == option, isTrue);
      });

      test('Nones', () {
        const none1 = const None<int>();
        const none2 = const None<int>();
        expect(none1 == none2, isTrue);
      });

      test('None and Option that is None', () {
        const none = const None<int>();
        final option = Option<int>.fromNullable(null);
        expect(none == option, isTrue);
      });
    });

    group('is false for', () {
      test('Options that are Some and None', () {
        final some = Option.fromNullable(7);
        final none = Option<int>.fromNullable(null);
        expect(some == none, isFalse);
      });
    });
  });

  group('*Option.fromNullable*', () {
    group('if [nullableValue] is', () {
      test('not null returns Some with [nullableValue]', () {
        const value = 7;
        final some = Option.fromNullable(value);
        expect(some, const Some(value));
      });

      test('null returns None', () {
        expect(Option<int>.fromNullable(null), const None<int>());
      });
    });
  });

  group('*Option.fromEither*', () {
    group('if [either] is', () {
      test('Right returns Some with right value', () {
        const value = 'seven';
        final right = Either<int, String>.right(value);
        final some = Option.fromEither(right);
        expect(some, const Some(value));
      });

      test('Left returns None', () {
        const value = 7;
        final left = Either<int, String>.left(value);
        expect(Option.fromEither(left), const None<String>());
      });
    });
  });

  group('*Option.fromLeftEither*', () {
    group('if [either] is', () {
      test('Left returns Some with left value', () {
        const value = 7;
        final left = Either<int, String>.left(value);
        final some = Option.fromLeftEither(left);
        expect(some, const Some(value));
      });

      test('Right returns None', () {
        const value = 'seven';
        final right = Either<int, String>.right(value);
        expect(Option.fromLeftEither(right), const None<int>());
      });
    });
  });

  group('*isSome*', () {
    test('if is Some returns true', () {
      expect(some.isSome, isTrue);
    });

    test('if is None returns false', () {
      expect(none.isSome, isFalse);
    });
  });

  group('*isNone', () {
    test('if is Some returns false', () {
      expect(some.isNone, isFalse);
    });

    test('if is None returns true', () {
      expect(none.isNone, isTrue);
    });
  });

  group('*valueOr*', () {
    test('if is Some returns value', () {
      expect(some.valueOr(null), value);
    });

    test('if is None returns [ifNone]', () {
      const ifNone = 77;
      expect(none.valueOr(ifNone), ifNone);
    });
  });

  group('*valueOrDo*', () {
    group('if is Some', () {
      test('returns value', () {
        expect(some.valueOrDo(() => value - 1), value);
      });

      test('and [ifNone] is null throws ArgumentError', () {
        expect(() => some.valueOrDo(null), throwsArgumentError);
      });
    });

    group('if is None', () {
      test('calls [ifNone]', () {
        final ifNone = () => 77;
        expect(none.valueOrDo(ifNone), ifNone());
      });

      test('and [ifNone] is null throws ArgumentError', () {
        expect(() => none.valueOrDo(null), throwsArgumentError);
      });
    });
  });

  group('*option*', () {
    group('if is Some', () {
      test('applies [f] to value', () {
        final f = (int n) => n * 2;
        expect(some.option(constant(null), f), f(value));
      });

      test('and [f] is null throws ArgumentError', () {
        expect(() => some.option(constant(77), null), throwsArgumentError);
      });
    });

    group('if is None', () {
      test('calls [ifNone]', () {
        final ifNone = () => 'seven';
        expect(none.option(ifNone, (n) => n.toString()), ifNone());
      });

      test('and [f] is null throws ArgumentError', () {
        expect(() => none.option(constant(77), null), throwsArgumentError);
      });
    });
  });

  group('*doIfSome*', () {
    var counter = 0;
    final action = (int n) => counter += n;

    setUp(() {
      counter = 0;
    });

    group('if is Some', () {
      test('calls [action] with value', () {
        final initial = counter;
        some.doIfSome(action);
        final result = counter;
        counter = initial;
        action(value);
        expect(counter, result);
      });

      test('and [action] is null throws ArgumentError', () {
        expect(() => some.doIfSome(null), throwsArgumentError);
      });
    });

    group('if is None', () {
      test('does nothing', () {
        final initial = counter;
        none.doIfSome(action);
        final result = counter;
        expect(initial, result);
      });

      test('and [action] is null throws ArgumentError', () {
        expect(() => none.doIfSome(null), throwsArgumentError);
      });
    });
  });

  group('*map*', () {
    final f = (int n) => n.isOdd;

    group('if is Some', () {
      test('applies [f] to value and returns the result in Some', () {
        final result = some.map(f);
        expect(result, Some(f(value)));
      });

      test('and [f] is null throws ArgumentError', () {
        expect(() => some.map<int>(null), throwsArgumentError);
      });
    });

    group('if is None', () {
      test('returns None', () {
        final result = none.map(f);
        expect(result, const None<bool>());
      });

      test('and [f] is null throws ArgumentError', () {
        expect(() => none.map<int>(null), throwsArgumentError);
      });
    });
  });

  group('*bind*', () {
    final f = (int n) => n.isOdd ? Some('odd: $n') : const None<String>();
    group('if is Some', () {
      test('applies [f] to value', () {
        final result = some.bind(f);
        expect(result, f(value));
      });

      test('and [f] is null throws ArgumentError', () {
        expect(() => some.bind<int>(null), throwsArgumentError);
      });
    });

    group('if is None', () {
      test('returns None', () {
        final result = none.bind(f);
        expect(result, const None<String>());
      });

      test('and [f] is null throws ArgumentError', () {
        expect(() => none.bind<int>(null), throwsArgumentError);
      });
    });
  });

  group('*or*', () {
    group('if is Some', () {
      test('returns self', () {
        const Option<int> another = null;
        final some2 = some.or(another);
        expect(some, some2);
      });
    });

    group('if is None', () {
      test('returns [another]', () {
        const another = const Some(7);
        final another2 = none.or(another);
        expect(another, another2);
      });
    });
  });

  group('*|*', () {
    group('if is Some', () {
      test('returns self', () {
        const Option<int> another = null;
        final some2 = some | another;
        expect(some, some2);
      });
    });

    group('if is None', () {
      test('returns [another]', () {
        const another = const Some(7);
        final another2 = none | another;
        expect(another, another2);
      });
    });
  });

  group('guard', () {
    group('if is Some and predicate is', () {
      test('true returns Some', () {
        expect(some.guard((_) => true), some);
      });

      test('false returns None', () {
        expect(some.guard((_) => false), none);
      });

      test('null throws ArgumentError', () {
        expect(() => some.guard(null), throwsArgumentError);
      });
    });

    group('if is None and predicate is', () {
      test('true returns None', () {
        expect(none.guard((_) => true), none);
      });

      test('false returns None', () {
        expect(none.guard((_) => false), none);
      });

      test('null throws ArgumentError', () {
        expect(() => none.guard(null), throwsArgumentError);
      });
    });
  });

  group('JoinOptionExtension:', () {
    group('*join*', () {
      test('if is Some returns inner Option', () {
        final innerOption = Option.fromNullable(7);
        final someOption = Option.fromNullable(innerOption);
        expect(someOption.join(), innerOption);
      });

      test('if is None returns None', () {
        final none = Option<Option<int>>.fromNullable(null);
        expect(none.join(), const None<int>());
      });
    });
  });
}
