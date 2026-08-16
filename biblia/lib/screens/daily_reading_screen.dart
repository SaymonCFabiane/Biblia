import 'package:flutter/material.dart';

import '../db/database_helper.dart';
import '../liturgical/liturgical_calendar.dart';
import '../models/bible_models.dart';
import 'reading_screen.dart';

class DailyReadingScreen extends StatefulWidget {
  const DailyReadingScreen({super.key});

  @override
  State<DailyReadingScreen> createState() => _DailyReadingScreenState();
}

class _DailyReadingScreenState extends State<DailyReadingScreen> {
  late Future<ChapterRef?> _future;
  late final LiturgicalDay _liturgicalDay;

  @override
  void initState() {
    super.initState();
    // O capítulo em si continua vindo da rotação sequencial simples (ver
    // DatabaseHelper.getTodayReading) — não temos o Lecionário oficial da
    // Igreja no banco local (veja lib/liturgical/lectionary_provider.dart).
    // O calendário litúrgico só entra aqui pra exibição (tempo, semana, cor).
    _future = DatabaseHelper.instance.getTodayReading();
    _liturgicalDay = LiturgicalDay.forDate(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final dateLabel = _formatDatePtBr(today);
    final accentColor = _colorFor(_liturgicalDay.color);

    return Column(
      children: [
        Container(height: 5, color: accentColor),
        Expanded(
          child: FutureBuilder<ChapterRef?>(
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
                        _liturgicalDay.displayName,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _capitalize(dateLabel),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 24),
                      // "Leitura sugerida", não a leitura oficial do Lecionário:
                      // veja a nota em initState() e em lectionary_provider.dart.
                      Text(
                        'Leitura sugerida',
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
          ),
        ),
      ],
    );
  }

  // Cores meramente decorativas (faixa fina no topo) — nunca usadas como cor
  // de texto, então não afetam contraste em modo escuro/fonte grande. O
  // branco litúrgico vira dourado aqui porque branco puro é invisível sobre
  // fundo claro.
  Color _colorFor(LiturgicalColor color) {
    switch (color) {
      case LiturgicalColor.roxo:
        return const Color(0xFF6A4C93);
      case LiturgicalColor.branco:
        return const Color(0xFFC9A227);
      case LiturgicalColor.verde:
        return const Color(0xFF2E7D32);
      case LiturgicalColor.vermelho:
        return const Color(0xFFC62828);
      case LiturgicalColor.rosa:
        return const Color(0xFFD81B8C);
    }
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
