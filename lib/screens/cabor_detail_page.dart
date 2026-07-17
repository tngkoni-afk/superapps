import 'package:flutter/material.dart';

import '../data/siorg_seed.dart';
import '../models/atlit_model.dart';
import '../models/cabor_model.dart';
import '../services/api_service.dart';
import '../theme/colors.dart';
import '../widgets/login_required_view.dart';
import '../widgets/siorg_header.dart';
import 'athlete_list_page.dart';
import 'athlete_profile_page.dart';
import 'klub_detail_page.dart';

/// Detail Cabang Olahraga (SIORG `/cabor/:id`).
///
/// Statistik, Induk Organisasi, Klub, dan Atlit diambil REAL dari API.
class CaborDetailPage extends StatefulWidget {
  final CaborModel cabor;
  const CaborDetailPage({super.key, required this.cabor});

  @override
  State<CaborDetailPage> createState() => _CaborDetailPageState();
}

class _CaborDetailPageState extends State<CaborDetailPage> {
  int _tab = 0;
  static const _tabs = ['Induk Organisasi', 'Pengurus', 'Klub', 'Atlit', 'Statistik'];

  final ApiService _apiService = ApiService();
  Future<List<AtlitModel>>? _atlitFuture; // lazy: dimuat saat tab Atlit dibuka
  Map<String, dynamic>? _detail;
  bool _loadingDetail = true;
  bool? _loggedIn; // null = masih cek token

  CaborModel get c => widget.cabor;

  @override
  void initState() {
    super.initState();
    _checkLogin();
    _loadDetail();
  }

  /// Tab Pengurus & Atlit berisi data pribadi — wajib login untuk melihat.
  Future<void> _checkLogin() async {
    final token = await _apiService.getToken();
    if (!mounted) return;
    setState(() => _loggedIn = token != null);
  }

  Future<void> _loadDetail() async {
    final id = int.tryParse(c.id);
    final data = id == null ? null : await _apiService.fetchCaborDetail(id);
    if (!mounted) return;
    setState(() {
      _detail = data;
      _loadingDetail = false;
    });
  }

  // Helpers baca data detail real.
  Map<String, dynamic>? get _stat => _detail?['statistik'] as Map<String, dynamic>?;
  Map<String, dynamic>? get _induk => _detail?['induk'] as Map<String, dynamic>?;
  List get _klubs => (_detail?['klub'] as List?) ?? const [];
  // Logo induk: dari detail API; sebelum termuat pakai logo bawaan list cabor.
  String get _indukLogo {
    final fromDetail = _str(_induk?['logo']);
    return fromDetail.isNotEmpty ? fromDetail : (c.logo ?? '');
  }

  int _statInt(String key, int fallback) {
    final v = _stat?[key];
    if (v == null) return fallback;
    return v is int ? v : int.tryParse('$v') ?? fallback;
  }

