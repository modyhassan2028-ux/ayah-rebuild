import 'package:just_audio/just_audio.dart';

/// نفس نمط الرابط المستخرج من كود التطبيق الأصلي:
/// https://audio.ayah.app/{reciterKey}/{surah:03d}-1.mp3
class AudioService {
  static final AudioService i = AudioService._();
  AudioService._();

  final AudioPlayer player = AudioPlayer();
  String? reciterKey;
  String? reciterName;
  int surah = 1;

  String urlFor(String key, int surah) =>
      'https://audio.ayah.app/$key/${surah.toString().padLeft(3, '0')}-1.mp3';

  Future<void> playSurah(String key, String name, int s) async {
    reciterKey = key;
    reciterName = name;
    surah = s;
    await player.setUrl(urlFor(key, s));
    player.play();
  }

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
