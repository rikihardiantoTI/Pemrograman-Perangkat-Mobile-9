import 'package:flutter/material.dart';
import 'ui/kas/home_screen.dart';
import 'ui/kas/kas_view_model.dart';

void main() {
  runApp(NusaKasApp());
}

class NusaKasApp extends StatelessWidget {
  final KasViewModel? viewModel;

  NusaKasApp({super.key, this.viewModel});

  late final KasViewModel _effectiveViewModel = viewModel ?? KasViewModel();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NusaKas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF07152F),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5EE7E7),
          brightness: Brightness.dark,
          surface: const Color(0xFF102345),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF07152F),
          foregroundColor: Color(0xFFF5F3EE),
          centerTitle: false,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF0D1B3D),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF263B62)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF263B62)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF5EE7E7), width: 1.5),
          ),
        ),
      ),
      home: HomeScreen(viewModel: _effectiveViewModel),
    );
  }
}