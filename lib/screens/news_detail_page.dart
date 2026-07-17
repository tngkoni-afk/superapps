import 'package:flutter/material.dart';
import '../theme/colors.dart';

class NewsDetailPage extends StatelessWidget {
  final String image;
  final String title;
  final String tag;
  final String category;
  final String time;
  final String content;

  const NewsDetailPage({
    super.key,
    required this.image,
    required this.title,
    required this.tag,
    required this.category,
    required this.time,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    // Estimasi waktu baca sederhana (asumsi 200 kata per menit)
    final int readTime = (content.split(' ').length / 200).ceil();

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // 1. HEADER DENGAN PARALLAX IMAGE
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            elevation: 0,
            leading: _backButton(context),
            actions: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.share, color: Colors.white)),
              IconButton(onPressed: () {}, icon: const Icon(Icons.bookmark_border, color: Colors.white)),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(image, fit: BoxFit.cover),
                  // Overlay gradient agar teks atau icon di atasnya tetap terlihat
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Colors.black54, Colors.transparent],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. KONTEN BERITA
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Kategori & Estimasi Waktu
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.navy.withValues(alpha:0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            category.toUpperCase(),
                            style: const TextStyle(color: AppColors.navy, fontWeight: FontWeight.bold, fontSize: 10),
                          ),
                        ),
                        Text("$readTime Menit Baca", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Judul Utama
                    Text(
                      title,
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, height: 1.2, letterSpacing: -0.5),
                    ),
                    const SizedBox(height: 20),
                    
                    // Info Penulis (Author Box)
                    _authorBox(),
                    
                    const Divider(height: 40, thickness: 1),
                    
                    // Body Berita
                    Text(
                      content,
                      style: const TextStyle(
                        fontSize: 17,
                        height: 1.7,
                        color: Color(0xFF2D2D2D),
                        letterSpacing: 0.2,
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Tagar (Tags)
                    Wrap(
                      spacing: 8,
                      children: ["#KONI", "#Tangerang", "#Olahraga", "#Update"]
                          .map((t) => Chip(label: Text(t, style: const TextStyle(fontSize: 12)), backgroundColor: Colors.grey.shade100, side: BorderSide.none))
                          .toList(),
                    ),
                    
                    const Divider(height: 60),

                    // 3. SEKSI BERITA TERKAIT (Placeholder UI)
                    const Text("Berita Terkait", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _relatedNewsItem("Persiapan Atlet Menuju Porprov 2026"),
                    _relatedNewsItem("KONI Tangerang Gelar Workshop Pelatih"),
                    
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
      // Floating Share Button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: AppColors.navy,
        icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
        label: const Text("Tulis Komentar", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  // Tombol Back Custom
  Widget _backButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: Colors.black26, shape: BoxShape.circle),
      child: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  // Widget Profil Penulis
  Widget _authorBox() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 20,
          backgroundColor: Color(0xFFEEEEEE),
          child: Icon(Icons.person, color: Colors.grey),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Redaksi KONI", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            Text(time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ],
    );
  }

  // Widget Item Berita Terkait
  Widget _relatedNewsItem(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(width: 80, height: 60, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8))),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}