import 'dart:typed_data';
import 'package:flutter/foundation.dart';
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

  /// Try to read the user's avatar/photo URL from user metadata.
  /// Checks common keys used by different providers and our own app.
  static String? getAvatarUrlFromUser(User? user) {
    try {
      final meta = user?.userMetadata ?? {};
      final List<String> keys = ['avatar_url', 'picture', 'photo_url', 'profile_pic'];
      for (final k in keys) {
        final v = meta[k]?.toString();
        if (v != null && v.isNotEmpty) return v;
      }
      return null;
    } catch (e) {
      debugPrint('getAvatarUrlFromUser error: $e');
      return null;
    }
  }

  /// Upload avatar bytes to Supabase Storage and return a public URL.
  /// It also updates the user's metadata with the `avatar_url` pointing to the public URL.
  /// Requires an existing bucket named `avatars`. Make the bucket public or add proper RLS.
  static Future<String> uploadAvatarBytes({
    required Uint8List bytes,
    String contentType = 'image/jpeg',
  }) async {
    final user = currentUser;
    if (user == null) throw Exception('No hay usuario autenticado');

    final bucket = client.storage.from('avatars');
    final path = 'users/${user.id}/avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
    try {
      await bucket.uploadBinary(
        path,
        bytes,
        fileOptions: FileOptions(contentType: contentType, upsert: true),
      );

      // Try to get a public URL (works if bucket/object is public)
      final publicUrl = bucket.getPublicUrl(path);

      // Update user metadata so we can use it everywhere
      await updateUser(data: {'avatar_url': publicUrl});

      return publicUrl;
    } on StorageException catch (e) {
      debugPrint('Storage upload error: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Unexpected upload error: $e');
      rethrow;
    }
  }
}
