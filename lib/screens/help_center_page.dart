import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../widgets/profile_ui.dart';

/// Pusat Bantuan — statis: FAQ + kontak KONI Kab. Tangerang.
class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});

  static const _faq = [
    [
      'Bagaimana cara masuk (login)?',
      'Gunakan email dan password akun yang telah didaftarkan oleh admin KONI. '
          'Jika belum punya akun, hubungi sekretariat KONI Kabupaten Tangerang.'
    ],
    [
      'Bagaimana mengubah data profil?',
      'Buka menu Profil, lalu pilih "Ubah Profil" untuk memperbarui nama dan email, '
          'atau "Ganti Password" untuk mengganti kata sandi.'
    ],
    [
      'Data atlet/pelatih saya belum muncul?',
      'Data bersumber dari basis data KONI. Bila ada yang belum sesuai, sampaikan '
          'ke admin cabor atau sekretariat untuk diperbarui.'
    ],
    [
      'Kenapa sebagian menu masih "Segera Hadir"?',
      'Beberapa fitur masih dalam pengembangan bertahap dan akan aktif pada '
          'pembaruan aplikasi berikutnya.'
    ],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          profileSubHeader(context, 'Pusat Bantuan', 'Pertanyaan umum & kontak'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 28),
              children: [
                const Text('Pertanyaan Umum (FAQ)',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.ink)),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20)),
                  child: Column(
                    children: List.generate(_faq.length, (i) {
                      return Theme(
                        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                          title: Text(_faq[i][0],
                              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.ink)),
                          iconColor: AppColors.navy,
                          collapsedIconColor: AppColors.muted,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(_faq[i][1],
                                  style: const TextStyle(fontSize: 12.5, color: AppColors.muted2, height: 1.5)),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Hubungi Kami',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.ink)),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20)),
                  child: Column(
                    children: const [
                      _ContactRow(Icons.location_on_outlined, 'Sekretariat',
                          'GOR KONI, Kab. Tangerang, Banten'),
                      Divider(height: 1, color: AppColors.line, indent: 60),
                      _ContactRow(Icons.mail_outline, 'Email', 'sekretariat@konigemilang.tangerangkab.go.id'),
                      Divider(height: 1, color: AppColors.line, indent: 60),
                      _ContactRow(Icons.public, 'Website', 'konigemilang.tangerangkab.go.id'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  const _ContactRow(this.icon, this.title, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: AppColors.tintGreen, borderRadius: BorderRadius.circular(12)),
            alignment: Alignment.center,
            child: Icon(icon, size: 19, color: AppColors.success),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 11.5, color: AppColors.muted, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.ink)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
