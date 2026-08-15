import 'dart:async';

import 'package:flutter/material.dart';

import '../db/database_helper.dart';
import '../models/bible_models.dart';
import 'reading_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  List<Verse> _results = [];
  bool _loading = false;
  bool _searched = false;
  Timer? _debounce;

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () => _runSearch(value));
  }

  Future<void> _runSearch(String value) async {
    final query = value.trim();
    if (query.length < 2) {
      setState(() {
        _results = [];
        _searched = false;
      });
      return;
    }
    setState(() => _loading = true);
    final results = await DatabaseHelper.instance.searchVerses(query);
    if (!mounted) return;
    setState(() {
      _results = results;
      _loading = false;
      _searched = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _controller,
            onChanged: _onChanged,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Buscar palavra ou trecho...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              suffixIcon: _controller.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _controller.clear();
                        setState(() {
                          _results = [];
                          _searched = false;
                        });
                      },
                    ),
            ),
          ),
        ),
        if (_loading) const LinearProgressIndicator(),
        Expanded(
          child: !_searched
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(
                      'Digite ao menos 2 letras para buscar em toda a bíblia.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : _results.isEmpty && !_loading
                  ? const Center(child: Text('Nenhum resultado encontrado.'))
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _results.length,
                      separatorBuilder: (_, __) => const Divider(height: 24),
                      itemBuilder: (context, i) {
                        final v = _results[i];
                        return InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ReadingScreen(
                                  bookId: v.bookId,
                                  bookLabel: v.bookLabel ?? '',
                                  chapter: v.chapter,
                                  highlightVerse: v.verse,
                                ),
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                v.reference,
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      color: Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(v.text, style: Theme.of(context).textTheme.bodyMedium),
                            ],
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
