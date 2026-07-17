import 'package:flutter/material.dart';

/// SIORG design tokens (navy + grey + red KONI accent).
///
/// Source of truth: `new design/FLUTTER_HANDOFF.md` (§1 Design Tokens).
/// Brand name stays "KONI"; only the palette is refreshed.
///
/// Phase 1: this file is additive. Existing screens still use their own
/// inline colors until they are migrated (Phase 2). Prefer these tokens for
/// all new code.
class AppColors {
  AppColors._();

  // ----- Brand -----
  static const ink = Color(0xFF1C2A45); // teks utama / navy gelap
  static const navy = Color(0xFF2E4374); // aksen navy
  static const red = Color(0xFFD62828); // aksen merah KONI (badge/teks)
  static const gold = Color(0xFFF4A261); // aksen emas (loader splash)

  // ----- Header merah (SIORG v2): gradient 158° untuk header layar -----
  static const redLight = Color(0xFFE63333);
  static const redMid = Color(0xFFC81F1F);
  static const redDark = Color(0xFFA81818);
  static const headerGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [redLight, redMid, redDark],
    stops: [0.0, 0.58, 1.0],
  );

  // ----- Teks sekunder -----
  static const secondary = Color(0xFF5B6B8C);
  static const muted = Color(0xFF8A93A2);
  static const muted2 = Color(0xFF9AA3B2);
  static const faint = Color(0xFFB6BCC7);

  // ----- Permukaan -----
  static const bg = Color(0xFFF3F5F9); // background layar
  static const surface = Color(0xFFFFFFFF); // kartu
  static const line = Color(0xFFF3F5F8); // garis pemisah
  static const line2 = Color(0xFFEEF1F5); // track progress bar

  // ----- Tint lembut (latar kartu tonal & badge) -----
  static const tintNavy = Color(0xFFE4ECF9);
  static const tintRed = Color(0xFFFBECEC);
  static const tintGreen = Color(0xFFE4F4EB);
  static const tintGold = Color(0xFFFBF1E2);
  static const tintPurple = Color(0xFFF0EBF7);
  static const tintGray = Color(0xFFEDF0F4);

  // ----- Status -----
  static const success = Color(0xFF2BA35B); // Aktif
  static const warning = Color(0xFFC98A1E); // Pembinaan / Menunggu
  static const danger = Color(0xFFD62828); // Cedera

  // ----- Bottom nav -----
  static const navBar = Color(0xFF1C2A45);
  static const navInactive = Color(0xFF8893AD);
}
