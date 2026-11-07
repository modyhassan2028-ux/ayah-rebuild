import 'package:flutter/material.dart';
import 'app_shell.dart';
import '../data/quran_data.dart';
import '../services/storage.dart';
import 'mushaf_screen.dart';

/// المفضلة — تبويب من قائمة الأصل (favorites)، منفصل عن العلامات.
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});
  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  Widget build(BuildContext context) {
    final pages = Storage.favorites.toList()..sort();
    return Scaffold(
      appBar: AppBar(
        leading: Builder(builder: (c) => IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: AppShell.openDrawer,
        )),
      title: const Text('المفضلة')),
      body: pages.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(28),
                child: Text(
                  'لا توجد آيات في المفضلة بعد\nاضغط النجمة في شاشة المصحف لإضافتها',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF6B5A4B), height: 1.7),
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: pages.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFE4D8C8)),
              itemBuilder: (c, i) {
                final page = pages[i];
                final surah = QuranData.surahOfPage(page);
                return ListTile(
                  leading: const Icon(Icons.star_rounded, color: Color(0xFFC9A227)),
                  title: Text('سورة ${surah.name}'),
                  subtitle: Text('صفحة $page'),
                  trailing: IconButton(
                    icon: const Icon(Icons.star_rounded, color: Color(0xFFC9A227), size: 20),
                    onPressed: () async {
                      await Storage.toggleFavorite(page);
                      setState(() {});
                    },
                  ),
                  onTap: () async {
                    await Navigator.push(context,
                        MaterialPageRoute(builder: (_) => MushafScreen(initialPage: page)));
                    setState(() {});
                  },
                );
              },
            ),
    );
  }
}
