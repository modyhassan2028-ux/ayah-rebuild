import 'package:flutter/material.dart';
import '../services/khatmah_service.dart';
import 'mushaf_screen.dart';

/// برنامج الختمة — المدد والكلمات من نصوص الأصل
class KhatmahScreen extends StatefulWidget {
  const KhatmahScreen({super.key});
  @override
  State<KhatmahScreen> createState() => _KhatmahScreenState();
}

class _KhatmahScreenState extends State<KhatmahScreen> {
  @override
  void initState() {
    super.initState();
    KhatmahService.load().then((_) { if (mounted) setState(() {}); });
  }

  @override
  Widget build(BuildContext context) {
    final st = KhatmahService.current;
    return Scaffold(
      appBar: AppBar(title: const Text('برنامج الختمة')),
      body: st == null ? _plans() : _active(st),
    );
  }

  Widget _plans() {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 10, right: 4),
          child: Text('اختر خطة الختمة', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        ),
        ...KhatmahService.plans.map((p) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                title: Text(p.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text(p.subtitle, style: const TextStyle(fontSize: 12)),
                trailing: const Icon(Icons.chevron_left, size: 18),
                onTap: () async {
                  await KhatmahService.start(p);
                  if (mounted) setState(() {});
                },
              ),
            )),
      ],
    );
  }

  Widget _active(KhatmahState st) {
    final (from, to) = st.dayRange(st.dayNumber);
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0B2A1C),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(st.plan.title, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text('اليوم ${st.dayNumber} من ${st.plan.days}',
                style: const TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: st.progress,
                minHeight: 8,
                backgroundColor: Colors.white24,
                color: const Color(0xFF7FD1A2),
              ),
            ),
            const SizedBox(height: 10),
            Text('الورد اليومي: صفحة $from إلى $to',
                style: const TextStyle(color: Colors.white, fontSize: 13)),
          ]),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: () async {
            await Navigator.push(context, MaterialPageRoute(builder: (_) => MushafScreen(initialPage: from)));
            if (mounted) setState(() {});
          },
          icon: const Icon(Icons.menu_book_rounded),
          label: const Text('قراءة ورد اليوم'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () async {
            await KhatmahService.completeDay();
            if (mounted) setState(() {});
          },
          icon: const Icon(Icons.check_circle_outline),
          label: const Text('أكملت هذا الورد'),
        ),
        const SizedBox(height: 16),
        Text('بدأت في ${st.startDate}', style: const TextStyle(fontSize: 11, color: Colors.black54)),
        const Divider(height: 26),
        ListTile(
          dense: true,
          leading: const Icon(Icons.refresh, size: 18),
          title: const Text('ختمة جديدة'),
          onTap: () async {
            await KhatmahService.clear();
            if (mounted) setState(() {});
          },
        ),
      ],
    );
  }
}
