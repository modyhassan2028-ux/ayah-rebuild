import 'package:flutter/material.dart';
import '../services/storage.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('الوضع الداكن'),
            value: Storage.darkMode,
            onChanged: (v) async {
              await Storage.setDark(v);
              setState(() {});
            },
          ),
          ListTile(
            title: const Text('إعادة ضبط تقدّم القراءة'),
            trailing: const Icon(Icons.refresh, size: 18),
            onTap: () async {
              await Storage.setLastPage(1);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تمت إعادة الضبط إلى الصفحة الأولى')),
                );
              }
            },
          ),
          const Divider(),
          const ListTile(title: Text('عن التطبيق')),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: Text(
              'نسخة مبنية من كود وأصول تطبيق Ayah (com.ayah 7.8.2).\n'
              'المصحف: 604 صفحة × 15 سطرًا بصور التطبيق الأصلية.\n'
              'التفسير: «المختصر في التفسير» من قاعدة بيانات التطبيق.\n'
              'فهرس السور والآيات من جدول bookEntry الأصلي.',
              style: TextStyle(fontSize: 12.5, height: 1.9),
            ),
          ),
        ],
      ),
    );
  }
}
