import 'package:flutter/material.dart';

import '../screens/agenda_page.dart';
import '../screens/athlete_list_page.dart';
import '../screens/cabor_list_page.dart';
import '../screens/profil_page.dart';
import '../theme/colors.dart';

/// Floating bottom navigation SIORG (5 tab): Beranda · Cabor · Atlet · Agenda · Profil.
///
/// Bar navy melayang dengan margin & radius sesuai handoff (§1). Navigasi
/// default memakai `Navigator.push` (mengikuti arsitektur existing). Tab yang
/// sedang aktif tidak melakukan apa-apa; "Beranda" mengembalikan ke root.
class SiorgBottomNav extends StatelessWidget {
  /// 0 Beranda · 1 Cabor · 2 Atlet · 3 Agenda · 4 Profil
  final int active;
  const SiorgBottomNav({super.key, required this.active});

  void _go(BuildContext context, int index) {
    if (index == active) return;
    // Kembali ke Beranda (route pertama setelah splash/login) lalu push tab
    // tujuan — meniru perpindahan tab tanpa menumpuk stack navigasi.
    Navigator.popUntil(context, (route) => route.isFirst);
    final WidgetBuilder? builder = switch (index) {
      1 => (_) => const CaborListPage(),
      2 => (_) => const AthleteListPage(),
      3 => (_) => const AgendaPage(),
      4 => (_) => const ProfilPage(),
      _ => null, // 0 = Beranda (sudah di root)
    };
    if (builder != null) {
      Navigator.push(context, MaterialPageRoute(builder: builder));
    }
  }

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.home_rounded, 'Beranda'),
      (Icons.grid_view_rounded, 'Cabor'),
      (Icons.person_rounded, 'Atlet'),
      (Icons.calendar_today_rounded, 'Agenda'),
      (Icons.account_circle_rounded, 'Profil'),
    ];
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      height: 66,
      decoration: BoxDecoration(
        color: AppColors.navBar,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.navBar.withValues(alpha: 0.45),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Row(
        children: List.generate(items.length, (i) {
          final selected = i == active;
          final color = selected ? Colors.white : AppColors.navInactive;
          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => _go(context, i),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(items[i].$1, color: color, size: 22),
                  const SizedBox(height: 3),
                  Text(
                    items[i].$2,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
