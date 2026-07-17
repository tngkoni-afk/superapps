import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/atlit_model.dart';
import '../theme/colors.dart';
import '../utils/mask.dart';
import '../widgets/siorg_bottom_nav.dart';
import '../widgets/siorg_header.dart';
import '../widgets/login_required_view.dart';
import '../widgets/photo_preview.dart';

/// Detail Atlet (SIORG `/atlet/:id`).
///
/// Data dari `ApiService.fetchAtlitDetail`. Tab: Biodata · Prestasi ·
/// Sertifikasi · Pertandingan · Dokumen. Sertifikasi/Pertandingan/Dokumen
/// belum tersedia di API sehingga menampilkan empty state.
class AthleteProfilePage extends StatefulWidget {
  final int atlitId;
  const AthleteProfilePage({super.key, required this.atlitId});

  @override
  State<AthleteProfilePage> createState() => _AthleteProfilePageState();
}

class _AthleteProfilePageState extends State<AthleteProfilePage> {
  final ApiService _apiService = ApiService();
  late Future<AtlitModel> _future;
  int _tab = 0;

  static const _tabs = ['Biodata', 'Prestasi', 'Sertifikasi', 'Pertandingan', 'Dokumen'];
  static const _palette = [
    AppColors.navy, AppColors.success, Color(0xFFC25A2E), Color(0xFF2E8BA6),
    Color(0xFF7A4DA0), AppColors.warning, Color(0xFF545B66), Color(0xFFB23A48),
  ];

