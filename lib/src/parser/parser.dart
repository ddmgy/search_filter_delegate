import 'package:equatable/equatable.dart';
import 'package:petitparser/petitparser.dart';

// Remove when petitparser v4.5.0 is released.
extension _SurroundedByParserExtension<T> on Parser<T> {
  Parser<T> surroundedBy(Parser<void> before, [Parser<void>? after]) => [
    before,
    this,
    after ?? before,
  ].toSequenceParser()
      .pick(1)
      .cast<T>();
}

class _SearchFilterGrammarDefinition extends GrammarDefinition {
  @override
  Parser start() => ref0(_filter);

  Parser _filter() => [
    char('@'),
    ref0(_filterName),
    char(':'),
    ref0(_filterTerm),
  ].toSequenceParser();

  Parser _filterName() => pattern(r'A-Za-z0-9\-_\.')
      .plus()
      .flatten();

  Parser _filterTerm() => <Parser>[
    ref0(_simpleTerm),
    ref0(_singleQuotedTerm),
    ref0(_doubleQuotedTerm),
  ].toChoiceParser()
      .flatten();

  Parser _simpleTerm() => ref0(_filterName);

  Parser _singleQuotedTerm() => pattern(r'A-Za-z0-9\-_\.\,\?\!\(\)\^\"').plus()
      .separatedBy(whitespace().plus())
      .surroundedBy(char("'"));

  Parser _doubleQuotedTerm() => pattern(r"A-Za-z0-9\-_\.\,\'").plus()
      .separatedBy(whitespace().plus())
      .surroundedBy(char('"'));
}

class SearchFilterParserDefinition extends _SearchFilterGrammarDefinition {
  @override
  Parser<ParserResult> start() => super.start().map((it) => ParserResult(
    name: it[1],
    term: it[3],
  ));
}

class ParserResult extends Equatable {
  final String name;
  final String term;

  @override
  List<Object?> get props => [
    name,
    term,
  ];

  @override
  bool get stringify => true;

  const ParserResult({
    required this.name,
    required this.term,
  });
}
