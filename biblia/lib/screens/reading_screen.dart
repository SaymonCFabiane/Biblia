import 'package:flutter/material.dart';

import '../db/database_helper.dart';
import '../models/bible_models.dart';

class ReadingScreen extends StatefulWidget {
  final int bookId;
  final String bookLabel;
  final int chapter;
  final int? highlightVerse;

  const ReadingScreen({
    super.key,
    required this.bookId,
    required this.bookLabel,
    required this.chapter,
    this.highlightVerse,
  });

  @override
  State<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen> {
  late int _chapter;
  late Future<List<Verse>> _future;
  List<int> _availableChapters = [];
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _chapter = widget.chapter;
    _load();
    DatabaseHelper.instance.getAvailableChapters(widget.bookId).then((c) {
      if (mounted) setState(() => _availableChapters = c);
    });
  }

  void _load() {
    _future = DatabaseHelper.instance.getChapterVerses(widget.bookId, _chapter);
  }

  void _goTo(int newChapter) {
    setState(() {
      _chapter = newChapter;
      _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final idx = _availableChapters.indexOf(_chapter);
    final hasPrev = idx > 0;
    final hasNext = idx >= 0 && idx < _availableChapters.length - 1;

    return Scaffold(
      appBar: AppBar(title: Text('${widget.bookLabel} $_chapter')),
      body: FutureBuilder<List<Verse>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final verses = snapshot.data ?? [];
          if (verses.isEmpty) {
            return const Center(child: Text('Conteúdo indisponível para este capítulo.'));
          }
          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(20),
            itemCount: verses.length,
            itemBuilder: (context, i) {
              final v = verses[i];
              final isHighlighted = widget.highlightVerse != null && v.verse == widget.highlightVerse;
              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: isHighlighted ? const EdgeInsets.all(10) : EdgeInsets.zero,
                decoration: isHighlighted
                    ? BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10),
                      )
                    : null,
                child: RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyLarge,
                    children: [
                      TextSpan(
                        text: '${v.verse}  ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      TextSpan(text: v.text),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: hasPrev ? () => _goTo(_availableChapters[idx - 1]) : null,
                icon: const Icon(Icons.chevron_left),
                label: const Text('Anterior'),
              ),
              TextButton(
                onPressed: hasNext ? () => _goTo(_availableChapters[idx + 1]) : null,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Próximo'),
                    Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
