import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../typeclasses/functor.dart';
import 'loadable.dart';
import 'option.dart';

// NOTICE
// Constant constructors return values with dynamic parameter types
// instead of set generic ones.
// That is why there are some *ingore* pragmas.
// NOTICE

/// Represents possibility of 2 types of values: [Left] or [Right].
@immutable
abstract class Either<L, R> extends Equatable implements Monad<R> {
  const Either._();

  /// Right value of [Either].
  ///
  /// Same as [Right(right)].
  static Either<L, R> right<L, R>(R right) => Right(right);

  /// Left value of [Either].
  ///
  /// Same as [Left(left)].
  static Either<L, R> left<L, R>(L left) => Left(left);

  /// Creates [Either] from [Option].
  ///
  /// * If [optionalRight] is Some(right) - returns Right(right).
  /// * If [optionalRight] is None() - returns Left([left]).
  static Either<L, R> fromOption<L, R>(Option<R> optionalRight, L left) {
    ArgumentError.checkNotNull(optionalRight, 'optionalRight');
    return optionalRight.option(
      () => Either.left(left),
      Either.right,
    );
  }

  /// Creates [Either] from [Loaded]:
  /// * [Success] -> [Right]
  /// * [Failed] -> [Left]
  static Either<L, R> fromLoaded<L, R>(Loaded<L, R> loaded) {
    ArgumentError.checkNotNull(loaded, 'loaded');
    return loaded.branchLoaded(
      ifFailed: Either.left,
      ifSuccess: Either.right,
    );
  }

  /// Creates [Either] from [Loadable]:
  /// * [Success] -> [Right]
  /// * [Failed] -> [Left]
  /// * [Loading] -> [ifLoading]
  static Either<L, R> fromLoadable<L, R>(
    Loadable<L, R> loadable, {
    @required Either<L, R> Function() ifLoading,
  }) {
    ArgumentError.checkNotNull(ifLoading, 'ifLoading');
    if (loadable is Loaded<L, R>) {
      return Either.fromLoaded(loadable);
    } else {
      return ifLoading();
    }
  }

  /// Turns [Left] into [Right] and [Right] into [Left].
  Either<R, L> mirrored() {
    return either(
      (left) => Right(left),
      (right) => Left(right),
    );
  }

  @override
  bool get stringify => true;

  /// If is [Left].
  ///
  /// `is Left<L,R>` may be more useful as it casts
  /// variable to [Left] so you can get data directly via [Left.left].
  ///
  /// ```
  /// final Either<String, int> stringOrInt = Left('seven');
  ///
  /// if (stringOrInt.isLeft) {
  ///   // Can't use Left.left here.
  ///   // But we checked that it is Left,
  ///   // so using .leftOr(null) will never result in null
  ///   // (unless actual value in Left is null).
  ///   final seven = stringOrInt.leftOr(null); // 'seven'
  /// }
  ///
  /// if (stringOrInt is Left<String, int>) {
  ///   // stringOrInt is treated as Left<String, int> here.
  ///   // So we can use [Left.left] directly.
  ///   final seven = stringOrInt.left; // 'seven'
  /// }
  /// ```
  bool get isLeft;

  /// If is [Right].
  ///
  /// `is Right<L,R>` may be more useful as it casts
  /// variable to [Right] so you can get data directly via [Right.right].
  ///
  /// ```
  /// final Either<String, int> stringOrInt = Right(7);
  ///
  /// if (stringOrInt.isRight) {
  ///   // Can't use Right.right here.
  ///   // But we checked that it is Right,
  ///   // so using .rightOr(null) will never result in null
  ///   // (unless actual value in Right is null).
  ///   final seven = stringOrInt.rightOr(null); // 7
  /// }
  ///
  /// if (stringOrInt is Right<String, int>) {
  ///   // stringOrInt is treated as Right<String, int> here.
  ///   // So we can use [Right.right] directly.
  ///   final seven = stringOrInt.right; // 7
  /// }
  /// ```
  bool get isRight;

