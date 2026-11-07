import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'data/quran_data.dart';
import 'services/storage.dart';
import 'screens/app_shell.dart';

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
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: base,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFEF9F1),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF2E9DD),
          foregroundColor: Color(0xFF4D3322),
          surfaceTintColor: Colors.transparent,
          elevation: 2,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1F6E43), brightness: Brightness.dark),
        useMaterial3: true,
      ),
      themeMode: _dark ? ThemeMode.dark : ThemeMode.light,
      home: const AppShell(),
    );
  }
}
