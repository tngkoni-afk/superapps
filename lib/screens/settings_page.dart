import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/colors.dart';
import '../widgets/profile_ui.dart';

/// Pengaturan — sebagian besar statis; preferensi disimpan lokal (SharedPreferences).
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notif = true;
  bool _loading = true;

  static const _kNotif = 'pref_notif';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _notif = prefs.getBool(_kNotif) ?? true;
      _loading = false;
    });
  }

  Future<void> _setNotif(bool v) async {
    setState(() => _notif = v);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kNotif, v);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          profileSubHeader(context, 'Pengaturan', 'Preferensi aplikasi'),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.navy))
                : ListView(
                    padding: const EdgeInsets.fromLTRB(18, 20, 18, 28),
                    children: [
                      _card([
                        _switchRow(Icons.notifications_none_rounded, 'Notifikasi',
                            'Terima pemberitahuan agenda & berita', _notif, _setNotif),
                        _staticRow(Icons.language_rounded, 'Bahasa', 'Indonesia'),
                        _staticRow(Icons.brightness_6_outlined, 'Tema', 'Terang'),
                      ]),
                      const SizedBox(height: 16),
                      _card([
                        _tapRow(Icons.cached_rounded, 'Bersihkan Cache', 'Kosongkan data sementara', () {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cache dibersihkan')));
                        }),
                      ]),
                      const SizedBox(height: 18),
                      const Center(
                        child: Text('Versi aplikasi 1.0.0',
                            style: TextStyle(fontSize: 11, color: AppColors.faint, fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _card(List<Widget> rows) {
    final children = <Widget>[];
    for (var i = 0; i < rows.length; i++) {
      children.add(rows[i]);
      if (i != rows.length - 1) {
        children.add(const Divider(height: 1, color: AppColors.line, indent: 60));
      }
    }
    return Container(
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20)),
      child: Column(children: children),
    );
  }

  Widget _iconBox(IconData icon) => Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(color: AppColors.tintNavy, borderRadius: BorderRadius.circular(12)),
        alignment: Alignment.center,
        child: Icon(icon, size: 19, color: AppColors.navy),
      );

  Widget _switchRow(IconData icon, String title, String sub, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          _iconBox(icon),
          const SizedBox(width: 12),
          Expanded(child: _titleSub(title, sub)),
          Switch(value: value, activeThumbColor: AppColors.navy, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _staticRow(IconData icon, String title, String trailing) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          _iconBox(icon),
          const SizedBox(width: 12),
          Expanded(child: Text(title,
              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.ink))),
          Text(trailing, style: const TextStyle(fontSize: 12.5, color: AppColors.muted, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _tapRow(IconData icon, String title, String sub, VoidCallback onTap) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            _iconBox(icon),
            const SizedBox(width: 12),
            Expanded(child: _titleSub(title, sub)),
            const Icon(Icons.chevron_right, size: 20, color: AppColors.faint),
          ],
        ),
      ),
    );
  }

  Widget _titleSub(String title, String sub) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.ink)),
          const SizedBox(height: 2),
          Text(sub, style: const TextStyle(fontSize: 11.5, color: AppColors.muted, fontWeight: FontWeight.w500)),
        ],
      );
}
