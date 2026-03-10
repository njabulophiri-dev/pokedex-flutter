import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pokemon.dart';

class PokeApiService {
  static const String baseUrl = 'https://pokeapi.co/api/v2';

  Future<List<Pokemon>> getPokemonList({int offset = 0, int limit = 20}) async {
    final url = Uri.parse('$baseUrl/pokemon?offset=$offset&limit=$limit');
    
    try {
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['results'];
        return results.map((json) => Pokemon.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load Pokémon: ${response.statusCode}');
      }
    } catch (e) {
      // Re-throw with context
      throw Exception('Network error fetching Pokémon list: $e');
    }
  }

  Future<Map<String, dynamic>> getPokemonDetail(int id) async {
    // Need two endpoints: pokemon/{id} for stats, species/{id} for description
    final pokemonUrl = Uri.parse('$baseUrl/pokemon/$id');
    final speciesUrl = Uri.parse('$baseUrl/pokemon-species/$id');
    
    try {
      final pokemonResponse = await http.get(pokemonUrl);
      final speciesResponse = await http.get(speciesUrl);
      
      if (pokemonResponse.statusCode == 200 && speciesResponse.statusCode == 200) {
        final pokemonData = json.decode(pokemonResponse.body);
        final speciesData = json.decode(speciesResponse.body);
        
        // Find English description; fallback if not found
        String description = 'No description available';
        try {
          final flavorText = (speciesData['flavor_text_entries'] as List)
              .firstWhere(
                (entry) => entry['language']['name'] == 'en',
                orElse: () => {'flavor_text': description},
              )['flavor_text'];
          
          // Clean up weird characters
          description = flavorText
              .replaceAll('\n', ' ')
              .replaceAll('\f', ' ');
        } catch (e) {
          print('Error parsing description: $e');
        }

        return {
          'pokemon': pokemonData,
          'description': description,
        };
      } else {
        throw Exception('Failed to load Pokémon details');
      }
    } catch (e) {
      throw Exception('Network error fetching details: $e');
    }
  }
}