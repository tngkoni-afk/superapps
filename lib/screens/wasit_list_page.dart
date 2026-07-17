import 'dart:async';
import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../theme/colors.dart';
import '../widgets/login_required_view.dart';
import '../widgets/siorg_header.dart';
import 'person_detail_page.dart';

/// Daftar Wasit (API publik `/public/wasit`) — infinite scroll + search
/// server-side, mekanisme sama dengan Atlet/Pelatih. Detail butuh login.
class WasitListPage extends StatefulWidget {
  /// Bila diisi, difilter ke wasit cabor tersebut (via riwayat pengalaman).
  final String? caborId;
  final String? caborName;
  const WasitListPage({super.key, this.caborId, this.caborName});

  @override
  State<WasitListPage> createState() => _WasitListPageState();
}

class _WasitListPageState extends State<WasitListPage> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scroll = ScrollController();
  Timer? _debounce;

  static const int _pageSize = 15;
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;
  bool _loggedIn = true; // dicek dulu di _init; false → tampilkan LoginRequiredView
  bool _loadingMore = false;
  bool _hasMore = true;
  int _page = 1;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _init();
  }

  /// Data wasit hanya untuk pengguna login — cek token dulu sebelum fetch.
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
      _query = query;
    });
    final data = await _apiService.fetchWasitPage(page: 1, query: query, caborId: widget.caborId);
    if (!mounted) return;
    setState(() {
      _items = data;
      _page = 1;
      _hasMore = data.length >= _pageSize;
      _loading = false;
    });
  }

  Future<void> _loadMore() async {
    if (!_loggedIn || _loadingMore || !_hasMore || _loading) return;
    setState(() => _loadingMore = true);
    final next = _page + 1;
    final data = await _apiService.fetchWasitPage(page: next, query: _query, caborId: widget.caborId);
    if (!mounted) return;
    setState(() {
      _items.addAll(data);
      _page = next;
      _hasMore = data.length >= _pageSize;
      _loadingMore = false;
    });
  }

  void _onSearch(String q) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () => _fetch(query: q));
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  void _openDetail(Map<String, dynamic> w) {
    final id = int.tryParse((w['id'] ?? '').toString());
    if (id == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PersonDetailPage(
          id: id,
          roleLabel: 'Wasit',
          fetcher: _apiService.fetchWasitDetail,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          _header(),
          Expanded(child: _body()),
        ],
      ),
    );
  }

  Widget _body() {
    if (!_loggedIn) {
      return const LoginRequiredView(
        title: 'Login Diperlukan',
        message: 'Anda harus login untuk melihat data wasit.',
      );
    }
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.navy));
    }
    if (_items.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('Belum ada data wasit', style: TextStyle(color: AppColors.muted)),
        ),
      );
    }
    return ListView.builder(
      controller: _scroll,
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
      itemCount: _items.length + 1,
      itemBuilder: (_, i) {
        if (i >= _items.length) return _listFooter();
        return _wasitCard(_items[i]);
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
    if (!_hasMore) {
      return const Padding(
        padding: EdgeInsets.only(top: 6, bottom: 18),
        child: Center(
          child: Text('— semua wasit telah dimuat —',
              style: TextStyle(color: AppColors.faint, fontSize: 11, fontWeight: FontWeight.w500)),
        ),
      );
    }
    return const SizedBox(height: 8);
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.caborName != null ? 'Wasit ${widget.caborName}' : 'Wasit',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(widget.caborName != null ? 'Wasit cabang ini' : 'Wasit terdaftar KONI Kab. Tangerang',
                        style: const TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w500)),
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
                    onChanged: _onSearch,
                    decoration: const InputDecoration(
                      hintText: 'Cari nama wasit...',
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
        ],
      ),
    );
  }

  Widget _wasitCard(Map<String, dynamic> w) {
    final nama = (w['nama'] ?? '-').toString();
    final foto = (w['foto_url'] ?? '').toString();
    final gender = (w['jenis_kelamin'] ?? '').toString();
    final lahir = (w['tempat_lahir'] ?? '').toString();
    final subtitle = [gender, lahir].where((s) => s.isNotEmpty).join(' · ');

    return GestureDetector(
      onTap: () => _openDetail(w),
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(18)),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: foto.isNotEmpty
                  ? Image.network(foto, width: 52, height: 52, fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _avatarFallback(nama))
                  : _avatarFallback(nama),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nama,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.ink),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(subtitle,
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
  }

  Widget _avatarFallback(String nama) {
    return Container(
      width: 52,
      height: 52,
      color: AppColors.tintGold,
      alignment: Alignment.center,
      child: Text(_initials(nama),
          style: const TextStyle(color: AppColors.warning, fontWeight: FontWeight.w800, fontSize: 14)),
    );
  }
}
