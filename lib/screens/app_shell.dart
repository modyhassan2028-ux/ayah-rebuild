import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'khatmah_screen.dart';
import 'bookmarks_screen.dart';
import 'favorites_screen.dart';
import 'notes_screen.dart';
import 'today_screen.dart';
import 'listen_screen.dart';
import 'reminders_screen.dart';
import 'settings_screen.dart';
import 'about_screen.dart';

/// الهيكل كما في الأصل: درج جانبي + شريط سفلي بخمسة تبويبات
/// (الفهرس · الختمة · العلامات · المفضلة · الملاحظات) — من res/menu/bottom_navigation.xml
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  static final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  /// أي شاشة تفتح درج الهيكل من زر القائمة
  static void openDrawer() => scaffoldKey.currentState?.openEndDrawer();

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _i = 0;

  static const _bar = Color(0xFFF2E9DD);
  static const _tint = Color(0xFF007330);
  static const _text = Color(0xFF4D3322);

  final _pages = const [
    HomeScreen(),
    KhatmahScreen(),
    BookmarksScreen(),
    FavoritesScreen(),
    NotesScreen(),
  ];

  final _titles = const ['الفهرس', 'الختمة', 'العلامات', 'المفضلة', 'الملاحظات'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: AppShell.scaffoldKey,
      endDrawer: _drawer(),
      body: IndexedStack(index: _i, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _i,
        onTap: (v) => setState(() => _i = v),
        type: BottomNavigationBarType.fixed,
        backgroundColor: _bar,
        selectedItemColor: _tint,
        unselectedItemColor: _text,
        selectedFontSize: 11.5,
        unselectedFontSize: 11.5,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list_alt_rounded), label: 'الفهرس'),
          BottomNavigationBarItem(icon: Icon(Icons.track_changes_rounded), label: 'الختمة'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark_border_rounded), label: 'العلامات'),
          BottomNavigationBarItem(icon: Icon(Icons.star_border_rounded), label: 'المفضلة'),
          BottomNavigationBarItem(icon: Icon(Icons.sticky_note_2_outlined), label: 'الملاحظات'),
        ],
      ),
    );
  }

  Widget _drawer() {
    void go(Widget page) {
      Navigator.pop(context);
      Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    }

    return Drawer(
      backgroundColor: const Color(0xFFF5EFE9),
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
              color: const Color(0xFFF2E9DD),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset('assets/images/ic_launcher.png', width: 54, height: 54),
                  ),
                  const SizedBox(height: 10),
                  const Text('آية',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w800, color: _text)),
                  const Text('مصحف وتفسير وتلاوة',
                      style: TextStyle(fontSize: 12, color: Color(0xFF6B5A4B))),
                ],
              ),
            ),
            const SizedBox(height: 6),
            _tile(Icons.wb_sunny_outlined, 'اليوم', () => go(const TodayScreen())),
            _tile(Icons.headphones_rounded, 'الاستماع للقراء', () => go(const ListenScreen())),
            _tile(Icons.alarm_rounded, 'التذكيرات', () => go(const RemindersScreen())),
            _tile(Icons.settings_outlined, 'الإعدادات', () => go(const SettingsScreen())),
            _tile(Icons.info_outline_rounded, 'عن تطبيق آية', () => go(const AboutScreen())),
            const Spacer(),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('الإصدار 7.8.2',
                  style: TextStyle(fontSize: 11.5, color: Color(0xFF9C8B7B))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile(IconData icon, String label, VoidCallback onTap) => ListTile(
        leading: Icon(icon, color: _tint, size: 21),
        title: Text(label, style: const TextStyle(fontSize: 14, color: _text)),
        onTap: onTap,
      );
}
