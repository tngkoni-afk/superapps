import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/agenda_model.dart';
import 'agenda_detail_page.dart';
import '../theme/colors.dart';
import '../widgets/siorg_bottom_nav.dart';
import '../widgets/siorg_header.dart';

/// Agenda Kegiatan (SIORG `/agenda`).
///
/// Data dari `ApiService.fetchAgenda` (API nyata). Tiga tampilan sesuai
/// handoff: Kalender (grid bulan + daftar), Timeline, dan List. Tipe/warna
/// kegiatan diturunkan dari nama agenda karena belum ada field kategori di API.
class AgendaPage extends StatefulWidget {
  const AgendaPage({super.key});

  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  final ApiService _apiService = ApiService();

  List<AgendaModel> _items = [];
  bool _loading = true;
  String? _error;
  String _view = 'Kalender'; // Kalender | Timeline | List

  static const _views = ['Kalender', 'Timeline', 'List'];
  static const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'];
  static const _monthsFull = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _apiService.fetchAgenda();
      if (!mounted) return;
      setState(() {
        _items = data;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Gagal memuat agenda';
        _loading = false;
      });
    }
  }

  // ----- Date helpers -----
  DateTime? _date(AgendaModel a) {
    try {
      return DateTime.parse(a.tanggalMulai);
    } catch (_) {
      return null;
    }
  }

  String _day(AgendaModel a) => _date(a)?.day.toString().padLeft(2, '0') ?? '00';
  String _mon(AgendaModel a) {
    final d = _date(a);
    return d == null ? 'MMM' : _months[d.month - 1];
  }

  String _meta(AgendaModel a) {
    final lok = a.lokasi.isEmpty ? 'Tangerang' : a.lokasi;
    return lok;
  }

  /// Tipe kegiatan diturunkan dari nama agenda.
  ({String label, Color fg, Color tint}) _type(AgendaModel a) {
    final n = a.namaAgenda.toLowerCase();
    if (n.contains('seleksi')) return (label: 'Seleksi', fg: AppColors.navy, tint: AppColors.tintNavy);
    if (n.contains('kejuaraan') || n.contains('kejurnas') || n.contains('liga')) {
      return (label: 'Kejuaraan', fg: AppColors.red, tint: AppColors.tintRed);
    }
    if (n.contains('pelatihan') || n.contains('workshop') || n.contains('sertifikasi')) {
      return (label: 'Pelatihan', fg: AppColors.success, tint: AppColors.tintGreen);
    }
    if (n.contains('rapat') || n.contains('koordinasi')) {
      return (label: 'Rapat', fg: AppColors.warning, tint: AppColors.tintGold);
    }
    return (label: 'Kegiatan', fg: AppColors.secondary, tint: AppColors.tintGray);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      bottomNavigationBar: const SiorgBottomNav(active: 3),
      body: Column(
        children: [
          _header(),
          Expanded(child: _body()),
        ],
      ),
    );
  }

  Widget _header() {
    String monthLabel = 'Kegiatan KONI';
    if (_items.isNotEmpty) {
      final d = _date(_items.first);
      if (d != null) monthLabel = '${_monthsFull[d.month - 1]} ${d.year}';
    }
    return SiorgHeader(
      radius: 30,
      padding: const EdgeInsets.fromLTRB(18, 52, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SiorgHeader.iconButton(Icons.chevron_left, () => Navigator.pop(context)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Agenda Kegiatan',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
                    Text(monthLabel,
                        style: const TextStyle(fontSize: 12.5, color: Colors.white70, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(99)),
            child: Row(
              children: _views.map((v) {
                final active = _view == v;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _view = v),
                    child: Container(
                      height: 34,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: active ? AppColors.navy : Colors.transparent,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(v,
                          style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: active ? Colors.white : AppColors.secondary)),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _body() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.navy));
    }
    if (_error != null) {
      return Center(child: Text(_error!, style: const TextStyle(color: AppColors.danger)));
    }
    if (_items.isEmpty) {
      return const Center(child: Text('Tidak ada agenda', style: TextStyle(color: AppColors.muted)));
    }
    return RefreshIndicator(
      color: AppColors.navy,
      onRefresh: _fetch,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
        child: switch (_view) {
          'Timeline' => _timelineView(),
          'List' => _listView(),
          _ => _kalenderView(),
        },
      ),
    );
  }

  // ----- KALENDER -----
  Widget _kalenderView() {
    final ref = _date(_items.first) ?? DateTime(2026, 6);
    final firstDay = DateTime(ref.year, ref.month, 1);
    final daysInMonth = DateTime(ref.year, ref.month + 1, 0).day;
    final leading = firstDay.weekday - 1; // Senin = 1
    final agendaDays = _items
        .map(_date)
        .where((d) => d != null && d.year == ref.year && d.month == ref.month)
        .map((d) => d!.day)
        .toSet();

    final cells = <int?>[...List.filled(leading, null), ...List.generate(daysInMonth, (i) => i + 1)];
    while (cells.length % 7 != 0) {
      cells.add(null);
    }
    final weeks = <List<int?>>[];
    for (var i = 0; i < cells.length; i += 7) {
      weeks.add(cells.sublist(i, i + 7));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(22)),
          child: Column(
            children: [
              Row(
                children: const ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min']
                    .map((d) => Expanded(
                          child: Center(
                            child: Text(d,
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.faint)),
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 6),
              ...weeks.map((week) => Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Row(
                      children: week.map((day) {
                        final hasAgenda = day != null && agendaDays.contains(day);
                        return Expanded(
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Container(
                              margin: const EdgeInsets.all(1),
                              decoration: BoxDecoration(
                                color: hasAgenda ? AppColors.tintNavy : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: day == null
                                  ? const SizedBox.shrink()
                                  : Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text('$day',
                                            style: TextStyle(
                                                fontSize: 12.5,
                                                fontWeight: FontWeight.w700,
                                                color: hasAgenda ? AppColors.navy : AppColors.ink)),
                                        const SizedBox(height: 2),
                                        Container(
                                          width: 5, height: 5,
                                          decoration: BoxDecoration(
                                            color: hasAgenda ? AppColors.red : Colors.transparent,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  )),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const Text('Daftar Kegiatan',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.ink)),
        const SizedBox(height: 12),
        ..._items.map(_kalenderCard),
      ],
    );
  }

  Widget _kalenderCard(AgendaModel a) {
    final t = _type(a);
    return GestureDetector(
      onTap: () => _openDetail(a),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(18)),
        child: Row(
          children: [
            Container(
              width: 46, height: 50,
              decoration: BoxDecoration(color: t.tint, borderRadius: BorderRadius.circular(13)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_day(a), style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: t.fg, height: 1)),
                  Text(_mon(a).toUpperCase(), style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: t.fg)),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(child: _agendaInfo(a, t)),
            const Icon(Icons.chevron_right, color: AppColors.faint, size: 18),
          ],
        ),
      ),
    );
  }

  // ----- TIMELINE -----
  Widget _timelineView() {
    return Column(
      children: List.generate(_items.length, (i) {
        final a = _items[i];
        final t = _type(a);
        final isLast = i == _items.length - 1;
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 42,
                child: Column(
                  children: [
                    Text(_day(a), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.ink)),
                    Text(_mon(a).toUpperCase(),
                        style: const TextStyle(fontSize: 9, color: AppColors.muted2, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Container(width: 10, height: 10, decoration: BoxDecoration(color: t.fg, shape: BoxShape.circle)),
                    if (!isLast) Expanded(child: Container(width: 2, color: const Color(0xFFE6E9EF), margin: const EdgeInsets.only(top: 3))),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: GestureDetector(
                    onTap: () => _openDetail(a),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(18)),
                      child: _agendaInfo(a, t),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // ----- LIST -----
  Widget _listView() {
    return Column(
      children: _items.map((a) {
        final t = _type(a);
        return GestureDetector(
          onTap: () => _openDetail(a),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border(left: BorderSide(color: t.fg, width: 4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(t.label.toUpperCase(),
                        style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: t.fg, letterSpacing: 0.4)),
                    Text('${_day(a)} ${_mon(a)}',
                        style: const TextStyle(fontSize: 11, color: AppColors.muted2, fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(a.namaAgenda,
                    style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.ink, height: 1.3),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(_meta(a),
                    style: const TextStyle(fontSize: 11, color: AppColors.muted2, fontWeight: FontWeight.w500),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _agendaInfo(AgendaModel a, ({String label, Color fg, Color tint}) t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
          decoration: BoxDecoration(color: t.tint, borderRadius: BorderRadius.circular(99)),
          child: Text(t.label.toUpperCase(),
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: t.fg)),
        ),
        const SizedBox(height: 6),
        Text(a.namaAgenda,
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.ink, height: 1.3),
            maxLines: 2, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 3),
        Text(_meta(a),
            style: const TextStyle(fontSize: 10.5, color: AppColors.muted2, fontWeight: FontWeight.w500),
            maxLines: 1, overflow: TextOverflow.ellipsis),
      ],
    );
  }

  void _openDetail(AgendaModel a) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => AgendaDetailPage(agenda: a)));
  }
}
