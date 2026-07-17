import 'package:flutter/material.dart';

import '../models/cabor_model.dart';
import '../theme/colors.dart';

/// Data seed SIORG (sumber: prototipe `new design/KONI v2.dc.html`).
///
/// Dipakai untuk layar yang belum punya endpoint API: detail cabor
/// (induk/pengurus/klub/statistik) dan sebagai fallback daftar cabor.
/// Saat backend menyediakan endpoint, ganti pemakaian ini di layar terkait.
class SiorgSeed {
  SiorgSeed._();

  /// Warna teks & latar badge status cabang/atlet/klub.
  static Color statusFg(String status) {
    switch (status.toLowerCase()) {
      case 'aktif':
        return AppColors.success;
      case 'pembinaan':
      case 'menunggu':
        return AppColors.warning;
      case 'cedera':
        return AppColors.danger;
      default:
        return AppColors.secondary;
    }
  }

  static Color statusBg(String status) {
    switch (status.toLowerCase()) {
      case 'aktif':
        return AppColors.tintGreen;
      case 'pembinaan':
      case 'menunggu':
        return AppColors.tintGold;
      case 'cedera':
        return AppColors.tintRed;
      default:
        return AppColors.tintGray;
    }
  }

  static IndukModel _induk(String abbr, String full, String kab, String prov) {
    final slug = abbr.toLowerCase();
    return IndukModel(
      full: full,
      kab: kab,
      prov: prov,
      phone: '021-5959-${1000 + abbr.length * 111}',
      email: 'sekretariat@$slug-tangerang.or.id',
      web: 'www.$slug-tangerang.or.id',
    );
  }

  static const _sejarah =
      'Cabang olahraga ini resmi terdaftar sebagai anggota KONI Kabupaten Tangerang '
      'dan terus berkembang melalui pembinaan berjenjang di tingkat klub hingga daerah.';
  static const _visi =
      'Menjadi cabang olahraga unggulan yang berprestasi di tingkat provinsi dan nasional '
      'melalui pembinaan atlet yang berkelanjutan dan tata kelola yang profesional.';
  static const _misi = [
    'Membina atlet usia dini secara berjenjang dan terukur.',
    'Meningkatkan kompetensi pelatih dan wasit bersertifikat.',
    'Memperkuat kerja sama dengan klub di seluruh kecamatan.',
  ];

  /// 10 cabang olahraga (SPORTS) lengkap dengan induk organisasi.
  static final List<CaborModel> cabors = [
    CaborModel(
      id: 'pssi', name: 'Sepak Bola', abbr: 'PSSI', year: 1979, status: 'Aktif',
      atlet: 248, klub: 18, pelatih: 32, wasit: 14, color: const Color(0xFF2E4374),
      induk: _induk('PSSI', 'Persatuan Sepak Bola Seluruh Indonesia', 'Askab PSSI Kabupaten Tangerang', 'Asprov PSSI Banten'),
      sejarah: _sejarah, visi: _visi, misi: _misi,
    ),
    CaborModel(
      id: 'pbsi', name: 'Bulu Tangkis', abbr: 'PBSI', year: 1981, status: 'Aktif',
      atlet: 196, klub: 22, pelatih: 28, wasit: 12, color: const Color(0xFF2BA35B),
      induk: _induk('PBSI', 'Persatuan Bulu Tangkis Seluruh Indonesia', 'Pengkab PBSI Kabupaten Tangerang', 'Pengprov PBSI Banten'),
      sejarah: _sejarah, visi: _visi, misi: _misi,
    ),
    CaborModel(
      id: 'pasi', name: 'Atletik', abbr: 'PASI', year: 1980, status: 'Aktif',
      atlet: 172, klub: 9, pelatih: 18, wasit: 8, color: const Color(0xFFC25A2E),
      induk: _induk('PASI', 'Persatuan Atletik Seluruh Indonesia', 'Pengkab PASI Kabupaten Tangerang', 'Pengprov PASI Banten'),
      sejarah: _sejarah, visi: _visi, misi: _misi,
    ),
    CaborModel(
      id: 'prsi', name: 'Renang', abbr: 'PRSI', year: 1985, status: 'Aktif',
      atlet: 154, klub: 11, pelatih: 16, wasit: 9, color: const Color(0xFF2E8BA6),
      induk: _induk('PRSI', 'Persatuan Renang Seluruh Indonesia', 'Pengkab PRSI Kabupaten Tangerang', 'Pengprov PRSI Banten'),
      sejarah: _sejarah, visi: _visi, misi: _misi,
    ),
    CaborModel(
      id: 'ipsi', name: 'Pencak Silat', abbr: 'IPSI', year: 1977, status: 'Aktif',
      atlet: 148, klub: 16, pelatih: 20, wasit: 11, color: const Color(0xFF7A4DA0),
      induk: _induk('IPSI', 'Ikatan Pencak Silat Indonesia', 'Pengkab IPSI Kabupaten Tangerang', 'Pengprov IPSI Banten'),
      sejarah: _sejarah, visi: _visi, misi: _misi,
    ),
    CaborModel(
      id: 'pbvsi', name: 'Bola Voli', abbr: 'PBVSI', year: 1982, status: 'Aktif',
      atlet: 132, klub: 14, pelatih: 15, wasit: 7, color: const Color(0xFFC98A1E),
      induk: _induk('PBVSI', 'Persatuan Bola Voli Seluruh Indonesia', 'Pengkab PBVSI Kabupaten Tangerang', 'Pengprov PBVSI Banten'),
      sejarah: _sejarah, visi: _visi, misi: _misi,
    ),
    CaborModel(
      id: 'forki', name: 'Karate', abbr: 'FORKI', year: 1984, status: 'Aktif',
      atlet: 118, klub: 13, pelatih: 14, wasit: 9, color: const Color(0xFF545B66),
      induk: _induk('FORKI', 'Federasi Olahraga Karate-Do Indonesia', 'Pengkab FORKI Kabupaten Tangerang', 'Pengprov FORKI Banten'),
      sejarah: _sejarah, visi: _visi, misi: _misi,
    ),
    CaborModel(
      id: 'ti', name: 'Taekwondo', abbr: 'TI', year: 1986, status: 'Aktif',
      atlet: 104, klub: 10, pelatih: 12, wasit: 6, color: const Color(0xFFB23A48),
      induk: _induk('TI', 'Taekwondo Indonesia', 'Pengkab TI Kabupaten Tangerang', 'Pengprov TI Banten'),
      sejarah: _sejarah, visi: _visi, misi: _misi,
    ),
    CaborModel(
      id: 'perbasi', name: 'Bola Basket', abbr: 'PRB', year: 1983, status: 'Aktif',
      atlet: 96, klub: 8, pelatih: 11, wasit: 6, color: const Color(0xFFD2691E),
      induk: _induk('PERBASI', 'Persatuan Bola Basket Seluruh Indonesia', 'Pengkab PERBASI Kabupaten Tangerang', 'Pengprov PERBASI Banten'),
      sejarah: _sejarah, visi: _visi, misi: _misi,
    ),
    CaborModel(
      id: 'percasi', name: 'Catur', abbr: 'PCS', year: 1988, status: 'Pembinaan',
      atlet: 62, klub: 6, pelatih: 5, wasit: 4, color: const Color(0xFF3A3A40),
      induk: _induk('PERCASI', 'Persatuan Catur Seluruh Indonesia', 'Pengkab PERCASI Kabupaten Tangerang', 'Pengprov PERCASI Banten'),
      sejarah: _sejarah, visi: _visi, misi: _misi,
    ),
  ];

