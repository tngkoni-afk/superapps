import 'package:flutter/material.dart';

import '../theme/colors.dart';
import 'siorg_header.dart';

/// Header sederhana bergaya SIORG dengan tombol back — dipakai sub-halaman profil.
Widget profileSubHeader(BuildContext context, String title, String subtitle) {
  return SiorgHeader(
    radius: 30,
    padding: const EdgeInsets.fromLTRB(18, 52, 18, 20),
    child: Row(
      children: [
        SiorgHeader.iconButton(Icons.chevron_left, () => Navigator.pop(context)),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: Colors.white)),
              Text(subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    ),
  );
}

/// Tombol utama biru dengan state loading — dipakai bersama form profil/password.
Widget primaryButton(String label, bool loading, VoidCallback onTap) {
  return SizedBox(
    width: double.infinity,
    height: 52,
    child: ElevatedButton(
      onPressed: loading ? null : onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: loading
          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          : Text(label, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700)),
    ),
  );
}
