import 'package:flutter/material.dart';

import '../theme/colors.dart';

/// Buka preview foto layar penuh (bisa dicubit/zoom). Aman dipanggil dengan
/// url kosong (tidak melakukan apa-apa). Fallback ke inisial bila gambar gagal.
void showPhotoPreview(BuildContext context, String url, {String? initials}) {
  if (url.trim().isEmpty) return;
  showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.92),
    builder: (ctx) => _PhotoPreviewDialog(url: url, initials: initials),
  );
}

class _PhotoPreviewDialog extends StatelessWidget {
  final String url;
  final String? initials;
  const _PhotoPreviewDialog({required this.url, this.initials});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: InteractiveViewer(
                minScale: 0.8,
                maxScale: 4,
                child: Center(
                  child: Image.network(
                    url,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => _fallback(),
                    loadingBuilder: (_, child, progress) => progress == null
                        ? child
                        : const Center(child: CircularProgressIndicator(color: Colors.white)),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 44,
            right: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                child: const Icon(Icons.close, color: Colors.white, size: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallback() {
    return Container(
      width: 200,
      height: 200,
      decoration: const BoxDecoration(color: AppColors.tintNavy, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(initials ?? '?',
          style: const TextStyle(color: AppColors.navy, fontSize: 64, fontWeight: FontWeight.w800)),
    );
  }
}
