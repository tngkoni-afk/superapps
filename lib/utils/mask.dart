/// Utilitas masking data sensitif untuk tampilan detail (privasi).
/// Aturan mudah disesuaikan bila perlu.
class Mask {
  Mask._();

  /// NIK / No. KK: tampilkan 4 digit terakhir, sisanya disamarkan.
  /// "3273010101990001" -> "************0001"
  static String id(String? value) {
    final s = (value ?? '').trim();
    if (s.isEmpty) return '-';
    if (s.length <= 4) return s;
    return '${'*' * (s.length - 4)}${s.substring(s.length - 4)}';
  }

  /// Nama orang tua: tiap kata jadi huruf awal + bintang.
  /// "Budi Santoso" -> "B*** S******"
  static String name(String? value) {
    final s = (value ?? '').trim();
    if (s.isEmpty) return '-';
    return s
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .map((w) => w.length == 1 ? w : '${w[0]}${'*' * (w.length - 1)}')
        .join(' ');
  }

  /// No. telepon: 3 digit terakhir disamarkan.
  /// "081234567890" -> "081234567***"
  static String phone(String? value) {
    final s = (value ?? '').trim();
    if (s.isEmpty) return '-';
    if (s.length <= 3) return '*' * s.length;
    return '${s.substring(0, s.length - 3)}***';
  }
}
