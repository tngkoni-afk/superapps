import 'package:flutter/material.dart';

import '../screens/login_page.dart';
import '../theme/colors.dart';

/// Tampilan "kunci" untuk halaman detail/profil ketika pengguna belum login.
/// Pesan default sesuai permintaan: "Mohon login untuk melihat detail profil".
class LoginRequiredView extends StatelessWidget {
  final String title;
  final String message;
  const LoginRequiredView({
    super.key,
    this.title = 'Detail Dikunci',
    this.message = 'Mohon login untuk melihat detail profil',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(color: AppColors.tintNavy, shape: BoxShape.circle),
              child: const Icon(Icons.lock_outline, size: 56, color: AppColors.navy),
            ),
            const SizedBox(height: 22),
            Text(title,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.ink)),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.secondary, height: 1.5, fontSize: 13.5),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.red,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () => Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (_) => const LoginPage())),
                child: const Text('Login Sekarang', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Kembali', style: TextStyle(color: AppColors.muted, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}
