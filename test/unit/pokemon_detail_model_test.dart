import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/models/pokemon.dart';

void main() {
  group('PokemonDetail Model', () {
    test('fromJson parses stats correctly', () {
      final json = {
        'id': 25,
        'name': 'pikachu',
        'height': 4,
        'weight': 60,
        'types': [
          {'type': {'name': 'electric'}}
        ],
        'stats': [
          {'stat': {'name': 'hp'}, 'base_stat': 35},
          {'stat': {'name': 'attack'}, 'base_stat': 55},
          {'stat': {'name': 'defense'}, 'base_stat': 40},
          {'stat': {'name': 'speed'}, 'base_stat': 90},
        ],
        'sprites': {
          'other': {
            'official-artwork': {
              'front_default': 'https://example.com/pikachu.png'
            }
          }
        }
      };
      
      final description = 'A cute electric mouse';
      final detail = PokemonDetail.fromJson(json, description);
      
      expect(detail.id, 25);
      expect(detail.name, 'pikachu');
      expect(detail.types, ['electric']);
      expect(detail.stats['hp'], 35);
      expect(detail.stats['attack'], 55);
      expect(detail.imageUrl, 'https://example.com/pikachu.png');
    });

    test('handles missing stats gracefully', () {
      final json = {
        'id': 1,
        'name': 'bulbasaur',
        'height': 7,
        'weight': 69,
        'types': [],
        'stats': [], // Empty stats
        'sprites': {
          'other': {
            'official-artwork': {
              'front_default': null
            }
          }
        }
      };
      
      final detail = PokemonDetail.fromJson(json, 'Test description');
      
      expect(detail.stats['hp'], 0); // Should default to 0
      expect(detail.imageUrl, ''); // Should default to empty string
    });
  });
}