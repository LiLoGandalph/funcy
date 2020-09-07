import 'package:funcy/funcy.dart';
import 'package:test/test.dart';

void main() {
  group('IterableOptionExtension:', () {
    group('*mapSomes*', () {
      test('maps Iterable with [f], then leaves only data from [Some]s', () {
        final f = (int n) => n.isOdd ? Some('$n') : const None<String>();
        final list = List.generate(10, identity);
        final actual = list.mapSomes(f).toList();
        final match = list
            .map(f)
            .where((opt) => opt.isSome)
            .map((some) => some.valueOr(null))
            .toList();
        expect(actual, match);
      });
    });
  });

  group('MapOptionExtension:', () {
    group('*tryGet*', () {
      final map = {7: 'seven', null: 'not null', 10: null};
      test(
          'if Map contains [key] to non-null value - '
          'returns [Some] with the value', () {
        expect(map.tryGet(7), Some(map[7]));
        expect(map.tryGet(null), Some(map[null]));
      });

      group('returns None if', () {
        test('Map does not contain given [key]', () {
          expect(map.tryGet(77), const None<String>());
        });

        test('value associated to [key] is null', () {
          expect(map.tryGet(10), const None<String>());
        });
      });
    });
  });

  group('JsonOptionExtension:', () {
    final json = {
      'int': 7,
      null: 'not null',
      'string': 'hello',
      'real null': null
    };
    group('*tryGet*', () {
      test(
          'if Map contains [key] to non-null value of type [T] - '
          'returns [Some] with the value casted to [T]', () {
        // ignore: avoid_as
        expect(json.tryGet<int>('int'), Some(json['int'] as int));
        // ignore: avoid_as
        expect(json.tryGet<String>(null), Some(json[null] as String));
      });

      group('returns None if', () {
        test('Map does not contain given [key]', () {
          expect(json.tryGet<int>('absent'), const None<int>());
        });

        test('value associated to [key] is null', () {
          expect(json.tryGet<int>('real null'), const None<int>());
          expect(json.tryGet<dynamic>('real null'), const None<dynamic>());
        });

        test('value associated to [key] is not of type [T]', () {
          expect(json.tryGet<int>('string'), const None<int>());
        });
      });
    });
  });

  group('StringOptionExtension:', () {
    group('*tryParseInt*', () {
      const iString = '101';
      const i = 101;
      const radix = 2;
      const iRadix = 5;

      group('if parses int', () {
        test('returns Some with result', () {
          expect(iString.tryParseInt(), const Some(i));
        });

        test('with radix returns Some with result', () {
          expect(iString.tryParseInt(radix: radix), const Some(iRadix));
        });
      });

      test('if failed to parse returns None', () {
        expect('not int'.tryParseInt(), const None<int>());
      });

      test('if string is null throws ArgumentError', () {
        expect(() => null.tryParseInt(), throwsArgumentError);
      });
    });

    group('*tryParseDouble*', () {
      const dString = '7.7';
      const d = 7.7;

      group('if parses double', () {
        test('returns Some with result', () {
          expect(dString.tryParseDouble(), const Some(d));
        });

        test('if failed to parse returns None', () {
          expect('not double'.tryParseDouble(), const None<double>());
        });

        test('if string is null throws ArgumentError', () {
          expect(() => null.tryParseDouble(), throwsArgumentError);
        });
      });
    });
  });
}
