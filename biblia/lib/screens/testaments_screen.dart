import 'package:flutter/material.dart';

import '../db/database_helper.dart';
import '../models/bible_models.dart';
import 'books_screen.dart';

class TestamentsScreen extends StatefulWidget {
  const TestamentsScreen({super.key});

  @override
  State<TestamentsScreen> createState() => _TestamentsScreenState();
}

class _TestamentsScreenState extends State<TestamentsScreen> {
  late Future<List<Testament>> _future;

  @override
  void initState() {
    super.initState();
    _future = DatabaseHelper.instance.getTestaments();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Testament>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final testaments = snapshot.data ?? [];
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: testaments.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final t = testaments[i];
            return Card(
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                leading: Icon(
                  t.id == 1 ? Icons.auto_stories_outlined : Icons.menu_book_outlined,
                  size: 32,
                ),
                title: Text(t.name, style: Theme.of(context).textTheme.titleMedium),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BooksScreen(testamentId: t.id, testamentName: t.name),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
