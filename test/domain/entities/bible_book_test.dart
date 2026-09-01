import 'package:flutter_test/flutter_test.dart';

import 'package:bible_desktop/domain/entities/bible_book.dart';

void main() {
  group('bibleBooks catalog', () {
    test('contém os 66 livros canônicos', () {
      expect(bibleBooks.length, 66);
    });

    test('possui ids únicos', () {
      final ids = bibleBooks.map((b) => b.id).toSet();
      expect(ids.length, bibleBooks.length);
    });

    test('todos os livros têm ao menos 1 capítulo', () {
      expect(bibleBooks.every((b) => b.chapters > 0), isTrue);
    });

    test('Antigo Testamento tem 39 livros e Novo Testamento 27', () {
      final old = bibleBooks.where((b) => b.isOldTestament).length;
      final newT = bibleBooks.where((b) => !b.isOldTestament).length;
      expect(old, 39);
      expect(newT, 27);
    });

    test('Gênesis é o primeiro livro e Apocalipse o último', () {
      expect(bibleBooks.first.id, 'gn');
      expect(bibleBooks.last.id, 're');
    });
  });
}
