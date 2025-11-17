import 'dart:ui';
import 'package:flutter/material.dart';
import 'main_tab_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _loginSuccess = false;

  late AnimationController _checkmarkController;

  @override
  void initState() {
    super.initState();
    _checkmarkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _checkmarkController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _loginSuccess = false;
      });

      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      final username = _usernameController.text.trim().toUpperCase();
      final password = _passwordController.text.trim().toUpperCase();

      if (username == 'ADMIN' && password == 'ADMIN') {
        // ✅ Success animation
        setState(() => _loginSuccess = true);
        _checkmarkController.forward();

        await Future.delayed(const Duration(seconds: 1));

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainTabScreen()),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid credentials. Use ADMIN / ADMIN.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }

      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🌈 Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // 🧩 Login Form Card
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
                        const Text(
                          "Welcome Back",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 32),
                        TextFormField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            labelText: "Username",
                            prefixIcon: const Icon(Icons.person_outline,
                                color: Colors.blue),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) =>
                          value == null || value.isEmpty
                              ? 'Please enter username'
                              : null,
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
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) =>
                          value == null || value.isEmpty
                              ? 'Please enter password'
                              : null,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _isLoading ? null : _login,
                            child: const Text(
                              "LOGIN",
                              style: TextStyle(
                                fontSize: 18,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Hint: ADMIN / ADMIN",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 🌫️ Glass Blur Overlay during loading or success
          if (_isLoading)
            AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                alignment: Alignment.center,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    color: Colors.black45,
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        child: _loginSuccess
                            ? ScaleTransition(
                          scale: CurvedAnimation(
                            parent: _checkmarkController,
                            curve: Curves.elasticOut,
                          ),
                          child: const Icon(
                            Icons.check_circle,
                            color: Colors.greenAccent,
                            size: 100,
                          ),
                        )
                            : const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                                color: Colors.white),
                            SizedBox(height: 16),
                            Text(
                              'Logging in...',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

//NEW LOGIN
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
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
