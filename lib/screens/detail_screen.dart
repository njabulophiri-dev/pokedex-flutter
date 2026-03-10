import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/pokeapi_service.dart';
import '../models/pokemon.dart';
import '../providers/pokemon_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class DetailScreen extends StatefulWidget {
  final int pokemonId;

  const DetailScreen({super.key, required this.pokemonId});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final PokeApiService _apiService = PokeApiService();
  PokemonDetail? _pokemon;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    try {
      final data = await _apiService.getPokemonDetail(widget.pokemonId);
      setState(() {
        _pokemon = PokemonDetail.fromJson(
          data['pokemon'],
          data['description'],
        );
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: $_error'),
                      ElevatedButton(
                        onPressed: _loadDetails,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    final provider = Provider.of<PokemonProvider>(context);
    final isFavourite = provider.isFavourite(widget.pokemonId);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 300,
          floating: false,
          pinned: true,
          actions: [
            IconButton(
              icon: Icon(
                isFavourite ? Icons.favorite : Icons.favorite_border,
                color: isFavourite ? Colors.red : Colors.white,
              ),
              onPressed: () {
                provider.toggleFavourite(widget.pokemonId);
              },
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              _pokemon!.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            background: Stack(
              fit: StackFit.expand,
              children: [
                Container(color: Colors.grey[200]),
                CachedNetworkImage(
                  imageUrl: _pokemon!.imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => 
                      const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => 
                      const Icon(Icons.error, size: 50),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Types
                Row(
                  children: _pokemon!.types.map((type) {
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getTypeColor(type),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        type,
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                
                // Description
                Text(
                  _pokemon!.description,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                
                // Stats
                const Text(
                  'Stats',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildStat('HP', _pokemon!.stats['hp']!),
                _buildStat('Attack', _pokemon!.stats['attack']!),
                _buildStat('Defense', _pokemon!.stats['defense']!),
                _buildStat('Speed', _pokemon!.stats['speed']!),
                const SizedBox(height: 16),
                
                // Height/Weight
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                        'Height',
                        '${_pokemon!.height / 10} m',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInfoCard(
                        'Weight',
                        '${_pokemon!.weight / 10} kg',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStat(String label, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: LinearProgressIndicator(
              value: value / 255,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                value > 150 ? Colors.green : Colors.orange,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(value.toString()),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'fire': return Colors.orange;
      case 'water': return Colors.blue;
      case 'grass': return Colors.green;
      case 'electric': return Colors.yellow.shade700;
      case 'psychic': return Colors.pink;
      case 'ice': return Colors.lightBlue;
      case 'dragon': return Colors.deepPurple;
      case 'dark': return Colors.brown;
      case 'fairy': return Colors.pink.shade300;
      case 'poison': return Colors.purple;
      case 'ground': return Colors.amber;
      case 'flying': return Colors.indigo.shade300;
      case 'bug': return Colors.lightGreen;
      case 'rock': return Colors.amber.shade800;
      case 'ghost': return Colors.deepPurple.shade400;
      case 'steel': return Colors.blueGrey;
      default: return Colors.grey;
    }
  }
}