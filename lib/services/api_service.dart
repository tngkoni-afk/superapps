import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/berita_model.dart';
import '../models/agenda_model.dart';
import '../models/atlit_model.dart';

class ApiService {
  // Terpusat di lib/config/api_config.dart
  static const String baseUrl = ApiConfig.baseUrl;

  static const String _tokenKey = 'api_token';

  // Token auth disimpan terenkripsi (Android Keystore), bukan plaintext.
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // --- AUTENTIKASI ---
  Future<String?> getToken() async {
    final secureToken = await _secureStorage.read(key: _tokenKey);
    if (secureToken != null) return secureToken;

    // Migrasi token lama yang tersimpan plaintext di SharedPreferences ke
    // secure storage, lalu hapus jejaknya dari prefs.
    final prefs = await SharedPreferences.getInstance();
    final legacyToken = prefs.getString(_tokenKey);
    if (legacyToken != null) {
      await _secureStorage.write(key: _tokenKey, value: legacyToken);
      await prefs.remove(_tokenKey);
      return legacyToken;
    }
    return null;
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/login"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email, 'password': password}),
      );

      final decoded = jsonDecode(response.body);
      if (response.statusCode == 200 && decoded['status'] == 'success') {
        final token = decoded['data']['token'];
        await _secureStorage.write(key: _tokenKey, value: token);
        return {'success': true, 'message': 'Login berhasil'};
      } else {
        return {'success': false, 'message': decoded['message'] ?? 'Login gagal'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan koneksi'};
    }
  }

