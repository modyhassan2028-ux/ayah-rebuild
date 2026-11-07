import 'package:flutter/material.dart';
import 'data/quran_data.dart';
import 'services/storage.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Storage.init();
  await QuranData.load();
  runApp(const AyahApp());
}

class AyahApp extends StatefulWidget {
  const AyahApp({super.key});
  @override
  State<AyahApp> createState() => _AyahAppState();
}

class _AyahAppState extends State<AyahApp> {
  bool _dark = false;

  @override
  void initState() {
    super.initState();
    _dark = Storage.darkMode;
  }

  @override
  Widget build(BuildContext context) {
    final base = ColorScheme.fromSeed(seedColor: const Color(0xFF1F6E43));
    return MaterialApp(
      title: 'Ayah',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: base,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F6F2),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFFF7F6F2), surfaceTintColor: Colors.transparent),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1F6E43), brightness: Brightness.dark),
        useMaterial3: true,
      ),
      themeMode: _dark ? ThemeMode.dark : ThemeMode.light,
      home: const HomeScreen(),
    );
  }
}
