class AgendaModel {
  final int id;
  final String namaAgenda;
  final String lokasi;
  final String tanggalMulai;
  final String tanggalSelesai;
  final String keterangan;
  final String? imageUrl;
  final String? status;
  final String? penyelenggara;
  final bool isFeatured;
  final int? capacity;
  final String? contactInfo;
  final String? registrationDeadline;
  final int viewCount;
  final double? latitude;
  final double? longitude;

  AgendaModel({
    required this.id,
    required this.namaAgenda,
    required this.lokasi,
    required this.tanggalMulai,
    required this.tanggalSelesai,
    required this.keterangan,
    this.imageUrl,
    this.status,
    this.penyelenggara,
    this.isFeatured = false,
    this.capacity,
    this.contactInfo,
    this.registrationDeadline,
    this.viewCount = 0,
    this.latitude,
    this.longitude,
  });

  /// Koordinat valid untuk dipetakan (kolom bisa null / string dari API).
  bool get hasCoordinates => latitude != null && longitude != null;

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  factory AgendaModel.fromJson(Map<String, dynamic> json) {
    return AgendaModel(
      id: json['id'] ?? 0,
      namaAgenda: json['judul'] ?? 'Tanpa Judul', 
      lokasi: json['lokasi'] ?? 'Lokasi tidak tersedia',
      tanggalMulai: json['tanggal_mulai'] ?? '-',
      tanggalSelesai: json['tanggal_selesai'] ?? '-',
      keterangan: (json['deskripsi'] ?? 'Tidak ada keterangan')
          .replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ''), 
      imageUrl: json['image_url'] ?? json['image'],
      status: json['status'],
      penyelenggara: json['penyelenggara'],
      isFeatured: json['featured'] == true || json['featured'] == 1,
      capacity: json['capacity'] != null ? int.tryParse(json['capacity'].toString()) : null,
      contactInfo: json['contact_info'],
      registrationDeadline: json['registration_deadline'],
      viewCount: json['view_count'] != null ? int.tryParse(json['view_count'].toString()) ?? 0 : 0,
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
    );
  }
}