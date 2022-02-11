import '../filter.dart';

typedef Matcher<T> = bool Function(T selected, T query);
typedef Selector<T, R> = R Function(T item);

class SearchFilter<T, R> {
  final Matcher<R> _matcher;
  final InputMapper<R>? _mapper;
  final Selector<T, R> _selector;

  const SearchFilter({
    required Matcher<R> matcher,
    required Selector<T, R> selector,
    InputMapper<R>? mapper,
  }) :
    _matcher = matcher,
    _selector = selector,
    _mapper = mapper;

  bool doesMatch(T item, String query) {
    final selected = _selector(item);
    final mapped = (_mapper ?? InputMapper.forType<R>()).map(query);

    return _matcher(selected, mapped);
  }
}
