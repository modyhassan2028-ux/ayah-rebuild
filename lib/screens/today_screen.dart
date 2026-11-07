import 'package:flutter/material.dart';
import '../data/quran_data.dart';
import '../services/storage.dart';
import '../services/khatmah_service.dart';
import '../services/notes_service.dart';
import 'mushaf_screen.dart';
import 'khatmah_screen.dart';

/// اليوم — شاشة الدرج الأولى في الأصل: متابعة القراءة + الورد + أرقامك.
class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});
  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  int _notes = 0;

  @override
  void initState() {
    super.initState();
    KhatmahService.load();
    NotesService.all().then((v) {
      if (mounted) setState(() => _notes = v.length);
    });
  }

  int get _dailyPage {
    final now = DateTime.now();
    final n = now.difference(DateTime(now.year, 1, 1)).inDays;
    return (n % QuranData.totalPages) + 1;
  }

  @override
  Widget build(BuildContext context) {
    final last = Storage.lastPage;
    final lastSurah = QuranData.surahOfPage(last);
    final favs = Storage.favorites.length;
    final marks = Storage.bookmarks.length;
    final notes = _notes;
    final k = KhatmahService.current;

    return Scaffold(
      appBar: AppBar(title: const Text('اليوم')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          _card(
            title: 'متابعة القراءة',
            child: InkWell(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => MushafScreen(initialPage: last))),
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  children: [
                    Container(
                      width: 46, height: 46,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6F0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.menu_book_rounded, color: Color(0xFF007330)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('سورة ${lastSurah.name}',
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                          Text('صفحة $last من ٦٠٤',
                              style: const TextStyle(fontSize: 12.5, color: Color(0xFF6B5A4B))),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_left, color: Color(0xFF9C8B7B)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _card(
            title: 'الورد اليومي',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                if (k == null)
                  const Text('لا توجد ختمة جارية',
                      style: TextStyle(color: Color(0xFF6B5A4B), fontSize: 13.5))
                else
                  Text('${k.plan.title} — ورد اليوم ${k.dayNumber} من ${k.plan.days}',
                      style: const TextStyle(fontSize: 13.5)),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: k == null ? 0 : k.progress.clamp(0.0, 1.0),
                  minHeight: 7,
                  borderRadius: BorderRadius.circular(6),
                  backgroundColor: const Color(0xFFE7DCCB),
                  color: const Color(0xFF007330),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const KhatmahScreen())),
                  child: const Text('إدارة الختمة'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _stat('العلامات', '$marks'),
              const SizedBox(width: 10),
              _stat('المفضلة', '$favs'),
              const SizedBox(width: 10),
              _stat('الملاحظات', '$notes'),
            ],
          ),
          const SizedBox(height: 12),
          _card(
            title: 'آية اليوم',
            child: InkWell(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => MushafScreen(initialPage: _dailyPage))),
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text('افتح صفحة اليوم: سورة ${QuranData.surahOfPage(_dailyPage).name}',
                          style: const TextStyle(fontSize: 14.5)),
                    ),
                    const Icon(Icons.chevron_left, color: Color(0xFF9C8B7B)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required String title, required Widget child}) => Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEDE3D6)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5)),
            child,
          ],
        ),
      );

  Widget _stat(String label, String value) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFEDE3D6)),
          ),
          child: Column(
            children: [
              Text(value, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text(label, style: const TextStyle(fontSize: 11.5, color: Color(0xFF6B5A4B))),
            ],
          ),
        ),
      );
}
