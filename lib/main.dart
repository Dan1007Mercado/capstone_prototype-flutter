import 'package:flutter/material.dart';

import 'pages/landing/splash_landing.dart';
import 'theme/app_theme.dart';
import 'state/app_state.dart';

void main() {
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
