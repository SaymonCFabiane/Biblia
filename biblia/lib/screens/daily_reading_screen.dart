import 'package:flutter/material.dart';

import '../db/database_helper.dart';
import '../models/bible_models.dart';
import 'reading_screen.dart';

class DailyReadingScreen extends StatefulWidget {
  const DailyReadingScreen({super.key});

  @override
  State<DailyReadingScreen> createState() => _DailyReadingScreenState();
}

class _DailyReadingScreenState extends State<DailyReadingScreen> {
  late Future<ChapterRef?> _future;

  @override
  void initState() {
    super.initState();
    _future = DatabaseHelper.instance.getTodayReading();
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final dateLabel = _formatDatePtBr(today);

    return FutureBuilder<ChapterRef?>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final chapter = snapshot.data;
        if (chapter == null) {
          return const Center(child: Text('Não foi possível carregar a leitura de hoje.'));
        }

        return Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.wb_sunny, size: 56, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 16),
                Text(
                  _capitalize(dateLabel),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 24),
                Text(
                  'Leitura de hoje',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${chapter.bookLabel} ${chapter.chapter}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ReadingScreen(
                          bookId: chapter.bookId,
                          bookLabel: chapter.bookLabel,
                          chapter: chapter.chapter,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.menu_book),
                  label: const Text('Ler agora'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  static const _weekdays = [
    'segunda-feira',
    'terça-feira',
    'quarta-feira',
    'quinta-feira',
    'sexta-feira',
    'sábado',
    'domingo',
  ];

  static const _months = [
    'janeiro',
    'fevereiro',
    'março',
    'abril',
    'maio',
    'junho',
    'julho',
    'agosto',
    'setembro',
    'outubro',
    'novembro',
    'dezembro',
  ];

  String _formatDatePtBr(DateTime d) {
    final weekday = _weekdays[d.weekday - 1];
    final month = _months[d.month - 1];
    return '$weekday, ${d.day} de $month';
  }
}
