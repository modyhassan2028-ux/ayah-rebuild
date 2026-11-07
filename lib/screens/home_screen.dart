import 'package:flutter/material.dart';
import 'app_shell.dart';
import '../data/quran_data.dart';
import '../services/storage.dart';
import 'mushaf_screen.dart';
import 'bookmarks_screen.dart';
import 'settings_screen.dart';
import 'listen_screen.dart';
import 'khatmah_screen.dart';
import 'notes_screen.dart';
import 'reminders_screen.dart';
import '../services/reminders_service.dart';
import '../services/khatmah_service.dart';

/// الرئيسية — متابعة القراءة + الختمة + فهرس السور
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _q = '';
  int _last = 1;

  @override
  void initState() {
    super.initState();
    _last = Storage.lastPage;
    KhatmahService.load();
  }

  Future<void> _open(int page) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => MushafScreen(initialPage: page)));
    if (mounted) setState(() => _last = Storage.lastPage);
  }

  @override
  Widget build(BuildContext context) {
    final s = QuranData.surahOfPage(_last);
    final list = QuranData.search(_q);
    return Scaffold(
      appBar: AppBar(
        leading: Builder(builder: (c) => IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: AppShell.openDrawer,
        )),
      
        title: Row(children: [
          Image.asset('assets/images/ic_launcher.png', width: 28,
              errorBuilder: (_, __, ___) => const SizedBox()),
          const SizedBox(width: 8),
          const Text('Ayah', style: TextStyle(fontWeight: FontWeight.w800)),
        ]),
        actions: [
          IconButton(
            tooltip: 'الاستماع',
            icon: const Icon(Icons.headphones_outlined),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ListenScreen())),
          ),
          IconButton(
            tooltip: 'العلامات',
            icon: const Icon(Icons.bookmarks_outlined),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const BookmarksScreen())),
          ),
          IconButton(
            tooltip: 'برنامج الختمة',
            icon: const Icon(Icons.event_repeat_outlined),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const KhatmahScreen())),
          ),
          IconButton(
            tooltip: 'الملاحظات',
            icon: const Icon(Icons.edit_note),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const NotesScreen())),
          ),
          IconButton(
            tooltip: 'التذكيرات',
            icon: const Icon(Icons.notifications_none),
            onPressed: () async {
              await RemindersService.init();
              if (!context.mounted) return;
              await Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const RemindersScreen()));
            },
          ),
          IconButton(
            tooltip: 'الإعدادات',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
              setState(() {});
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(54),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
            child: TextField(
              onChanged: (v) => setState(() => _q = v),
              decoration: InputDecoration(
                isDense: true,
                hintText: 'ابحث عن سورة',
                prefixIcon: const Icon(Icons.search, size: 20),
                filled: true,
                fillColor: Colors.black.withValues(alpha: .04),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 20),
        children: [
          // متابعة القراءة
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => _open(_last),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  begin: Alignment.topRight, end: Alignment.bottomLeft,
                  colors: [Color(0xFF12402A), Color(0xFF0B2A1C)],
                ),
              ),
              child: Row(children: [
                const Icon(Icons.menu_book_rounded, color: Colors.white70),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('متابعة القراءة', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text('سورة ${s.name} · صفحة $_last',
                        style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
                  ]),
                ),
                const Icon(Icons.arrow_back_ios_new, size: 16, color: Colors.white70),
              ]),
            ),
          ),
          const SizedBox(height: 14),
          // تقدّم الختمة
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () async {
              await Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const KhatmahScreen()));
              if (mounted) setState(() {});
            },
            child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Text('تقدّم الختمة', style: TextStyle(fontWeight: FontWeight.w700)),
                const Spacer(),
                Text('$_last / ${QuranData.totalPages}', style: const TextStyle(fontSize: 12)),
              ]),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: _last / QuranData.totalPages,
                  minHeight: 8,
                  backgroundColor: Colors.black12,
                  color: const Color(0xFF1F6E43),
                ),
              ),
              const SizedBox(height: 8),
              Text('${((_last / QuranData.totalPages) * 100).toStringAsFixed(1)}% من المصحف',
                  style: const TextStyle(fontSize: 11, color: Colors.black54)),
            ]),
          )),
          const SizedBox(height: 18),
          Text(_q.trim().isEmpty ? 'السور' : 'نتائج البحث (${list.length})',
              style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          if (list.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 26),
              alignment: Alignment.center,
              child: const Text('لا توجد سورة بهذا الاسم', style: TextStyle(color: Colors.black54)),
            ),
          ...list.map((s) => Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                child: ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  dense: true,
                  leading: CircleAvatar(
                    radius: 14,
                    backgroundColor: const Color(0xFFEAF5EE),
                    child: Text('${s.n}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                  ),
                  title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('صفحة ${s.page}', style: const TextStyle(fontSize: 11)),
                  trailing: const Icon(Icons.chevron_left, size: 18),
                  onTap: () => _open(s.page),
                ),
              )),
        ],
      ),
    );
  }
}
