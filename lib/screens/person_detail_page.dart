import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../utils/mask.dart';
import '../widgets/login_required_view.dart';
import '../widgets/photo_preview.dart';
import '../widgets/siorg_header.dart';

/// Detail biodata orang (pelatih/wasit) — data dari endpoint terproteksi.
/// Jika belum login (401), tampilkan pesan "Mohon login untuk melihat detail profil".
class PersonDetailPage extends StatefulWidget {
  final int id;
  final String roleLabel; // "Pelatih" / "Wasit"
  final Future<Map<String, dynamic>> Function(int id) fetcher;

  const PersonDetailPage({
    super.key,
    required this.id,
    required this.roleLabel,
    required this.fetcher,
  });

  @override
  State<PersonDetailPage> createState() => _PersonDetailPageState();
}

class _PersonDetailPageState extends State<PersonDetailPage> {
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.fetcher(widget.id);
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  List<String> _caborList(Map<String, dynamic> d) {
    final raw = d['cabor'];
    if (raw is List) {
      return raw.map((e) => e.toString()).where((s) => s.trim().isNotEmpty).toList();
    }
    return const [];
  }

  Widget _caborChip(String c) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(99)),
        child: Text(c, style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w700)),
      );

  String _val(dynamic v) {
    final s = (v ?? '').toString().trim();
    return s.isEmpty || s == '0' ? '-' : s;
  }

  String _gender(dynamic g) {
    final s = (g ?? '').toString().toLowerCase();
    if (s.startsWith('l')) return 'Laki-laki';
    if (s.startsWith('p')) return 'Perempuan';
    return '-';
  }

  String _birth(Map<String, dynamic> d) {
    final tempat = (d['tempat_lahir'] ?? '').toString();
    final tgl = (d['tgl_lahir'] ?? '').toString();
    if (tgl.isEmpty) return tempat.isEmpty ? '-' : tempat;
    String t = tgl;
    try {
      final dt = DateTime.parse(tgl);
      const m = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'];
      t = '${dt.day} ${m[dt.month - 1]} ${dt.year}';
    } catch (_) {}
    return tempat.isEmpty ? t : '$tempat, $t';
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
            if (snapshot.error.toString().contains('Silakan login')) {
              return const LoginRequiredView();
            }
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('Gagal memuat detail', style: TextStyle(color: AppColors.danger)),
              ),
            );
          }
          return _detail(snapshot.data ?? const {});
        },
      ),
    );
  }

  Widget _detail(Map<String, dynamic> d) {
    final nama = _val(d['nama']);
    final foto = (d['foto_url'] ?? '').toString();

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
                  Text('Detail ${widget.roleLabel}',
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white)),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => showPhotoPreview(context, foto, initials: _initials(nama)),
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: foto.isNotEmpty
                              ? Image.network(foto, width: 64, height: 64, fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => _avatar(nama))
                              : _avatar(nama),
                        ),
                        if (foto.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.all(3),
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
                            child: const Icon(Icons.zoom_in, size: 12, color: Colors.white),
                          ),
                      ],
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
                        Text(widget.roleLabel,
                            style: const TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w600)),
                        if (_caborList(d).isNotEmpty) ...[
                          const SizedBox(height: 7),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: _caborList(d).map(_caborChip).toList(),
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
              _sectionTitle('Biodata'),
              const SizedBox(height: 10),
              _card([
                _row('NIK', Mask.id(d['nik']?.toString())),
                _row('No. KK', Mask.id(d['no_kk']?.toString())),
                _row('Jenis Kelamin', _gender(d['jenis_kelamin'])),
                _row('Tempat, Tgl Lahir', _birth(d)),
                _row('Status Pernikahan', _val(d['status_pernikahan'])),
                _row('Alamat Domisili', _val(d['alamat_domisili'])),
                _row('Nama Orang Tua', Mask.name(d['nama_orangtua']?.toString())),
                _row('No. Telp', Mask.phone(d['no_telp']?.toString())),
                _row('No. HP', Mask.phone(d['no_hp']?.toString())),
                _row('Tinggi Badan', d['tinggi_badan'] != null ? '${_val(d['tinggi_badan'])} cm' : '-'),
                _row('Berat Badan', d['berat_badan'] != null ? '${_val(d['berat_badan'])} kg' : '-'),
              ]),
            ],
          ),
        ),
      ],
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
