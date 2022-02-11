import 'package:equatable/equatable.dart';
import 'package:petitparser/petitparser.dart';

class MatchesSkippingWithRemainderResult<T> extends Equatable {
  final List<T> matches;
  final String remainder;

  @override
  List<Object?> get props => [
    matches,
    remainder,
  ];

  const MatchesSkippingWithRemainderResult(this.matches, this.remainder);

  @override
  String toString() => "${runtimeType}(${matches}, '${remainder}')";
}

extension MatchesSkippingWithRemainderParserExtensions<T> on Parser<T> {
  MatchesSkippingWithRemainderResult<T> matchesSkippingWithRemainder(String input) {
    final matches = <T>[];
    final failures = <int>[];

    mapWithRemainder(
      matches.add,
      failures.add,
      hasSideEffects: true,
    ).or(any()).star().fastParseOn(input, 0);

    return MatchesSkippingWithRemainderResult(
      matches,
      String.fromCharCodes(failures),
    );
  }
}

extension MapWithRemainderParserExtensions<T> on Parser<T> {
  Parser<R> mapWithRemainder<R>(
    R Function(T) successCallback,
    R Function(int) failureCallback, {
      bool hasSideEffects = false,
    }
  ) => MapWithRemainderParser<T, R>(
    this,
    successCallback,
    failureCallback,
    hasSideEffects,
  );
}

class MapWithRemainderParser<T, R> extends DelegateParser<T, R> {
  final R Function(T) successCallback;
  final R Function(int) failureCallback;
  final bool hasSideEffects;

  MapWithRemainderParser(
    Parser<T> delegate,
    this.successCallback,
    this.failureCallback, [
      this.hasSideEffects = false,
    ]
  ) : super(delegate);

  @override
  Result<R> parseOn(Context context) {
    final result = delegate.parseOn(context);

    if (result.isSuccess) {
      return result.success(successCallback(result.value));
    } else {
      // I do not like this. Need to investigate better solutions.
      if (result.position < result.buffer.length) {
        failureCallback(result.buffer.codeUnitAt(result.position));
      }

      return result.failure(result.message);
    }
  }

  @override
  int fastParseOn(String buffer, int position) => hasSideEffects
    ? super.fastParseOn(buffer, position)
    : delegate.fastParseOn(buffer, position);

  @override
  MapWithRemainderParser<T, R> copy() => MapWithRemainderParser(
    delegate,
    successCallback,
    failureCallback,
    hasSideEffects,
  );

  @override
  bool hasEqualProperties(MapWithRemainderParser<T, R> other) => super.hasEqualProperties(other)
    && successCallback == other.successCallback
    && failureCallback == other.failureCallback
    && hasSideEffects == other.hasSideEffects;
}
