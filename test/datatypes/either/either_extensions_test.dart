import 'package:funcy/funcy.dart';
import 'package:test/test.dart';

void main() {
  group('JoinEitherExtension:', () {
    group('*join*', () {
      test('if Right returns inner value', () {
        const inRight = const Right<String, int>(7);
        const outRight = const Right<String, Either<String, int>>(inRight);
        expect(outRight.join(), inRight);
      });

      test('if Left returns self', () {
        const left = const Left<String, Either<String, int>>('seven');
        expect(left.join(), const Left<String, int>('seven'));
      });
    });
  });

  group('IterableEitherExtension:', () {
    final list = List.generate(10, identity);
    final f = (int n) => n.isOdd
        ? Either.right<String, int>(n * n)
        : Either.left<String, int>(n.toString());

    group('*whereRights*', () {
      test('Leaves only Right values', () {
        final eithers = list.map(f).toList();
        final rightValues = eithers.whereRights().toList();
        final test = eithers
            .where((eith) => eith.isRight)
            .map((rights) => rights.rightOr(null))
            .toList();
        expect(rightValues, test);
      });
    });

    group('*whereLefts*', () {
      test('Leaves only Left values', () {
        final eithers = list.map(f).toList();
        final leftValues = eithers.whereLefts().toList();
        final test = eithers
            .where((eith) => eith.isLeft)
            .map((lefts) => lefts.leftOr(null))
            .toList();
        expect(leftValues, test);
      });
    });
  });
}
