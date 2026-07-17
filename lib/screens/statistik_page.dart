import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../theme/colors.dart';
import '../widgets/siorg_header.dart';
import 'athlete_list_page.dart';
import 'cabor_list_page.dart';
import 'klub_list_page.dart';
import 'pelatih_list_page.dart';
import 'wasit_list_page.dart';

/// Statistik — ringkasan data KONI dari `/public/statistik`.
/// Kartu metrik bisa diketuk ke daftar terkait, plus bar distribusi.
class StatistikPage extends StatefulWidget {
  const StatistikPage({super.key});

  @override
  State<StatistikPage> createState() => _StatistikPageState();
}

class _StatistikPageState extends State<StatistikPage> {
  final ApiService _apiService = ApiService();
  Map<String, int> _stats = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s = await _apiService.fetchStatistik();
    if (!mounted) return;
    setState(() {
      _stats = s;
      _loading = false;
    });
  }

  String _fmt(int? n) {
    if (n == null) return '—';
    final s = n.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  int _v(String k) => _stats[k] ?? 0;

  void _open(Widget page) => Navigator.push(context, MaterialPageRoute(builder: (_) => page));

  @override
  Widget build(BuildContext context) {
    final metrics = <_Metric>[
      _Metric('Atlet', 'total_atlit', Icons.directions_run_rounded, AppColors.navy, AppColors.tintNavy,
          () => _open(const AthleteListPage())),
      _Metric('Cabang Olahraga', 'total_cabor', Icons.sports_rounded, const Color(0xFF7A4DA0), AppColors.tintPurple,
          () => _open(const CaborListPage())),
      _Metric('Pelatih', 'total_pelatih', Icons.sports_kabaddi_rounded, AppColors.warning, AppColors.tintGold,
          () => _open(const PelatihListPage())),
      _Metric('Wasit', 'total_wasit', Icons.sports_score_rounded, const Color(0xFF2E8BA6), const Color(0xFFE4F0F2),
          () => _open(const WasitListPage())),
      _Metric('Klub', 'total_klub', Icons.groups_rounded, AppColors.success, AppColors.tintGreen,
          () => _open(const KlubListPage())),
      _Metric('Prestasi', 'total_prestasi', Icons.emoji_events_rounded, AppColors.red, AppColors.tintRed, null),
    ];

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          _header(),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.navy))
                : RefreshIndicator(
                    color: AppColors.redMid,
                    onRefresh: _load,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
                      children: [
                        _grid(metrics),
                        const SizedBox(height: 22),
                        _distribusi(metrics.where((m) => m.key != 'total_prestasi').toList()),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return SiorgHeader(
      radius: 30,
      padding: const EdgeInsets.fromLTRB(18, 52, 18, 20),
      child: Row(
        children: [
          SiorgHeader.iconButton(Icons.chevron_left, () => Navigator.pop(context)),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Statistik',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
                Text('Ringkasan data KONI Kab. Tangerang',
                    style: TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _grid(List<_Metric> metrics) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.25,
      children: metrics.map(_metricCard).toList(),
    );
  }

  Widget _metricCard(_Metric m) {
    return GestureDetector(
      onTap: m.onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(color: m.tint, borderRadius: BorderRadius.circular(12)),
                  alignment: Alignment.center,
                  child: Icon(m.icon, size: 20, color: m.color),
                ),
                const Spacer(),
                if (m.onTap != null) const Icon(Icons.chevron_right, size: 18, color: AppColors.faint),
              ],
            ),
            const Spacer(),
            Text(_fmt(_v(m.key)),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.ink)),
            const SizedBox(height: 2),
            Text(m.label,
                style: const TextStyle(fontSize: 11.5, color: AppColors.secondary, fontWeight: FontWeight.w500),
                maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _distribusi(List<_Metric> metrics) {
    final maxVal = metrics.map((m) => _v(m.key)).fold<int>(1, (p, e) => e > p ? e : p);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Distribusi Data',
              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.ink)),
          const SizedBox(height: 16),
          ...metrics.map((m) {
            final v = _v(m.key);
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(m.label,
                          style: const TextStyle(fontSize: 12.5, color: AppColors.secondary, fontWeight: FontWeight.w600)),
                      Text(_fmt(v),
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.ink)),
                    ],
                  ),
                  const SizedBox(height: 7),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: maxVal == 0 ? 0 : v / maxVal,
                      minHeight: 9,
                      backgroundColor: AppColors.line2,
                      valueColor: AlwaysStoppedAnimation<Color>(m.color),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _Metric {
  final String label;
  final String key;
  final IconData icon;
  final Color color;
  final Color tint;
  final VoidCallback? onTap;
  const _Metric(this.label, this.key, this.icon, this.color, this.tint, this.onTap);
}
