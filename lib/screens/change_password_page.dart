import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../theme/colors.dart';
import '../widgets/profile_ui.dart';

/// Ganti Password — current + new + confirm (POST /auth/change-password).
class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _api = ApiService();
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _saving = false;
  bool _obCurrent = true, _obNew = true, _obConfirm = true;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final res = await _api.changePassword(
      currentPassword: _currentCtrl.text,
      newPassword: _newCtrl.text,
    );
    if (!mounted) return;
    setState(() => _saving = false);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(res['message']?.toString() ?? '-'),
      backgroundColor: res['success'] == true ? AppColors.success : AppColors.danger,
    ));
    if (res['success'] == true) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          profileSubHeader(context, 'Ganti Password', 'Amankan akun dengan password baru'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 28),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Password Saat Ini'),
                    _passwordField(_currentCtrl, _obCurrent, () => setState(() => _obCurrent = !_obCurrent),
                        validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null),
                    const SizedBox(height: 16),
                    _label('Password Baru'),
                    _passwordField(_newCtrl, _obNew, () => setState(() => _obNew = !_obNew),
                        validator: (v) => (v == null || v.length < 6) ? 'Minimal 6 karakter' : null),
                    const SizedBox(height: 16),
                    _label('Konfirmasi Password Baru'),
                    _passwordField(_confirmCtrl, _obConfirm, () => setState(() => _obConfirm = !_obConfirm),
                        validator: (v) => (v != _newCtrl.text) ? 'Konfirmasi tidak cocok' : null),
                    const SizedBox(height: 28),
                    primaryButton('Ubah Password', _saving, _save),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 2),
        child: Text(t, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.ink)),
      );

  Widget _passwordField(TextEditingController c, bool obscure, VoidCallback onToggle,
      {String? Function(String?)? validator}) {
    return TextFormField(
      controller: c,
      obscureText: obscure,
      validator: validator,
      style: const TextStyle(fontSize: 14, color: AppColors.ink),
      decoration: InputDecoration(
        hintText: '••••••',
        prefixIcon: const Icon(Icons.lock_outline, size: 20, color: AppColors.muted),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              size: 20, color: AppColors.muted),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      ),
    );
  }
}
