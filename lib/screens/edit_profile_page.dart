import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../theme/colors.dart';
import '../widgets/profile_ui.dart';

/// Ubah Profil — form nama & email (PUT /auth/profile).
/// Mengembalikan `true` lewat Navigator.pop bila berhasil disimpan.
class EditProfilePage extends StatefulWidget {
  final String initialName;
  final String initialEmail;
  const EditProfilePage({super.key, required this.initialName, required this.initialEmail});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _api = ApiService();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialName);
    _emailCtrl = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final res = await _api.updateProfile(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
    );
    if (!mounted) return;
    setState(() => _saving = false);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(res['message']?.toString() ?? '-'),
      backgroundColor: res['success'] == true ? AppColors.success : AppColors.danger,
    ));
    if (res['success'] == true) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          profileSubHeader(context, 'Ubah Profil', 'Perbarui nama & email akun'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 28),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Nama Lengkap'),
                    _field(_nameCtrl, 'Nama lengkap', Icons.person_outline,
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null),
                    const SizedBox(height: 16),
                    _label('Email'),
                    _field(_emailCtrl, 'nama@email.com', Icons.mail_outline,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Email wajib diisi';
                      if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim())) {
                        return 'Format email tidak valid';
                      }
                      return null;
                    }),
                    const SizedBox(height: 28),
                    primaryButton('Simpan Perubahan', _saving, _save),
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

  Widget _field(TextEditingController c, String hint, IconData icon,
      {TextInputType? keyboardType, String? Function(String?)? validator}) {
    return TextFormField(
      controller: c,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(fontSize: 14, color: AppColors.ink),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 20, color: AppColors.muted),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      ),
    );
  }
}
