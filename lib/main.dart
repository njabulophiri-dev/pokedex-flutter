import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';  // Generated file
import 'providers/pokemon_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with generated options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PokemonProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: Consumer<PokemonProvider>(
        builder: (context, provider, child) {
          return MaterialApp(
            title: 'Pokédex',
            debugShowCheckedModeBanner: false,
            theme: ThemeData.light().copyWith(
              primaryColor: Colors.red,
              colorScheme: const ColorScheme.light(
                primary: Colors.red,
                secondary: Colors.blue,
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
            darkTheme: ThemeData.dark().copyWith(
              primaryColor: Colors.red.shade800,
              colorScheme: const ColorScheme.dark(
                primary: Colors.red,
                secondary: Colors.blue,
              ),
              appBarTheme: AppBarTheme(
                backgroundColor: Colors.red.shade800,
                foregroundColor: Colors.white,
              ),
            ),
            themeMode: provider.themeMode,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}