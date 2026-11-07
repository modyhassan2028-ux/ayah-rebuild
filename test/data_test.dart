import 'package:flutter_test/flutter_test.dart';
import 'package:ayah_rebuild/data/quran_data.dart';
import 'package:ayah_rebuild/services/khatmah_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async => QuranData.load());

  test('فهرس السور: 114 سورة وأول صفحة للفاتحة', () {
    expect(QuranData.surahs.length, 114);
    expect(QuranData.surahs.first.name.contains('الفاتحة'), isTrue);
    expect(QuranData.surahOfPage(1).n, 1);
    expect(QuranData.surahOfPage(604).n, 114);
  });

  test('البحث يرجّح السورة المطلوبة', () {
    final r = QuranData.search('الكهف');
    expect(r.length, 1);
    expect(r.first.n, 18);
    expect(QuranData.search('').length, 114);
  });

  test('توزيع ورد الختمة يغطي المصحف كاملًا', () {
    for (final plan in KhatmahService.plans) {
      var last = 0;
      for (var d = 1; d <= plan.days; d++) {
        final (from, to) = KhatmahState(plan, '2026-01-01', d - 1).dayRange(d);
        expect(from, lessThanOrEqualTo(to));
        expect(from, greaterThanOrEqualTo(last));
        last = to;
      }
      expect(last, greaterThanOrEqualTo(QuranData.totalPages - plan.days));
    }
  });
}