  Future<void> logout() async {
    final token = await getToken();
    if (token != null) {
      try {
        await http.post(
          Uri.parse("$baseUrl/auth/logout"),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      } catch (_) {}
    }
    await _secureStorage.delete(key: _tokenKey);
    // Bersihkan juga token lama bila masih tersisa di SharedPreferences.
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  /// Profil user yang sedang login (GET /auth/me).
  /// Mengembalikan map {id, name, email, avatar, role} atau null bila belum
  /// login / token tidak valid (401).
  Future<Map<String, dynamic>?> getProfile() async {
    final token = await getToken();
    if (token == null) return null;
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/auth/me"),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 25));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final data = decoded['data'];
        if (data is Map<String, dynamic>) return data;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // Ambil pesan error pertama dari respons Laravel (422 {errors:{field:[..]}}).
  String? _firstError(dynamic decoded) {
    if (decoded is Map) {
      final errors = decoded['errors'];
      if (errors is Map) {
        for (final v in errors.values) {
          if (v is List && v.isNotEmpty) return v.first.toString();
        }
      }
      if (decoded['message'] != null) return decoded['message'].toString();
    }
    return null;
  }

  Future<Map<String, dynamic>> updateProfile({required String name, required String email}) async {
    final token = await getToken();
    if (token == null) return {'success': false, 'message': 'Sesi berakhir, silakan login ulang'};
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/auth/profile"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'name': name, 'email': email}),
      ).timeout(const Duration(seconds: 25));

      final decoded = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'message': decoded['message'] ?? 'Profil diperbarui', 'data': decoded['data']};
      }
      return {'success': false, 'message': _firstError(decoded) ?? 'Gagal memperbarui profil'};
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan koneksi'};
    }
  }

  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final token = await getToken();
    if (token == null) return {'success': false, 'message': 'Sesi berakhir, silakan login ulang'};
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/change-password"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'current_password': currentPassword,
          'new_password': newPassword,
          'new_password_confirmation': newPassword,
        }),
      ).timeout(const Duration(seconds: 25));

      final decoded = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'message': decoded['message'] ?? 'Password berhasil diubah'};
      }
      return {'success': false, 'message': _firstError(decoded) ?? 'Gagal mengubah password'};
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan koneksi'};
    }
  }

  // Ambil seluruh halaman dari endpoint Laravel-paginate (data.data[]).
  Future<List<Map<String, dynamic>>> _fetchAllPaginated(String path, {Map<String, String>? params}) async {
    final result = <Map<String, dynamic>>[];
    try {
      var page = 1;
      while (true) {
        final uri = Uri.parse("$baseUrl$path").replace(
          queryParameters: {'page': '$page', ...?params},
        );
        final response = await http
            .get(uri, headers: {'Accept': 'application/json'})
            .timeout(const Duration(seconds: 25));
        if (response.statusCode != 200) break;

        final data = jsonDecode(response.body)['data'];
        final list = (data is Map) ? data['data'] : null;
        if (list is List) {
          result.addAll(list.map((e) => Map<String, dynamic>.from(e as Map)));
        }
        final current = (data is Map ? data['current_page'] : page) ?? page;
        final last = (data is Map ? data['last_page'] : page) ?? page;
        if (current >= last || page >= 50) break; // safety cap
        page++;
      }
    } catch (e) {
      debugPrint("fetch $path error: $e");
    }
    return result;
  }

  Future<List<Map<String, dynamic>>> fetchKlub() => _fetchAllPaginated('/public/klub');

  /// Detail klub (publik): baris klub + induk_organisasi, cabor, total_atlet,
  /// dan daftar atlet klub. Melempar Exception bila gagal.
  Future<Map<String, dynamic>> fetchKlubDetail(int id) async {
    final response = await http.get(
      Uri.parse("$baseUrl/public/klub/$id"),
      headers: {'Accept': 'application/json'},
    ).timeout(const Duration(seconds: 25));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      if (data is Map<String, dynamic>) return data;
    }
    throw Exception('Gagal memuat detail klub');
  }
  Future<List<Map<String, dynamic>>> fetchPelatih({String? caborId}) =>
      _fetchAllPaginated('/public/pelatih', params: caborId != null ? {'cabor_id': caborId} : null);
  Future<List<Map<String, dynamic>>> fetchWasit({String? caborId}) =>
      _fetchAllPaginated('/public/wasit', params: caborId != null ? {'cabor_id': caborId} : null);

  // Ambil SATU halaman dari endpoint paginate (untuk infinite scroll).
  Future<List<Map<String, dynamic>>> _fetchPage(String path, {int page = 1, Map<String, String>? params}) async {
    try {
      final uri = Uri.parse("$baseUrl$path").replace(
        queryParameters: {'page': '$page', ...?params},
      );
      final response = await http
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 25));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        final list = (data is Map) ? data['data'] : null;
        if (list is List) {
          return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        }
      }
    } catch (e) {
      debugPrint("fetchPage $path error: $e");
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> fetchPelatihPage({int page = 1, String query = '', String? caborId}) =>
      _fetchPage('/public/pelatih', page: page, params: {
        if (query.isNotEmpty) 'q': query,
        'cabor_id': ?caborId,
      });

  Future<List<Map<String, dynamic>>> fetchKlubPage({int page = 1, String query = ''}) =>
      _fetchPage('/public/klub', page: page, params: {if (query.isNotEmpty) 'q': query});

  Future<List<Map<String, dynamic>>> fetchWasitPage({int page = 1, String query = '', String? caborId}) =>
      _fetchPage('/public/wasit', page: page, params: {
        if (query.isNotEmpty) 'q': query,
        'cabor_id': ?caborId,
      });

  // Detail biodata pelatih/wasit — endpoint terproteksi. Melempar
  // Exception('Silakan login') saat 401 agar UI menampilkan LoginRequiredView.
  Future<Map<String, dynamic>> _fetchPersonDetail(String path) async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse("$baseUrl$path"),
      headers: {
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 25));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      return data is Map<String, dynamic> ? data : <String, dynamic>{};
    } else if (response.statusCode == 401) {
      throw Exception('Silakan login');
    }
    throw Exception('Gagal memuat detail');
  }

  Future<Map<String, dynamic>> fetchPelatihDetail(int id) => _fetchPersonDetail('/pelatih/$id');
  Future<Map<String, dynamic>> fetchWasitDetail(int id) => _fetchPersonDetail('/wasit/$id');

  // --- STATISTIK RINGKASAN DASHBOARD ---
  Future<Map<String, int>> fetchStatistik() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/public/statistik"),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 25));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final data = decoded['data'];
        if (data is Map<String, dynamic>) {
          return data.map((k, v) =>
              MapEntry(k, v is int ? v : int.tryParse(v.toString()) ?? 0));
        }
      }
    } catch (e) {
      debugPrint("fetchStatistik error: $e");
    }
    return {};
  }

  // --- FUNGSI AMBIL BERITA ---
  Future<List<BeritaModel>> fetchBerita() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/public/berita"),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 25));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        // Laravel paginate() membungkus data di data['data']
        final List<dynamic> listBerita = responseData['data']['data'];

        return listBerita.map((json) => BeritaModel.fromJson(json)).toList();
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("fetchBerita error: $e");
      throw Exception("Koneksi gagal");
    }
  }

  // --- FUNGSI AMBIL AGENDA ---
  Future<List<AgendaModel>> fetchAgenda({bool upcoming = false, String? query}) async {
  try {
    final queryParams = <String, String>{};
    if (upcoming) {
      queryParams['status'] = 'upcoming';
    } else if (query != null && query.isNotEmpty) {
      queryParams['q'] = query;
    }
    final uri = Uri.parse("$baseUrl/public/agenda").replace(
      queryParameters: queryParams.isEmpty ? null : queryParams,
    );

    final response = await http.get(
      uri,
      headers: {'Accept': 'application/json'},
    ).timeout(const Duration(seconds: 25));

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      
      // Laravel Paginate biasanya menaruh list data di dalam key 'data'
      // Log kamu: {current_page: 1, data: [...]}
      final dynamic agendaData = decoded['data'];

      if (agendaData is List) {
        return agendaData.map((json) => AgendaModel.fromJson(json)).toList();
      } else if (agendaData is Map && agendaData.containsKey('data')) {
        // Jika ternyata 'data' di dalam 'data' (nested paginate)
        final List<dynamic> list = agendaData['data'];
        return list.map((json) => AgendaModel.fromJson(json)).toList();
      }
      return [];
    } else {
      throw Exception("Gagal muat agenda");
    }
  } catch (e) {
    debugPrint("Error Detail: $e");
    throw Exception("Koneksi bermasalah");
  }
}

  // --- FUNGSI AMBIL ATLET ---
  Future<List<AtlitModel>> fetchAtlit({String query = "", String? caborId, int page = 1}) async {
    final token = await getToken();

    final queryParams = <String, String>{
      'q': query,
      'page': '$page',
      if (caborId != null && caborId.isNotEmpty) 'cabor_id': caborId,
    };
    final uri = Uri.parse("$baseUrl/public/atlit").replace(
      queryParameters: queryParams,
    );

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 25));

    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = jsonDecode(response.body);
      final List<dynamic> listData = decoded['data']['data'];
      return listData.map((json) => AtlitModel.fromJson(json)).toList();
    } else {
      throw Exception("Gagal mengambil data atlet");
    }
  }

  Future<AtlitModel> fetchAtlitDetail(int id) async {
    try {
      final token = await getToken();
      // Gunakan baseUrl yang sudah didefinisikan di dalam class ApiService
      final response = await http.get(
        Uri.parse("$baseUrl/atlit/$id"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 25)); 
      
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        // Laravel mengembalikan data di dalam key 'data'
        return AtlitModel.fromJson(decoded['data']); 
      } else if (response.statusCode == 401) {
        throw Exception("Silakan login untuk melihat detail atlet.");
      } else {
        throw Exception("Gagal mengambil detail atlit");
      }
    } catch (e) {
      debugPrint("fetchAtlitDetail error: $e");
      throw Exception("Terjadi kesalahan koneksi");
    }
  }
  
  // --- FETCH CABOR (PUBLIC) ---
  // Seluruh cabor + hitungan real (total_atlet, total_klub) dari semua halaman.
  Future<List<Map<String, dynamic>>> fetchCabor() => _fetchAllPaginated('/public/cabor');

  // Detail cabor (publik): {id, nama, statistik{atlet,klub,pelatih,wasit},
  // induk{...}, klub[...]}. Mengembalikan null bila gagal/404.
  Future<Map<String, dynamic>?> fetchCaborDetail(int id) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/public/cabor/$id"),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 25));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        if (data is Map<String, dynamic>) return data;
      }
    } catch (e) {
      debugPrint("fetchCaborDetail error: $e");
    }
    return null;
  }
}
