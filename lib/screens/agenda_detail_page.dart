import 'package:flutter/material.dart';
import '../models/agenda_model.dart';
import '../theme/colors.dart';

class AgendaDetailPage extends StatelessWidget {
  final AgendaModel agenda;
  const AgendaDetailPage({super.key, required this.agenda});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildModernAppBar(context),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildEventQuickStats(),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTitleSection(),
                          const SizedBox(height: 32),
                          _buildDescriptionSection(),
                          const SizedBox(height: 32),
                          _buildTimelineSection(), // Rundown Acara
                          const SizedBox(height: 32),
                          _buildGuestSection(), // Tokoh Penting
                          const SizedBox(height: 32),
                          _buildLocationSection(),
                          const SizedBox(height: 140), // Space for bottom button
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          _buildBottomActionBar(),
        ],
      ),
    );
  }

  // 1. APPBAR DENGAN PARALLAX & GLASS EFFECT
  Widget _buildModernAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 380,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.navy,
      leading: _circleIconButton(Icons.arrow_back, () => Navigator.pop(context)),
      actions: [
        _circleIconButton(Icons.share_outlined, () {}),
        const SizedBox(width: 12),
        _circleIconButton(Icons.bookmark_border, () {}),
        const SizedBox(width: 16),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              agenda.imageUrl ?? "https://images.unsplash.com/photo-1517649763962-0c623066013b?q=80&w=1200",
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const Center(child: Icon(Icons.image, size: 80, color: Colors.grey)),
            ),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Color(0xFFF8F9FA), Colors.transparent],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 2. QUICK STATS (GRID GAYA PROFIL ATLIT)
  Widget _buildEventQuickStats() {
    return Transform.translate(
      offset: const Offset(0, -40),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            _statItem("Status", "Upcoming", Icons.timer_outlined, Colors.blue),
            const SizedBox(width: 12),
            _statItem("Peserta", "500+", Icons.people_outline, AppColors.navy),
            const SizedBox(width: 12),
            _statItem("Poin", "100 XP", Icons.stars_outlined, Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String label, String val, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha:0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  String _formatTanggal(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      final months = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
      return "${dt.day} ${months[dt.month - 1]} ${dt.year}";
    } catch (e) {
      return dateStr;
    }
  }

  // 3. JUDUL & TAGS
  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: AppColors.navy.withValues(alpha:0.1), borderRadius: BorderRadius.circular(8)),
          child: const Text("OFFICIAL EVENT", style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.bold, fontSize: 10)),
        ),
        const SizedBox(height: 16),
        Text(agenda.namaAgenda, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(Icons.calendar_month, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Text(_formatTanggal(agenda.tanggalMulai), style: const TextStyle(color: Colors.grey, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.location_on, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Text(agenda.lokasi, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          ],
        ),
      ],
    );
  }

  // 4. DESKRIPSI
  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Deskripsi Kegiatan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Text(agenda.keterangan, style: const TextStyle(fontSize: 15, height: 1.8, color: Colors.black87)),
      ],
    );
  }

  // 5. TIMELINE / RUNDOWN
  Widget _buildTimelineSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Rundown Acara", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _timelineItem("08:00", "Pembukaan & Registrasi", true),
        _timelineItem("09:30", "Sambutan Ketua KONI", false),
        _timelineItem("10:30", "Pelaksanaan Kompetisi", false),
      ],
    );
  }

  Widget _timelineItem(String time, String title, bool isFirst) {
    return Row(
      children: [
        Column(
          children: [
            Container(width: 12, height: 12, decoration: const BoxDecoration(color: AppColors.navy, shape: BoxShape.circle)),
            Container(width: 2, height: 40, color: Colors.grey.shade200),
          ],
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(time, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.navy, fontSize: 12)),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
            const SizedBox(height: 20),
          ],
        )
      ],
    );
  }

  // 6. GUEST SECTION
  Widget _buildGuestSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Tokoh Penting", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        SizedBox(
          height: 60,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: List.generate(3, (i) => const Padding(
              padding: EdgeInsets.only(right: 12),
              child: CircleAvatar(radius: 25, backgroundColor: Colors.grey, child: Icon(Icons.person, color: Colors.white)),
            )),
          ),
        ),
      ],
    );
  }

  // 7. LOCATION
  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Lokasi & Map", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        // Nama lokasi selalu ditampilkan (sebelumnya hilang).
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.place_outlined, size: 20, color: AppColors.navy),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                agenda.lokasi,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: agenda.hasCoordinates ? _buildMap() : _buildMapPlaceholder(),
        ),
      ],
    );
  }

  // Peta statis di koordinat agenda yang sebenarnya, lengkap dengan penanda.
  // Yandex memakai urutan ll=lon,lat (keyless).
  Widget _buildMap() {
    final lat = agenda.latitude!;
    final lng = agenda.longitude!;
    final url =
        "https://static-maps.yandex.ru/1.x/?lang=en_US&ll=$lng,$lat&z=15&l=map&size=600,300&pt=$lng,$lat,pm2rdm";
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
      ),
    );
  }

  // Ditampilkan bila agenda belum memiliki koordinat (lat/lng null),
  // menggantikan peta yang salah/menyesatkan.
  Widget _buildMapPlaceholder() {
    return Container(
      height: 140,
      width: double.infinity,
      color: Colors.grey.shade100,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.map_outlined, size: 36, color: Colors.grey.shade400),
          const SizedBox(height: 8),
          Text(
            "Lokasi belum dipetakan",
            style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // 8. BOTTOM ACTION BAR (FIXED ICON ERROR)
  Widget _buildBottomActionBar() {
    return Positioned(
      bottom: 30, left: 24, right: 24,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha:0.1), blurRadius: 30, offset: const Offset(0, 10))],
        ),
        child: Row(
          children: [
            // PERBAIKAN: Mengganti Icons.calendar_add_on menjadi Icons.event
            _circleIconButton(Icons.event, () {}, color: Colors.grey.shade100, iconColor: Colors.black),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navy,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  elevation: 0,
                ),
                child: const Text("IKUTI KEGIATAN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circleIconButton(IconData icon, VoidCallback onTap, {Color? color, Color? iconColor}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: color ?? Colors.black26, shape: BoxShape.circle),
        child: Icon(icon, color: iconColor ?? Colors.white, size: 22),
      ),
    );
  }
}