import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:sms_app/helpers/notification_helper.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _controller = TextEditingController();
  bool _isLoading = false;

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    final res = await http.post(
      Uri.parse("http://localhost:5000/api/User/forgot"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"email": _controller.text.trim()}),
    );
    setState(() => _isLoading = false);

    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //   content: Text(res.body),
    //   backgroundColor: res.statusCode == 200 ? Colors.green : Colors.red,
    // ));
    if (res.statusCode == 200) {
      showSuccess(res.body);
    }
    else {
      showError(res.body);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Forgot Password")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text("Send Reset Code"),
            ),
          ],
        ),
      ),
    );
  }
}
