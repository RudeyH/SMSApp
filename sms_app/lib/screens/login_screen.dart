// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:sms_app/screens/reset_password_screen.dart';
// import '../providers/auth_provider.dart';
// import 'main_tab_screen.dart';
// import 'forgot_password_screen.dart';
// import 'signup_screen.dart';
//
// class LoginScreen extends ConsumerStatefulWidget {
//   const LoginScreen({super.key});
//
//   @override
//   ConsumerState<LoginScreen> createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends ConsumerState<LoginScreen>
//     with SingleTickerProviderStateMixin {
//   final _formKey = GlobalKey<FormState>();
//   final _usernameController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _isLoading = false;
//   bool _obscurePassword = true;
//
//   late AnimationController _checkmarkController;
//
//   @override
//   void initState() {
//     super.initState();
//     _checkmarkController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 800),
//     );
//   }
//
//   Future<void> _login() async {
//     if (!_formKey.currentState!.validate()) return;
//
//     final username = _usernameController.text.trim();
//     final password = _passwordController.text.trim();
//
//     setState(() => _isLoading = true);
//
//     final notifier = ref.read(authProvider.notifier);
//     await notifier.login(username, password);
//
//     final mountedNow = mounted;
//     if (!mountedNow) return;
//
//     final state = ref.read(authProvider);
//
//     state.whenOrNull(
//       data: (user) async {
//         if (user != null) {
//           _checkmarkController.forward();
//           await Future.delayed(const Duration(seconds: 1));
//
//           if (!mounted) return;
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (_) => const MainTabScreen()),
//           );
//         }
//       },
//       error: (err, _) {
//         if (!mounted) return;
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(err.toString()), backgroundColor: Colors.red),
//         );
//       },
//     );
//
//     if (!mounted) return;
//     setState(() => _isLoading = false);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           Container(
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//             ),
//           ),
//           Center(
//             child: SingleChildScrollView(
//               child: Card(
//                 elevation: 10,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(24),
//                 ),
//                 margin: const EdgeInsets.symmetric(horizontal: 24),
//                 child: Padding(
//                   padding: const EdgeInsets.all(24),
//                   child: Form(
//                     key: _formKey,
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         const Icon(Icons.lock_outline,
//                             size: 80, color: Colors.blue),
//                         const SizedBox(height: 16),
//                         const Text("Welcome Back",
//                             style: TextStyle(
//                                 fontSize: 26, fontWeight: FontWeight.bold)),
//                         const SizedBox(height: 32),
//                         TextFormField(
//                           controller: _usernameController,
//                           decoration: const InputDecoration(
//                             labelText: "Username or Email",
//                             prefixIcon:
//                             Icon(Icons.person_outline, color: Colors.blue),
//                           ),
//                           validator: (value) =>
//                           value!.isEmpty ? 'Enter username/email' : null,
//                         ),
//                         const SizedBox(height: 16),
//                         TextFormField(
//                           controller: _passwordController,
//                           obscureText: _obscurePassword,
//                           decoration: InputDecoration(
//                             labelText: "Password",
//                             prefixIcon: const Icon(Icons.lock_outline,
//                                 color: Colors.blue),
//                             suffixIcon: IconButton(
//                               icon: Icon(
//                                 _obscurePassword
//                                     ? Icons.visibility_off
//                                     : Icons.visibility,
//                                 color: Colors.grey,
//                               ),
//                               onPressed: () {
//                                 setState(() {
//                                   _obscurePassword = !_obscurePassword;
//                                 });
//                               },
//                             ),
//                           ),
//                           validator: (value) =>
//                           value!.isEmpty ? 'Enter password' : null,
//                         ),
//                         const SizedBox(height: 24),
//                         ElevatedButton(
//                           onPressed: _isLoading ? null : _login,
//                           style: ElevatedButton.styleFrom(
//                               shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(12)),
//                               minimumSize: const Size.fromHeight(48)),
//                           child: const Text("LOGIN"),
//                         ),
//                         const SizedBox(height: 16),
//                         TextButton(
//                           onPressed: () => Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (_) => const ForgotPasswordScreen()),
//                           ),
//                           child: const Text("Forgot Password?"),
//                         ),
//                         const SizedBox(height: 8),
//                         TextButton(
//                           onPressed: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(builder: (_) => const ResetPasswordScreen()),
//                             );
//                           },
//                           child: const Text("Reset Password"),
//                         ),
//                         const SizedBox(height: 8),
//                         TextButton(
//                           onPressed: () => Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (_) => const SignupScreen()),
//                           ),
//                           child: const Text("Create New Account"),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sms_app/screens/reset_password_screen.dart';
import '../providers/auth_provider.dart';
import 'main_tab_screen.dart';
import 'forgot_password_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  // animation state
  bool _showSuccess = false;
  bool _showError = false;

  late AnimationController _iconController;

  @override
  void initState() {
    super.initState();
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    setState(() {
      _isLoading = true;
      _showSuccess = false;
      _showError = false;
    });

    final notifier = ref.read(authProvider.notifier);
    await notifier.login(username, password);

    if (!mounted) return;
    final state = ref.read(authProvider);

    state.whenOrNull(
      data: (user) async {
        if (user != null) {
          setState(() => _showSuccess = true);
          _iconController.forward();

          await Future.delayed(const Duration(seconds: 1));
          if (!mounted) return;

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainTabScreen()),
          );
        }
      },
      error: (err, _) async {
        setState(() {
          _showError = true;
        });
        _iconController.forward();

        await Future.delayed(const Duration(seconds: 1));

        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _showError = false;
          _iconController.reset();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(err.toString()), backgroundColor: Colors.red),
        );
      },
    );
  }

  Widget _buildStatusIcon() {
    if (_showSuccess) {
      return ScaleTransition(
        scale: CurvedAnimation(
          parent: _iconController,
          curve: Curves.elasticOut,
        ),
        child: const Icon(Icons.check_circle,
            size: 120, color: Colors.greenAccent),
      );
    }

    if (_showError) {
      return ScaleTransition(
        scale: CurvedAnimation(
          parent: _iconController,
          curve: Curves.elasticOut,
        ),
        child: const Icon(Icons.cancel, size: 120, color: Colors.redAccent),
      );
    }

    return const CircularProgressIndicator(
      strokeWidth: 6,
      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // FORM
          Center(
            child: SingleChildScrollView(
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 24),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.lock_outline,
                            size: 80, color: Colors.blue),
                        const SizedBox(height: 16),
                        const Text("Welcome Back",
                            style: TextStyle(
                                fontSize: 26, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 32),

                        TextFormField(
                          controller: _usernameController,
                          decoration: const InputDecoration(
                            labelText: "Username or Email",
                            prefixIcon: Icon(Icons.person_outline,
                                color: Colors.blue),
                          ),
                          validator: (value) =>
                          value!.isEmpty ? 'Enter username/email' : null,
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: "Password",
                            prefixIcon: const Icon(Icons.lock_outline,
                                color: Colors.blue),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.grey,
                              ),
                              onPressed: () => setState(
                                      () => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          validator: (value) =>
                          value!.isEmpty ? 'Enter password' : null,
                        ),

                        const SizedBox(height: 24),

                        ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            minimumSize: const Size.fromHeight(48),
                          ),
                          child: const Text("LOGIN"),
                        ),

                        const SizedBox(height: 16),

                        TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ForgotPasswordScreen()),
                          ),
                          child: const Text("Forgot Password?"),
                        ),

                        TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ResetPasswordScreen()),
                          ),
                          child: const Text("Reset Password"),
                        ),

                        TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SignupScreen()),
                          ),
                          child: const Text("Create New Account"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // LOADING / SUCCESS / ERROR OVERLAY
          if (_isLoading || _showSuccess || _showError)
            Container(
              color: Colors.black.withValues(alpha: (0.6)),
              child: Center(
                child: _buildStatusIcon(),
              ),
            ),
        ],
      ),
    );
  }
}

