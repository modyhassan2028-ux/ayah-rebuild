import 'package:flutter/material.dart';
import 'app_shell.dart';
import '../data/quran_data.dart';
import '../services/notes_service.dart';
import 'mushaf_screen.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});
  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  List<Note> _notes = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final n = await NotesService.all();
    if (mounted) setState(() => _notes = n);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(builder: (c) => IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: AppShell.openDrawer,
        )),
      title: const Text('الملاحظات')),
      body: _notes.isEmpty
          ? const Center(child: Text('لا توجد ملاحظات بعد — أضفها من المصحف'))
          : ListView(
              padding: const EdgeInsets.all(12),
              children: _notes.map((n) {
                final s = QuranData.surahOfPage(n.page);
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    title: Text(n.body),
                    subtitle: Text('سورة ${s.name} · صفحة ${n.page} · ${n.created}', style: const TextStyle(fontSize: 11)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18),
                      onPressed: () async {
                        await NotesService.remove(n.id);
                        _load();
                      },
                    ),
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => MushafScreen(initialPage: n.page))),
                  ),
                );
              }).toList(),
            ),
    );
  }
}
