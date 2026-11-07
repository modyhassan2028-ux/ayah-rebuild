import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/quran_data.dart';
import '../services/storage.dart';
import '../services/tafsir_service.dart';

/// التفسير — شاشة tafsir.xml من الأصل: رأس صفحة، نص التفسير، تذييل صفحة.
class TafsirScreen extends StatefulWidget {
  final int initialPage;
  const TafsirScreen({super.key, this.initialPage = 1});
  @override
  State<TafsirScreen> createState() => _TafsirScreenState();
}

class _TafsirScreenState extends State<TafsirScreen> {
  late int _page;
  String _text = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _page = widget.initialPage.clamp(1, QuranData.totalPages);
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final t = await TafsirService.forPage(_page);
    if (!mounted) return;
    setState(() {
      _text = t;
      _loading = false;
    });
  }

  void _go(int delta) {
    final next = (_page + delta).clamp(1, QuranData.totalPages);
    if (next == _page) return;
    setState(() => _page = next);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final surah = QuranData.surahOfPage(_page);
    return Scaffold(
      appBar: AppBar(
        title: Text('التفسير · ${surah.name} · $_page',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            tooltip: 'نسخ',
            icon: const Icon(Icons.copy_all_rounded),
            onPressed: _text.isEmpty
                ? null
                : () async {
                    await Clipboard.setData(ClipboardData(text: _text));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('تم نسخ التفسير')));
                    }
                  },
          ),
        ],
      ),
      body: Column(
        children: [
          _header(surah.name, _page),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _text.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Text('لا يوجد تفسير لهذه الصفحة',
                              style: TextStyle(color: Color(0xFF6B5A4B))),
                        ),
                      )
                    : Scrollbar(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                          child: SelectableText(
                            _text,
                            textAlign: TextAlign.justify,
                            style: const TextStyle(
                              fontSize: 17,
                              height: 2.0,
                              color: Color(0xFF3E2C1E),
                              fontFamily: 'Amiri',
                            ),
                          ),
                        ),
                      ),
          ),
          _footer(_page),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextButton.icon(
                onPressed: _page > 1 ? () => _go(-1) : null,
                icon: const Icon(Icons.arrow_forward_rounded),
                label: const Text('السابقة'),
              ),
            ),
            Text('$_page / ${QuranData.totalPages}',
                style: const TextStyle(fontWeight: FontWeight.w700)),
            Expanded(
              child: TextButton.icon(
                onPressed: _page < QuranData.totalPages ? () => _go(1) : null,
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('التالية'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(String surah, int page) => Container(
        margin: const EdgeInsets.fromLTRB(10, 10, 10, 4),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF2E9DD),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0D2BF)),
        ),
        child: Center(
          child: Text('سورة $surah — صفحة $page',
              style: const TextStyle(
                  fontSize: 13.5, fontWeight: FontWeight.w700, color: Color(0xFF4D3322))),
        ),
      );

  Widget _footer(int page) => Container(
        margin: const EdgeInsets.fromLTRB(10, 4, 10, 8),
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Center(
          child: Text('$page',
              style: const TextStyle(fontSize: 12.5, color: Color(0xFF9C8B7B))),
        ),
      );
}
