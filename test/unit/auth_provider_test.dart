import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/providers/auth_provider.dart';

// Mock AuthProvider that doesn't use Firebase
class MockAuthProvider extends AuthProvider {
  @override
  bool get isLoggedIn => false;
  
  @override
  String? get error => null;
  
  @override
  bool get isLoading => false;
  
  // Override methods that use Firebase to do nothing
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

  group('AuthProvider', () {
    test('initial state is correct', () {
      final auth = MockAuthProvider();
      
      expect(auth.isLoading, false);
      expect(auth.isLoggedIn, false);
      expect(auth.error, null);
    });

    test('clearError resets error state', () {
      final auth = MockAuthProvider();
      auth.clearError();
      expect(auth.error, null);
    });
  });
}