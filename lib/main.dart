import 'package:flutter/material.dart';
import 'screens/onboarding_page.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const KoniApp());
}

class KoniApp extends StatelessWidget {
  const KoniApp({super.key});

  /// Skala teks global untuk seluruh aplikasi. 1.0 = ukuran asli.
  /// Naikkan angka ini untuk memperbesar SEMUA font secara proporsional.
  /// (1.2 = +20%. Nilai lebih tinggi bisa membuat sebagian kotak berukuran
  /// tetap kepenuhan/overflow.)
  static const double textScale = 1.05;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      // Paksa skala teks tetap (abaikan setting sistem) demi tampilan konsisten.
      builder: (context, child) => MediaQuery.withClampedTextScaling(
        minScaleFactor: textScale,
        maxScaleFactor: textScale,
        child: child!,
      ),
      home: const OnboardingPage(),
    );
  }
}
