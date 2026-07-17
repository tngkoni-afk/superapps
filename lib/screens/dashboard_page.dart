import 'package:flutter/material.dart';
import 'news_detail_page.dart';
import 'agenda_detail_page.dart';
import 'athlete_list_page.dart';
import '../services/api_service.dart';
import '../models/berita_model.dart';
import '../models/agenda_model.dart';
import 'coming_soon_page.dart';
import 'cabor_list_page.dart';
import 'pelatih_list_page.dart';
import 'wasit_list_page.dart';
import 'statistik_page.dart';
import 'profil_page.dart';
import 'login_page.dart';
import '../config/api_config.dart';
import '../theme/colors.dart';
import '../widgets/siorg_bottom_nav.dart';
import '../widgets/siorg_header.dart';

/// Beranda (SIORG `/dashboard`).
///
/// Struktur sesuai handoff: greeting header, KPI tonal, kartu statistik,
/// Menu Cepat, lalu Berita & Agenda terdekat. Greeting dari /auth/me dan
/// angka KPI/statistik dari /public/statistik (count real DB) — semua live API.
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final ApiService _apiService = ApiService();

  late Future<List<BeritaModel>> _futureBerita;
  late Future<List<AgendaModel>> _futureAgenda;

  // Greeting profil — dinamis dari /auth/me; fallback "Guest" bila belum login.
  String _greetName = 'Guest';
  String _greetRole = 'Tamu';
  String? _avatarUrl;
  bool _loggedIn = false;

  // Statistik ringkasan dari /public/statistik (count real DB).
  Map<String, int> _stats = {};

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadProfile();
    _loadStats();
  }

  void _loadData() {
    _futureBerita = _apiService.fetchBerita();
    _futureAgenda = _apiService.fetchAgenda(upcoming: true);
  }

  Future<void> _loadStats() async {
    final s = await _apiService.fetchStatistik();
    if (!mounted) return;
    setState(() => _stats = s);
  }

  /// Format angka ala Indonesia (1842 -> "1.842"); null/kosong -> "—".
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

  void _goAthletes() =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => const AthleteListPage()));
  void _goCabor() =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => const CaborListPage()));
  void _goPelatih() =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => const PelatihListPage()));
  void _goWasit() =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => const WasitListPage()));
  void _goStatistik() =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => const StatistikPage()));

  /// Muat profil user yang sedang login. Bila belum login → tetap "Guest".
  Future<void> _loadProfile() async {
    final p = await _apiService.getProfile();
    if (!mounted) return;
    setState(() {
      if (p != null) {
        _loggedIn = true;
        _greetName = (p['name'] ?? 'Pengguna').toString();
        _greetRole = _titleCase((p['role'] ?? 'Pengurus KONI').toString());
        _avatarUrl = _avatarUrlFrom(p['avatar']);
      } else {
        _loggedIn = false;
        _greetName = 'Guest';
        _greetRole = 'Tamu';
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

  void _onProfileTap() {
    if (_loggedIn) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilPage()));
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage()))
          .then((_) => _loadProfile());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      bottomNavigationBar: const SiorgBottomNav(active: 0),
      body: RefreshIndicator(
        color: AppColors.redMid,
        onRefresh: () async {
          setState(_loadData);
          await Future.wait([_loadStats(), _loadProfile()]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 20, 18, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _statGrid(),
                    const SizedBox(height: 24),
                    _sectionTitle('Berita Terkini'),
                    const SizedBox(height: 4),
                    _heroNews(),
                    _newsList(),
                    const SizedBox(height: 20),
                    _sectionTitle('Agenda Terdekat'),
                    const SizedBox(height: 4),
                    _agendaPreview(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= HEADER (greeting + KPI) =================
  Widget _header() {
    return SiorgHeader(
      radius: 30,
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(onTap: _onProfileTap, child: _profileAvatar()),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Halo, $_greetName',
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(_greetRole,
                        style: const TextStyle(fontSize: 11.5, color: Colors.white70, fontWeight: FontWeight.w600),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              SiorgHeader.iconButton(
                Icons.notifications_none_rounded,
                () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => const ComingSoonPage(title: 'Notifikasi'))),
              ),
              const SizedBox(width: 10),
              _koniLogoChip(),
            ],
          ),
          const SizedBox(height: 18),
          _kpiCardWhite(),
        ],
      ),
    );
  }

  Widget _kpiCardWhite() {
    return GestureDetector(
      onTap: _goAthletes,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(22)),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total atlet terdaftar',
                      style: TextStyle(fontSize: 11.5, color: AppColors.secondary, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text(_fmt(_stats['total_atlit']),
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.ink, height: 1.15)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(color: AppColors.tintRed, borderRadius: BorderRadius.circular(14)),
              child: const Row(
                children: [
                  Text('Lihat', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.red)),
                  SizedBox(width: 2),
                  Icon(Icons.chevron_right, size: 16, color: AppColors.red),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileAvatar() {
    if (!_loggedIn) {
      return Container(
        width: 46,
        height: 46,
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: const Icon(Icons.person_outline, color: AppColors.redMid, size: 24),
      );
    }
    if (_avatarUrl != null) {
      return ClipOval(
        child: Image.network(_avatarUrl!, width: 46, height: 46, fit: BoxFit.cover,
            errorBuilder: (_, _, _) => SiorgHeader.initialsAvatar(_initialsOf(_greetName), size: 46)),
      );
    }
    return SiorgHeader.initialsAvatar(_initialsOf(_greetName), size: 46);
  }

  Widget _koniLogoChip() {
    return Container(
      width: 42,
      height: 42,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(13)),
      child: Image.asset('assets/koni_logo.png', fit: BoxFit.contain,
          errorBuilder: (_, _, _) => const Icon(Icons.emoji_events, color: AppColors.red, size: 20)),
    );
  }

  // ================= STAT GRID (2x2) — angka live + tappable =================
  Widget _statGrid() {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              _statCard('CO', _fmt(_stats['total_cabor']), 'Cabang Olahraga', AppColors.tintNavy, AppColors.navy,
                  onTap: _goCabor),
              const SizedBox(height: 12),
              _statCard('WS', _fmt(_stats['total_wasit']), 'Wasit', AppColors.tintPurple, const Color(0xFF7A4DA0),
                  onTap: _goWasit),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            children: [
              _statCard('PL', _fmt(_stats['total_pelatih']), 'Pelatih', AppColors.tintGold, AppColors.warning,
                  onTap: _goPelatih),
              const SizedBox(height: 12),
              _statCard('ST', '', 'Statistik', AppColors.tintGray, AppColors.secondary,
                  onTap: _goStatistik, valueIcon: Icons.bar_chart_rounded),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statCard(String mono, String value, String label, Color tint, Color fg,
      {VoidCallback? onTap, IconData? valueIcon}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(11)),
                  alignment: Alignment.center,
                  child: Text(mono, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: fg)),
                ),
                const Spacer(),
                if (onTap != null) const Icon(Icons.chevron_right, size: 18, color: AppColors.faint),
              ],
            ),
            const SizedBox(height: 12),
            valueIcon != null
                ? Icon(valueIcon, size: 26, color: AppColors.ink)
                : Text(value,
                    maxLines: 1,
                    overflow: TextOverflow.visible,
                    style: const TextStyle(
                        fontSize: 26, height: 1.05, fontWeight: FontWeight.w800, color: AppColors.ink)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 11.5, color: AppColors.secondary, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  // ================= SECTION TITLE =================
  Widget _sectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.ink));
  }

  // ================= BERITA =================
  Widget _heroNews() {
    return FutureBuilder<List<BeritaModel>>(
      future: _futureBerita,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator(color: AppColors.navy)),
          );
        }
        if (snapshot.hasError) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text('Gagal memuat berita', style: TextStyle(color: AppColors.muted)),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const SizedBox.shrink();
        final hero = snapshot.data![0];
        return GestureDetector(
          onTap: () => _openDetail(hero),
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  Image.network(hero.foto ?? '', height: 200, width: double.infinity, fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          Container(height: 200, color: AppColors.tintGray, child: const Icon(Icons.image))),
                  Container(
                    height: 200,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.bottomCenter, end: Alignment.topCenter,
                          colors: [Colors.black87, Colors.transparent]),
                    ),
                  ),
                  Positioned(
                    bottom: 16, left: 16, right: 16,
                    child: Text(hero.judul,
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _newsList() {
    return FutureBuilder<List<BeritaModel>>(
      future: _futureBerita,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.length < 2) return const SizedBox.shrink();
        final items = snapshot.data!.skip(1).take(3).toList();
        return Column(
          children: items
              .map((berita) => GestureDetector(
                    onTap: () => _openDetail(berita),
                    child: Container(
                      margin: const EdgeInsets.only(top: 12),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(berita.foto ?? '', width: 76, height: 64, fit: BoxFit.cover,
                                errorBuilder: (_, _, _) =>
                                    Container(width: 76, height: 64, color: AppColors.tintGray)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(berita.judul, maxLines: 2, overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.ink)),
                                const SizedBox(height: 4),
                                Text(berita.createdAt,
                                    style: const TextStyle(fontSize: 11, color: AppColors.muted)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ))
              .toList(),
        );
      },
    );
  }

  // ================= AGENDA =================
  String _getMonth(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'];
      return months[dt.month - 1];
    } catch (_) {
      return 'MMM';
    }
  }

  String _getDay(String dateStr) {
    try {
      return DateTime.parse(dateStr).day.toString().padLeft(2, '0');
    } catch (_) {
      return '00';
    }
  }

  Widget _agendaPreview() {
    return FutureBuilder<List<AgendaModel>>(
      future: _futureAgenda,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator(color: AppColors.navy)),
          );
        }
        if (snapshot.hasError) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('Gagal memuat agenda', style: TextStyle(color: AppColors.muted)),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('Tidak ada agenda terdekat', style: TextStyle(color: AppColors.muted)),
          );
        }
        return Column(
          children: snapshot.data!.take(3).map((agenda) {
            return GestureDetector(
              onTap: () => _openAgendaDetail(agenda),
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      Container(
                        width: 64,
                        decoration: const BoxDecoration(
                          color: AppColors.navy,
                          borderRadius: BorderRadius.horizontal(left: Radius.circular(16)),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_getMonth(agenda.tanggalMulai).toUpperCase(),
                                style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w700)),
                            Text(_getDay(agenda.tanggalMulai),
                                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(agenda.namaAgenda,
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.ink),
                                  maxLines: 1, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.location_on_outlined, size: 14, color: AppColors.navy),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(agenda.lokasi.isEmpty ? 'Tangerang' : agenda.lokasi,
                                        style: const TextStyle(fontSize: 11.5, color: AppColors.muted), maxLines: 1),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: Icon(Icons.chevron_right, color: AppColors.faint, size: 20),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // ================= NAV HELPERS =================
  void _openDetail(BeritaModel berita) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => NewsDetailPage(
                image: berita.foto ?? '',
                title: berita.judul,
                tag: 'KONI',
                category: 'Berita',
                time: berita.createdAt,
                content: berita.deskripsi)));
  }

  void _openAgendaDetail(AgendaModel agenda) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => AgendaDetailPage(agenda: agenda)));
  }
}
