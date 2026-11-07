import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/quran_data.dart';

/// مشاركة — شاشة share_modal.xml من الأصل: من/إلى، صيغة المشاركة، شارة آية، ثم مشاركة.
class ShareScreen extends StatefulWidget {
  final int initialPage;
  const ShareScreen({super.key, this.initialPage = 1});
  @override
  State<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends State<ShareScreen> {
  late int _from;
  late int _to;
  int _format = 1; // 0 صورة · 1 نص · 2 نص بدون تشكيل
  bool _badge = true;

  @override
  void initState() {
    super.initState();
    final p = widget.initialPage.clamp(1, QuranData.totalPages);
    _from = p;
    _to = p;
  }

  String get _payload {
    final a = QuranData.surahOfPage(_from);
    final b = QuranData.surahOfPage(_to);
    final range = _from == _to ? 'صفحة $_from' : 'الصفحات $_from — $_to';
    final buf = StringBuffer();
    buf.writeln('سورة ${a.name}${_from == _to ? '' : ' إلى سورة ${b.name}'} — $range');
    if (_format == 0) {
      buf.writeln('(مشاركة صورة الصفحة: افتح المصحف على الصفحة $_from ثم زر المشاركة)');
    }
    if (_badge) {
      buf.writeln();
      buf.writeln('بواسطة تطبيق آية');
    }
    return buf.toString().trim();
  }

  Future<void> _share() async {
    await Clipboard.setData(ClipboardData(text: _payload));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('تم نسخ النص — الصقه في أي تطبيق للمشاركة'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('مشاركة')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          Row(
            children: [
              Expanded(child: _picker('من', _from, (v) => setState(() => _from = v))),
              const SizedBox(width: 12),
              Expanded(child: _picker('إلى', _to, (v) => setState(() => _to = v))),
            ],
          ),
          const SizedBox(height: 18),
          RadioListTile<int>(
            value: 0,
            groupValue: _format,
            onChanged: (v) => setState(() => _format = v!),
            title: const Text('مشاركة صورة'),
            contentPadding: EdgeInsets.zero,
          ),
          RadioListTile<int>(
            value: 1,
            groupValue: _format,
            onChanged: (v) => setState(() => _format = v!),
            title: const Text('مشاركة نص'),
            contentPadding: EdgeInsets.zero,
          ),
          RadioListTile<int>(
            value: 2,
            groupValue: _format,
            onChanged: (v) => setState(() => _format = v!),
            title: const Text('نص بدون تشكيل'),
            contentPadding: EdgeInsets.zero,
          ),
          const Divider(height: 28),
          SwitchListTile(
            value: _badge,
            onChanged: (v) => setState(() => _badge = v),
            contentPadding: EdgeInsets.zero,
            title: const Text('إضافة "بواسطة تطبيق آية"'),
            subtitle: const Text('ساعدنا في نشر التطبيق.',
                style: TextStyle(fontSize: 12, color: Color(0xFF6B5A4B))),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEDE3D6)),
            ),
            child: SelectableText(_payload,
                style: const TextStyle(fontSize: 13, height: 1.8)),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _share,
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF007330), minimumSize: const Size.fromHeight(48)),
            child: const Text('مشاركة'),
          ),
        ],
      ),
    );
  }

  Widget _picker(String label, int value, ValueChanged<int> onChanged) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12.5, color: Color(0xFF6B5A4B))),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE0D2BF)),
            ),
            child: DropdownButton<int>(
              value: value,
              isExpanded: true,
              underline: const SizedBox.shrink(),
              items: List.generate(
                QuranData.totalPages,
                (i) => DropdownMenuItem(
                  value: i + 1,
                  child: Text('${i + 1} · ${QuranData.surahOfPage(i + 1).name}',
                      style: const TextStyle(fontSize: 12.5), overflow: TextOverflow.ellipsis),
                ),
              ),
              onChanged: (v) => v == null ? null : onChanged(v),
            ),
          ),
        ],
      );
}
