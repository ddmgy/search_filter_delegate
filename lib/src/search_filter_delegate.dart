import 'package:flutter/material.dart';

import 'filter.dart';
import 'parser.dart';

typedef ItemSelectedCallback<T> = void Function(T);
typedef WidgetItemBuilder<T> = Widget Function(BuildContext, T);

class SearchFilterDelegate<T> extends SearchDelegate<T> {
  final _parser = SearchFilterParserDefinition().build();

  final List<T> items;
  final ItemSelectedCallback<T> onSelected;
  final Map<String, SearchFilter<T, dynamic>> filters;
  final SearchFilter<T, String>? remainderFilter;
  final bool ignoreRemainder;
  final WidgetItemBuilder<T> resultBuilder;
  final WidgetItemBuilder<T>? suggestionBuilder;
  final WidgetBuilder emptyBuilder;
  final Widget Function(BuildContext, String, Object) errorBuilder;
  final List<Widget> Function(BuildContext)? explanationBuilder;
  final bool showHelp;

  SearchFilterDelegate({
    required this.items,
    required this.onSelected,
    required this.filters,
    this.remainderFilter,
    this.ignoreRemainder = true,
    required this.resultBuilder,
    this.suggestionBuilder,
    required this.emptyBuilder,
    required this.errorBuilder,
    this.explanationBuilder,
    this.showHelp = true,
    String? searchLabel,
  }) :
    assert(ignoreRemainder || remainderFilter != null),
    super(
      searchFieldLabel: searchLabel,
    );

  @override
  List<Widget>? buildActions(BuildContext context) => [
    IconButton(
      icon: const Icon(Icons.close),
      onPressed: () => query = '',
    ),
    if (showHelp) IconButton(
      icon: const Icon(Icons.help),
      onPressed: () => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Filter information'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Filters take the form @name:term'),
                const Text('term in filter may be surrounded by single- or double- quotes'),
                const Text('Unknown filters will be ignored'),
                const SizedBox(height: 8),
                const Text('Available filters:'),
                if (explanationBuilder != null) ...explanationBuilder!.call(context),
              ],
            ),
          ),
        ),
      ),
    ),
  ];

  @override
  Widget? buildLeading(BuildContext context) => null;

  @override
  Widget buildResults(BuildContext context) => _buildEntries(
    context,
    resultBuilder,
  );

  @override
  Widget buildSuggestions(BuildContext context) => _buildEntries(
    context,
    suggestionBuilder ?? resultBuilder,
  );

  Widget _buildEntries(BuildContext context, WidgetItemBuilder<T> builder) {
    final result = _parser.matchesSkippingWithRemainder(query);
    List<T> filteredItems = List<T>.of(items, growable: false);

    for (final match in result.matches) {
      if (match is ParserResult) {
        final filter = filters[match.name];
        if (filter != null) {
          try {
            filteredItems = filteredItems
              .where((item) => filter.doesMatch(item, match.term))
              .toList();
          } catch (e) {
            return errorBuilder(context, match.term, e);
          }
        }
      }
    }

    final remainder = result.remainder.trim();
    if (remainder.isNotEmpty && !ignoreRemainder) {
      try {
        filteredItems = filteredItems
          .where((item) => remainderFilter!.doesMatch(item, remainder))
          .toList();
      } catch (e) {
        return errorBuilder(context, remainder, e);
      }
    }

    if (filteredItems.isEmpty) {
      return emptyBuilder(context);
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        final item = filteredItems[index];

        return Stack(
          children: [
            builder(context, item),
            Positioned.fill(
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  onTap: () => onSelected(item),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
