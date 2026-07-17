# SIORG — Handoff ke Flutter

Panduan implementasi aplikasi **SIORG (Sistem Informasi Organisasi Olahraga)** — KONI Kabupaten Tangerang — dari prototipe `SIORG v2.dc.html` (gaya "Material You / Soft", navy + abu + aksen merah KONI).

Gunakan `SIORG v2.dc.html` sebagai **referensi visual** (buka di browser / ekspor standalone). Dokumen ini memetakan token, layar, navigasi, data, dan komponen ke Flutter.

---

## 1. Design Tokens

### Warna (`lib/theme/colors.dart`)
```dart
import 'package:flutter/material.dart';

class AppColors {
  // Brand
  static const ink        = Color(0xFF1C2A45); // teks utama / navy gelap
  static const navy       = Color(0xFF2E4374); // aksen navy
  static const red        = Color(0xFFD62828); // aksen merah KONI (hemat)
  static const gold       = Color(0xFFF4A261); // aksen emas (loader splash)

  // Teks sekunder
  static const secondary  = Color(0xFF5B6B8C);
  static const muted      = Color(0xFF8A93A2);
  static const muted2     = Color(0xFF9AA3B2);
  static const faint      = Color(0xFFB6BCC7);

  // Permukaan
  static const bg         = Color(0xFFF3F5F9); // background layar
  static const surface    = Color(0xFFFFFFFF); // kartu
  static const line       = Color(0xFFF3F5F8); // garis pemisah
  static const line2      = Color(0xFFEEF1F5); // track progress bar

  // Tint lembut (latar kartu tonal & badge)
  static const tintNavy   = Color(0xFFE4ECF9);
  static const tintRed    = Color(0xFFFBECEC);
  static const tintGreen  = Color(0xFFE4F4EB);
  static const tintGold   = Color(0xFFFBF1E2);
  static const tintPurple = Color(0xFFF0EBF7);
  static const tintGray   = Color(0xFFEDF0F4);

  // Status
  static const success    = Color(0xFF2BA35B); // Aktif
  static const warning    = Color(0xFFC98A1E); // Pembinaan / Menunggu
  static const danger     = Color(0xFFD62828); // Cedera

  // Bottom nav
  static const navBar      = Color(0xFF1C2A45);
  static const navInactive = Color(0xFF8893AD);
}
```

### Tipografi
- Font family: **Plus Jakarta Sans** (tambahkan paket `google_fonts` atau bundel font; weight 400/500/600/700/800).
- Skala kira-kira:
  | Token | Size | Weight | Pemakaian |
  |---|---|---|---|
  | display | 38–44 | 800 | angka KPI besar, statistik |
  | h1 | 21–25 | 800 | judul layar |
  | h2 | 14.5–18 | 800 | judul section / nama |
  | body | 12.5–13.5 | 500–700 | isi |
  | caption | 10.5–11.5 | 500–600 | meta / label |
  | overline | 11 | 700 | label section (UPPERCASE, letter-spacing .08em) |

### Bentuk & jarak
- Radius kartu: **20–22**; header sheet (lengkung bawah): **30–32**; tile/ikon: **12–18**; pill/badge/chip: **999**.
- Padding layar: **18–22** horizontal. Gap antar kartu: **10–14**.
- Bottom nav: floating, `margin: 14`, `height: 66`, `radius: 24`, warna `navBar`, shadow lembut.
- Avatar: lingkaran; inisial 2 huruf di atas warna cabang/role.

---

## 2. Inventaris Layar & Rute

| Rute | Layar | Catatan |
|---|---|---|
| `/splash` | Splash | Foto full-bleed + kartu logo + tagline "Semangat Juara KONI Kabupaten Tangerang"; auto ke login ±2.5s |
| `/login` | Login | Email/NIK, password, lupa password, Google |
| `/dashboard` | Beranda | KPI tonal, menu cepat, berita, agenda terdekat |
| `/organisasi` | Daftar Cabor | search + kartu cabang (atlet/klub/pelatih/wasit) |
| `/cabor/:id` | Detail Cabang | Tab: **Induk Organisasi · Pengurus · Klub · Statistik** |
| `/cabor/:id/pengurus/:i` | Profil Pengurus | jabatan, kontak, pendidikan, bio, riwayat |
| `/cabor/:id/klub/:i` | Detail Klub | statistik, profil, prestasi, atlet |
| `/atlet` | Daftar Atlet | search + filter (Semua/Putra/Putri/Aktif/Cedera) |
| `/atlet/:id` | Detail Atlet | Tab: **Biodata · Prestasi · Sertifikasi · Pertandingan · Dokumen** |
| `/agenda` | Agenda | View: **Kalender · Timeline · List**; kalender & item clickable |
| `/agenda/:i` | Detail Kegiatan | tanggal/waktu/lokasi, deskripsi, rundown, penanggung jawab |
| `/analytics` | Statistik & Analitik | 4 KPI + chart (bar/donut/bar/line) semua clickable |
| `/analytics/:metric` | Detail Statistik | breakdown; baris bisa diklik ke `/cabor/:id` |
| `/profil` | Profil Saya | akun, aplikasi, logout |

