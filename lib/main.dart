import 'package:flutter/material.dart';
import 'screens/app_shell.dart';

void main() => runApp(const R4TIoApp());

class R4TIoApp extends StatelessWidget {
  const R4TIoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'R4T.io',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1565C0),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1565C0),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const AppShell(),
    );
  }
}
