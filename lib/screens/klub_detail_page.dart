import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../theme/colors.dart';
import '../widgets/photo_preview.dart';
import '../widgets/siorg_header.dart';
import 'athlete_profile_page.dart';

/// Detail Klub Olahraga (publik, `GET /public/klub/:id`).
///
/// Menampilkan foto/logo, deskripsi, informasi (cabor, induk organisasi,
/// alamat, kontak), dan daftar atlet yang terdaftar di klub tersebut.
class KlubDetailPage extends StatefulWidget {
  final int klubId;

  const KlubDetailPage({super.key, required this.klubId});

  @override
  State<KlubDetailPage> createState() => _KlubDetailPageState();
}

class _KlubDetailPageState extends State<KlubDetailPage> {
  final ApiService _apiService = ApiService();
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = _apiService.fetchKlubDetail(widget.klubId);
  }

  String _val(dynamic v) {
    final s = (v ?? '').toString().trim();
    return (s.isEmpty || s == '-') ? '-' : s;
  }

  bool _has(dynamic v) => _val(v) != '-';

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  String _gender(dynamic g) {
    final s = (g ?? '').toString().toLowerCase();
    if (s.startsWith('l')) return 'Putra';
    if (s.startsWith('p')) return 'Putri';
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: FutureBuilder<Map<String, dynamic>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.navy));
          }
          if (snapshot.hasError) {
            return _errorView();
          }
          return _detail(snapshot.data ?? const {});
        },
      ),
    );
  }

  Widget _errorView() {
    return Column(
      children: [
        _headerBar(),
        const Expanded(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('Gagal memuat detail klub',
                  textAlign: TextAlign.center, style: TextStyle(color: AppColors.danger)),
            ),
          ),
        ),
      ],
    );
  }

  /// Header polos (dipakai saat error, sebelum data klub tersedia).
  Widget _headerBar() {
    return SiorgHeader(
      radius: 30,
      padding: const EdgeInsets.fromLTRB(18, 52, 18, 20),
      child: Row(
        children: [
          SiorgHeader.iconButton(Icons.chevron_left, () => Navigator.pop(context)),
          const SizedBox(width: 12),
          const Text('Detail Klub',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _detail(Map<String, dynamic> d) {
    final nama = _val(d['nama']) == '-' ? 'Klub' : _val(d['nama']);
    final foto = (d['foto_url'] ?? '').toString();
    final cabor = _val(d['cabor']);
    final deskripsi = _val(d['deskripsi']);
    final atlet = (d['atlet'] as List?) ?? const [];

    return Column(
      children: [
        SiorgHeader(
          radius: 30,
          padding: const EdgeInsets.fromLTRB(18, 52, 18, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SiorgHeader.iconButton(Icons.chevron_left, () => Navigator.pop(context)),
                  const SizedBox(width: 12),
                  const Text('Detail Klub',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white)),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => showPhotoPreview(context, foto, initials: _initials(nama)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: foto.isNotEmpty
                          ? Image.network(foto, width: 64, height: 64, fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => _avatar(nama))
                          : _avatar(nama),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(nama,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
                            maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        const Text('Klub Olahraga',
                            style: TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w600)),
                        if (cabor != '-') ...[
                          const SizedBox(height: 7),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(99)),
                            child: Text(cabor,
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.white, fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 28),
            children: [
              if (deskripsi != '-') ...[
                _sectionTitle('Tentang Klub'),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration:
                      BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(18)),
                  child: Text(deskripsi,
                      style: const TextStyle(fontSize: 12.5, height: 1.6, color: AppColors.secondary)),
                ),
                const SizedBox(height: 18),
              ],
              _sectionTitle('Informasi'),
              const SizedBox(height: 10),
              _card([
                _row('Cabang Olahraga', cabor),
                _row('Induk Organisasi', _val(d['induk_organisasi'])),
                _row('Alamat', _val(d['alamat'])),
                _row('Kontak', _val(d['kontak'])),
                _row('Jumlah Atlet', '${atlet.length}'),
              ]),
              const SizedBox(height: 18),
              _sectionTitle('Atlet Klub'),
              const SizedBox(height: 10),
              if (atlet.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration:
                      BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(18)),
                  child: const Text('Belum ada atlet terdaftar di klub ini.',
                      style: TextStyle(fontSize: 12.5, color: AppColors.muted)),
                )
              else
                ...atlet.map((raw) => _atletCard(Map<String, dynamic>.from(raw as Map))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _atletCard(Map<String, dynamic> a) {
    final nama = _val(a['nama']) == '-' ? 'Atlet' : _val(a['nama']);
    final gender = _gender(a['jenis_kelamin']);
    final status = _has(a['status_atlet']) ? _val(a['status_atlet']).toUpperCase() : '';
    final sub = [gender, status].where((s) => s.isNotEmpty).join(' · ');
    final id = int.tryParse((a['id'] ?? '').toString());

    return GestureDetector(
      onTap: id == null
          ? null
          : () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AthleteProfilePage(atlitId: id)),
              ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(18)),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(color: AppColors.tintNavy, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Text(_initials(nama),
                  style: const TextStyle(color: AppColors.navy, fontSize: 13, fontWeight: FontWeight.w800)),
            ),
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
                        style: const TextStyle(
                            fontSize: 11.5, color: AppColors.muted2, fontWeight: FontWeight.w500)),
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

  Widget _avatar(String nama) => Container(
        width: 64,
        height: 64,
        color: Colors.white24,
        alignment: Alignment.center,
        child: Text(_initials(nama),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
      );

  Widget _sectionTitle(String t) =>
      Text(t, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.ink));

  Widget _card(List<Widget> rows) {
    final children = <Widget>[];
    for (var i = 0; i < rows.length; i++) {
      children.add(rows[i]);
      if (i != rows.length - 1) children.add(const Divider(height: 1, color: AppColors.line));
    }
    return Container(
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(18)),
      child: Column(children: children),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label,
                style: const TextStyle(fontSize: 12.5, color: AppColors.muted, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontSize: 12.5, color: AppColors.ink, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