  String _str(dynamic v) {
    final s = (v ?? '').toString().trim();
    return (s.isEmpty || s == '-') ? '' : s;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          _header(),
          _tabBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
              child: _tabContent(),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- HEADER ----------------
  Widget _header() {
    return SiorgHeader(
      radius: 32,
      padding: const EdgeInsets.fromLTRB(18, 50, 18, 20),
      child: Column(
        children: [
          Row(
            children: [
              SiorgHeader.iconButton(Icons.chevron_left, () => Navigator.pop(context)),
              const Expanded(
                child: Center(
                  child: Text('Detail Cabang',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ),
              const SizedBox(width: 42),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _headerLogo(),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.name,
                        style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: Colors.white)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                              color: Colors.white, borderRadius: BorderRadius.circular(99)),
                          child: Text(c.status,
                              style: TextStyle(
                                  fontSize: 10, fontWeight: FontWeight.w700, color: SiorgSeed.statusFg(c.status))),
                        ),
                        if (c.year > 0) ...[
                          const SizedBox(width: 8),
                          Text('Berdiri ${c.year}',
                              style: const TextStyle(fontSize: 11.5, color: Colors.white70, fontWeight: FontWeight.w500)),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Logo di header: pakai logo induk organisasi bila ada, fallback singkatan.
  Widget _headerLogo() {
    final url = _indukLogo;
    if (url.isEmpty) {
      return Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(18),
        ),
        alignment: Alignment.center,
        child: Text(c.abbr,
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800)),
      );
    }
    return Container(
      width: 60,
      height: 60,
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      alignment: Alignment.center,
      child: Image.network(
        url,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => Text(c.abbr,
            style: TextStyle(color: c.color, fontSize: 13, fontWeight: FontWeight.w800)),
      ),
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

  Widget _tabContent() {
    // Pengurus (1) & Atlit (3) tak bergantung pada _detail; tab lain menunggu.
    if (_loadingDetail && _tab != 1 && _tab != 3) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 60),
        child: Center(child: CircularProgressIndicator(color: AppColors.navy)),
      );
    }
    // Pengurus & Atlit hanya untuk pengguna yang sudah login.
    if (_tab == 1 || _tab == 3) {
      if (_loggedIn == null) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 60),
          child: Center(child: CircularProgressIndicator(color: AppColors.navy)),
        );
      }
      if (_loggedIn == false) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 30),
          child: LoginRequiredView(
            title: 'Login Diperlukan',
            message: 'Anda harus login untuk melihat data ${_tab == 1 ? 'pengurus' : 'atlit'}.',
          ),
        );
      }
    }
    switch (_tab) {
      case 1:
        return _pengurusTab();
      case 2:
        return _klubTab();
      case 3:
        return _atlitTab();
      case 4:
        return _statistikTab();
      default:
        return _indukTab();
    }
  }

  // ---------------- TAB 3: ATLIT (real) ----------------
  Widget _atlitTab() {
    _atlitFuture ??= _apiService.fetchAtlit(caborId: c.id);
    return FutureBuilder<List<AtlitModel>>(
      future: _atlitFuture,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 50),
            child: Center(child: CircularProgressIndicator(color: AppColors.navy)),
          );
        }
        final list = snap.data ?? const <AtlitModel>[];
        if (list.isEmpty) {
          return _emptyState('Belum ada atlet terdaftar untuk cabang ini.');
        }
        final total = _statInt('atlet', list.length);
        return Column(
          children: [
            ...list.map(_atlitCard),
            if (total > list.length) ...[
              const SizedBox(height: 4),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => AthleteListPage(caborId: c.id, caborName: c.name)),
                ),
                child: Text('Lihat semua $total atlet',
                    style: const TextStyle(color: AppColors.navy, fontWeight: FontWeight.w700)),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _atlitCard(AtlitModel a) {
    final foto = a.foto ?? '';
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AthleteProfilePage(atlitId: a.id)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(18)),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: foto.isNotEmpty
                  ? Image.network(foto, width: 46, height: 46, fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _avatar(_klubInitials(a.nama), c.color, 46, 14))
                  : _avatar(_klubInitials(a.nama), c.color, 46, 14),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Text(a.nama,
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.ink),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            const Icon(Icons.chevron_right, color: AppColors.faint, size: 20),
          ],
        ),
      ),
    );
  }

  // ---------------- TAB 0: INDUK (real) ----------------
  Widget _indukTab() {
    final ind = _induk;
    if (ind == null) {
      return _emptyState('Belum ada data induk organisasi untuk cabang ini.');
    }

    final namaInduk = _str(ind['nama']);
    final namaOrg = _str(ind['nama_organisasi']);
    final alamat = _str(ind['alamat']);
    final kontak = _str(ind['kontak']);
    final visi = _str(ind['visi']);
    final misi = _str(ind['misi']);
    final sejarah = _str(ind['sejarah']);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _card(
          child: Column(
            children: [
              Row(
                children: [
                  _indukLogoBox(46, 14),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(namaInduk.isEmpty ? c.name : namaInduk,
                            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.ink)),
                        const SizedBox(height: 2),
                        const Text('Induk Organisasi Cabang',
                            style: TextStyle(fontSize: 11, color: AppColors.muted2, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              if (namaOrg.isNotEmpty) _infoRow('Nama Lengkap', namaOrg),
              if (alamat.isNotEmpty) _infoRow('Alamat / Sekretariat', alamat),
              if (kontak.isNotEmpty) _infoRow('Kontak', kontak, last: true),
              if (namaOrg.isEmpty && alamat.isEmpty && kontak.isEmpty)
                _infoRow('Info', 'Belum ada rincian kontak', last: true),
            ],
          ),
        ),
        if (sejarah.isNotEmpty) ...[
          const SizedBox(height: 12),
          _textCard('Sejarah', sejarah),
        ],
        if (visi.isNotEmpty) ...[
          const SizedBox(height: 12),
          _textCard('Visi', visi),
        ],
        if (misi.isNotEmpty) ...[
          const SizedBox(height: 12),
          _textCard('Misi', misi),
        ],
      ],
    );
  }

  /// Logo induk organisasi (dari API) dengan fallback kotak singkatan cabor.
  Widget _indukLogoBox(double size, double radius) {
    final fallback = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: c.color, borderRadius: BorderRadius.circular(radius)),
      alignment: Alignment.center,
      child: Text(c.abbr,
          style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w800)),
    );
    final url = _indukLogo;
    if (url.isEmpty) return fallback;
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppColors.line, width: 1),
      ),
      child: Image.network(url, fit: BoxFit.contain, errorBuilder: (_, _, _) => fallback),
    );
  }

  Widget _emptyState(String msg) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Center(
        child: Text(msg, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.muted, height: 1.5)),
      ),
    );
  }

  Widget _infoRow(String label, String value, {bool last = false, Color? valueColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(
        border: last ? null : const Border(bottom: BorderSide(color: AppColors.line, width: 1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(value,
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: valueColor ?? AppColors.ink)),
          ),
        ],
      ),
    );
  }

  // ---------------- TAB 1: PENGURUS (real) ----------------
  List get _pengurusList => (_detail?['pengurus'] as List?) ?? const [];

  Widget _pengurusTab() {
    if (_pengurusList.isEmpty) {
      return _emptyState('Belum ada data pengurus untuk cabang ini.');
    }
    return Column(
      children: _pengurusList.map((raw) {
        final p = Map<String, dynamic>.from(raw as Map);
        final nama = _str(p['nama']).isEmpty ? '-' : _str(p['nama']);
        final posisi = _str(p['posisi']);
        final status = _str(p['status_kepengurusan']);
        final sub = [posisi, status].where((s) => s.isNotEmpty).join(' · ');
        return GestureDetector(
          onTap: () => _showPengurusSheetReal(p),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(18)),
            child: Row(
              children: [
                _avatar(_klubInitials(nama), c.color, 46, 14),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(nama,
                          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.ink),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      if (sub.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(sub,
                            style: const TextStyle(fontSize: 11.5, color: AppColors.muted2, fontWeight: FontWeight.w500)),
                      ],
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.faint, size: 20),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showPengurusSheetReal(Map<String, dynamic> p) {
    final nama = _str(p['nama']).isEmpty ? '-' : _str(p['nama']);
    final posisi = _str(p['posisi']);
    final status = _str(p['status_kepengurusan']);
    final mulai = _str(p['tgl_mulai_jabatan']);
    final akhir = _str(p['tgl_akhir_jabatan']);
    final periode = [mulai, akhir].where((s) => s.isNotEmpty).join(' s/d ');
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: _grabber()),
            const SizedBox(height: 16),
            Row(
              children: [
                _avatar(_klubInitials(nama), c.color, 56, 18),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(nama,
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.ink)),
                      if (posisi.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(posisi,
                            style: const TextStyle(fontSize: 12, color: AppColors.secondary, fontWeight: FontWeight.w600)),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (posisi.isNotEmpty) _sheetRow(Icons.badge_outlined, 'Jabatan', posisi),
            if (status.isNotEmpty) _sheetRow(Icons.verified_outlined, 'Status', status),
            if (periode.isNotEmpty) _sheetRow(Icons.event_outlined, 'Periode', periode),
            if (posisi.isEmpty && status.isEmpty && periode.isEmpty)
              _sheetRow(Icons.info_outline, 'Info', 'Belum ada rincian jabatan'),
          ],
        ),
      ),
    );
  }

  // ---------------- TAB 2: KLUB (real) ----------------
  Widget _klubTab() {
    if (_klubs.isEmpty) {
      return _emptyState('Belum ada klub terdaftar untuk cabang ini.');
    }
    return Column(
      children: _klubs.map((raw) {
        final cl = Map<String, dynamic>.from(raw as Map);
        final nama = _str(cl['nama']).isEmpty ? 'Klub' : _str(cl['nama']);
        final alamat = _str(cl['alamat']);
        final foto = _str(cl['foto_url']);
        final klubId = int.tryParse((cl['id'] ?? '').toString());
        return GestureDetector(
          onTap: klubId == null
              ? () => _showKlubSheetReal(cl)
              : () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => KlubDetailPage(klubId: klubId)),
                  ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(18)),
            child: Row(
              children: [
                foto.isEmpty
                    ? _avatar(_klubInitials(nama), c.color, 46, 14)
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.network(foto, width: 46, height: 46, fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => _avatar(_klubInitials(nama), c.color, 46, 14)),
                      ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(nama,
                          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.ink),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      if (alamat.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(alamat,
                            style: const TextStyle(fontSize: 11.5, color: AppColors.muted2, fontWeight: FontWeight.w500),
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.faint, size: 20),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  String _klubInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  void _showKlubSheetReal(Map<String, dynamic> cl) {
    final nama = _str(cl['nama']).isEmpty ? 'Klub' : _str(cl['nama']);
    final alamat = _str(cl['alamat']);
    final kontak = _str(cl['kontak']);
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: _grabber()),
            const SizedBox(height: 16),
            Row(
              children: [
                _avatar(_klubInitials(nama), c.color, 56, 18),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(nama,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.ink)),
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (alamat.isNotEmpty) _sheetRow(Icons.location_on_outlined, 'Alamat', alamat),
            if (kontak.isNotEmpty) _sheetRow(Icons.phone_outlined, 'Kontak', kontak),
            if (alamat.isEmpty && kontak.isEmpty)
              _sheetRow(Icons.info_outline, 'Info', 'Belum ada rincian klub'),
          ],
        ),
      ),
    );
  }

  // ---------------- TAB 3: STATISTIK ----------------
  Widget _statistikTab() {
    final bars = <_Bar>[
      _Bar('Atlet', _statInt('atlet', c.atlet), AppColors.navy),
      _Bar('Klub', _statInt('klub', c.klub), AppColors.success),
      _Bar('Pelatih', _statInt('pelatih', c.pelatih), AppColors.warning),
      _Bar('Wasit', _statInt('wasit', c.wasit), const Color(0xFF7A4DA0)),
    ];
    final maxVal = bars.map((b) => b.value).fold<int>(1, (p, e) => e > p ? e : p);
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Statistik Cabang',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.ink)),
          const SizedBox(height: 16),
          ...bars.map((b) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(b.label,
                            style: const TextStyle(fontSize: 12.5, color: AppColors.secondary, fontWeight: FontWeight.w600)),
                        Text('${b.value}',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.ink)),
                      ],
                    ),
                    const SizedBox(height: 7),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        value: maxVal == 0 ? 0 : b.value / maxVal,
                        minHeight: 9,
                        backgroundColor: AppColors.line2,
                        valueColor: AlwaysStoppedAnimation<Color>(b.color),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  // ---------------- BOTTOM SHEETS ----------------

  // ---------------- SHARED ----------------
  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20)),
      child: child,
    );
  }

  Widget _textCard(String title, String body) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.ink)),
          const SizedBox(height: 7),
          Text(body, style: const TextStyle(fontSize: 12.5, height: 1.6, color: AppColors.secondary)),
        ],
      ),
    );
  }

  Widget _avatar(String initials, Color color, double size, double radius) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(radius)),
      alignment: Alignment.center,
      child: Text(initials,
          style: TextStyle(color: Colors.white, fontSize: size * 0.3, fontWeight: FontWeight.w700)),
    );
  }

  Widget _grabber() => Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(color: AppColors.line2, borderRadius: BorderRadius.circular(99)),
      );

  Widget _sheetRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.muted2),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ink)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Bar {
  final String label;
  final int value;
  final Color color;
  const _Bar(this.label, this.value, this.color);
}
