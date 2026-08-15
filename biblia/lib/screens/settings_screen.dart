import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Aparência', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                RadioListTile<ThemeMode>(
                  title: const Text('Claro'),
                  value: ThemeMode.light,
                  groupValue: settings.themeMode,
                  onChanged: (v) => settings.setThemeMode(v!),
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('Escuro'),
                  value: ThemeMode.dark,
                  groupValue: settings.themeMode,
                  onChanged: (v) => settings.setThemeMode(v!),
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('Seguir o sistema'),
                  value: ThemeMode.system,
                  groupValue: settings.themeMode,
                  onChanged: (v) => settings.setThemeMode(v!),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Tamanho da letra', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: AppFontSize.values.map((size) {
                return RadioListTile<AppFontSize>(
                  title: Text(size.label, style: TextStyle(fontSize: 16 * size.scale)),
                  value: size,
                  groupValue: settings.fontSize,
                  onChanged: (v) => settings.setFontSize(v!),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
