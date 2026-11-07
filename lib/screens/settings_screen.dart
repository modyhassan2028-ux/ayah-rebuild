import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../services/backup_service.dart';
import 'package:share_plus/share_plus.dart';
import '../services/backup_service.dart';
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
          ListTile(
            leading: const Icon(Icons.backup_outlined),
            title: const Text('إنشاء نسخة احتياطية'),
            subtitle: const Text('العلامات والملاحظات والتقدّم في ملف JSON'),
            onTap: () async {
              final path = await BackupService.writeFile();
              await Share.shareXFiles([XFile(path)], text: 'نسخة احتياطية من Ayah');
            },
          ),
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('استرجاع من نسخة احتياطية'),
            subtitle: const Text('اختر ملف JSON سبق تصديره'),
            onTap: () async {
              final clip = await Clipboard.getData('text/plain');
              final c = TextEditingController(text: clip?.text ?? '');
              if (!mounted) return;
              final ok = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('استرجاع من نسخة'),
                  content: TextField(
                    controller: c,
                    maxLines: 6,
                    decoration: const InputDecoration(hintText: 'الصق مسار ملف النسخة أو محتوى JSON'),
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
                    FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('استرجاع')),
                  ],
                ),
              );
              if (ok != true) return;
              final txt = c.text.trim();
              int n;
              try {
                n = txt.startsWith('{')
                    ? await BackupService.restoreJson(txt)
                    : await BackupService.restoreFromPath(txt);
              } catch (_) {
                n = -1;
              }
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(n < 0 ? 'الملف غير صالح' : 'تم استرجاع $n ملاحظة والعلامات')));
            },
          ),
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
