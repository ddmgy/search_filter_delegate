abstract class InputMapper<T> {
  const InputMapper();

  T map(String input);

  static InputMapper<R> forType<R>() {
    if (!_registeredInputMappers.containsKey(R)) {
      throw Exception(
        'There is no InputMapper registered for type ${R}. '
        'Register type with InputMapper.registerInputMapper<${R}>.'
      );
    }

    return _registeredInputMappers[R]! as InputMapper<R>;
  }

  static InputMapper<R>? tryForType<R>() {
    if (_registeredInputMappers.containsKey(R)) {
      return _registeredInputMappers[R]! as InputMapper<R>;
    }

    return null;
  }

  static bool registerInputMapper<R>(
    InputMapper<R> inputMapper, {
      bool overwrite = false,
  }) {
    final typeExists = _registeredInputMappers.containsKey(R);
    if (!typeExists || overwrite) {
      _registeredInputMappers[R] = inputMapper;
    }

    return typeExists;
  }

  static InputMapper<R> unregisterInputMapper<R>() {
    return _registeredInputMappers.remove(R) as InputMapper<R>;
  }

  static final Map<Type, InputMapper> _registeredInputMappers = {
    num: const NumInputMapper(),
    int: const IntInputMapper(),
    double: const DoubleInputMapper(),
    String: const StringInputMapper(),
  };
}

class StringInputMapper extends InputMapper<String> {
  const StringInputMapper();

  @override
  String map(String input) => input;
}

class NumInputMapper extends InputMapper<num> {
  const NumInputMapper();

  @override
  num map(String input) => num.parse(input);
}

class IntInputMapper extends InputMapper<int> {
  const IntInputMapper();

  @override
  int map(String input) => int.parse(input);
}

class DoubleInputMapper extends InputMapper<double> {
  const DoubleInputMapper();

  @override
  double map(String input) => double.parse(input);
}
