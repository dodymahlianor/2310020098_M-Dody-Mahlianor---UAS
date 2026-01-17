import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'state/app_settings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final settings = AppSettings();
  await settings.load(); // load qari + theme dari SharedPreferences

  runApp(
    ChangeNotifierProvider.value(
      value: settings,
      child: const EquranApp(),
    ),
  );
}
