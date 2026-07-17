import 'package:flutter/material.dart';

/// Models untuk fitur Organisasi/Cabor (SIORG).
///
/// Daftar cabor punya endpoint publik (`ApiService.fetchCabor`) yang hanya
/// mengembalikan `{id, nama}`. Field kaya (abbr/warna/jumlah/induk/pengurus/
/// klub) belum tersedia di backend, sehingga diisi dari data seed
/// (`lib/data/siorg_seed.dart`) sesuai handoff SIORG. Saat endpoint detail
/// tersedia, tambahkan `fromJson` dan ganti sumber data di layar terkait.

class IndukModel {
  final String full; // nama lengkap induk nasional
  final String kab; // pengurus kabupaten
  final String prov; // pengurus provinsi
  final String tingkat;
  final String sekretariat;
  final String phone;
  final String email;
  final String web;

  const IndukModel({
    required this.full,
    required this.kab,
    required this.prov,
    this.tingkat = 'Kabupaten/Kota',
    this.sekretariat = 'Gedung KONI, Jl. Abdul Hamid, Tigaraksa',
    required this.phone,
    required this.email,
    required this.web,
  });
}

class PengurusModel {
  final String name;
  final String role;
  final String period;
  final String initials;
  final Color color;
  final String phone;
  final String email;
  final String since;
  final String edu;
  final String bio;

  const PengurusModel({
    required this.name,
    required this.role,
    required this.period,
    required this.initials,
    required this.color,
    required this.phone,
    required this.email,
    required this.since,
    required this.edu,
    required this.bio,
  });
}

class KlubPrestasi {
  final String title;
  final String year;
  final String medal;

  const KlubPrestasi({required this.title, required this.year, required this.medal});
}

class KlubModel {
  final String name;
  final String sport;
  final String head;
  final String status;
  final String address;
  final String phone;
  final String email;
  final String initials;
  final int year;
  final int atlet;
  final int pelatih;
  final Color color;
  final List<KlubPrestasi> prestasi;

  const KlubModel({
    required this.name,
    required this.sport,
    required this.head,
    required this.status,
    required this.address,
    required this.phone,
    required this.email,
    required this.initials,
    required this.year,
    required this.atlet,
    required this.pelatih,
    required this.color,
    this.prestasi = const [],
  });
}

class CaborModel {
  final String id;
  final String name;
  final String abbr;
  final String status; // Aktif | Pembinaan
  final int year;
  final int atlet;
  final int klub;
  final int pelatih;
  final int wasit;
  final Color color;
  final IndukModel induk;
  final String sejarah;
  final String visi;
  final List<String> misi;
  final String? logo; // URL logo induk organisasi (dari API list/detail)

  const CaborModel({
    required this.id,
    required this.name,
    required this.abbr,
    required this.status,
    required this.year,
    required this.atlet,
    required this.klub,
    required this.pelatih,
    required this.wasit,
    required this.color,
    required this.induk,
    this.sejarah = '',
    this.visi = '',
    this.misi = const [],
    this.logo,
  });

  bool get isAktif => status.toLowerCase() == 'aktif';

  /// Palet warna deterministik untuk kartu cabor (tanpa kolom warna di DB).
  static const _palette = [
    Color(0xFF2E4374), Color(0xFF2BA35B), Color(0xFFC25A2E), Color(0xFF2E8BA6),
    Color(0xFF7A4DA0), Color(0xFFC98A1E), Color(0xFF545B66), Color(0xFFB23A48),
  ];

  static Color colorFor(String seed) => _palette[seed.hashCode.abs() % _palette.length];

  /// Singkatan dari nama (mis. "Bola Voli" -> "BV", "Catur" -> "CAT").
  static String abbrFromName(String name) {
    final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '?';
    if (words.length == 1) {
      final w = words.first;
      return w.substring(0, w.length >= 3 ? 3 : w.length).toUpperCase();
    }
    return words.map((w) => w[0]).take(3).join().toUpperCase();
  }

  static int _toInt(dynamic v) => v is int ? v : int.tryParse('${v ?? 0}') ?? 0;

  /// Dari item daftar API `/public/cabor` (id, nama, total_atlet, total_klub).
  /// Field kaya (induk/sejarah/visi/misi) diisi saat membuka detail.
  factory CaborModel.fromList(Map<String, dynamic> j) {
    final nama = (j['nama'] ?? 'Cabor').toString();
    final id = (j['id'] ?? nama).toString();
    return CaborModel(
      id: id,
      name: nama,
      abbr: abbrFromName(nama),
      status: 'Aktif',
      year: 0,
      atlet: _toInt(j['total_atlet']),
      klub: _toInt(j['total_klub']),
      pelatih: _toInt(j['total_pelatih']),
      wasit: _toInt(j['total_wasit']),
      color: colorFor(id),
      induk: const IndukModel(full: '-', kab: '-', prov: '-', phone: '-', email: '-', web: '-'),
      logo: (j['logo'] ?? '').toString().isEmpty ? null : j['logo'].toString(),
    );
  }
}
