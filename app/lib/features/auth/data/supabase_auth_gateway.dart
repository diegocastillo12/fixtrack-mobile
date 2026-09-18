import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/login_controller.dart';

class SupabaseAuthGateway implements AuthGateway {
  @override
  Future<String> signIn(String email, String password) async {
    final response = await Supabase.instance.client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    final token = response.session?.accessToken;
    if (token == null || token.isEmpty) {
      throw StateError('No se recibió un token de sesión');
    }
    return token;
  }
}

class LocalTokenStore implements TokenStore {
  static const key = 'auth_token';

  @override
  Future<void> save(String token) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(key, token);
  }

  @override
  Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(key);
  }
}
