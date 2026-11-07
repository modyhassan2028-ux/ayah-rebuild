import 'package:flutter/material.dart';
import '../data/quran_data.dart';
import '../services/storage.dart';
import '../services/tafsir_service.dart';

/// المصحف — كل صفحة 15 سطرًا من صور التطبيق الأصلية (assets/images/pages)
class MushafScreen extends StatefulWidget {
  final int initialPage;
  const MushafScreen({super.key, this.initialPage = 1});
  @override
  State<MushafScreen> createState() => _MushafScreenState();
}

class _MushafScreenState extends State<MushafScreen> {
  late final PageController _c = PageController(initialPage: widget.initialPage - 1);
  late int _page = widget.initialPage;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _go(int page) {
    final p = page.clamp(1, QuranData.totalPages);
    _c.jumpToPage(p - 1);
    setState(() => _page = p);
    Storage.setLastPage(p);
  }

  Future<void> _jumpDialog() async {
    final t = TextEditingController(text: '$_page');
    final v = await showDialog<int>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('انتقل إلى صفحة'),
        content: TextField(
          controller: t,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: '1 - 604'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          FilledButton(
            onPressed: () => Navigator.pop(context, int.tryParse(t.text.trim())),
            child: const Text('انتقال'),
          ),
        ],
      ),
    );
    if (v != null) _go(v);
  }

  Future<void> _tafsir() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: .7,
        builder: (c, sc) => FutureBuilder<String>(
          future: TafsirService.forPage(_page),
          builder: (c, snap) {
            final txt = snap.data ?? '';
            return ListView(
              controller: sc,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
              children: [
                Text('تفسير صفحة $_page',
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                if (snap.connectionState != ConnectionState.done)
                  const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
                else if (txt.isEmpty)
                  const Text('لا يوجد نص تفسير لهذه الصفحة في قاعدة الأصل.')
                else
                  Text(txt, style: const TextStyle(fontSize: 16, height: 2.0)),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _index() async {
    final s = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (_) => ListView(
        children: QuranData.surahs
            .map((x) => ListTile(
                  dense: true,
                  leading: Text('${x.n}', style: const TextStyle(fontSize: 12)),
                  title: Text(x.name),
                  trailing: Text('${x.page}', style: const TextStyle(fontSize: 11)),
                  onTap: () => Navigator.pop(context, x.page),
                ))
            .toList(),
      ),
    );
    if (s != null) _go(s);
  }

  @override
  Widget build(BuildContext context) {
    final surah = QuranData.surahOfPage(_page);
    final marked = Storage.bookmarks.contains(_page);
    return Scaffold(
      appBar: AppBar(
        title: Text('سورة ${surah.name} · $_page', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            tooltip: 'علامة',
            icon: Icon(marked ? Icons.bookmark : Icons.bookmark_border,
                color: marked ? const Color(0xFF1F6E43) : null),
            onPressed: () async {
              await Storage.toggleBookmark(_page);
              setState(() {});
            },
          ),
          IconButton(tooltip: 'التفسير', icon: const Icon(Icons.article_outlined), onPressed: _tafsir),
          IconButton(tooltip: 'الفهرس', icon: const Icon(Icons.list), onPressed: _index),
          IconButton(tooltip: 'انتقال', icon: const Icon(Icons.pin_outlined), onPressed: _jumpDialog),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _c,
              reverse: true,
              itemCount: QuranData.totalPages,
              onPageChanged: (i) {
                setState(() => _page = i + 1);
                Storage.setLastPage(i + 1);
              },
              itemBuilder: (c, i) => _PageView(page: i + 1),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            color: Colors.black.withValues(alpha: .03),
            child: Row(
              children: [
                IconButton(icon: const Icon(Icons.chevron_right), onPressed: () => _go(_page - 1)),
                Expanded(
                  child: Text('$_page / ${QuranData.totalPages}',
                      textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
                ),
                IconButton(icon: const Icon(Icons.chevron_left), onPressed: () => _go(_page + 1)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PageView extends StatelessWidget {
  final int page;
  const _PageView({required this.page});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFCF8EE),
      padding: const EdgeInsets.all(4),
      child: Column(
        children: List.generate(15, (i) => Expanded(
          child: Image.asset(
            'assets/images/pages/$page/${i + 1}.png',
            fit: BoxFit.fill,
            filterQuality: FilterQuality.medium,
            errorBuilder: (_, __, ___) => const SizedBox(),
          ),
        )),
      ),
    );
  }
}
