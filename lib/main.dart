import 'package:flutter/material.dart';

import 'package:capstone_prototype/pages/landing/splash_landing.dart';
import 'package:capstone_prototype/theme/app_theme.dart';
import 'package:capstone_prototype/state/app_state.dart';

import 'package:capstone_prototype/services/firebase_analytics_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseAnalyticsService().initialize();
  runApp(const TalaanScanApp());
}

class TalaanScanApp extends StatefulWidget {
  const TalaanScanApp({super.key});

  @override
  State<TalaanScanApp> createState() => _TalaanScanAppState();
}

class _TalaanScanAppState extends State<TalaanScanApp> {
  late final AppState _appState = AppState();

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      notifier: _appState,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'TalaanScan',
        theme: buildAppTheme(Brightness.light),
        darkTheme: buildAppTheme(Brightness.dark),
        themeMode: ThemeMode.system,
        home: const SplashLanding(),
      ),
    );
  }
}