  /// Functor map.
  ///
  /// If is [Right] - applies [f] to value and returns it in [Right].
  /// Otherwise does nothing.
  ///
  /// ```
  /// Either<ApiError, Msg> receiveMsg() {...}
  /// ApiData findDataForMsg(Msg) {...}
  ///
  /// final errorOrData = receiveMsg().map(findDataForMsg);
  /// ```
  ///
  /// If [f] is null - throws [ArgumentError].
  @override
  Either<L, T> map<T>(T Function(R value) f);

  /// Monad bind.
  ///
  /// If is [Right] - applies [f] to the value. Otherwise does nothing.
  ///
  /// Similar to [map], but allows [f] to return [Either].
  ///
  /// ```
  /// Either<ApiError, RawMsg> makeRequest() {...}
  /// Either<ApiError, Msg> tryParseMsg(RawMsg rawMsg) {...}
  ///
  /// Either<ApiError, Msg> errorOrMsg = makeRequest().bind(tryParseMsg);
  /// ```
  ///
  /// If [f] is null - throws [ArgumentError].
  @override
  Either<L, T> bind<T>(Either<L, T> Function(R value) f);

  /// Branches execution:
  ///
  /// * is [Left] - [fromLeft] is applied to value,
  /// * is [Right] - [fromRight] is applied to value.
  ///
  /// ```
  /// Either<ApiError, ApiResponse> errorOrResponse = await makeRequest();
  /// errorOrResponse.either(
  ///   (error) {
  ///     writeLog(error);
  ///     retryRequest();
  ///   },
  ///   (response) {
  ///     useApiResponse(response);
  ///   },
  /// );
  /// ```
  ///
  /// If [fromLeft] and/or [fromRight] is null - throws [ArgumentError].
  T either<T>(T Function(L) fromLeft, T Function(R) fromRight);

  /// If is [Right] - applies [fromRight] to value. Otherwise returns [ifLeft].
  ///
  /// If [fromRight] is null - throws [ArgumentError].
  T fromRight<T>(T ifLeft, T Function(R) fromRight);

  /// If is [Right] - returns value. Otherwise returns [ifLeft].
  R rightOr(R ifLeft);

  /// If is [Left] - applies [fromLeft] to value. Otherwise returns [ifRight].
  ///
  /// If [fromLeft] is null - throws [ArgumentError].
  T fromLeft<T>(T ifRight, T Function(L) fromLeft);

  /// If is [Left] - returns value. Otherwise returns [ifRight].
  L leftOr(L ifRight);

  L _unsafeLeft();
  R _unsafeRight();
}

/// Left value of [Either]. Conventionally represents 'failure'.
class Left<L, R> extends Either<L, R> {
  /// Left value of [Either]. Conventionally represents 'failure'.
  const Left(this.left) : super._();

  /// Left value.
  final L left;

  @override
  List<Object> get props => [left];

  @override
  L _unsafeLeft() => left;
  @override
  R _unsafeRight() => throw UnsupportedError("Can't get *right* from Left");

  @override
  T either<T>(T Function(L) fromLeft, T Function(R) fromRight) {
    ArgumentError.checkNotNull(fromLeft, 'fromLeft');
    ArgumentError.checkNotNull(fromRight, 'fromRight');
    return fromLeft(left);
  }

  @override
  T fromLeft<T>(T ifRight, T Function(L) fromLeft) {
    ArgumentError.checkNotNull(fromLeft, 'fromLeft');
    return fromLeft(left);
  }

  @override
  T fromRight<T>(T ifLeft, T Function(R) fromRight) {
    ArgumentError.checkNotNull(fromRight, 'fromRight');
    return ifLeft;
  }

  @override
  bool get isLeft => true;

  @override
  bool get isRight => false;

  @override
  Either<L, T> map<T>(T Function(R) f) {
    ArgumentError.checkNotNull(f, 'f');
    return Left(left);
  }

