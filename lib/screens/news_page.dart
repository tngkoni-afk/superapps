import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/berita_model.dart';
import 'signup_page.dart';
import 'athlete_list_page.dart';
import 'agenda_page.dart';
import 'news_detail_page.dart';
import 'coming_soon_page.dart';
import 'cabor_list_page.dart';
import '../theme/colors.dart';
import '../widgets/siorg_bottom_nav.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  final ApiService _apiService = ApiService();
  String selectedCategory = "Semua";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. TOP LOGO & PROFILE (Identik Gambar 2)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset("assets/koni_logo.png", height: 50, errorBuilder: (_, _, _) => const Icon(Icons.emoji_events, color: AppColors.navy)),
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUpPage())),
                      child: const CircleAvatar(backgroundColor: Color(0xFFF5F5F5), child: Icon(Icons.person_outline, color: Colors.grey)),
                    ),
                  ],
                ),
              ),

              // 2. SEARCH BAR
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(12)),
                  child: const TextField(
                    decoration: InputDecoration(
                      hintText: "Cari berita...",
                      border: InputBorder.none,
                      icon: Icon(Icons.search, color: Colors.grey),
                    ),
                  ),
                ),
              ),

              // 3. CATEGORY CHIPS (Horizontal Scroll)
              const SizedBox(height: 20),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: ["Semua", "Sepakbola", "Basket", "Badminton"].map((cat) {
                    bool isSelected = selectedCategory == cat;
                    return GestureDetector(
                      onTap: () => setState(() => selectedCategory = cat),
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.navy : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: isSelected ? AppColors.navy : Colors.grey.shade300),
                        ),
                        child: Text(cat, style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // 4. ICON MENU WITH LABELS (Identik Gambar 2)
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _menuIcon(Icons.person, "Atlit", () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AthleteListPage()))),
                  _menuIcon(Icons.newspaper, "Berita", () {}, isActive: true),
                  _menuIcon(Icons.sports, "Cabor", () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CaborListPage()))),
                  _menuIcon(Icons.calendar_month, "Agenda", () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AgendaPage()))),
                  _menuIcon(Icons.emoji_events, "Prestasi", () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ComingSoonPage(title: "Prestasi")))),
                ],
              ),

              // 5. HERO CARD (Berita Utama)
              const SizedBox(height: 25),
              FutureBuilder<List<BeritaModel>>(
                future: _apiService.fetchBerita(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final heroNews = snapshot.data![0];
                  return _buildHeroCard(heroNews);
                },
              ),

              // 6. NEWS LIST (Section Title & Items)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text("Berita Terkini", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              _buildNewsList(),
              
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const SiorgBottomNav(active: -1),
    );
  }

  Widget _menuIcon(IconData icon, String label, VoidCallback onTap, {bool isActive = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.tintNavy,
              shape: BoxShape.circle,
              border: isActive ? Border.all(color: AppColors.navy, width: 1) : null,
            ),
            child: Icon(icon, color: isActive ? AppColors.navy : AppColors.muted2, size: 24),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.black87)),
        ],
      ),
    );
  }

  void _openDetail(BeritaModel berita) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => NewsDetailPage(image: berita.foto ?? '', title: berita.judul, tag: "KONI", category: "Berita", time: berita.createdAt, content: berita.deskripsi)));
  }

  Widget _buildHeroCard(BeritaModel news) {
    return GestureDetector(
      onTap: () => _openDetail(news),
      child: Container(
      height: 220,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        image: DecorationImage(
          image: NetworkImage(news.foto ?? "https://images.unsplash.com/photo-1504450758481-7338eba7524a?q=80&w=800"),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: LinearGradient(begin: Alignment.bottomCenter, colors: [Colors.black.withValues(alpha:0.8), Colors.transparent]),
        ),
        alignment: Alignment.bottomLeft,
        child: Text(news.judul, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold), maxLines: 2),
      ),
      ),
    );
  }

  Widget _buildNewsList() {
    return FutureBuilder<List<BeritaModel>>(
      future: _apiService.fetchBerita(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final item = snapshot.data![index];
            return GestureDetector(
              onTap: () => _openDetail(item),
              child: Container(
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 15),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(item.foto ?? "", width: 80, height: 80, fit: BoxFit.cover, errorBuilder: (_, _, _) => Container(width: 80, height: 80, color: Colors.grey.shade100)),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.judul, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 2),
                        const SizedBox(height: 8),
                        const Text("23 menit lalu", style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  )
                ],
              ),
              ),
            );
          },
        );
      },
    );
  }

}