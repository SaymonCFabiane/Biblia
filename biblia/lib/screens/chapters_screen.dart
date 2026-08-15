import 'package:flutter/material.dart';

import '../db/database_helper.dart';
import 'reading_screen.dart';

class ChaptersScreen extends StatefulWidget {
  final int bookId;
  final String bookLabel;
  final int chapterCount;

  const ChaptersScreen({
    super.key,
    required this.bookId,
    required this.bookLabel,
    required this.chapterCount,
  });

  @override
  State<ChaptersScreen> createState() => _ChaptersScreenState();
}

class _ChaptersScreenState extends State<ChaptersScreen> {
  late Future<List<int>> _future;

  @override
  void initState() {
    super.initState();
    _future = DatabaseHelper.instance.getAvailableChapters(widget.bookId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.bookLabel)),
      body: FutureBuilder<List<int>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final chapters = snapshot.data ?? [];
          if (chapters.isEmpty) {
            return const Center(child: Text('Nenhum capítulo disponível para este livro.'));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.3,
            ),
            itemCount: chapters.length,
            itemBuilder: (context, i) {
              final chapter = chapters[i];
              return FilledButton.tonal(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ReadingScreen(
                        bookId: widget.bookId,
                        bookLabel: widget.bookLabel,
                        chapter: chapter,
                      ),
                    ),
                  );
                },
                child: Text('$chapter', style: const TextStyle(fontSize: 18)),
              );
            },
          );
        },
      ),
    );
  }
}
