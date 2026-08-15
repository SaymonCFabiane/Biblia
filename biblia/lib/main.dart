import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/settings_provider.dart';
import 'screens/home_shell.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => SettingsProvider(),
      child: const BibliaApp(),
    ),
  );
}

class BibliaApp extends StatelessWidget {
  const BibliaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    const seedColor = Color(0xFF5B3A29); // marrom terroso, remete a couro/páginas antigas

    final lightTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: seedColor, brightness: Brightness.light),
      textTheme: _buildTextTheme(ThemeData.light().textTheme, settings.fontSize.scale),
      appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
    );

    final darkTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: seedColor, brightness: Brightness.dark),
      textTheme: _buildTextTheme(ThemeData.dark().textTheme, settings.fontSize.scale),
      appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
    );

    return MaterialApp(
      title: 'Bíblia',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: settings.themeMode,
      home: const HomeShell(),
    );
  }

  TextTheme _buildTextTheme(TextTheme base, double scale) {
    return base.copyWith(
      bodyLarge: base.bodyLarge?.copyWith(fontSize: (base.bodyLarge?.fontSize ?? 16) * scale, height: 1.5),
      bodyMedium: base.bodyMedium?.copyWith(fontSize: (base.bodyMedium?.fontSize ?? 14) * scale, height: 1.5),
      titleLarge: base.titleLarge?.copyWith(fontSize: (base.titleLarge?.fontSize ?? 22) * scale),
      titleMedium: base.titleMedium?.copyWith(fontSize: (base.titleMedium?.fontSize ?? 18) * scale),
      headlineSmall: base.headlineSmall?.copyWith(fontSize: (base.headlineSmall?.fontSize ?? 24) * scale),
    );
  }
}
