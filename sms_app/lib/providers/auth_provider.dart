import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
  final storage = const FlutterSecureStorage();
  @override
  AsyncValue<dynamic> build() {
    return const AsyncValue.data(null);
  }

  // ------------------------------------------------------------
  // LOGIN
  // ------------------------------------------------------------
  Future<void> login(String username, String password) async {
    state = const AsyncValue.loading();
    final res = await http.post(
      Uri.parse("$_baseUrl/login"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "usernameOrEmail": username,
        "password": password,
      }),
    );

    if (res.statusCode == 200) {
      try {
        final data = jsonDecode(res.body);

        // Save JWT token securely //
        await storage.write(key: 'jwt', value: data["token"]);
        await storage.write(key: 'refreshToken', value: data["refreshToken"]);

        // Save user profile if needed
        await storage.write(key: 'user', value: jsonEncode(data["user"]));

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
  // LOGOUT
  // ------------------------------------------------------------
  Future<void> logout() async {
    await storage.delete(key: 'jwt');
    await storage.delete(key: 'user');

    state = const AsyncValue.data(null);
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

  Future<bool> refreshToken() async {
    final refreshToken = await storage.read(key: "refreshToken");
    if (refreshToken == null) return false;

    final res = await http.post(
      Uri.parse("${Config().baseUrl}/User/refresh-token"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"refreshToken": refreshToken}),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);

      await storage.write(key: 'jwt', value: data["token"]);
      await storage.write(key: 'refreshToken', value: data["refreshToken"]);

      return true;
    }

    return false;
  }

  Future<http.Response> authenticatedRequest(
      Ref ref,
      Future<http.Response> Function(Map<String, String> headers) action,
      ) async {
    final headers = await getAuthHeaders(ref);
    var response = await action(headers);

    if (response.statusCode == 401) {
      // try refresh
      final ok = await ref.read(authProvider.notifier).refreshToken();
      if (!ok) {
        ref.read(authProvider.notifier).logout();
        return response;
      }

      // retry with new token
      final newHeaders = await getAuthHeaders(ref);
      response = await action(newHeaders);
    }

    return response;
  }


  // ------------------------------------------------------------
// GLOBAL FUNCTION → Attach Bearer Token Automatically
// ------------------------------------------------------------
  Future<Map<String, String>> getAuthHeaders(Ref ref) async {
    String? token = await storage.read(key: 'jwt');

    // If no token → return basic headers
    if (token == null) {
      return {"Content-Type": "application/json"};
    }

    // Temporary headers
    final headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token"
    };

    return headers;
  }

}
