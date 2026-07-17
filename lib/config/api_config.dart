import 'package:flutter/foundation.dart';

class ApiConfig {
  // ===================== TOGGLE LINGKUNGAN =====================
  // true  = MAMP lokal (uji di HP; HP & laptop harus 1 Wi-Fi)
  // false = produksi
  //
  // Setel ke true HANYA saat butuh uji lokal. Nilainya di-AND dengan
  // kDebugMode sehingga build rilis TIDAK PERNAH memakai endpoint HTTP lokal,
  // walau lupa dikembalikan ke false.
  static const bool _useLocalRequested = false;
  static const bool useLocal = kDebugMode && _useLocalRequested;

  // --- Produksi (HTTPS, di root domain) ---
  static const String _prodRoot = "https://konigemilang.tangerangkab.go.id";
  static const String _prodHost = "konigemilang.tangerangkab.go.id";

  // --- Lokal MAMP ---
  // IP LAN laptop dari `ipconfig` (Wi-Fi). Project dilayani di /koni/public.
  // Ganti IP ini bila jaringan/laptop berubah.
  // Lewat `adb reverse tcp:8080 tcp:80`: HP mengakses MAMP laptop via localhost
  // over USB — bebas dari perubahan IP Wi-Fi/DHCP. Jalankan sekali tiap HP
  // tersambung ulang: adb reverse tcp:8080 tcp:80
  static const String _localRoot = "http://localhost:8080/koni/public";
  static const String _localHost = "localhost:8080/koni/public";

  // --- Aktif ---
  static const String root = useLocal ? _localRoot : _prodRoot;

  // Base URL untuk REST API
  static const String baseUrl = "$root/api/v1";

  // Base URL untuk Storage/Files/Gambar
  static const String storageUrl = "$root/storage";

  // Host untuk fallback URL gambar (dipakai berita_model).
  static const String serverIp = useLocal ? _localHost : _prodHost;
}
