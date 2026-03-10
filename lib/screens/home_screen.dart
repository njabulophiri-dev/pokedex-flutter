import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pokemon_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/pokemon_card.dart';
import 'detail_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: Consumer2<PokemonProvider, AuthProvider>(
        builder: (context, pokemonProvider, authProvider, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Pokédex'),
              actions: [
                // Theme toggle button
                IconButton(
                  icon: const Icon(Icons.brightness_4),
                  onPressed: () {
                    pokemonProvider.toggleTheme();
                  },
                ),
                // Menu button
                Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () => Scaffold.of(context).openEndDrawer(),
                  ),
                ),
              ],
            ),
            endDrawer: _buildDrawer(context, pokemonProvider, authProvider),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search Pokémon...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (query) {
                      pokemonProvider.search(query);
                    },
                  ),
                ),
                Expanded(
                  child: _buildPokemonGrid(context, pokemonProvider),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, PokemonProvider pokemonProvider, AuthProvider authProvider) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drawer Header with Menu title
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Theme.of(context).primaryColor,
            child: const Text(
              'MENU',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Drawer Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Favourites item (always visible)
                ListTile(
                  leading: const Icon(Icons.favorite, color: Colors.red),
                  title: const Text('Favourites'),
                  onTap: () {
                    Navigator.pop(context); // Close drawer
                    _showFavourites(context, pokemonProvider, authProvider);
                  },
                ),
                
                const Divider(),
                
                // Auth items (conditional)
                if (!authProvider.isLoggedIn) ...[
                  ListTile(
                    leading: const Icon(Icons.login),
                    title: const Text('Log In'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LoginScreen(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.person_add),
                    title: const Text('Sign Up'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LoginScreen(isSignUp: true),
                        ),
                      );
                    },
                  ),
                ] else ...[
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(authProvider.user?.email ?? 'Profile'),
                    enabled: false,
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Logout'),
                    onTap: () async {
                      await authProvider.signOut();
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Logged out successfully')),
                        );
                      }
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFavourites(BuildContext context, PokemonProvider pokemonProvider, AuthProvider authProvider) {
    if (!authProvider.isLoggedIn) {
      _showSignInPrompt(context);
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final favourites = pokemonProvider.pokemonList
            .where((p) => pokemonProvider.isFavourite(p.id))
            .toList();

        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Favourites',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: favourites.isEmpty
                    ? const Center(child: Text('No favourites yet'))
                    : GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.9,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: favourites.length,
                        itemBuilder: (context, index) {
                          final pokemon = favourites[index];
                          return PokemonCard(
                            pokemon: pokemon,
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DetailScreen(pokemonId: pokemon.id),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSignInPrompt(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign in to save favorites'),
        content: const Text(
          'Create an account to keep your favorite Pokémon across devices.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const LoginScreen(),
                ),
              );
            },
            child: const Text('Sign In'),
          ),
        ],
      ),
    );
  }

  Widget _buildPokemonGrid(BuildContext context, PokemonProvider provider) {
    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: ${provider.error}'),
            ElevatedButton(
              onPressed: () => provider.loadPokemon(reset: true),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final pokemonList = provider.filteredPokemonList;
    
    if (pokemonList.isEmpty && !provider.isLoading) {
      return const Center(
        child: Text('No Pokémon found'),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.pixels >= 
            notification.metrics.maxScrollExtent - 200) {
          provider.loadPokemon();
        }
        return true;
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.9,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: pokemonList.length + (provider.isLoading ? 20 : 0),
        itemBuilder: (context, index) {
          if (index >= pokemonList.length) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          
          final pokemon = pokemonList[index];
          return PokemonCard(
            pokemon: pokemon,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetailScreen(pokemonId: pokemon.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}