### Bottom Navigation (5 tab)
`Beranda` · `Cabor` (Organisasi) · `Atlet` · `Agenda` · `Profil`.
Detail screen di-*push* di atas tab induknya (Cabor detail & turunannya tetap menyorot tab **Cabor**; agenda detail → **Agenda**).

Saran paket navigasi: **go_router** dengan `StatefulShellRoute` untuk bottom nav + nested push.

---

## 3. Model Data (`lib/models/`)

```dart
class Sport {            // Cabang olahraga (cabor)
  final String id, name, abbr, status;      // status: Aktif | Pembinaan
  final int year, atlet, klub, pelatih, wasit;
  final Color color;
  final Induk induk;                         // induk organisasi
}

class Induk {
  final String full, kab, prov, tingkat, sekretariat, phone, email, web;
}

class Official {         // Pengurus
  final String name, role, period, initials, phone, email, since, edu, bio;
  final Color color;
  final List<RiwayatJabatan> riwayat;
}

class Club {             // Klub
  final String name, sport, head, status, address, phone, email, initials;
  final int year, atlet, pelatih;
  final List<Prestasi> prestasi;
  final List<MiniAthlete> atletNames;
}

class Athlete {          // Atlet
  final String id, name, initials, sport, club, cat, gender, kec, status;
  final String nik, birth, age, addr, phone, email, height, weight, blood, coach;
  final Color sportColor;
  final List<Achievement> ach;
  final List<Certificate> certs;
  final List<MatchResult> matches;
  final List<DocItem> docs;
}

class AgendaItem {       // Kegiatan
  final String day, mon, type, title, fullDate, time, location, address;
  final String organizer, cabor, participants, status, desc;
  final Color fg; final Color tint;
  final Pic pic;
  final List<Rundown> rundown;
}

enum Role { superAdmin, pengurusKoni, pengurusCabor, pengurusKlub, atlet, pelatih, wasit }
```
Data contoh lengkap (10 cabor, 8 atlet, 6 klub, 6 pengurus, 5 agenda) ada di blok `class Component` dalam `SIORG v2.dc.html` — salin nilainya ke file seed Dart.

---

## 4. Pemetaan Komponen → Widget Flutter

| Elemen prototipe | Widget Flutter |
|---|---|
| Layar + status bar iPhone | `Scaffold` (frame device hanya untuk preview, tidak diporting) |
| Header tonal lengkung bawah | `Container(decoration: BoxDecoration(color: tintNavy, borderRadius: vertical(bottom: 30)))` |
| Kartu putih | `Card` / `Container` radius 20–22, `boxShadow` lembut |
| KPI tonal | `Container` tint + angka `display` + label |
| Badge status | `Container` pill: warna teks = status, bg = tint status |
| Chip filter | `ChoiceChip` / custom pill (`ink` saat aktif) |
| Tab (pill) | `TabBar` custom indicator pill, atau `SegmentedButton` |
| Bottom nav melayang | `NavigationBar` dibungkus `Container` margin+radius, atau custom `Row` |
| Progress/bar chart | `LinearProgressIndicator` atau `FractionallySizedBox` track + fill |
| Donut chart | `fl_chart` `PieChart` (atau `CustomPaint`) |
| Line chart | `fl_chart` `LineChart` |
| List item + chevron → detail | `ListTile` / `InkWell` + `Navigator.push` |
| Kalender | `table_calendar` (tandai hari berkegiatan, `onDaySelected` → `/agenda/:i`) |
| Drop foto splash | `Image.asset`/`Image.network` (di prototipe pakai komponen drag-drop) |

---

## 5. Aset
- `assets/koni-logo-transparent.png` — logo KONI Kab. Tangerang **tanpa background** (untuk dipakai di atas foto/warna). Daftarkan di `pubspec.yaml`.
- Foto splash: sediakan foto olahraga/stadion sendiri (`assets/splash_bg.jpg`).

---

## 6. Catatan Interaksi
- **Multi-role**: tampilan dashboard/menu menyesuaikan `Role` (lihat daftar `ROLES`). Simpan role aktif di state (mis. `Provider`/`Riverpod`).
- **Status warna**: Aktif→success, Pembinaan→warning, Cedera→danger.
- **Drill-down Analytics**: KPI/chart → `/analytics/:metric` → baris → `/cabor/:id`.
- **Agenda**: hari berkegiatan & kartu kegiatan → `/agenda/:i`.

> Semua nilai warna, teks, dan data contoh bersumber dari `SIORG v2.dc.html`. Untuk piksel/spacing presisi, buka file itu berdampingan saat membangun widget.
