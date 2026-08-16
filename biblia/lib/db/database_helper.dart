import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../../../models/bible_models.dart';

/// Versão do banco embutido nos assets. Se você atualizar o arquivo
/// assets/db/biblia.db, incremente este número para forçar a recópia
/// no dispositivo do usuário (senão ele continua usando a cópia antiga).
const int kEmbeddedDbVersion = 1;

class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final dbPath = join(documentsDir.path, 'biblia_v$kEmbeddedDbVersion.db');
    final dbFile = File(dbPath);

    if (!await dbFile.exists()) {
      // Copia o banco pré-populado dos assets para o armazenamento do app.
      final data = await rootBundle.load('assets/db/biblia.db');
      final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await dbFile.writeAsBytes(bytes, flush: true);
    }

    return openDatabase(dbPath, readOnly: false);
  }

  // ---------- Testamentos / Livros ----------

  Future<List<Testament>> getTestaments() async {
    final db = await database;
    final rows = await db.query('testament', orderBy: 'id');
    return rows.map((r) => Testament.fromMap(r)).toList();
  }

  Future<List<Book>> getBooksByTestament(int testamentId) async {
    final db = await database;
    final rows = await db.query(
      'books',
      where: 'testament = ?',
      whereArgs: [testamentId],
      orderBy: 'book_order',
    );
    return rows.map((r) => Book.fromMap(r)).toList();
  }

  Future<Book?> getBook(int bookId) async {
    final db = await database;
    final rows = await db.query('books', where: 'id = ?', whereArgs: [bookId]);
    if (rows.isEmpty) return null;
    return Book.fromMap(rows.first);
  }

  // ---------- Versículos ----------

  Future<List<Verse>> getChapterVerses(int bookId, int chapter) async {
    final db = await database;
    final rows = await db.query(
      'verses',
      where: 'book = ? AND chapter = ?',
      whereArgs: [bookId, chapter],
      orderBy: 'verse',
    );
    return rows.map((r) => Verse.fromMap(r)).toList();
  }

  /// Lista de capítulos que realmente têm conteúdo para um livro
  /// (alguns livros do dump de origem estão sem versículos).
  Future<List<int>> getAvailableChapters(int bookId) async {
    final db = await database;
    final rows = await db.rawQuery(
      'SELECT DISTINCT chapter FROM verses WHERE book = ? ORDER BY chapter',
      [bookId],
    );
    return rows.map((r) => r['chapter'] as int).toList();
  }

  // ---------- Busca ----------

  Future<List<Verse>> searchVerses(String query, {int limit = 100}) async {
    if (query.trim().isEmpty) return [];
    final db = await database;

    // Full-text search (rápido) via FTS4; cai para LIKE se o termo for muito curto.
    final ftsQuery = query.trim().split(RegExp(r'\s+')).map((w) => '$w*').join(' ');
    List<Map<String, dynamic>> rows;
    try {
      rows = await db.rawQuery(
        '''
        SELECT v.id, v.book, v.chapter, v.verse, v.text, b.label
        FROM verses_fts f
        JOIN verses v ON v.id = f.rowid
        JOIN books b ON b.id = v.book
        WHERE f.text MATCH ?
        ORDER BY b.book_order, v.chapter, v.verse
        LIMIT ?
        ''',
        [ftsQuery, limit],
      );
    } catch (_) {
      rows = [];
    }

    if (rows.isEmpty) {
      // fallback simples por LIKE (cobre termos muito curtos ou com acentuação parcial)
      rows = await db.rawQuery(
        '''
        SELECT v.id, v.book, v.chapter, v.verse, v.text, b.label
        FROM verses v
        JOIN books b ON b.id = v.book
        WHERE v.text LIKE ?
        ORDER BY b.book_order, v.chapter, v.verse
        LIMIT ?
        ''',
        ['%${query.trim()}%', limit],
      );
    }

    return rows.map((r) => Verse.fromMap(r)).toList();
  }

  // ---------- Leitura do dia ----------

  /// Retorna a lista ordenada (ordem canônica da bíblia) de todos os
  /// capítulos que possuem conteúdo. Usada para montar o plano de leitura.
  Future<List<ChapterRef>> getAllAvailableChapters() async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT DISTINCT v.book AS book_id, b.label AS label, v.chapter AS chapter, b.book_order AS book_order
      FROM verses v
      JOIN books b ON b.id = v.book
      ORDER BY b.book_order, v.chapter
    ''');
    return rows
        .map((r) => ChapterRef(
              bookId: r['book_id'] as int,
              bookLabel: r['label'] as String,
              chapter: r['chapter'] as int,
            ))
        .toList();
  }

  /// Escolhe o capítulo do dia de forma determinística: todo mundo que abrir
  /// o app no mesmo dia vê a mesma leitura, e o plano avança um capítulo por
  /// dia, percorrendo a bíblia inteira em ordem e recomeçando ao terminar.
  ///
  /// Isto NÃO é o Lecionário oficial da Igreja (a leitura específica do dia,
  /// com ciclo A/B/C aos domingos e I/II nos dias de semana) — essa tabela
  /// não está no banco local e não dá pra deduzir a partir dos versículos.
  /// Por isso a tela chama isto de "leitura sugerida". Veja
  /// lib/liturgical/lectionary_provider.dart para o porquê e para o ponto de
  /// extensão preparado pra plugar uma fonte real do Lecionário no futuro.
  Future<ChapterRef?> getTodayReading() async {
    final chapters = await getAllAvailableChapters();
    if (chapters.isEmpty) return null;
    final epochDay = DateTime.now().toUtc().millisecondsSinceEpoch ~/ (1000 * 60 * 60 * 24);
    final index = epochDay % chapters.length;
    return chapters[index];
  }
}
