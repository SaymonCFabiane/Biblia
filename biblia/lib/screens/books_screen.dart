import 'package:flutter/material.dart';

import '../db/database_helper.dart';
import '../models/bible_models.dart';
import 'chapters_screen.dart';

class BooksScreen extends StatefulWidget {
  final int testamentId;
  final String testamentName;

  const BooksScreen({super.key, required this.testamentId, required this.testamentName});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  late Future<List<Book>> _future;

  @override
  void initState() {
    super.initState();
    _future = DatabaseHelper.instance.getBooksByTestament(widget.testamentId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.testamentName)),
      body: FutureBuilder<List<Book>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final books = snapshot.data ?? [];
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: books.length,
            itemBuilder: (context, i) {
              final b = books[i];
              return ListTile(
                title: Text(b.label, style: Theme.of(context).textTheme.bodyLarge),
                subtitle: b.hasContent
                    ? Text('${b.chapterCount} capítulo${b.chapterCount == 1 ? '' : 's'}')
                    : const Text('Conteúdo indisponível', style: TextStyle(fontStyle: FontStyle.italic)),
                trailing: b.hasContent ? const Icon(Icons.chevron_right) : null,
                enabled: b.hasContent,
                onTap: !b.hasContent
                    ? null
                    : () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ChaptersScreen(bookId: b.id, bookLabel: b.label, chapterCount: b.chapterCount),
                          ),
                        );
                      },
              );
            },
          );
        },
      ),
    );
  }
}
