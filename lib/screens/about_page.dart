import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../widgets/profile_ui.dart';

/// Tentang Aplikasi — statis.
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          profileSubHeader(context, 'Tentang Aplikasi', 'Informasi & versi'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 24, 18, 28),
              children: [
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 88,
                        height: 88,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(24)),
                        child: Image.asset('assets/koni_logo.png', fit: BoxFit.contain,
                            errorBuilder: (_, _, _) => const Icon(Icons.emoji_events, color: AppColors.red, size: 40)),
                      ),
                      const SizedBox(height: 14),
                      const Text('KONI GEMILANG',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.ink)),
                      const SizedBox(height: 3),
                      const Text('Aplikasi Resmi KONI Kabupaten Tangerang',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12.5, color: AppColors.muted, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(color: AppColors.tintNavy, borderRadius: BorderRadius.circular(99)),
                        child: const Text('Versi 1.0.0',
                            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.navy)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                _section('Tentang', [
                  'Aplikasi resmi KONI Kabupaten Tangerang untuk menampilkan data '
                      'cabang olahraga, atlet, pelatih, klub, berita, dan agenda kegiatan '
                      'keolahragaan secara terpadu.',
                ]),
                const SizedBox(height: 16),
                _infoCard([
                  ['Pengelola', 'KONI Kabupaten Tangerang'],
                  ['Wilayah', 'Kabupaten Tangerang, Banten'],
                  ['Kategori', 'Olahraga & Organisasi'],
                ]),
                const SizedBox(height: 22),
                const Center(
                  child: Text('© 2026 KONI Kabupaten Tangerang\nHak cipta dilindungi.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 10.5, color: AppColors.faint, fontWeight: FontWeight.w500, height: 1.5)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String title, List<String> paragraphs) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.ink)),
          const SizedBox(height: 8),
          ...paragraphs.map((p) => Text(p,
              style: const TextStyle(fontSize: 12.5, color: AppColors.muted2, height: 1.55))),
        ],
      ),
    );
  }

  Widget _infoCard(List<List<String>> rows) {
    return Container(
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: List.generate(rows.length, (i) {
          final r = rows[i];
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(r[0], style: const TextStyle(fontSize: 12.5, color: AppColors.muted, fontWeight: FontWeight.w600)),
                    Flexible(
                      child: Text(r[1],
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.ink)),
                    ),
                  ],
                ),
              ),
              if (i != rows.length - 1) const Divider(height: 1, color: AppColors.line),
            ],
          );
        }),
      ),
    );
  }
}
