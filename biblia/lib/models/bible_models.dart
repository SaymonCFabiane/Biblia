class Testament {
  final int id;
  final String name;

  Testament({required this.id, required this.name});

  factory Testament.fromMap(Map<String, dynamic> map) {
    return Testament(id: map['id'] as int, name: map['name'] as String);
  }
}

class Book {
  final int id;
  final String label;
  final String searchName;
  final int testamentId;
  final int chapterCount;
  final int order;

  Book({
    required this.id,
    required this.label,
    required this.searchName,
    required this.testamentId,
    required this.chapterCount,
    required this.order,
  });

  bool get hasContent => chapterCount > 0;

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'] as int,
      label: map['label'] as String,
      searchName: (map['search_name'] ?? '') as String,
      testamentId: map['testament'] as int,
      chapterCount: (map['chapter_count'] ?? 0) as int,
      order: (map['book_order'] ?? 0) as int,
    );
  }
}

class Verse {
  final int id;
  final int bookId;
  final int chapter;
  final int verse;
  final String text;
  final String? bookLabel; // preenchido quando vem de um JOIN (ex: busca)

  Verse({
    required this.id,
    required this.bookId,
    required this.chapter,
    required this.verse,
    required this.text,
    this.bookLabel,
  });

  factory Verse.fromMap(Map<String, dynamic> map) {
    return Verse(
      id: map['id'] as int,
      bookId: map['book'] as int,
      chapter: map['chapter'] as int,
      verse: map['verse'] as int,
      text: map['text'] as String,
      bookLabel: map['label'] as String?,
    );
  }

  String get reference => '${bookLabel ?? ''} $chapter:$verse'.trim();
}

/// Representa uma referência simples (livro + capítulo), usada na leitura do dia.
class ChapterRef {
  final int bookId;
  final String bookLabel;
  final int chapter;

  ChapterRef({
    required this.bookId,
    required this.bookLabel,
    required this.chapter,
  });
}
