import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// التذكيرات — نفس الأنواع الثلاثة في الأصل: آية اليوم، سورة الكهف، الورد اليومي
class ReminderDef {
  final int id;
  final String title;
  final bool fridayOnly;
  final int defaultHour;
  final int defaultMinute;
  const ReminderDef(this.id, this.title, {this.fridayOnly = false, this.defaultHour = 8, this.defaultMinute = 0});
}

class RemindersService {
  static final plugin = FlutterLocalNotificationsPlugin();
  static bool _init = false;

  static const defs = [
    ReminderDef(201, 'آية اليوم', defaultHour: 8),
    ReminderDef(202, 'سورة الكهف', fridayOnly: true, defaultHour: 9),
    ReminderDef(203, 'الورد اليومي', defaultHour: 21),
  ];

  static Future<void> init() async {
    if (_init) return;
    tzdata.initializeTimeZones();
    // ضبط المنطقة الزمنية المحلية من إزاحة الجهاز الحالية
    try {
      final off = DateTime.now().timeZoneOffset;
      final zones = <String>['Africa/Cairo', 'Asia/Riyadh', 'UTC'];
      var found = false;
      for (final n in zones) {
        if (tz.TZDateTime.now(tz.getLocation(n)).timeZoneOffset == off) {
          tz.setLocalLocation(tz.getLocation(n));
          found = true;
          break;
        }
      }
      if (!found && zones.isNotEmpty) tz.setLocalLocation(tz.getLocation('Africa/Cairo'));
    } catch (_) {}
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await plugin.initialize(const InitializationSettings(android: android));
    await plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    _init = true;
  }

  static Future<bool> isOn(int id) async {
    final p = await SharedPreferences.getInstance();
    return p.getBool('rem_${id}_on') ?? false;
  }

  static Future<(int, int)> timeOf(ReminderDef d) async {
    final p = await SharedPreferences.getInstance();
    return (p.getInt('rem_${d.id}_h') ?? d.defaultHour, p.getInt('rem_${d.id}_m') ?? d.defaultMinute);
  }

  static NotificationDetails get _details => const NotificationDetails(
        android: AndroidNotificationDetails('ayah_reminders', 'التذكيرات',
            channelDescription: 'تذكيرات القراءة اليومية', importance: Importance.high, priority: Priority.high),
      );

  static Future<void> set(int id, bool on, int hour, int minute) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool('rem_${id}_on', on);
    await p.setInt('rem_${id}_h', hour);
    await p.setInt('rem_${id}_m', minute);
    await plugin.cancel(id);
    if (!on) return;
    final def = defs.firstWhere((x) => x.id == id);
    final now = tz.TZDateTime.now(tz.local);
    var when = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (when.isBefore(now)) when = when.add(const Duration(days: 1));
    if (def.fridayOnly) {
      while (when.weekday != DateTime.friday) {
        when = when.add(const Duration(days: 1));
      }
    }
    await plugin.zonedSchedule(
      id,
      'Ayah',
      def.fridayOnly ? 'حان وقت قراءة سورة الكهف' : 'حان وقت ${def.title}',
      when,
      _details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: def.fridayOnly ? DateTimeComponents.dayOfWeekAndTime : DateTimeComponents.time,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
