import 'package:flutter/material.dart';

import '../data/siorg_seed.dart';
import '../models/cabor_model.dart';
import '../services/api_service.dart';
import '../theme/colors.dart';
import '../widgets/siorg_bottom_nav.dart';
import '../widgets/siorg_header.dart';
import 'athlete_list_page.dart';
import 'cabor_detail_page.dart';
import 'klub_list_page.dart';
import 'pelatih_list_page.dart';
import 'wasit_list_page.dart';

/// Daftar Cabang Olahraga (SIORG `/organisasi`).
///
/// Sumber data: `ApiService.fetchCabor()` (endpoint publik `{id, nama}`),
/// di-*enrich* dengan data seed SIORG untuk abbr/warna/jumlah/induk. Jika API
/// gagal atau kosong, fallback ke seed penuh agar layar tetap berguna.
class CaborListPage extends StatefulWidget {
  const CaborListPage({super.key});

  @override
  State<CaborListPage> createState() => _CaborListPageState();
}

class _CaborListPageState extends State<CaborListPage> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  late Future<List<CaborModel>> _futureCabor;

  String _query = '';
  String _statusFilter = 'Semua'; // Semua | Aktif | Pembinaan

  @override
  void initState() {
    super.initState();
    _futureCabor = _loadCabor();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Ambil cabor real dari API (nama + jumlah atlet/klub). Fallback ke seed
  /// hanya bila API kosong/error (offline).
  Future<List<CaborModel>> _loadCabor() async {
    try {
      final apiData = await _apiService.fetchCabor();
      if (apiData.isEmpty) return SiorgSeed.cabors;
      return apiData.map((e) => CaborModel.fromList(e)).toList();
    } catch (_) {
      return SiorgSeed.cabors; // fallback offline
    }
  }

  List<CaborModel> _applyFilters(List<CaborModel> source) {
    return source.where((c) {
      final matchQuery = _query.isEmpty ||
          c.name.toLowerCase().contains(_query.toLowerCase()) ||
          c.abbr.toLowerCase().contains(_query.toLowerCase());
      final matchStatus = _statusFilter == 'Semua' || c.status == _statusFilter;
      return matchQuery && matchStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      bottomNavigationBar: const SiorgBottomNav(active: 1),
      body: Column(
        children: [
          _header(),
          Expanded(
            child: FutureBuilder<List<CaborModel>>(
              future: _futureCabor,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.navy));
                }
                final all = snapshot.data ?? const <CaborModel>[];
                final list = _applyFilters(all);
                if (list.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('Cabang olahraga tidak ditemukan',
                          style: TextStyle(color: AppColors.muted)),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
                  itemCount: list.length,
                  itemBuilder: (_, i) => _caborCard(list[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return SiorgHeader(
      radius: 30,
      padding: const EdgeInsets.fromLTRB(18, 52, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SiorgHeader.iconButton(Icons.chevron_left, () => Navigator.pop(context)),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Organisasi',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
                    Text('Cabang olahraga KONI Kab. Tangerang',
                        style: TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                const Icon(Icons.search, size: 18, color: AppColors.muted),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _query = v),
                    decoration: const InputDecoration(
                      hintText: 'Cari cabang olahraga...',
                      hintStyle: TextStyle(color: AppColors.muted, fontSize: 13.5),
                      border: InputBorder.none,
                      isCollapsed: true,
                    ),
                    style: const TextStyle(fontSize: 13.5, color: AppColors.ink),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 32,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: ['Semua', 'Aktif', 'Pembinaan']
                  .map((f) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _filterChip(f),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label) {
    final active = _statusFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _statusFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppColors.ink : AppColors.surface,
          borderRadius: BorderRadius.circular(99),
        ),
        alignment: Alignment.center,
        child: Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: active ? Colors.white : AppColors.secondary)),
      ),
    );
  }

  Widget _caborCard(CaborModel c) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CaborDetailPage(cabor: c)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 18, offset: const Offset(0, 8)),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                _caborLogo(c),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c.name,
                          style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800, color: AppColors.ink)),
                      const SizedBox(height: 3),
                      Text(c.year > 0 ? 'Berdiri ${c.year} · ${c.abbr}' : c.abbr,
                          style: const TextStyle(fontSize: 11.5, color: AppColors.muted2, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                _statusBadge(c.status),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _miniStat('Atlet', c.atlet, AppColors.tintNavy, AppColors.navy, onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                      builder: (_) => AthleteListPage(caborId: c.id, caborName: c.name)));
                }),
                const SizedBox(width: 8),
                _miniStat('Klub', c.klub, AppColors.tintGreen, AppColors.success, onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                      builder: (_) => KlubListPage(caborId: c.id, caborName: c.name)));
                }),
                const SizedBox(width: 8),
                _miniStat('Pelatih', c.pelatih, AppColors.tintGold, AppColors.warning, onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                      builder: (_) => PelatihListPage(caborId: c.id, caborName: c.name)));
                }),
                const SizedBox(width: 8),
                _miniStat('Wasit', c.wasit, AppColors.tintPurple, const Color(0xFF7A4DA0), onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                      builder: (_) => WasitListPage(caborId: c.id, caborName: c.name)));
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Logo induk organisasi cabor; fallback kotak singkatan bila belum ada.
  Widget _caborLogo(CaborModel c) {
    final fallback = Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(color: c.color, borderRadius: BorderRadius.circular(15)),
      alignment: Alignment.center,
      child: Text(c.abbr,
          style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w800)),
    );
    final url = c.logo ?? '';
    if (url.isEmpty) return fallback;
    return Container(
      width: 52,
      height: 52,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.line, width: 1),
      ),
      child: Image.network(url, fit: BoxFit.contain, errorBuilder: (_, _, _) => fallback),
    );
  }

  Widget _statusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: SiorgSeed.statusBg(status), borderRadius: BorderRadius.circular(99)),
      child: Text(status,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: SiorgSeed.statusFg(status))),
    );
  }

  Widget _miniStat(String label, int value, Color bg, Color fg, {VoidCallback? onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
          child: Column(
            children: [
              Text('$value', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: fg)),
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(label, style: const TextStyle(fontSize: 10, color: AppColors.secondary, fontWeight: FontWeight.w600)),
                  if (onTap != null) ...[
                    const SizedBox(width: 2),
                    Icon(Icons.chevron_right, size: 11, color: fg.withValues(alpha: 0.8)),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
