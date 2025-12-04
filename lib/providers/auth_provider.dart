import 'package:flutter_riverpod/flutter_riverpod.dart';

// Simple user model
class User {
  final String id;
  final String email;
  final String name;

  User({
    required this.id,
    required this.email,
    required this.name,
  });
}

// Auth state notifier
class AuthNotifier extends StateNotifier<User?> {
  AuthNotifier() : super(null);

  // Sign up
  Future<bool> signUp(String email, String password, String name) async {
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 1)); // Simulating API call
      
      // For now, just create a mock user
      state = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        name: name,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  // Login
  Future<bool> login(String email, String password) async {
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 1)); // Simulating API call
      
      // For now, just create a mock user
      state = User(
        id: '12345',
        email: email,
        name: 'User', // You'd get this from your API
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  // Logout
  void logout() {
    state = null;
  }
}

// Auth provider
final authProvider = StateNotifierProvider<AuthNotifier, User?>((ref) {
  return AuthNotifier();
});