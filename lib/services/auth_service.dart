import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'appwrite_config.dart';

class AuthService {
  final Account _account = Account(getClient());

  // Register a new user, then log them in automatically
  Future<models.User> createAccount(
    String email,
    String password,
    String name,
  ) async {
    await _account.create(
      userId: ID.unique(),
      email: email,
      password: password,
      name: name,
    );
    await login(email, password);
    return await _account.get();
  }

  // Log in an existing user
  Future<models.Session> login(String email, String password) {
    return _account.createEmailPasswordSession(
      email: email,
      password: password,
    );
  }

  // Returns the logged-in user, or null if nobody is logged in
  Future<models.User?> getCurrentUser() async {
    try {
      return await _account.get();
    } on AppwriteException {
      return null;
    }
  }

  // Log out the current user
  Future<void> logout() async {
    await _account.deleteSession(sessionId: 'current');
  }
}