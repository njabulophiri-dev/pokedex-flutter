import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/models/pokemon.dart';

void main() {
  group('Pokemon Model', () {
    test('fromJson creates correct Pokemon from API response', () {
      final json = {
        'name': 'pikachu',
        'url': 'https://pokeapi.co/api/v2/pokemon/25/'
      };
      
      final pokemon = Pokemon.fromJson(json);
      
      expect(pokemon.name, 'pikachu');
      expect(pokemon.id, 25);
      expect(pokemon.imageUrl, contains('25.png'));
      expect(pokemon.thumbnailUrl, contains('25.png'));
    });

    test('handles different ID formats correctly', () {
      final json = {
        'name': 'bulbasaur',
        'url': 'https://pokeapi.co/api/v2/pokemon/1/'
      };
      
      final pokemon = Pokemon.fromJson(json);
      expect(pokemon.id, 1);
    });
  });
}