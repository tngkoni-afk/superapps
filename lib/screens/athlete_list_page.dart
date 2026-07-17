import 'package:flutter/material.dart';
import 'dart:async';
import '../services/api_service.dart';
import '../models/atlit_model.dart';
import 'athlete_profile_page.dart';
import '../theme/colors.dart';
import '../widgets/login_required_view.dart';
import '../widgets/siorg_bottom_nav.dart';
import '../widgets/siorg_header.dart';

/// Daftar Atlet (SIORG `/atlet`).
///
/// Data dari `ApiService.fetchAtlit` (API nyata, search server-side dengan
/// debounce). Filter jenis kelamin (Semua/Putra/Putri) dan status atlit
/// (TSG/PENGCAB/DEGRAD, dari field `status_atlet`) diterapkan client-side.
class AthleteListPage extends StatefulWidget {
  /// Bila diisi, daftar difilter ke cabor tersebut (dipakai dari detail cabor).
  final String? caborId;
  final String? caborName;
  const AthleteListPage({super.key, this.caborId, this.caborName});

  @override
  State<AthleteListPage> createState() => _AthleteListPageState();
}

class _AthleteListPageState extends State<AthleteListPage> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  List<AtlitModel> _all = [];
  bool _loading = true;
  bool _loggedIn = true; // dicek dulu di _init; false → tampilkan LoginRequiredView
  String? _error;
  String _filter = 'Semua'; // Semua | Putra | Putri | TSG | PENGCAB | DEGRAD

  // Paginasi (infinite scroll) — atlet bisa ratusan, jadi dimuat bertahap.
  final ScrollController _scroll = ScrollController();
  static const int _pageSize = 15;
  int _page = 1;
  bool _hasMore = true;
  bool _loadingMore = false;
  String _query = '';

  // Palet warna avatar (dipakai bila atlet tak punya foto).
  static const _palette = [
    AppColors.navy, AppColors.success, Color(0xFFC25A2E), Color(0xFF2E8BA6),
    Color(0xFF7A4DA0), AppColors.warning, Color(0xFF545B66), Color(0xFFB23A48),
  ];

  static const _chips = ['Semua', 'Putra', 'Putri', 'TSG', 'PENGCAB', 'DEGRAD'];

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _init();
  }

  /// Data atlet hanya untuk pengguna login — cek token dulu sebelum fetch.
  Future<void> _init() async {
    final token = await _apiService.getToken();
    if (!mounted) return;
    if (token == null) {
      setState(() {
        _loggedIn = false;
        _loading = false;
      });
      return;
    }
    _fetch();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scroll.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 300) {
      _loadMore();
    }
  }

  Future<void> _fetch({String query = ''}) async {
    if (!_loggedIn) return;
    setState(() {
      _loading = true;
      _error = null;
      _query = query;
    });
    try {
      final data = await _apiService.fetchAtlit(query: query, caborId: widget.caborId, page: 1);
      if (!mounted) return;
      setState(() {
        _all = data;
        _page = 1;
        _hasMore = data.length >= _pageSize;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().contains('Silakan login') ? 'Silakan login untuk melihat atlet' : 'Gagal memuat data atlet';
        _loading = false;
      });
    }
  }

  /// Muat halaman berikutnya lalu tambahkan ke daftar (dipanggil saat scroll).
  Future<void> _loadMore() async {
    if (!_loggedIn || _loadingMore || !_hasMore || _loading) return;
    setState(() => _loadingMore = true);
    try {
      final next = _page + 1;
      final data = await _apiService.fetchAtlit(query: _query, caborId: widget.caborId, page: next);
      if (!mounted) return;
      setState(() {
        _all.addAll(data);
        _page = next;
        _hasMore = data.length >= _pageSize;
        _loadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingMore = false);
    }
  }

  void _onSearch(String q) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () => _fetch(query: q));
  }

  // ----- Helpers data -----
  String _genderCode(AtlitModel a) {
    final g = (a.jenisKelamin ?? '').toLowerCase();
    if (g.startsWith('l')) return 'L'; // 'L' / 'Laki-laki'
    if (g.startsWith('p')) return 'P'; // 'P' / 'Perempuan'
    return '-';
  }

  String _genderLabel(AtlitModel a) {
    switch (_genderCode(a)) {
      case 'L':
        return 'Putra';
      case 'P':
        return 'Putri';
      default:
        return '-';
    }
  }

  /// Status atlit dari API: TSG | PENGCAB | DEGRAD (bisa kosong).
  String _statusOf(AtlitModel a) => (a.statusAtlet ?? '').trim().toUpperCase();

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  Color _avatarColor(AtlitModel a) => _palette[a.id.abs() % _palette.length];

  List<AtlitModel> get _filtered {
    return _all.where((a) {
      switch (_filter) {
        case 'Putra':
          return _genderCode(a) == 'L';
        case 'Putri':
          return _genderCode(a) == 'P';
        case 'TSG':
        case 'PENGCAB':
        case 'DEGRAD':
          return _statusOf(a) == _filter;
        default:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final list = _filtered;
    return Scaffold(
      backgroundColor: AppColors.bg,
      bottomNavigationBar: const SiorgBottomNav(active: 2),
      body: Column(
        children: [
          _header(list.length),
          Expanded(child: _body(list)),
        ],
      ),
    );
  }

  Widget _header(int count) {
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.caborName ?? 'Atlet',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(widget.caborName != null ? 'Atlet cabang · $count' : '$count atlet ditampilkan',
                        style: const TextStyle(fontSize: 12.5, color: Colors.white70, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
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
                    onChanged: _onSearch,
                    decoration: const InputDecoration(
                      hintText: 'Cari nama atlet...',
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
              children: _chips
                  .map((f) => Padding(padding: const EdgeInsets.only(right: 8), child: _filterChip(f)))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label) {
    final active = _filter == label;
    return GestureDetector(
      onTap: () => setState(() => _filter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? AppColors.ink : AppColors.surface,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w700, color: active ? Colors.white : AppColors.secondary)),
      ),
    );
  }

  Widget _body(List<AtlitModel> list) {
    if (!_loggedIn) {
      return const LoginRequiredView(
        title: 'Login Diperlukan',
        message: 'Anda harus login untuk melihat data atlit.',
      );
    }
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.navy));
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.danger)),
        ),
      );
    }
    if (list.isEmpty) {
      return const Center(
        child: Text('Atlet tidak ditemukan', style: TextStyle(color: AppColors.muted)),
      );
    }
    return ListView.builder(
      controller: _scroll,
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
      itemCount: list.length + 1, // +1 untuk footer (loading / penanda habis)
      itemBuilder: (_, i) {
        if (i >= list.length) return _listFooter();
        return _athleteCard(list[i]);
      },
    );
  }

  Widget _listFooter() {
    if (_loadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator(color: AppColors.navy)),
      );
    }
    // Hanya tampilkan penanda "habis" saat tidak sedang memfilter client-side.
    if (!_hasMore && _filter == 'Semua') {
      return const Padding(
        padding: EdgeInsets.only(top: 6, bottom: 18),
        child: Center(
          child: Text('— semua atlet telah dimuat —',
              style: TextStyle(color: AppColors.faint, fontSize: 11, fontWeight: FontWeight.w500)),
        ),
      );
    }
    return const SizedBox(height: 8);
  }

  Widget _athleteCard(AtlitModel a) {
    final status = _statusOf(a);
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AthleteProfilePage(atlitId: a.id)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 11),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _avatar(a),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(a.nama,
                      style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.ink),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(a.cabor,
                      style: const TextStyle(fontSize: 11.5, color: AppColors.muted2, fontWeight: FontWeight.w500),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  if (_genderLabel(a) != '-') _miniChip(_genderLabel(a)),
                ],
              ),
            ),
            if (status.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: _statusBg(status), borderRadius: BorderRadius.circular(99)),
                child: Text(status,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _statusFg(status))),
              ),
          ],
        ),
      ),
    );
  }

  Widget _avatar(AtlitModel a) {
    final color = _avatarColor(a);
    if (a.foto != null && a.foto!.isNotEmpty) {
      return ClipOval(
        child: Image.network(a.foto!, width: 52, height: 52, fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _initialAvatar(a, color)),
      );
    }
    return _initialAvatar(a, color);
  }

  Widget _initialAvatar(AtlitModel a, Color color) {
    return Container(
      width: 52, height: 52,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(_initials(a.nama),
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
    );
  }

  Widget _miniChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(color: AppColors.tintGray, borderRadius: BorderRadius.circular(99)),
      child: Text(label,
          style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: AppColors.secondary)),
    );
  }

  Color _statusFg(String s) {
    switch (s) {
      case 'TSG':
        return AppColors.success;
      case 'PENGCAB':
        return AppColors.navy;
      case 'DEGRAD':
        return AppColors.danger;
      default:
        return AppColors.secondary;
    }
  }

  Color _statusBg(String s) {
    switch (s) {
      case 'TSG':
        return AppColors.tintGreen;
      case 'PENGCAB':
        return AppColors.tintNavy;
      case 'DEGRAD':
        return AppColors.tintRed;
      default:
        return AppColors.tintGray;
    }
  }
}
