## 3.1.0

- Fix broken generic parameters in datatype conversion extensions.

- Add [NullableToOption] extension with [asOptional()] to convert nullable
(actually, any) types to [Option].

## 3.0.0

- Make [Future] transformer extensions actually useful.

- Add methods and extensions for easy conversion between datatypes.

## 2.1.0

- Add [Loadable.isSuccess] and [Loadable.dataOr].

## 2.0.1

- Fix bug with [JsonOptionExtension.tryGet] when called with [dynamic] 
as a type parameter it returned [Some] even when there where no proper value.

## 2.0.0

- Added [Failed.failure] field - you very often need a reason of failure.
So, [Loadable] is now parameterised by 2 generic types
and is more resembling of [Either] with extra [Loading] case.
That is also the reason [Loadable] does not implement [Alternative] anymore.

## 1.0.1

- Lowered *meta* package minimum version to support current version of Flutter.

## 1.0.0

- Initial version