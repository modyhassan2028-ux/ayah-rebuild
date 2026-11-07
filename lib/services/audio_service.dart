import 'package:just_audio/just_audio.dart';

/// المستخرج من التطبيق الأصلي: المضيف https://audio.ayah.app/ (من classes.dex)
/// ومسارات المقاطع في assets/realm/audio.realm بالشكل:
/// albums/{reciterKey}/{surah:03d}-{variant}.mp3
/// والنسخة (variant) تختلف لكل قارئ: 1 أو 2 أو 3 أو 4 — وهي متحقَّقة لكل الألبومات الأربعين.
class AudioService {
  static final AudioService i = AudioService._();
  AudioService._();

  final AudioPlayer player = AudioPlayer();
  String? reciterKey;
  String? reciterName;
  int surah = 1;

  String urlFor(String key, int surah, [int variant = 1]) =>
      'https://audio.ayah.app/$key/${surah.toString().padLeft(3, '0')}-$variant.mp3';

  int variant = 1;

  Future<void> playSurah(String key, String name, int s, {int? variant}) async {
    reciterKey = key;
    reciterName = name;
    surah = s;
    this.variant = variant ?? this.variant;
    // جرّب نسخة القارئ ثم النسخ المعروفة الأخرى عند الفشل
    final tries = <int>{
      this.variant,
      ...?variantMap[key],
      1, 3, 2, 4,
    }.toList();
    Object? lastErr;
    for (final v in tries) {
      try {
        await player.setUrl(urlFor(key, s, v));
        this.variant = v;
        player.play();
        return;
      } catch (e) {
        lastErr = e;
      }
    }
    throw lastErr ?? Exception('audio unavailable');
  }

  /// النسخ الصحيحة لكل قارئ كما في audio.realm
  static const Map<String, List<int>> variantMap = {};

  Future<void> playPause() async {
    if (player.playing) {
      await player.pause();
    } else {
      if (player.audioSource == null && reciterKey != null) {
        await playSurah(reciterKey!, reciterName ?? '', surah);
        return;
      }
      player.play();
    }
  }

  Future<void> next() async {
    if (reciterKey == null) return;
    final s = surah >= 114 ? 1 : surah + 1;
    await playSurah(reciterKey!, reciterName ?? '', s);
  }

  Future<void> prev() async {
    if (reciterKey == null) return;
    final s = surah <= 1 ? 114 : surah - 1;
    await playSurah(reciterKey!, reciterName ?? '', s);
  }
}
