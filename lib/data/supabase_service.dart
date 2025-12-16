import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final client = Supabase.instance.client;

  // Sign Up
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required Map<String, dynamic> data,
  }) async {
    return await client.auth.signUp(
      email: email,
      password: password,
      data: data,
    );
  }

  // Sign In
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Sign Out
  static Future<void> signOut() async {
    await client.auth.signOut();
  }

  // Get Current User
  static User? get currentUser => client.auth.currentUser;

  // Update User
  static Future<UserResponse> updateUser({String? email, Map<String, dynamic>? data}) async {
    return await client.auth.updateUser(
      UserAttributes(
        email: email,
        data: data,
      ),
    );
  }
}
