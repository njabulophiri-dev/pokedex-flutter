import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:pokedex_app/models/pokemon.dart';
import 'package:pokedex_app/widgets/pokemon_card.dart';
import 'package:pokedex_app/providers/pokemon_provider.dart';
import 'package:pokedex_app/providers/auth_provider.dart';

// Mock classes
class MockPokemonProvider with ChangeNotifier implements PokemonProvider {
  @override
  bool isFavourite(int id) => id == 25; // Make Pikachu favourite for testing
  
  @override
  bool get isLoading => false;
  
  @override
  String? get error => null;
  
  @override
  List<Pokemon> get filteredPokemonList => [];
  
  @override
  Set<int> get favouriteIds => {25};
  
  @override
  bool get hasMore => true;
  
  @override
  List<Pokemon> get pokemonList => [];
  
  @override
  ThemeMode get themeMode => ThemeMode.system;
  
  @override
  void loadPokemon({bool reset = false}) {}
  
  @override
  void search(String query) {}
  
  @override
  Future<void> toggleFavourite(int pokemonId) async {}
  
  @override
  void toggleTheme() {}
  
  @override
  void clearError() {}
  
  @override
  void resetSearch() {}
  
  @override
  Pokemon? getPokemonById(int id) => null;
}

class MockAuthProvider with ChangeNotifier implements AuthProvider {
  @override
  User? get user => null;
  
  @override
  String? get error => null;
  
  @override
  bool get isLoading => false;
  
  @override
  bool get isLoggedIn => false;
  
  @override
  Future<bool> signIn(String email, String password) async => false;
  
  @override
  Future<bool> signUp(String email, String password) async => false;
  
  @override
  Future<void> signOut() async {}
  
  @override
  void clearError() {}
}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets('PokemonCard displays name and image', (WidgetTester tester) async {
    final pokemon = Pokemon(
      name: 'pikachu',
      url: 'https://pokeapi.co/api/v2/pokemon/25/',
      id: 25,
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<PokemonProvider>.value(value: MockPokemonProvider()),
          ChangeNotifierProvider<AuthProvider>.value(value: MockAuthProvider()),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: PokemonCard(
              pokemon: pokemon,
              onTap: () {},
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('pikachu'), findsOneWidget);
    expect(find.text('#025'), findsOneWidget);
  });

  testWidgets('PokemonCard handles tap', (WidgetTester tester) async {
    var tapped = false;
    final pokemon = Pokemon(name: 'bulbasaur', url: '', id: 1);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<PokemonProvider>.value(value: MockPokemonProvider()),
          ChangeNotifierProvider<AuthProvider>.value(value: MockAuthProvider()),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: PokemonCard(
              pokemon: pokemon,
              onTap: () => tapped = true,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.byType(InkWell));
    await tester.pump();

    expect(tapped, true);
  });
}