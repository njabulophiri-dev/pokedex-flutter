import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pokemon.dart';
import '../services/pokeapi_service.dart';

class PokemonProvider extends ChangeNotifier {
  final PokeApiService _apiService = PokeApiService();
  
  List<Pokemon> _pokemonList = [];
  List<Pokemon> get pokemonList => _pokemonList;
  
  // Store favourites as Set for O(1) lookup, much faster than List
  final Set<int> _favouriteIds = {};
  Set<int> get favouriteIds => _favouriteIds;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  String? _error;
  String? get error => _error;
  
  // Pagination - API returns 20 at a time
  int _currentOffset = 0;
  bool _hasMore = true;
  bool get hasMore => _hasMore;
  
  String _searchQuery = '';
  List<Pokemon> get filteredPokemonList {
    if (_searchQuery.isEmpty) return _pokemonList;
    // Simple case-insensitive search
    return _pokemonList.where((p) => 
      p.name.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }
  
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  PokemonProvider() {
    loadPokemon();
    loadLocalFavourites();
    loadThemePreference();
    
    // Switch between cloud and local when user logs in/out
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        loadUserFavourites(user.uid);
      } else {
        loadLocalFavourites();
      }
    });
  }

  Future<void> loadPokemon({bool reset = false}) async {
    if (reset) {
      _currentOffset = 0;
      _pokemonList = [];
      _hasMore = true;
    }
    
    if (!_hasMore || _isLoading) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newPokemon = await _apiService.getPokemonList(offset: _currentOffset);
      
      if (newPokemon.isEmpty) {
        _hasMore = false; // No more data
      } else {
        _pokemonList = [..._pokemonList, ...newPokemon];
        _currentOffset += 20; // Next page
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void search(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> toggleFavourite(int pokemonId) async {
    final User? user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      // Use local storage when not logged in
      _toggleLocalFavourite(pokemonId);
      await _saveLocalFavourites(); // Save immediately
      notifyListeners();
      return;
    }

    // Sync to cloud if Logged in
    try {
      final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      
      if (_favouriteIds.contains(pokemonId)) {
        await userRef.update({
          'favourites': FieldValue.arrayRemove([pokemonId])
        });
        _favouriteIds.remove(pokemonId);
      } else {
        await userRef.update({
          'favourites': FieldValue.arrayUnion([pokemonId])
        });
        _favouriteIds.add(pokemonId);
      }
      notifyListeners();
    } catch (e) {
      print('Firestore error: $e - falling back to local');
      // If Offline Save locally
      _toggleLocalFavourite(pokemonId);
      await _saveLocalFavourites();
    }
  }

  void _toggleLocalFavourite(int pokemonId) {
    if (_favouriteIds.contains(pokemonId)) {
      _favouriteIds.remove(pokemonId);
    } else {
      _favouriteIds.add(pokemonId);
    }
  }

  bool isFavourite(int pokemonId) => _favouriteIds.contains(pokemonId);

  Future<void> loadUserFavourites(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      
      if (userDoc.exists) {
        final List<dynamic> favourites = userDoc.data()?['favourites'] ?? [];
        _favouriteIds.clear();
        _favouriteIds.addAll(favourites.map((e) => e as int).toSet());
      }
      notifyListeners();
    } catch (e) {
      print('Error loading cloud favourites: $e');
      await loadLocalFavourites(); // Fallback
    }
  }

  Future<void> _saveLocalFavourites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        'favourites',
        _favouriteIds.map((id) => id.toString()).toList(),
      );
    } catch (e) {
      print('Error saving local favourites: $e');
    }
  }

  Future<void> loadLocalFavourites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favs = prefs.getStringList('favourites') ?? [];
      _favouriteIds.clear();
      _favouriteIds.addAll(favs.map((id) => int.parse(id)).toSet());
      notifyListeners();
    } catch (e) {
      print('Error loading local favourites: $e');
      _favouriteIds.clear();
    }
  }

  void toggleTheme() {
    if (_themeMode == ThemeMode.light) {
      _themeMode = ThemeMode.dark;
    } else if (_themeMode == ThemeMode.dark) {
      _themeMode = ThemeMode.system;
    } else {
      _themeMode = ThemeMode.light;
    }
    _saveThemePreference();
    notifyListeners();
  }

  Future<void> _saveThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String themeValue;
      if (_themeMode == ThemeMode.light) {
        themeValue = 'light';
      } else if (_themeMode == ThemeMode.dark) {
        themeValue = 'dark';
      } else {
        themeValue = 'system';
      }
      await prefs.setString('theme_mode', themeValue);
    } catch (e) {
      print('Error saving theme: $e');
    }
  }

  Future<void> loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeValue = prefs.getString('theme_mode') ?? 'system';
      
      if (themeValue == 'light') {
        _themeMode = ThemeMode.light;
      } else if (themeValue == 'dark') {
        _themeMode = ThemeMode.dark;
      } else {
        _themeMode = ThemeMode.system;
      }
      notifyListeners();
    } catch (e) {
      print('Error loading theme: $e');
      _themeMode = ThemeMode.system;
    }
  }

  // Helper to get Pokemon by ID in detail screen
  Pokemon? getPokemonById(int id) {
    try {
      return _pokemonList.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void resetSearch() {
    _searchQuery = '';
    notifyListeners();
  }
}