  @override
  Either<L, T> bind<T>(Either<L, T> Function(R) f) {
    ArgumentError.checkNotNull(f, 'f');
    return Left(left);
  }

  @override
  L leftOr(L ifRight) => left;

  @override
  R rightOr(R ifLeft) => ifLeft;
}

/// Right value of [Either]. Conventionally represents 'success'.
class Right<L, R> extends Either<L, R> {
  /// Right value of [Either]. Conventionally represents 'success'.
  const Right(this.right) : super._();

  /// Right value.
  final R right;

  @override
  List<Object> get props => [right];

  @override
  L _unsafeLeft() => throw StateError("Can't get *left* from Right");
  @override
  R _unsafeRight() => right;

  @override
  T either<T>(T Function(L) fromLeft, T Function(R) fromRight) {
    ArgumentError.checkNotNull(fromLeft, 'fromLeft');
    ArgumentError.checkNotNull(fromRight, 'fromRight');
    return fromRight(right);
  }

  @override
  T fromLeft<T>(T ifRight, T Function(L) fromLeft) {
    ArgumentError.checkNotNull(fromLeft, 'fromLeft');
    return ifRight;
  }

  @override
  T fromRight<T>(T ifLeft, T Function(R) fromRight) {
    ArgumentError.checkNotNull(fromRight, 'fromRight');
    return fromRight(right);
  }

  @override
  bool get isLeft => false;

  @override
  bool get isRight => true;

  @override
  Either<L, T> map<T>(T Function(R) f) {
    ArgumentError.checkNotNull(f, 'f');
    return Right(f(right));
  }

  @override
  Either<L, T> bind<T>(Either<L, T> Function(R) f) {
    ArgumentError.checkNotNull(f, 'f');
    return f(right);
  }

  @override
  L leftOr(L ifRight) => ifRight;

  @override
  R rightOr(R ifLeft) => right;
}

/// Type-safe monad join implementation.
extension JoinEitherExtension<L, R> on Either<L, Either<L, R>> {
  /// 'Joins' 2 nested [Either]s.
  ///
  /// Returns [Right] only if both are [Right]. Otherwise returns [Left].
  ///
  /// ```
  /// Either<String, Either<String, int>> rightRightSeven = Right(Right(7));
  /// Either<String, Either<String, int>> rightLeftFail = Right(Left('fail'));
  /// Either<String, Either<String, int>> leftFail = Left('fail');
  ///
  /// rightRightSeven.join() // Right(7)
  /// rightLeftFail.join() // Left('fail')
  /// leftFail.join() // Left('fail')
  /// ```
  Either<L, R> join() => isRight ? _unsafeRight() : Left(_unsafeLeft());
}

/// Filtering methods on [Iterable] with [Either].
extension IterableEitherExtension<L, R> on Iterable<Either<L, R>> {
  /// Leaves only [Right] values.
  Iterable<R> whereRights() =>
      where((eith) => eith.isRight).map((right) => right._unsafeRight());

  /// Leaves only [Left] values.
  Iterable<L> whereLefts() =>
      where((eith) => eith.isLeft).map((left) => left._unsafeLeft());
}

/// Method for converting [Option] into [Either].
extension OptionToEitherExtension<L, R> on Option<R> {
  /// Extension method using [Either.fromOption].
  Either<L, R> toEither(L leftIfNone) => Either.fromOption(this, leftIfNone);
}

/// Method for converting [Loadable] into [Either].
extension LoadableToEitherExtension<L, R> on Loadable<L, R> {
  /// Extension method using [Either.fromLoadable].
  Either<L, R> toEither({@required Either<L, R> Function() ifLoading}) {
    return Either.fromLoadable(this, ifLoading: ifLoading);
  }
}

/// Method for converting [Loaded] into [Either].
extension LoadedToEitherExtension<L, R> on Loaded<L, R> {
  /// Extension method using [Either.fromLoaded].
  Either<L, R> toEither() => Either.fromLoaded(this);
}
