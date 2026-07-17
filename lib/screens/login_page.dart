import 'package:flutter/material.dart';
import 'signup_page.dart';
import 'dashboard_page.dart';
import '../services/api_service.dart';
import '../theme/colors.dart';

/// Login SIORG: header tonal + kartu logo, input berlabel (Email/NIK &
/// Password), tombol "Masuk" merah, opsi Google, dan tautan daftar.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool hidePassword = true;
  bool _isLoading = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _doLogin() async {
    setState(() => _isLoading = true);
    final result = await _apiService.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success']) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );
    }
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
              padding: const EdgeInsets.fromLTRB(26, 28, 26, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AuthField(
                    label: 'Email / NIK',
                    controller: _emailController,
                    hint: 'nama@koni.or.id',
                    icon: Icons.mail_outline,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  AuthField(
                    label: 'Password',
                    controller: _passwordController,
                    hint: 'Masukkan kata sandi',
                    icon: Icons.lock_outline,
                    obscure: hidePassword,
                    suffix: IconButton(
                      icon: Icon(hidePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: AppColors.muted, size: 20),
                      onPressed: () => setState(() => hidePassword = !hidePassword),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {},
                      child: const Text('Lupa Password?',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.red)),
                    ),
                  ),
                  const SizedBox(height: 22),
                  _primaryButton(),
                  const SizedBox(height: 22),
                  _divider(),
                  const SizedBox(height: 22),
                  _googleButton(),
                  const SizedBox(height: 24),
                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                          context, MaterialPageRoute(builder: (_) => const SignUpPage())),
                      child: const Text.rich(
                        TextSpan(
                          text: 'Belum punya akun? ',
                          style: TextStyle(fontSize: 12.5, color: AppColors.muted),
                          children: [
                            TextSpan(
                                text: 'Daftar',
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
      padding: const EdgeInsets.fromLTRB(28, 70, 28, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          const Text('Selamat Datang',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800, color: AppColors.ink, height: 1.15)),
          const SizedBox(height: 5),
          const Text('Masuk ke Sistem Informasi Organisasi Olahraga',
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
        onPressed: _isLoading ? null : _doLogin,
        child: _isLoading
            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text('Masuk', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _divider() {
    return const Row(
      children: [
        Expanded(child: Divider(color: Color(0xFFE2E5EA))),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 14),
          child: Text('atau', style: TextStyle(fontSize: 11.5, color: AppColors.muted2)),
        ),
        Expanded(child: Divider(color: Color(0xFFE2E5EA))),
      ],
    );
  }

  Widget _googleButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink,
          side: const BorderSide(color: Color(0xFFE6E9EF)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: () {},
        icon: const Icon(Icons.g_mobiledata, size: 28, color: Color(0xFF4285F4)),
        label: const Text('Masuk dengan Google', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

/// Input berlabel ala SIORG, dipakai bersama di Login & Register.
class AuthField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController? controller;
  final bool obscure;
  final Widget? suffix;
  final TextInputType? keyboardType;

  const AuthField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    this.controller,
    this.obscure = false,
    this.suffix,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.ink)),
        const SizedBox(height: 7),
        Container(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE6E9EF)),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: AppColors.muted2),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: obscure,
                  keyboardType: keyboardType,
                  style: const TextStyle(fontSize: 14, color: AppColors.ink),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: const TextStyle(color: AppColors.muted, fontSize: 14),
                    border: InputBorder.none,
                    isCollapsed: true,
                  ),
                ),
              ),
              ?suffix,
            ],
          ),
        ),
      ],
    );
  }
}
