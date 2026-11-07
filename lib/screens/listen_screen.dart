import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/quran_data.dart';
import '../services/audio_service.dart';
import 'package:just_audio/just_audio.dart';

/// الاستماع — قرّاء التطبيق الأصلي (من audio.realm) وتلاوة 114 سورة
class ListenScreen extends StatefulWidget {
  const ListenScreen({super.key});
  @override
  State<ListenScreen> createState() => _ListenScreenState();
}

class _ListenScreenState extends State<ListenScreen> {
  List<Map<String, String>> _reciters = [];
  Map<String, String>? _sel;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final raw = await rootBundle.loadString('assets/data/reciters.json');
    final m = json.decode(raw) as Map<String, dynamic>;
    setState(() => _reciters =
        (m['reciters'] as List).map((e) => (e as Map).cast<String, String>()).toList());
  }

  Future<void> _pickSurah() async {
    final s = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (_) => ListView(
        children: QuranData.surahs
            .map((x) => ListTile(
                  dense: true,
                  leading: Text('${x.n}', style: const TextStyle(fontSize: 12)),
                  title: Text(x.name),
                  onTap: () => Navigator.pop(context, x.n),
                ))
            .toList(),
      ),
    );
    if (s != null) {
      await AudioService.i.playSurah(_sel!['key']!, _sel!['name']!, s);
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الاستماع')),
      body: _sel == null
          ? ListView(
              children: _reciters
                  .map((r) => ListTile(
                        leading: const CircleAvatar(
                          radius: 16,
                          backgroundColor: Color(0xFFEAF5EE),
                          child: Icon(Icons.record_voice_over, size: 16, color: Color(0xFF1F6E43)),
                        ),
                        title: Text(r['name']!),
                        subtitle: Text(r['key']!, style: const TextStyle(fontSize: 11)),
                        onTap: () => setState(() => _sel = r),
                      ))
                  .toList(),
            )
          : Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(14),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(children: [
                    const Icon(Icons.person_outline),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_sel!['name']!, style: const TextStyle(fontWeight: FontWeight.w700))),
                    TextButton(
                      onPressed: () => setState(() => _sel = null),
                      child: const Text('تغيير'),
                    ),
                  ]),
                ),
                Expanded(
                  child: ListView(
                    children: QuranData.surahs
                        .map((x) => ListTile(
                              dense: true,
                              leading: Text('${x.n}', style: const TextStyle(fontSize: 12)),
                              title: Text(x.name),
                              trailing: const Icon(Icons.play_arrow, size: 18),
                              onTap: () => AudioService.i
                                  .playSurah(_sel!['key']!, _sel!['name']!, x.n)
                                  .then((_) { if (mounted) setState(() {}); }),
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: _sel == null
          ? null
          : StreamBuilder<PlayerState>(
              stream: AudioService.i.player.playerStateStream,
              builder: (c, snap) {
                final p = snap.data;
                return StreamBuilder<Duration?>(
                  stream: AudioService.i.player.durationStream,
                  builder: (c2, ds) => StreamBuilder<Duration>(
                    stream: AudioService.i.player.positionStream,
                    builder: (c3, ps) {
                      final dur = ds.data ?? Duration.zero;
                      final pos = ps.data ?? Duration.zero;
                      return SafeArea(
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                          color: const Color(0xFF0B2A1C),
                          child: Column(mainAxisSize: MainAxisSize.min, children: [
                            Row(children: [
                              const Icon(Icons.headphones, color: Colors.white70, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${AudioService.i.reciterName ?? ''} · سورة ${QuranData.surahs[AudioService.i.surah - 1].name}',
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.skip_next, color: Colors.white),
                                onPressed: () => AudioService.i.next().then((_) { if (mounted) setState(() {}); }),
                              ),
                              IconButton(
                                icon: Icon(p?.playing == true ? Icons.pause_circle : Icons.play_circle,
                                    color: Colors.white, size: 34),
                                onPressed: () => AudioService.i.playPause().then((_) { if (mounted) setState(() {}); }),
                              ),
                              IconButton(
                                icon: const Icon(Icons.skip_previous, color: Colors.white),
                                onPressed: () => AudioService.i.prev().then((_) { if (mounted) setState(() {}); }),
                              ),
                            ]),
                            Slider(
                              value: pos.inMilliseconds.toDouble(),
                              max: dur.inMilliseconds > 0 ? dur.inMilliseconds.toDouble() : 1,
                              onChanged: (v) => AudioService.i.player.seek(Duration(milliseconds: v.toInt())),
                            ),
                          ]),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
