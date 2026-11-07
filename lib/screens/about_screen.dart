import 'package:flutter/material.dart';

/// عن تطبيق آية — شاشة about من الأصل (about.xml / AboutActivity).
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('عن تطبيق آية')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          Center(
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Image.asset('assets/images/ic_launcher.png', width: 88, height: 88),
                ),
                const SizedBox(height: 12),
                const Text('آية',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                const Text('الإصدار 7.8.2',
                    style: TextStyle(fontSize: 12.5, color: Color(0xFF6B5A4B))),
              ],
            ),
          ),
          const SizedBox(height: 22),
          _row(Icons.menu_book_rounded, 'المصحف',
              '٦٠٤ صفحة من مصحف المدينة بخط واضح، مع فهرس السور والأجزاء.'),
          _row(Icons.translate_rounded, 'التفسير',
              'تفسير المختصر في ٦٠٥ صفحة، مربوطًا بكل صفحة من المصحف.'),
          _row(Icons.headphones_rounded, 'الاستماع',
              '٤٠ قارئًا بترتيب السور، تشغيل متصل دون تنزيل.'),
          _row(Icons.track_changes_rounded, 'الختمة',
              '١٤ برنامج ختمة (بالأجزاء وبالمعاني) مع ورد يومي وحفظ تلقائي.'),
          _row(Icons.bookmark_rounded, 'العلامات والمفضلة والملاحظات',
              'ثلاث قوائم مستقلة، كل واحدة تُفتح على الصفحة التي أضفتها منها.'),
          const SizedBox(height: 18),
          const Text(
            'بُني هذا الإصدار من منابع التطبيق الأصلية: بيانات المصحف والتفسير وقائمة القراء '
            'وأسماء الإعدادات كما هي في النسخة 7.8.2.',
            style: TextStyle(fontSize: 12.5, color: Color(0xFF6B5A4B), height: 1.8),
          ),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String title, String body) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEDE3D6)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFF007330), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(body,
                      style: const TextStyle(
                          fontSize: 12.5, color: Color(0xFF6B5A4B), height: 1.7)),
                ],
              ),
            ),
          ],
        ),
      );
}
