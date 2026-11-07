import 'package:flutter/material.dart';
import '../services/reminders_service.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});
  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  final Map<int, bool> _on = {};
  final Map<int, TimeOfDay> _t = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    for (final d in RemindersService.defs) {
      final on = await RemindersService.isOn(d.id);
      final (h, m) = await RemindersService.timeOf(d);
      _on[d.id] = on;
      _t[d.id] = TimeOfDay(hour: h, minute: m);
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('التذكيرات')),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: RemindersService.defs.map((d) {
          final on = _on[d.id] ?? false;
          final t = _t[d.id] ?? TimeOfDay(hour: d.defaultHour, minute: d.defaultMinute);
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
            child: Column(children: [
              SwitchListTile(
                title: Text(d.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text(d.fridayOnly ? 'كل جمعة · ${t.format(context)}' : 'كل يوم · ${t.format(context)}',
                    style: const TextStyle(fontSize: 12)),
                value: on,
                onChanged: (v) async {
                  setState(() => _on[d.id] = v);
                  await RemindersService.set(d.id, v, t.hour, t.minute);
                },
              ),
              if (on)
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton.icon(
                    icon: const Icon(Icons.access_time, size: 18),
                    label: Text('تغيير الوقت (${t.format(context)})'),
                    onPressed: () async {
                      final picked = await showTimePicker(context: context, initialTime: t);
                      if (picked != null) {
                        setState(() => _t[d.id] = picked);
                        await RemindersService.set(d.id, true, picked.hour, picked.minute);
                      }
                    },
                  ),
                ),
            ]),
          );
        }).toList(),
      ),
    );
  }
}
