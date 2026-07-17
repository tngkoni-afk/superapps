import 'package:flutter/material.dart';

import '../config/api_config.dart';
import '../services/api_service.dart';
import '../theme/colors.dart';
import '../widgets/siorg_bottom_nav.dart';
import '../widgets/siorg_header.dart';
import 'about_page.dart';
import 'change_password_page.dart';
import 'edit_profile_page.dart';
import 'help_center_page.dart';
import 'login_page.dart';
import 'settings_page.dart';

/// Profil Saya (SIORG `/profil`).
///
/// Header memuat data akun dari `/auth/me`. Menu Akun (Ubah Profil, Ganti
/// Password) memanggil endpoint nyata; menu Aplikasi (Pengaturan, Bantuan,
/// Tentang) sebagian besar statis.
class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  final ApiService _apiService = ApiService();

  bool _loading = true;
  bool _loggingOut = false;
  bool _loggedIn = false;
  String _name = 'Guest';
  String _email = '';
  String _role = 'Tamu';
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final p = await _apiService.getProfile();
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (p != null) {
        _loggedIn = true;
        _name = (p['name'] ?? 'Pengguna').toString();
        _email = (p['email'] ?? '').toString();
        _role = _titleCase((p['role'] ?? 'Anggota').toString());
        _avatarUrl = _avatarUrlFrom(p['avatar']);
      } else {
        _loggedIn = false;
        _name = 'Guest';
        _email = '';
        _role = 'Tamu';
        _avatarUrl = null;
      }
    });
  }

  String _titleCase(String s) => s
      .split(' ')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');

  String _initialsOf(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  String? _avatarUrlFrom(dynamic avatar) {
    if (avatar == null) return null;
    final s = avatar.toString();
    if (s.isEmpty) return null;
    if (s.startsWith('http')) return s;
    return '${ApiConfig.storageUrl}/$s';
  }

  void _open(Widget page) => Navigator.push(context, MaterialPageRoute(builder: (_) => page));

  Future<void> _openEditProfile() async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => EditProfilePage(initialName: _name, initialEmail: _email)),
    );
    if (changed == true) _loadProfile();
  }

  void _goLogin() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage()))
        .then((_) => _loadProfile());
  }

  Future<void> _logout() async {
    setState(() => _loggingOut = true);
    await _apiService.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      bottomNavigationBar: const SiorgBottomNav(active: 4),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.navy))
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 20, 18, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_loggedIn) ...[
                          _sectionLabel('Akun'),
                          _menuCard([
                            _MenuRow('Ubah Profil', 'UP', AppColors.tintNavy, AppColors.navy, _openEditProfile),
                            _MenuRow('Ganti Password', 'GP', AppColors.tintPurple, const Color(0xFF7A4DA0),
                                () => _open(const ChangePasswordPage())),
                          ]),
                          const SizedBox(height: 20),
                        ] else
                          _loginPrompt(),
                        _sectionLabel('Aplikasi'),
                        _menuCard([
                          _MenuRow('Pengaturan', 'PG', AppColors.tintGray, AppColors.secondary,
                              () => _open(const SettingsPage())),
                          _MenuRow('Pusat Bantuan', 'PB', AppColors.tintGreen, AppColors.success,
                              () => _open(const HelpCenterPage())),
                          _MenuRow('Tentang Aplikasi', 'TA', AppColors.tintGold, AppColors.warning,
                              () => _open(const AboutPage())),
                        ]),
                        const SizedBox(height: 22),
                        if (_loggedIn) _logoutButton(),
                        const SizedBox(height: 18),
                        const Center(
                          child: Text('KONI Kabupaten Tangerang · v1.0.0',
                              style: TextStyle(fontSize: 10.5, color: AppColors.faint, fontWeight: FontWeight.w500)),
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
    return SiorgHeader(
      radius: 32,
      padding: const EdgeInsets.fromLTRB(22, 52, 22, 26),
      child: Row(
        children: [
          _avatar(),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Text(_loggedIn ? _role : 'Belum masuk',
                    style: const TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w600)),
                if (_email.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(_email,
                      style: const TextStyle(fontSize: 11, color: Colors.white60, fontWeight: FontWeight.w500),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ],
            ),
          ),
          if (_loggedIn) SiorgHeader.iconButton(Icons.edit_outlined, _openEditProfile, size: 40),
        ],
      ),
    );
  }

  Widget _avatar() {
    Widget inner;
    if (!_loggedIn) {
      inner = const Icon(Icons.person_outline, color: Colors.white, size: 30);
    } else if (_avatarUrl != null) {
      return Container(
        width: 66,
        height: 66,
        padding: const EdgeInsets.all(4),
        decoration: const BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
        child: ClipOval(
          child: Image.network(_avatarUrl!, fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _initialsCircle()),
        ),
      );
    } else {
      return Container(
        width: 66,
        height: 66,
        padding: const EdgeInsets.all(4),
        decoration: const BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
        child: _initialsCircle(),
      );
    }
    return Container(
      width: 66,
      height: 66,
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
      child: Container(
        decoration: const BoxDecoration(color: AppColors.redMid, shape: BoxShape.circle),
        alignment: Alignment.center,
        child: inner,
      ),
    );
  }

  Widget _initialsCircle() {
    return Container(
      decoration: const BoxDecoration(color: AppColors.redMid, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(_initialsOf(_name),
          style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w700)),
    );
  }

  Widget _loginPrompt() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Belum masuk',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.ink)),
          const SizedBox(height: 4),
          const Text('Masuk untuk mengelola profil dan akun Anda.',
              style: TextStyle(fontSize: 12.5, color: AppColors.muted, fontWeight: FontWeight.w500)),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: _goLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.navy,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Masuk', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 0, 0, 10),
      child: Text(text.toUpperCase(),
          style: const TextStyle(
              fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8, color: AppColors.muted2)),
    );
  }

  Widget _menuCard(List<_MenuRow> items) {
    return Container(
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: List.generate(items.length, (i) {
          final m = items[i];
          final isLast = i == items.length - 1;
          return GestureDetector(
            onTap: m.onTap,
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                border: isLast ? null : const Border(bottom: BorderSide(color: AppColors.line, width: 1)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(color: m.tint, borderRadius: BorderRadius.circular(12)),
                    alignment: Alignment.center,
                    child: Text(m.mono, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: m.fg)),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Text(m.label,
                        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.ink)),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.faint, size: 20),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _logoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: _loggingOut ? null : _logout,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.tintRed,
          foregroundColor: AppColors.danger,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        icon: _loggingOut
            ? const SizedBox(
                width: 18, height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.danger))
            : const Icon(Icons.logout, size: 19),
        label: Text(_loggingOut ? 'Keluar...' : 'Keluar',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _MenuRow {
  final String label;
  final String mono;
  final Color tint;
  final Color fg;
  final VoidCallback onTap;
  const _MenuRow(this.label, this.mono, this.tint, this.fg, this.onTap);
}
