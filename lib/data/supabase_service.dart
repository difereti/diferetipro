import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

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

  /// Sign in with Google using Supabase OAuth
  /// On web this opens a popup/tab and returns to the same origin.
  /// On mobile, make sure Google provider is enabled and redirects are configured.
  static Future<void> signInWithGoogle() async {
    try {
      await client.auth.signInWithOAuth(
        OAuthProvider.google,
        // For Dreamflow preview (web), default redirect works.
        // If you later build for mobile, configure deep links and set redirectTo.
        redirectTo: kIsWeb ? null : null,
      );
    } on AuthException catch (e) {
      // Log the raw message for debugging
      debugPrint('Supabase Google OAuth error: ${e.message}');
      final msg = e.message.toLowerCase();
      if (msg.contains('provider is not enabled') || msg.contains('unsupported provider')) {
        throw Exception(
          'Google no está habilitado en Supabase. Ve a Authentication > Providers y actívalo.',
        );
      }
      // Bubble up other readable auth errors
      throw Exception(e.message);
    } catch (e) {
      debugPrint('Supabase Google OAuth unexpected error: $e');
      throw Exception('No se pudo iniciar sesión con Google. Intenta de nuevo.');
    }
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