  @override
  void initState() {
    super.initState();
    _future = _apiService.fetchAtlitDetail(widget.atlitId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      bottomNavigationBar: const SiorgBottomNav(active: 2),
      body: FutureBuilder<AtlitModel>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.navy));
          }
          if (snapshot.hasError) {
            if (snapshot.error.toString().contains('Silakan login')) return _lockedScreen();
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Gagal memuat detail atlet', textAlign: TextAlign.center, style: const TextStyle(color: AppColors.danger)),
              ),
            );
          }
          return _profile(snapshot.data!);
        },
      ),
    );
  }

  // ---------------- HELPERS ----------------
  Color get _sportColor => _palette[widget.atlitId.abs() % _palette.length];

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  String _age(String? tglLahir) {
    if (tglLahir == null) return '-';
    try {
      final birth = DateTime.parse(tglLahir);
      final today = DateTime.now();
      var age = today.year - birth.year;
      if (today.month < birth.month || (today.month == birth.month && today.day < birth.day)) age--;
      return '$age';
    } catch (_) {
      return '-';
    }
  }

  String _measure(String? v) => (v == null || v.isEmpty || v == '0') ? '-' : v;

  String _genderLabel(String? g) {
    final s = (g ?? '').toLowerCase();
    if (s.startsWith('l')) return 'Laki-laki';
    if (s.startsWith('p')) return 'Perempuan';
    return '-';
  }

  String _club(AtlitModel a) {
    if (a.riwayatCabor != null && a.riwayatCabor!.isNotEmpty) {
      return a.riwayatCabor![0]['nama_klub']?.toString() ?? a.cabor;
    }
    return a.cabor;
  }

  String _birth(AtlitModel a) {
    if (a.tglLahir == null) return '-';
    try {
      final dt = DateTime.parse(a.tglLahir!);
      const m = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'];
      final ttl = '${dt.day} ${m[dt.month - 1]} ${dt.year}';
      return a.tempatLahir != null && a.tempatLahir!.isNotEmpty ? '${a.tempatLahir}, $ttl' : ttl;
    } catch (_) {
      return a.tglLahir!;
    }
  }

  // ---------------- PROFILE ----------------
  Widget _profile(AtlitModel a) {
    return CustomScrollView(
      slivers: [
        SliverPersistentHeader(
          pinned: true,
          delegate: _AthleteHeaderDelegate(
            nama: a.nama,
            foto: a.foto ?? '',
            initials: _initials(a.nama),
            sub: '${a.cabor} · ${_club(a)}',
            cabor: a.cabor,
            usia: _age(a.tglLahir),
            tinggi: _measure(a.tinggiBadan),
            berat: _measure(a.beratBadan),
            color: _sportColor,
            onBack: () => Navigator.pop(context),
            onPhoto: () => showPhotoPreview(context, a.foto ?? '', initials: _initials(a.nama)),
          ),
        ),
        SliverPersistentHeader(
          pinned: true,
          delegate: _PinnedWidgetDelegate(
            height: 56,
            child: Container(color: AppColors.bg, alignment: Alignment.centerLeft, child: _tabBar()),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
            child: _tabContent(a),
          ),
        ),
      ],
    );
  }

  Widget _tabBar() {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _tabs.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final active = _tab == i;
          return Center(
            child: GestureDetector(
              onTap: () => setState(() => _tab = i),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: active ? AppColors.ink : AppColors.surface,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(_tabs[i],
                    style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: active ? Colors.white : AppColors.secondary)),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _tabContent(AtlitModel a) {
    switch (_tab) {
      case 1:
        return _prestasiTab(a);
      case 2:
        return _emptyState(Icons.workspace_premium_outlined, 'Belum ada data sertifikasi');
      case 3:
        return _emptyState(Icons.sports_score_outlined, 'Belum ada riwayat pertandingan');
      case 4:
        return _emptyState(Icons.folder_outlined, 'Belum ada dokumen');
      default:
        return _biodataTab(a);
    }
  }

  // ---------------- TAB 0: BIODATA ----------------
  Widget _biodataTab(AtlitModel a) {
    final rows = <(String, String)>[
      ('NIK', a.nik ?? '-'),
      ('Tempat/Tgl Lahir', _birth(a)),
      ('Jenis Kelamin', _genderLabel(a.jenisKelamin)),
      ('Golongan Darah', a.golonganDarah ?? '-'),
      ('Pendidikan', a.pendidikan ?? '-'),
      ('No. HP', Mask.phone(a.noTelp)),
      ('Alamat', a.alamat ?? '-'),
      ('Nama Orang Tua', Mask.name(a.namaOrangTua)),
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 17),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: List.generate(rows.length, (i) {
          final last = i == rows.length - 1;
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: last ? null : const Border(bottom: BorderSide(color: AppColors.line, width: 1)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(rows[i].$1, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(rows[i].$2,
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.ink)),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ---------------- TAB 1: PRESTASI ----------------
  Widget _prestasiTab(AtlitModel a) {
    final list = a.prestasi ?? [];
    if (list.isEmpty) return _emptyState(Icons.emoji_events_outlined, 'Belum ada riwayat prestasi');
    return Column(
      children: List.generate(list.length, (i) {
        final item = list[i] as Map;
        final title = (item['nama'] ?? item['kejuaraan'] ?? 'Kejuaraan').toString();
        final award = (item['penghargaan'] ?? item['medali'] ?? '-').toString();
        final year = (item['tahun'] ?? '').toString();
        final aw = award.toLowerCase();
        final isGold = aw.contains('emas') || aw.contains('1');
        final isSilver = aw.contains('perak') || aw.contains('2');
        final medalColor = isGold ? const Color(0xFFC98A1E) : isSilver ? const Color(0xFF9AA3B2) : const Color(0xFFC2825A);
        final isLast = i == list.length - 1;
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(color: medalColor, shape: BoxShape.circle),
                    child: const Icon(Icons.emoji_events, color: Colors.white, size: 18),
                  ),
                  if (!isLast) Expanded(child: Container(width: 2, color: const Color(0xFFE6E9EF), margin: const EdgeInsets.only(top: 2))),
                ],
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(18)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(award, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: medalColor)),
                            if (year.isNotEmpty)
                              Text(year, style: const TextStyle(fontSize: 11, color: AppColors.muted2, fontWeight: FontWeight.w700)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.ink, height: 1.35)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _emptyState(IconData icon, String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 64, height: 64,
              decoration: const BoxDecoration(color: AppColors.tintGray, shape: BoxShape.circle),
              child: Icon(icon, color: AppColors.muted2, size: 30),
            ),
            const SizedBox(height: 14),
            Text(message, style: const TextStyle(color: AppColors.muted, fontSize: 13, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  // ---------------- LOCKED ----------------
  Widget _lockedScreen() => const LoginRequiredView();
}

/// Sliver pinned sederhana untuk membungkus widget dengan tinggi tetap (tab bar).
class _PinnedWidgetDelegate extends SliverPersistentHeaderDelegate {
  final double height;
  final Widget child;
  _PinnedWidgetDelegate({required this.height, required this.child});

  @override
  double get minExtent => height;
  @override
  double get maxExtent => height;
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) =>
      SizedBox.expand(child: child);
  @override
  bool shouldRebuild(covariant _PinnedWidgetDelegate oldDelegate) =>
      oldDelegate.height != height || oldDelegate.child != child;
}

/// Header atlet yang mengecil saat di-scroll: foto menyusut (116→54), info
/// (cabang·klub + pill) melipat & memudar, sedangkan nama dan 3 kotak
/// (Usia/Tinggi/Berat) tetap dipertahankan. Scroll ke atas → membesar lagi.
class _AthleteHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String nama, foto, initials, sub, cabor, usia, tinggi, berat;
  final Color color;
  final VoidCallback onBack, onPhoto;

  _AthleteHeaderDelegate({
    required this.nama,
    required this.foto,
    required this.initials,
    required this.sub,
    required this.cabor,
    required this.usia,
    required this.tinggi,
    required this.berat,
    required this.color,
    required this.onBack,
    required this.onPhoto,
  });

  @override
  double get minExtent => 214;
  @override
  double get maxExtent => 348;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final t = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);
    final photo = lerpDouble(116, 54, t)!;
    final nameSize = lerpDouble(20, 15.5, t)!;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
      child: Container(
        decoration: const BoxDecoration(gradient: AppColors.headerGradient),
        child: Stack(
          children: [
            Positioned(
              top: -44,
              right: -30,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.08)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 44, 18, 14),
              child: Stack(
                children: [
                  Align(alignment: Alignment.topLeft, child: SiorgHeader.iconButton(Icons.chevron_left, onBack, size: 38)),
                  Positioned.fill(
                    child: Column(
              children: [
                GestureDetector(
                  onTap: onPhoto,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: photo,
                        height: photo,
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
                        child: foto.isNotEmpty
                            ? ClipOval(child: Image.network(foto, fit: BoxFit.cover, errorBuilder: (_, _, _) => _initCircle()))
                            : _initCircle(),
                      ),
                      if (foto.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.all(2),
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
                          child: const Icon(Icons.zoom_in, size: 12, color: Colors.white),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(nama,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: nameSize, fontWeight: FontWeight.w800, color: Colors.white)),
                // Bagian yang melipat saat collapse (cabang·klub + pill).
                ClipRect(
                  child: Align(
                    alignment: Alignment.topCenter,
                    heightFactor: (1 - t),
                    child: Opacity(
                      opacity: (1 - t).clamp(0.0, 1.0),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Column(
                          children: [
                            Text(sub,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 10),
                            Wrap(spacing: 8, children: [_pill(cabor), _pill('Aktif')]),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    _box(usia, 'Usia'),
                    const SizedBox(width: 10),
                    _box(tinggi, 'Tinggi cm'),
                    const SizedBox(width: 10),
                    _box(berat, 'Berat kg'),
                  ],
                ),
              ],
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

  Widget _initCircle() => Container(
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        alignment: Alignment.center,
        child: Text(initials, style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w700)),
      );

  Widget _pill(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(99)),
        child: Text(text,
            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.redMid)),
      );

  Widget _box(String value, String label) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(value,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.ink, height: 1)),
              const SizedBox(height: 3),
              Text(label,
                  style: const TextStyle(fontSize: 9.5, color: AppColors.muted, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      );

  @override
  bool shouldRebuild(covariant _AthleteHeaderDelegate old) =>
      old.nama != nama || old.foto != foto || old.sub != sub || old.usia != usia ||
      old.tinggi != tinggi || old.berat != berat || old.color != color;
}
