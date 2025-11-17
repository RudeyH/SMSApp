import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _email = TextEditingController();
  final _code = TextEditingController();
  final _newPass = TextEditingController();
  bool _isLoading = false;

  Future<void> _reset() async {
    setState(() => _isLoading = true);
    final res = await http.post(
      Uri.parse("http://localhost:5000/api/User/reset"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "email": _email.text.trim(),
        "resetCode": _code.text.trim(),
        "newPassword": _newPass.text.trim()
      }),
    );
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(res.body),
      backgroundColor: res.statusCode == 200 ? Colors.green : Colors.red,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reset Password")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(controller: _email, decoration: const InputDecoration(labelText: "Email")),
            TextField(controller: _code, decoration: const InputDecoration(labelText: "Reset Code")),
            TextField(controller: _newPass, decoration: const InputDecoration(labelText: "New Password"), obscureText: true),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _reset,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text("Change Password"),
            ),
          ],
        ),
      ),
    );
  }
}
