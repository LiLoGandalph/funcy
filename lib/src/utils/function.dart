/// Identity function - returns its argument.
/// ```
/// identity(7) // 7
/// identity(0) // 0
/// ```
/// Synonym for `(x) => x`.
/// Useful as a 'tear-off' (curried function),
/// where function is required as an argument.
/// ```
/// final optName = json.tryGet<String>('name');
/// optName.option(getDefaultName, identity);
/// ```
T identity<T>(T value) => value;

/// Creates constant function that always returns [value]
/// whatever given argument is.
/// ```
/// final const7 = constFun(7);
/// assertconst7(5) == 7);
/// assert(const7(0) == 7);
/// ```
/// Synonym for `(_) => value`. Useful as a 'tear-off' (curried function),
/// where function is required as an argument.
/// ```
/// final defaultValue = getDefaultValue();
/// List.generate(100, constFun(defaultValue));
/// ```
C Function(T) constFun<C, T>(C value) => (_) => value;

/// Creates constant function that always returns [value].
/// ```
/// final const7 = constant(7);
/// assert(const7() == 7);
/// assert(const7() == 7);
/// ```
/// Synonym for `() => value`. Useful as a 'tear-off' (curried function),
/// where function is required as an argument.
/// ```
/// final defaultLength = await getDefaultLength();
/// optString.option(constant(defaultLength), (s) => s.length);
/// optString.option(() => defaultLength, (s) => s.length);
/// ```
C Function() constant<C>(C value) => () => value;

/// Auxilary methods for function composition and *'fluent'* APIs.
extension FunctionFunctionExtension<A, B> on B Function(A) {
  /// Applies the function to given argument, then applies [next] to the result.
  ///
  /// ```
  /// final x2 = (n) => n * 2;
  /// final add3 = (n) => n + 3;
  /// x2.then(add3).then(print)(5); // prints '13'
  /// // is the same as
  /// print(add3(x2(5))); // prints '13'
  /// ```
  ///
  /// Throws [ArgumentError] if [next] is null.
  C Function(A) then<C>(C Function(B) next) {
    ArgumentError.checkNotNull(next, 'next');
    return (argument) => next(this(argument));
  }

  /// Applies the function to givent argument, then returns [value].
  ///
  /// Shorthand for `func.then(constant(value))`.
  C Function(A) thenConst<C>(C value) => then(constFun(value));

  /// Applies the function to the result of applying [first] to given argument.
  ///
  /// ```
  /// final x2 = (n) => n * 2;
  /// final add3 = (n) => n + 3;
  /// print.after(add3).after(x2)(5); // prints '13'
  /// // is the same as
  /// print(add3(x2(5))); // prints '13'
  /// ```
  B Function(C) after<C>(A Function(C) first) {
    ArgumentError.checkNotNull(first, 'first');
    return (argumentToFirst) => this(first(argumentToFirst));
  }
}

/// Auxilary methods for objects in function compositions and *'fluent'* APIs.
extension FunctionObjectExtension<T> on T {
  /// Applies [f] to the object.
  ///
  /// Can be useful in function compositions  and *'fluent'* APIs.
  /// ```
  /// List.generate(100, (i) => i * i)
  ///   .map((n) => createBussinessObject(n))
  ///   .where(bussinessFilter)
  ///   .take(7)
  ///   .toList(growable: false)
  ///   .pipe((objects) => usingBussinessObjects(objects));
  ///
  /// // is the same as
  ///
  /// usingBussinessObjects(
  ///   List.generate(100, (i) => i * i)
  ///     .map((n) => createBussinessObject(n))
  ///     .where(bussinessFilter)
  ///     .take(7)
  ///     .toList(growable: false));
  /// ```
  R pipe<R>(R Function(T) f) {
    ArgumentError.checkNotNull(f, 'f');
    return f(this);
  }

  /// Drops the object and returns [value].
  ///
  /// Shorthand for `obj.pipe((_) => anotherObj)`.
  ///
  /// ```
  /// final trace = (msg, value) => print('$msg: $value').discardWith(value);
  /// final seven = trace('Seven', 3 + 4); // prints 'Seven: 7'
  /// assert(seven, 7);
  /// ```
  R discardWith<R>(R value) => value;
}
