import 'dart:async';
import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../theme/colors.dart';
import '../widgets/siorg_header.dart';
import 'klub_detail_page.dart';

/// Daftar Klub Olahraga. Daftar utama: infinite scroll + search server-side
/// (mekanisme sama dengan Atlet). Mode per-cabor: klub diambil dari detail cabor.
class KlubListPage extends StatefulWidget {
  final String? caborId;
  final String? caborName;
  const KlubListPage({super.key, this.caborId, this.caborName});

  @override
  State<KlubListPage> createState() => _KlubListPageState();
}

class _KlubListPageState extends State<KlubListPage> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scroll = ScrollController();
  Timer? _debounce;

  static const int _pageSize = 15;
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  int _page = 1;
  String _query = '';

  bool get _isCaborMode => widget.caborId != null;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
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
    setState(() {
      _loading = true;
      _query = query;
    });
    if (_isCaborMode) {
      // Klub milik cabor → dari endpoint detail (list kecil, tanpa paginasi).
      final id = int.tryParse(widget.caborId!);
      final detail = id == null ? null : await _apiService.fetchCaborDetail(id);
      final list = (detail?['klub'] as List?) ?? const [];
      if (!mounted) return;
      setState(() {
        _items = list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        _hasMore = false;
        _loading = false;
      });
    } else {
      final data = await _apiService.fetchKlubPage(page: 1, query: query);
      if (!mounted) return;
      setState(() {
        _items = data;
        _page = 1;
        _hasMore = data.length >= _pageSize;
        _loading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_isCaborMode || _loadingMore || !_hasMore || _loading) return;
    setState(() => _loadingMore = true);
    final next = _page + 1;
    final data = await _apiService.fetchKlubPage(page: next, query: _query);
    if (!mounted) return;
    setState(() {
      _items.addAll(data);
      _page = next;
      _hasMore = data.length >= _pageSize;
      _loadingMore = false;
    });
  }

  void _onSearch(String q) {
    // Mode per-cabor: filter client-side (list sudah termuat penuh).
    if (_isCaborMode) {
      setState(() => _query = q);
      return;
    }
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () => _fetch(query: q));
  }

  List<Map<String, dynamic>> get _display {
    if (_isCaborMode && _query.isNotEmpty) {
      final ql = _query.toLowerCase();
      return _items.where((e) => (e['nama'] ?? '').toString().toLowerCase().contains(ql)).toList();
    }
    return _items;
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
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
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.navy));
    }
    final list = _display;
    if (list.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('Klub tidak ditemukan', style: TextStyle(color: AppColors.muted)),
        ),
      );
    }
    return ListView.builder(
      controller: _scroll,
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
      itemCount: list.length + 1,
      itemBuilder: (_, i) {
        if (i >= list.length) return _listFooter();
        return _klubCard(list[i]);
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
    if (!_hasMore && !_isCaborMode) {
      return const Padding(
        padding: EdgeInsets.only(top: 6, bottom: 18),
        child: Center(
          child: Text('— semua klub telah dimuat —',
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
                    Text(widget.caborName != null ? 'Klub ${widget.caborName}' : 'Klub Olahraga',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(widget.caborName != null ? 'Klub cabang ini' : 'Klub terdaftar KONI Kab. Tangerang',
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
                      hintText: 'Cari nama klub...',
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

  Widget _klubCard(Map<String, dynamic> k) {
    final nama = (k['nama'] ?? '-').toString();
    final foto = (k['foto_url'] ?? '').toString();
    final deskripsi = (k['deskripsi'] ?? '').toString();
    final id = int.tryParse((k['id'] ?? '').toString());

    return GestureDetector(
      onTap: id == null
          ? null
          : () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => KlubDetailPage(klubId: id)),
              ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(18)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: foto.isNotEmpty
                  ? Image.network(foto, width: 52, height: 52, fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _logoFallback(nama))
                  : _logoFallback(nama),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nama,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.ink),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  if (deskripsi.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(deskripsi,
                        style: const TextStyle(fontSize: 11.5, color: AppColors.muted2, height: 1.35),
                        maxLines: 2, overflow: TextOverflow.ellipsis),
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

  Widget _logoFallback(String nama) {
    return Container(
      width: 52,
      height: 52,
      color: AppColors.tintGreen,
      alignment: Alignment.center,
      child: Text(_initials(nama),
          style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w800, fontSize: 14)),
    );
  }
}
