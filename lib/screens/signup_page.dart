import 'package:flutter/material.dart';
import '../theme/colors.dart';
import 'login_page.dart';

/// Register SIORG — bentuk form sama dengan Login (header tonal + kartu logo,
/// input berlabel, tombol merah). Belum ada endpoint registrasi, sehingga
/// submit menampilkan konfirmasi lalu kembali ke Login.
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _hidePass = true;
  bool _hideConfirm = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final pass = _passwordController.text;
    final confirm = _confirmController.text;

    if (name.isEmpty || email.isEmpty || pass.isEmpty) {
      _snack('Lengkapi semua data terlebih dahulu');
      return;
    }
    if (pass != confirm) {
      _snack('Konfirmasi kata sandi tidak cocok');
      return;
    }
    _snack('Pendaftaran terkirim. Silakan hubungi admin untuk verifikasi.');
    Navigator.pop(context);
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            Padding(
              padding: const EdgeInsets.fromLTRB(26, 26, 26, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AuthField(
                    label: 'Nama Lengkap',
                    controller: _nameController,
                    hint: 'Nama lengkap Anda',
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 16),
                  AuthField(
                    label: 'Email / NIK',
                    controller: _emailController,
                    hint: 'nama@koni.or.id',
                    icon: Icons.mail_outline,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  AuthField(
                    label: 'Kata Sandi',
                    controller: _passwordController,
                    hint: 'Buat kata sandi',
                    icon: Icons.lock_outline,
                    obscure: _hidePass,
                    suffix: IconButton(
                      icon: Icon(_hidePass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: AppColors.muted, size: 20),
                      onPressed: () => setState(() => _hidePass = !_hidePass),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AuthField(
                    label: 'Konfirmasi Kata Sandi',
                    controller: _confirmController,
                    hint: 'Ulangi kata sandi',
                    icon: Icons.lock_outline,
                    obscure: _hideConfirm,
                    suffix: IconButton(
                      icon: Icon(_hideConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: AppColors.muted, size: 20),
                      onPressed: () => setState(() => _hideConfirm = !_hideConfirm),
                    ),
                  ),
                  const SizedBox(height: 26),
                  _primaryButton(),
                  const SizedBox(height: 24),
                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text.rich(
                        TextSpan(
                          text: 'Sudah punya akun? ',
                          style: TextStyle(fontSize: 12.5, color: AppColors.muted),
                          children: [
                            TextSpan(
                                text: 'Masuk',
                                style: TextStyle(color: AppColors.red, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.tintNavy,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(34)),
      ),
      padding: const EdgeInsets.fromLTRB(28, 56, 28, 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14)),
              child: const Icon(Icons.chevron_left, color: AppColors.navy),
            ),
          ),
          const SizedBox(height: 18),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(color: AppColors.ink.withValues(alpha: 0.18), blurRadius: 30, offset: const Offset(0, 14)),
              ],
            ),
            alignment: Alignment.center,
            child: Image.asset('assets/koni_logo.png', width: 54, height: 54,
                errorBuilder: (_, _, _) => const Icon(Icons.emoji_events, color: AppColors.red, size: 40)),
          ),
          const SizedBox(height: 20),
          const Text('Buat Akun',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800, color: AppColors.ink, height: 1.15)),
          const SizedBox(height: 5),
          const Text('Daftar untuk mengakses SIORG KONI Kab. Tangerang',
              style: TextStyle(fontSize: 13, color: AppColors.secondary, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _primaryButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.red,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: _submit,
        child: const Text('Daftar Sekarang', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
      ),
    );
  }
}
