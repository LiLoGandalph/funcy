## 2.0.0

- Added [Failed.failure] field - you very often need a reason of failure.
So, [Loadable] is now parameterised by 2 generic types
and is more resembling of [Either] with extra [Loading] case.
That is also the reason [Loadable] does not implement [Alternative] anymore.

## 1.0.1

- Lowered *meta* package minimum version to support current version of Flutter.

## 1.0.0

- Initial version