import '../config/api_config.dart';

class AtlitModel {
  final int id;
  final String nama;
  final String cabor;
  final String? foto;
  final String? beratBadan;
  final String? tinggiBadan;
  final String? tglLahir;
  final String? tempatLahir;
  final String? golonganDarah;
  final String? pendidikan;
  final String? nik;
  final String? jenisKelamin;
  final String? statusAtlet; // TSG | PENGCAB | DEGRAD
  final String? alamat;
  final String? noTelp;
  final String? namaOrangTua;
  final List<dynamic>? prestasi; // Untuk menampung list medali
  final List<dynamic>? riwayatCabor; // Riwayat Cabor (Klub, Pelatih)

  AtlitModel({
    required this.id,
    required this.nama,
    required this.cabor,
    this.foto,
    this.beratBadan,
    this.tinggiBadan,
    this.tglLahir,
    this.tempatLahir,
    this.golonganDarah,
    this.pendidikan,
    this.nik,
    this.jenisKelamin,
    this.statusAtlet,
    this.alamat,
    this.noTelp,
    this.namaOrangTua,
    this.prestasi,
    this.riwayatCabor,
  });

  factory AtlitModel.fromJson(Map<String, dynamic> json) {
    String parsedCabor = json['nama_cabor'] ?? json['cabor'] ?? '-';
    if (parsedCabor == '-' && json['riwayat_cabor'] != null && (json['riwayat_cabor'] as List).isNotEmpty) {
      parsedCabor = json['riwayat_cabor'][0]['nama_cabor'] ?? '-';
    }

    return AtlitModel(
      id: json['id'] ?? 0,
      nama: json['nama'] ?? 'Tanpa Nama',
      cabor: parsedCabor, // Join dari tabel cabor
      foto: _parseImageUrl(json['foto_url'] ?? json['foto']),
      beratBadan: json['berat_badan']?.toString(),
      tinggiBadan: json['tinggi_badan']?.toString(),
      tglLahir: json['tgl_lahir'],
      tempatLahir: json['tempat_lahir'],
      golonganDarah: json['nama_golongan_darah'] ?? json['id_golongan_darah']?.toString(),
      pendidikan: json['nama_pendidikan'] ?? json['id_pendidikan']?.toString(),
      nik: json['nik'],
      jenisKelamin: json['jenis_kelamin'],
      statusAtlet: json['status_atlet']?.toString(),
      alamat: json['alamat_domisili'] ?? json['alamat'],
      noTelp: json['no_hp'] ?? json['no_telp'],
      namaOrangTua: json['nama_orangtua'] ?? json['nama_orang_tua'],
      prestasi: json['prestasi'], // Diambil dari getAtlitDetail
      riwayatCabor: json['riwayat_cabor'], // Diambil dari getAtlitDetail
    );
  }

  static String? _parseImageUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http') || path.startsWith('data:image')) return path;
    // Hapus awalan '/' jika ada agar tidak double slash
    if (path.startsWith('/')) path = path.substring(1);
    return "${ApiConfig.storageUrl}/$path";
  }
}