  /// Pengurus (OFFICIALS) — di prototipe dipakai lintas cabang.
  static const List<PengurusModel> officials = [
    PengurusModel(name: 'H. Ahmad Subagja', role: 'Ketua Umum', period: '2025–2029', initials: 'AS', color: Color(0xFF2E4374), phone: '0812-1001-2025', email: 'ketua@koni-tangerang.or.id', since: 'Feb 2025', edu: 'S2 Manajemen Olahraga', bio: 'Memimpin organisasi dengan fokus pada pembinaan atlet usia dini, tata kelola transparan, dan penguatan kerja sama dengan klub di seluruh kecamatan.'),
    PengurusModel(name: 'Drs. Bambang Wijaya', role: 'Wakil Ketua', period: '2025–2029', initials: 'BW', color: Color(0xFF2E8BA6), phone: '0813-2002-1188', email: 'wakil@koni-tangerang.or.id', since: 'Feb 2025', edu: 'S1 Pendidikan Olahraga', bio: 'Mendampingi Ketua Umum dalam pengambilan kebijakan strategis dan koordinasi antar bidang organisasi.'),
    PengurusModel(name: 'Rina Marlina, S.E.', role: 'Sekretaris', period: '2025–2029', initials: 'RM', color: Color(0xFF2BA35B), phone: '0857-3003-7766', email: 'sekretaris@koni-tangerang.or.id', since: 'Feb 2025', edu: 'S1 Administrasi', bio: 'Mengelola administrasi, surat-menyurat, registrasi anggota, dan dokumentasi organisasi.'),
    PengurusModel(name: 'Hendra Gunawan', role: 'Bendahara', period: '2025–2029', initials: 'HG', color: Color(0xFFC98A1E), phone: '0812-4004-5512', email: 'bendahara@koni-tangerang.or.id', since: 'Feb 2025', edu: 'S1 Akuntansi', bio: 'Bertanggung jawab atas pengelolaan keuangan, anggaran kegiatan, dan pelaporan dana organisasi.'),
    PengurusModel(name: 'Yusuf Maulana', role: 'Bidang Pembinaan', period: '2025–2029', initials: 'YM', color: Color(0xFF7A4DA0), phone: '0856-5005-3321', email: 'pembinaan@koni-tangerang.or.id', since: 'Mar 2025', edu: 'S1 Kepelatihan', bio: 'Menyusun program pembinaan berjenjang, kurikulum latihan, dan sertifikasi pelatih.'),
    PengurusModel(name: 'Sri Wahyuni', role: 'Bidang Prestasi', period: '2025–2029', initials: 'SW', color: Color(0xFFD62828), phone: '0821-6006-9087', email: 'prestasi@koni-tangerang.or.id', since: 'Mar 2025', edu: 'S1 Ilmu Keolahragaan', bio: 'Mengkoordinir keikutsertaan atlet di kejuaraan, seleksi, serta pencatatan prestasi.'),
  ];

