import 'package:flutter/foundation.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  models.User? _user;
  models.User? get user => _user;

  bool _loading = true;
  bool get loading => _loading;

  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _checkUserStatus();
  }

  // On app start: is someone already logged in?
  Future<void> _checkUserStatus() async {
    _user = await _authService.getCurrentUser();
    _loading = false;
    notifyListeners();
  }

  // The three methods below return null on success,
  // or an error message to show on screen.

  Future<String?> register(String email, String password, String name) async {
    try {
      _user = await _authService.createAccount(email, password, name);
      notifyListeners();
      return null;
    } on AppwriteException catch (e) {
      return e.message ?? 'Registration failed.';
    } catch (e) {
      debugPrint('Registration error: $e');
      return 'Registration failed. Please try again.';
    }
  }

  Future<String?> login(String email, String password) async {
    try {
      await _authService.login(email, password);
      _user = await _authService.getCurrentUser();
      if (_user == null) {
        return 'Login succeeded but the session was not saved. Please try again.';
      }
      notifyListeners();
      return null;
    } on AppwriteException catch (e) {
      return e.message ?? 'Login failed.';
    } catch (e) {
      debugPrint('Login error: $e');
      return 'Login failed. Please try again.';
    }
  }

  Future<String?> logout() async {
    try {
      await _authService.logout();
      _user = null;
      notifyListeners();
      return null;
    } on AppwriteException catch (e) {
      return e.message ?? 'Logout failed.';
    } catch (e) {
      debugPrint('Logout error: $e');
      return 'Logout failed. Please try again.';
    }
  }
}