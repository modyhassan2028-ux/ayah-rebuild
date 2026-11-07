import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/quran_data.dart';

/// خطة الختمة — أسماء المدد من نصوص التطبيق الأصلي (by_quarters_* / by_meanings_*)
class KhatmahPlan {
  final String id;
  final String unit; // pages | quarters
  final int days;
  final String title;
  final String subtitle;
  const KhatmahPlan(this.id, this.unit, this.days, this.title, this.subtitle);

  int get total => unit == 'quarters' ? 240 : QuranData.totalPages;

  int pagesFor(int units) => unit == 'quarters'
      ? (units * QuranData.totalPages / 240).round().clamp(1, QuranData.totalPages)
      : units.clamp(1, QuranData.totalPages);
}

class KhatmahState {
  final KhatmahPlan plan;
  final String startDate;
  final int doneDays;
  const KhatmahState(this.plan, this.startDate, this.doneDays);

  int get dayNumber => (doneDays + 1).clamp(1, plan.days);

  /// حدود ورد اليوم بالصفحات
  (int, int) dayRange(int day) {
    final per = plan.total / plan.days;
    final fromUnit = ((day - 1) * per).ceil();
    final toUnit = (day * per).floor();
    return (plan.pagesFor(fromUnit), plan.pagesFor(toUnit == 0 ? 1 : toUnit));
  }

  double get progress => (doneDays / plan.days).clamp(0, 1);
}

class KhatmahService {
  static const _k = 'khatmah_state';

  static KhatmahState? get current => _cached;

  static KhatmahState? _cached;
  static bool _ready = false;

  static Future<void> load() async {
    if (_ready) return;
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_k);
    if (raw != null) {
      try {
        final m = json.decode(raw) as Map<String, dynamic>;
        final plan = KhatmahService.plans.firstWhere((x) => x.id == m['id']);
        _cached = KhatmahState(plan, m['start'] as String, m['done'] as int);
      } catch (_) {}
    }
    _ready = true;
  }

  static Future<void> start(KhatmahPlan plan) async {
    final p = await SharedPreferences.getInstance();
    final st = KhatmahState(plan, DateTime.now().toIso8601String().substring(0, 10), 0);
    _cached = st;
    await p.setString(_k, json.encode({'id': plan.id, 'start': st.startDate, 'done': 0}));
  }

  static Future<void> completeDay() async {
    final st = _cached;
    if (st == null) return;
    final done = (st.doneDays + 1).clamp(0, st.plan.days);
    _cached = KhatmahState(st.plan, st.startDate, done);
    final p = await SharedPreferences.getInstance();
    await p.setString(_k, json.encode({'id': st.plan.id, 'start': st.startDate, 'done': done}));
  }

  static Future<void> clear() async {
    _cached = null;
    final p = await SharedPreferences.getInstance();
    await p.remove(_k);
  }

  static List<KhatmahPlan> plans = const [
    KhatmahPlan('quarters_3', 'quarters', 3, 'ختمة ٣ أيام', 'الورد اليومي: ١٠ أجزاء'),
    KhatmahPlan('quarters_6', 'quarters', 6, 'ختمة ٦ أيام', 'الورد اليومي: ٥ أجزاء'),
    KhatmahPlan('quarters_10', 'quarters', 10, 'ختمة ١٠ أيام', 'الورد اليومي: ٣ أجزاء'),
    KhatmahPlan('quarters_15', 'quarters', 15, 'ختمة ١٥ يومًا', 'الورد اليومي: جزآن'),
    KhatmahPlan('quarters_20', 'quarters', 20, 'ختمة ٢٠ يومًا', 'الورد اليومي: جزء ونصف'),
    KhatmahPlan('quarters_30', 'quarters', 30, 'ختمة ٣٠ يومًا', 'الورد اليومي: جزء'),
    KhatmahPlan('quarter_40', 'quarters', 40, 'ختمة ٤٠ يومًا', 'الورد اليومي: حزب ونصف'),
    KhatmahPlan('quarter_60', 'quarters', 60, 'ختمة ٦٠ يومًا', 'الورد اليومي: حزب'),
    KhatmahPlan('quarter_80', 'quarters', 80, 'ختمة ٨٠ يومًا', 'الورد اليومي: ٣ أرباع'),
    KhatmahPlan('quarter_120', 'quarters', 120, 'ختمة ١٢٠ يومًا', 'الورد اليومي: ربعان'),
    KhatmahPlan('quarter_240', 'quarters', 240, 'ختمة ٢٤٠ يومًا', 'الورد اليومي: ربع'),
    KhatmahPlan('meanings_7', 'pages', 7, 'ختمة أسبوع (٧ أيام)', 'الورد اليومي: ٥ أجزاء تقريبًا'),
    KhatmahPlan('meanings_29', 'pages', 29, 'ختمة شهر (٢٩ يومًا)', 'الورد اليومي: ٢١ صفحة تقريبًا'),
    KhatmahPlan('meanings_60', 'pages', 60, 'ختمة شهرين (٦٠ يومًا)', 'الورد اليومي: ١٠ صفحات تقريبًا'),
  ];
}
