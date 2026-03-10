class Pokemon {
  final String name;
  final String url;
  final int id;

  Pokemon({required this.name, required this.url, required this.id});

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    // Extract ID from URL - e.g., "https://pokeapi.co/api/v2/pokemon/25/"
    final urlParts = json['url'].split('/');
    final id = int.parse(urlParts[urlParts.length - 2]);
    
    return Pokemon(
      name: json['name'],
      url: json['url'],
      id: id,
    );
  }

  // Official artwork for optimal quality
  String get imageUrl => 
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';
  
  // Thumbnail is smaller - better for grid view
  String get thumbnailUrl => 
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png';
}

class PokemonDetail {
  final int id;
  final String name;
  final int height;
  final int weight;
  final List<String> types;
  final Map<String, int> stats; // e.g., {'hp': 45, 'attack': 49}
  final String description;
  final String imageUrl;

  PokemonDetail({
    required this.id,
    required this.name,
    required this.height,
    required this.weight,
    required this.types,
    required this.stats,
    required this.description,
    required this.imageUrl,
  });

  factory PokemonDetail.fromJson(Map<String, dynamic> json, String description) {
    // Extract types
    final types = (json['types'] as List)
        .map((t) => t['type']['name'] as String)
        .toList();

    // Extract base stats for UI
    int getStat(String name) {
      try {
        final stat = (json['stats'] as List).firstWhere(
          (s) => s['stat']['name'] == name,
          orElse: () => {'base_stat': 0},
        );
        return stat['base_stat'] as int? ?? 0;
      } catch (e) {
        return 0; // Fallback if API changes
      }
    }

    final stats = {
      'hp': getStat('hp'),
      'attack': getStat('attack'),
      'defense': getStat('defense'),
      'speed': getStat('speed'),
    };

    return PokemonDetail(
      id: json['id'],
      name: json['name'],
      height: json['height'],
      weight: json['weight'],
      types: types,
      stats: stats,
      description: description,
      imageUrl: json['sprites']['other']['official-artwork']['front_default'] ?? '',
    );
  }
}