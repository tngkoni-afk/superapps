import 'package:flutter/material.dart';
import 'dashboard_page.dart';
import '../theme/colors.dart';

/// Splash SIORG: foto olahraga full-bleed + panel putih bawah + kartu logo
/// + tagline + loading bar emas. Otomatis ke Beranda setelah ±2.5 detik.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardPage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const panelHeight = 300.0;
    return Scaffold(
      backgroundColor: const Color(0xFF0E1320),
      body: Stack(
        children: [
          // Foto full-bleed
          Positioned.fill(
            child: Image.asset(
              'assets/onboarding/on1.jpg',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              errorBuilder: (_, _, _) => Container(color: const Color(0xFF0E1320)),
            ),
          ),
          // Scrim atas (status bar)
          Positioned(
            top: 0, left: 0, right: 0, height: 140,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Color(0x8C0E1320), Colors.transparent],
                ),
              ),
            ),
          ),
          // Panel putih bawah
          Positioned(
            left: 0, right: 0, bottom: 0, height: panelHeight,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
              ),
            ),
          ),
          // Kartu logo (mengangkangi tepi panel)
          Positioned(
            left: 0, right: 0, bottom: panelHeight - 53,
            child: Center(
              child: Container(
                width: 106,
                height: 106,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0E1320).withValues(alpha: 0.42),
                      blurRadius: 34,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Image.asset('assets/koni_logo.png', width: 76, height: 76,
                    errorBuilder: (_, _, _) => const Icon(Icons.emoji_events, color: AppColors.red, size: 56)),
              ),
            ),
          ),
          // Tagline
          const Positioned(
            left: 36, right: 36, bottom: 150,
            child: Text(
              'Semangat Juara KONI\nKabupaten Tangerang',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.ink, height: 1.32),
            ),
          ),
          // Loading bar emas
          Positioned(
            left: 0, right: 0, bottom: 92,
            child: Center(
              child: Container(
                width: 140,
                height: 4,
                decoration: BoxDecoration(color: const Color(0xFFEDEFF3), borderRadius: BorderRadius.circular(99)),
                alignment: Alignment.centerLeft,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 2200),
                  curve: Curves.easeOut,
                  builder: (_, value, _) => FractionallySizedBox(
                    widthFactor: value,
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(99)),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Footer
          const Positioned(
            left: 0, right: 0, bottom: 56,
            child: Text(
              'SIORG · Sistem Informasi Organisasi Olahraga',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10.5, color: AppColors.muted2, fontWeight: FontWeight.w600, letterSpacing: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
