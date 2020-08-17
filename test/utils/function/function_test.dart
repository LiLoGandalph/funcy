import 'package:test/test.dart';

import 'package:funcy/funcy.dart';

void main() {
  group('*identity*', () {
    group('returns', () {
      test('the same value it is given', () {
        const value = 7;
        expect(identity(value), value);
      });
      test('null if given null', () {
        expect(identity(null), null);
      });
    });
  });

  group('*constFun*', () {
    test('creates function that always returns [value] whatever argument is',
        () {
      const value = 7;
      expect(constFun<int, int>(value)(10), value);
      expect(constFun<int, int>(value)(null), value);
    });
    test('returns null if [value] is null', () {
      expect(constFun<int, int>(null)(10), null);
    });
  });

  group('*constant*', () {
    test('creates function that always returns [value]', () {
      const value = 7;
      expect(constant(value)(), value);
    });

    test('returns null if [value] is null', () {
      expect(constant(null)(), null);
    });
  });

  group('FunctionFunctionExtension:', () {
    group('*then*', () {
      test(
          'creates function that applies [next] to the result '
          'of applying this to given argument', () {
        final x2 = (int n) => n * 2;
        final add3 = (int n) => n + 3;
        final str = (int n) => 'int: $n';
        final check = x2.then(add3).then(str);
        final match = (int n) => str(add3(x2(n)));
        expect(check(5), match(5));
      });

      test('throws ArgumentError if [next] is null', () {
        final x2 = (int n) => n * 2;
        expect(() => x2.then<bool>(null), throwsArgumentError);
      });
    });

    group('*thenConst*', () {
      test(
          'creates function that returns [value] '
          'after applying this to given argument', () {
        var counter = 1;
        final doubleCounter = (int n) => counter *= 2;
        final complete = doubleCounter
            .then(doubleCounter)
            .then(doubleCounter)
            .thenConst('complete');
        expect(complete(1), 'complete');
        expect(counter, 8);
      });
    });

    group('*after*', () {
      test(
          'creates function that applies this to the result '
          'of applying [first] to given argument', () {
        final x2 = (num n) => n * 2;
        final add3 = (num n) => n + 3;
        final str = (num n) => 'int: $n';
        final check = str.after(add3).after(x2);
        final match = (num n) => str(add3(x2(n)));
        expect(check(5), match(5));
      });

      test('throws ArgumentError if [first] is null', () {
        final x2 = (num n) => n * 2;
        expect(() => x2.after<bool>(null), throwsArgumentError);
      });
    });
  });

  group('FunctionObjectExtension:', () {
    group('*pipe*', () {
      test('creates function that applies [f] to this', () {
        final x2 = (int n) => n * 2;
        const value = 7;
        expect(value.pipe(x2), x2(value));
      });

      test('throws ArgumentError if [f] is null', () {
        const value = 7;
        expect(() => value.pipe<bool>(null), throwsArgumentError);
      });
    });
    group('*discardWith*', () {
      test(
          'creates function that applies this to '
          'given argument and returns [value]', () {
        var counter = 1;
        final doubleCounter = (int n) => counter *= 2;
        final complete = doubleCounter
            .then(doubleCounter)
            .then(doubleCounter)(1)
            .discardWith('complete');
        expect(complete, 'complete');
        expect(counter, 8);
      });
    });
  });
}
