import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sms_app/screens/login_screen.dart';
import 'providers/theme_provider.dart';

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    final lightGradient = const LinearGradient(
      colors: [Color(0xFFE3F2FD), Colors.white],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final darkGradient = const LinearGradient(
      colors: [Colors.black, Color(0xFF1A1A1A)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final lightTheme = ThemeData(
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      scaffoldBackgroundColor: Colors.transparent,
      useMaterial3: true,
    );

    final darkTheme = ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.amber,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: Colors.transparent,
      useMaterial3: true,
    );

    return AnimatedTheme(
      data: isDark ? darkTheme : lightTheme,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: isDark ? darkGradient : lightGradient,
        ),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'SMS App',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeMode, // <- global application of ThemeMode
          scaffoldMessengerKey: rootScaffoldMessengerKey,
          home: const LoginScreen(),
        ),
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:sms_app/screens/login_screen.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
//
// void main() {
//   runApp(const ProviderScope(child: MyApp()));
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Stock Management System',
//       theme: ThemeData(
//         useMaterial3: true,
//         colorSchemeSeed: Colors.blue,
//       ),
//       home: const LoginScreen(),
//     );
//   }
// }
