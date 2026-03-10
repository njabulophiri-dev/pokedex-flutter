import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:pokedex_app/screens/home_screen.dart';
import 'package:pokedex_app/providers/pokemon_provider.dart';
import 'package:pokedex_app/providers/auth_provider.dart';
import 'package:pokedex_app/models/pokemon.dart';

// Mock classes that DON'T extend real providers
class MockPokemonProvider with ChangeNotifier implements PokemonProvider {
  @override
  bool get isLoading => false;
  
  @override
  String? get error => null;
  
  @override
  List<Pokemon> get filteredPokemonList => [];
  
  @override
  bool isFavourite(int id) => false;
  
  @override
  Set<int> get favouriteIds => {};
  
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

  testWidgets('Home screen has search bar and app bar', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<PokemonProvider>.value(value: MockPokemonProvider()),
          ChangeNotifierProvider<AuthProvider>.value(value: MockAuthProvider()),
        ],
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Verify app bar title
    expect(find.text('Pokédex'), findsOneWidget);
    
    // Verify search field exists
    expect(find.byType(TextField), findsOneWidget);
    
    // Check for search icon
    expect(find.byIcon(Icons.search), findsOneWidget);
    
    // Verify theme toggle button
    expect(find.byIcon(Icons.brightness_4), findsOneWidget);
    
    // Verify menu button
    expect(find.byIcon(Icons.menu), findsOneWidget);
  });
}