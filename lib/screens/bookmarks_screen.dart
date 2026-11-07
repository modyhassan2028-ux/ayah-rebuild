import 'package:flutter/material.dart';
import '../data/quran_data.dart';
import '../services/storage.dart';
import 'mushaf_screen.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});
  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  @override
  Widget build(BuildContext context) {
    final pages = Storage.bookmarks.toList()..sort();
    return Scaffold(
      appBar: AppBar(title: const Text('العلامات')),
      body: pages.isEmpty
          ? const Center(child: Text('لا توجد علامات بعد'))
          : ListView(
              children: pages.map((p) {
                final s = QuranData.surahOfPage(p);
                return ListTile(
                  leading: const Icon(Icons.bookmark, color: Color(0xFF1F6E43)),
                  title: Text('سورة ${s.name}'),
                  subtitle: Text('صفحة $p'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18),
                    onPressed: () async {
                      await Storage.toggleBookmark(p);
                      setState(() {});
                    },
                  ),
                  onTap: () async {
                    await Navigator.push(context,
                        MaterialPageRoute(builder: (_) => MushafScreen(initialPage: p)));
                    setState(() {});
                  },
                );
              }).toList(),
            ),
    );
  }
}
