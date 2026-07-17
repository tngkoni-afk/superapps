import 'package:flutter/material.dart';

import '../theme/colors.dart';

/// Header tonal SIORG v2: latar gradient merah (158°) dengan sudut bawah
/// melengkung dan lingkaran dekoratif putih transparan. Konten di dalamnya
/// memakai teks/ikon putih.
///
/// Dipakai seragam di seluruh layar (dashboard, list, detail, auth).
class SiorgHeader extends StatelessWidget {
  final Widget child;
  final double radius;
  final EdgeInsetsGeometry padding;

  const SiorgHeader({
    super.key,
    required this.child,
    this.radius = 30,
    this.padding = const EdgeInsets.fromLTRB(18, 52, 18, 20),
  });

  /// Tombol ikon di atas header (latar putih transparan, ikon putih).
  static Widget iconButton(IconData icon, VoidCallback onTap, {double size = 42}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }

  /// Avatar inisial di header: lingkaran putih dengan teks merah.
  static Widget initialsAvatar(String initials, {double size = 46}) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(color: AppColors.redMid, fontSize: size * 0.3, fontWeight: FontWeight.w800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(radius)),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.headerGradient),
        child: Stack(
          children: [
            // Lingkaran dekoratif putih transparan (pojok kanan atas).
            Positioned(
              top: -44,
              right: -30,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            Padding(padding: padding, child: child),
          ],
        ),
      ),
    );
  }
}