  /// Klub (CLUBS).
  static const List<KlubModel> clubs = [
    KlubModel(name: 'Persikat Junior', sport: 'Sepak Bola', head: 'Dadang Supriadi', atlet: 64, pelatih: 6, color: Color(0xFF2E4374), initials: 'PJ', year: 2009, status: 'Aktif', address: 'Jl. Raya Tigaraksa No. 12, Kab. Tangerang', phone: '0813-8800-1212', email: 'persikatjunior@mail.com', prestasi: [
      KlubPrestasi(title: 'Juara 1 Liga Remaja Kab. Tangerang', year: '2025', medal: 'Emas'),
      KlubPrestasi(title: 'Runner-up Piala Bupati U-17', year: '2024', medal: 'Perak'),
    ]),
    KlubModel(name: 'PB Garuda', sport: 'Bulu Tangkis', head: 'Hartono', atlet: 38, pelatih: 4, color: Color(0xFF2BA35B), initials: 'PG', year: 2012, status: 'Aktif', address: 'Jl. Citra Raya Boulevard, Cikupa', phone: '0812-7711-3344', email: 'pbgaruda@mail.com', prestasi: [
      KlubPrestasi(title: 'Juara 1 Sirkuit Nasional Junior', year: '2025', medal: 'Emas'),
      KlubPrestasi(title: 'Juara 3 Kejurprov Banten', year: '2024', medal: 'Perunggu'),
    ]),
    KlubModel(name: 'Tirta Tangerang', sport: 'Renang', head: 'Siska Amelia', atlet: 52, pelatih: 5, color: Color(0xFF2E8BA6), initials: 'TT', year: 2010, status: 'Aktif', address: 'Kolam Renang Kelapa Dua, Kab. Tangerang', phone: '0857-9090-1212', email: 'tirta.tng@mail.com', prestasi: [
      KlubPrestasi(title: 'Juara Umum O2SN Kab. Tangerang', year: '2025', medal: 'Emas'),
    ]),
    KlubModel(name: 'PS Bina Satria', sport: 'Pencak Silat', head: 'Gunawan', atlet: 45, pelatih: 4, color: Color(0xFF7A4DA0), initials: 'BS', year: 2008, status: 'Aktif', address: 'Padepokan Saga, Balaraja', phone: '0838-4545-7878', email: 'binasatria@mail.com', prestasi: [
      KlubPrestasi(title: 'Juara 1 PORPROV Banten', year: '2025', medal: 'Emas'),
      KlubPrestasi(title: 'Juara 2 Kejurnas Pelajar', year: '2023', medal: 'Perak'),
    ]),
    KlubModel(name: 'Lemkari Tangerang', sport: 'Karate', head: 'Fauzi Rahman', atlet: 30, pelatih: 3, color: Color(0xFF545B66), initials: 'LK', year: 2014, status: 'Aktif', address: 'GOR Curug, Kab. Tangerang', phone: '0812-3232-5656', email: 'lemkari.tng@mail.com', prestasi: [
      KlubPrestasi(title: 'Juara 3 Kejurprov Karate Banten', year: '2024', medal: 'Perunggu'),
    ]),
    KlubModel(name: 'Voli Mandiri', sport: 'Bola Voli', head: 'Endang Sulaeman', atlet: 41, pelatih: 3, color: Color(0xFFC98A1E), initials: 'VM', year: 2011, status: 'Aktif', address: 'Lapangan Kronjo, Kab. Tangerang', phone: '0856-1212-9090', email: 'volimandiri@mail.com', prestasi: [
      KlubPrestasi(title: 'Runner-up Liga Voli Kab. Tangerang', year: '2025', medal: 'Perak'),
    ]),
  ];

  /// Cari cabor seed berdasarkan id atau nama (untuk enrich data API).
  static CaborModel? byId(String id) {
    for (final c in cabors) {
      if (c.id == id) return c;
    }
    return null;
  }

  static CaborModel? byName(String name) {
    final n = name.trim().toLowerCase();
    for (final c in cabors) {
      if (c.name.toLowerCase() == n) return c;
    }
    return null;
  }

  /// Klub yang relevan dengan suatu cabor (match by sport name).
  static List<KlubModel> clubsOf(String sportName) {
    final list = clubs.where((c) => c.sport.toLowerCase() == sportName.toLowerCase()).toList();
    return list.isEmpty ? clubs.take(3).toList() : list;
  }
}
