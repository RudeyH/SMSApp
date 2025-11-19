import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../config.dart';

// ------------------------------------------------------------
// PROVIDER
// ------------------------------------------------------------
final authProvider = NotifierProvider<AuthNotifier, AsyncValue<dynamic>>(() {
  return AuthNotifier();
});

// ------------------------------------------------------------
// NOTIFIER (Riverpod 2.x)
// ------------------------------------------------------------
class AuthNotifier extends Notifier<AsyncValue<dynamic>> {
  final _baseUrl = '${Config().baseUrl}/User';

  @override
  AsyncValue<dynamic> build() {
    return const AsyncValue.data(null);
  }

  // ------------------------------------------------------------
  // LOGIN
  // ------------------------------------------------------------
  Future<void> login(String username, String password) async {
    state = const AsyncValue.loading();

    // try {
      final res = await http.post(
        Uri.parse("$_baseUrl/login"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "usernameOrEmail": username,
          "password": password,
        }),
      );

      // if (res.statusCode == 200) {
      //   final data = jsonDecode(res.body);
      //   state = AsyncValue.data(data);
      // } else {
      //   state = AsyncValue.error(
      //     jsonDecode(res.body)["message"] ?? "Login failed",
      //     StackTrace.current,
      //   );
      // }
    // } catch (e, st) {
    //   state = AsyncValue.error(e, st);
    // }
    if (res.statusCode == 200) {
      try {
        final data = jsonDecode(res.body);
        state = AsyncValue.data(data);
      } catch (e) {
        state =  AsyncValue.error("Invalid response format", StackTrace.current);
      }
    } else {
      // Try parsing JSON, else fallback to raw text
      String message;
      try {
        message = jsonDecode(res.body)["message"] ?? "Login failed";
      } catch (e) {
        message = res.body; // fallback if not JSON
      }

      state = AsyncValue.error(message, StackTrace.current);
    }
  }

  // ------------------------------------------------------------
  // REGISTER
  // ------------------------------------------------------------
  Future<bool> register(
      String username, String email, String password) async {
    final res = await http.post(
      Uri.parse("$_baseUrl/register"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "Username": username,
        "Email": email,
        "PasswordHash": password, // backend handles hashing
      }),
    );
    return res.statusCode == 200;
  }


  // ------------------------------------------------------------
  // REQUEST PASSWORD RESET
  // ------------------------------------------------------------
  Future<bool> requestPasswordReset(String email) async {
    final res = await http.post(
      Uri.parse("$_baseUrl/forgot-password"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"email": email}),
    );

    return res.statusCode == 200;
  }

  // ------------------------------------------------------------
  // RESET PASSWORD
  // ------------------------------------------------------------
  Future<bool> resetPassword(String token, String newPassword) async {
    final res = await http.post(
      Uri.parse("$_baseUrl/reset-password"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "token": token,
        "newPassword": newPassword,
      }),
    );

    return res.statusCode == 200;
  }
}
