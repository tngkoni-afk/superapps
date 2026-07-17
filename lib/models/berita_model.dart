import '../config/api_config.dart';

class BeritaModel {
  final int id;
  final String judul;
  final String? foto; 
  final String deskripsi;
  final String createdAt;

  BeritaModel({
    required this.id,
    required this.judul,
    this.foto,
    required this.deskripsi,
    required this.createdAt,
  });

  factory BeritaModel.fromJson(Map<String, dynamic> json) {
    String rawContent = json['deskripsi'] ?? json['content'] ?? json['konten'] ?? '';
    String? extractedImage = _extractImageFromHtml(rawContent);
    String? imagePath = json['featured_image_url'] ?? json['featured_image'] ?? json['gambar_url'] ?? json['foto'] ?? json['image'] ?? extractedImage;

    return BeritaModel(
      id: json['id'] ?? 0,
      judul: json['judul'] ?? json['title'] ?? 'Tanpa Judul',
      foto: _parseImageUrl(imagePath), 
      deskripsi: rawContent.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ''),
      createdAt: json['created_at'] ?? '',
    );
  }

  static String? _extractImageFromHtml(String html) {
    final regex = RegExp(r'<img[^>]+src="([^">]+)"');
    final match = regex.firstMatch(html);
    if (match != null && match.groupCount >= 1) {
      return match.group(1);
    }
    return null;
  }

  static String _parseImageUrl(String? path) {
    if (path == null || path.isEmpty) {
      return "https://images.unsplash.com/photo-1504450758481-7338eba7524a?q=80&w=800";
    }
    if (path.startsWith('http') || path.startsWith('data:image')) return path;
    
    // Hapus awalan '/' jika ada
    if (path.startsWith('/')) path = path.substring(1);
    
    // Jika path sudah mengandung awalan 'storage/', gabung langsung dengan domain root
    if (path.startsWith('storage/')) {
      return "https://${ApiConfig.serverIp}/$path";
    }

    return "${ApiConfig.storageUrl}/$path";
  }
}