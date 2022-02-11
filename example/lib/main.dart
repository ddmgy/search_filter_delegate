import 'dart:math' as Math;

import 'package:flutter/material.dart';

import 'package:equatable/equatable.dart';
import 'package:search_filter_delegate/search_filter_delegate.dart';

void main() {
  runApp(const MyApp());
}

class Pokemon extends Equatable {
  final String name;
  final String type;
  final int nationalDexNumber;
  final int generationIntroduced;

  @override
  List<Object?> get props => [
    name,
    type,
    nationalDexNumber,
    generationIntroduced,
  ];

  @override
  bool get stringify => true;

  const Pokemon(
    this.name,
    this.type,
    this.nationalDexNumber,
    this.generationIntroduced,
  );
}

// These are the 2020 Pokemon of the Year, I did not make this list.
const _pokemon = [
  Pokemon('Greninja', 'Water/Dark', 658, 6),
  Pokemon('Lucario', 'Fighting/Steel', 448, 4),
  Pokemon('Mimikyu', 'Ghost/Fairy', 778, 7),
  Pokemon('Charizard', 'Fire/Flying', 6, 1),
  Pokemon('Umbreon', 'Dark', 197, 2),
  Pokemon('Sylveon', 'Fairy', 700, 6),
  Pokemon('Garchomp', 'Dragon/Ground', 445, 4),
  Pokemon('Rayquaza', 'Dragon/Flying', 384, 3),
  Pokemon('Gardevoir', 'Psychic/Fairy', 282, 3),
  Pokemon('Gengar', 'Ghost/Poison', 94, 1),
  Pokemon('Dragapult', 'Dragon/Ghost', 887, 8),
  Pokemon('Tyranitar', 'Rock/Dark', 248, 2),
  Pokemon('Bulbasaur', 'Grass/Poison', 1, 1),
  Pokemon('Toxtricity', 'Electric/Poison', 849, 8),
  Pokemon('Lugia', 'Psychic/Flying', 249, 2),
  Pokemon('Rowlet', 'Grass/Flying', 722, 8),
  Pokemon('Aegislash', 'Steel/Ghost', 681, 6),
  Pokemon('Chandelure', 'Ghost/Fire', 609, 5),
  Pokemon('Pikachu', 'Electric', 25, 1),
  Pokemon('Eevee', 'Normal', 133, 1),
  Pokemon('Luxray', 'Electric', 405, 4),
  Pokemon('Decidueye', 'Grass/Ghost', 724, 7),
  Pokemon('Zoroark', 'Dark', 571, 5),
  Pokemon('Lycanroc', 'Rock', 745, 7),
  Pokemon('Corviknight', 'Flying/Steel', 823, 8),
  Pokemon('Flygon', 'Ground/Dragon', 330, 3),
  Pokemon('Hydreigon', 'Dark/Dragon', 635, 5),
  Pokemon('Sceptile', 'Grass', 254, 3),
  Pokemon('Blaziken', 'Fire/Fighting', 257, 3),
  Pokemon('Snom', 'Ice/Bug', 872, 8),
];

const _typeColors = <String, Color>{
  'normal': Color(0xFFAAAA99),
  'fire': Color(0xFFFF4422),
  'water': Color(0xFF3399FF),
  'electric': Color(0xFFFFCC33),
  'grass': Color(0xFF77CC55),
  'ice': Color(0xFF66CCFF),
  'fighting': Color(0xFFBB5544),
  'poison': Color(0xFFAA5599),
  'ground': Color(0xFFDDBB55),
  'flying': Color(0xFF8899FF),
  'psychic': Color(0xFFFF5599),
  'bug': Color(0xFFAABB22),
  'rock': Color(0xFFBBAA66),
  'ghost': Color(0xFF6666BB),
  'dragon': Color(0xFF7766EE),
  'dark': Color(0xFF775544),
  'steel': Color(0xFFAABB99),
  'fairy': Color(0xFFEE99EE),

};

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'search_filter_delegate example',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('search_filter_delegate example'),
    ),
    body: ListView.builder(
      itemCount: _pokemon.length,
      itemBuilder: (context, index) => _pokemonBuilder(
        context,
        _pokemon[index],
      ),
    ),
    floatingActionButton: FloatingActionButton(
      tooltip: 'Search people with filters',
      child: const Icon(Icons.search),
      onPressed: () => showSearch(
        context: context,
        delegate: SearchFilterDelegate<Pokemon>(
          items: _pokemon,
          onSelected: (pokemon) => print(pokemon),
          filters: {
            'name': SearchFilter<Pokemon, String>(
              selector: (pokemon) => pokemon.name.toLowerCase(),
              matcher: (name, query) => name.contains(query),
            ),
            'type': SearchFilter<Pokemon, String>(
              selector: (pokemon) => pokemon.type.toLowerCase(),
              matcher: (type, query) => type.contains(query),
            ),
            'gen': SearchFilter<Pokemon, int>(
              selector: (pokemon) => pokemon.generationIntroduced,
              matcher: (genIntroduced, query) => genIntroduced == query,
            ),
            'dexBefore': SearchFilter<Pokemon, int>(
              selector: (pokemon) => pokemon.nationalDexNumber,
              matcher: (dexNumber, query) => dexNumber < query,
            ),
          },
          resultBuilder: _pokemonBuilder,
          suggestionBuilder: _pokemonBuilder,
          emptyBuilder: (_) => const Center(
            child: Text('No Pokemon found'),
          ),
          errorBuilder: (_, query, error) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Error parsing: ${query}'),
                Text(error.toString()),
              ],
            ),
          ),
          explanationBuilder: (context) =>  const [
            Text('name: Pokemon\'s name contains term'),
            Text('type: Pokemon\'s type contains term'),
            Text('gen: Pokemon\'s initial generation equals term (as integer)'),
            Text('dexBefore: Pokemon\'s national Pokedex number is less than term (as integer)'),
          ],
        ),
      ),
    ),
  );

  Widget _pokemonBuilder(BuildContext context, Pokemon pokemon) => ListTile(
    leading: _iconBuilder(context, pokemon.type),
    title: Text(pokemon.name),
    subtitle: Text('${pokemon.type}, introduced in Generation ${pokemon.generationIntroduced}'),
    trailing: Text('${pokemon.nationalDexNumber}'),
  );

  Widget _iconBuilder(BuildContext context, String types) {
    final colors = types.split('/')
      .map((type) => Expanded(
        flex: 1,
        child: Container(
          color: _typeColors[type.toLowerCase()] ?? const Color(0xFF000000),
        ),
      ))
      .toList();

    return SizedBox(
      width: 48,
      height: 48,
      child: ClipOval(
        clipBehavior: Clip.antiAlias,
        child: Transform(
          transform: Matrix4.rotationZ(Math.pi / 5),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: colors,
          ),
        ),
      ),
    );
  }
}
