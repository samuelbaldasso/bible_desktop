import 'package:flutter_test/flutter_test.dart';

import 'package:bible_desktop/domain/entities/bible_chapter.dart';
import 'package:bible_desktop/domain/entities/verse.dart';
import 'package:bible_desktop/domain/errors/bible_api_exception.dart';
import 'package:bible_desktop/domain/repositories/bible_repository.dart';
import 'package:bible_desktop/domain/usecases/get_bible_chapter.dart';

class _FakeBibleRepository implements BibleRepository {
  _FakeBibleRepository({this.chapterToReturn, this.errorToThrow});

  final BibleChapter? chapterToReturn;
  final Object? errorToThrow;

  String? lastBookId;
  String? lastBookName;
  int? lastChapter;

  @override
  Future<BibleChapter> getChapter({
    required String bookId,
    required String bookName,
    required int chapter,
  }) async {
    lastBookId = bookId;
    lastBookName = bookName;
    lastChapter = chapter;

    if (errorToThrow != null) throw errorToThrow!;
    return chapterToReturn!;
  }
}

void main() {
  group('GetBibleChapter', () {
    test('delega os parâmetros recebidos para o repositório', () async {
      final chapter = const BibleChapter(
        bookId: 'jo',
        bookName: 'João',
        chapterNumber: 3,
        verses: [Verse(number: 1, text: 'Havia um homem...')],
      );
      final repository = _FakeBibleRepository(chapterToReturn: chapter);
      final usecase = GetBibleChapter(repository);

      final result = await usecase(
        bookId: 'jo',
        bookName: 'João',
        chapter: 3,
      );

      expect(result, same(chapter));
      expect(repository.lastBookId, 'jo');
      expect(repository.lastBookName, 'João');
      expect(repository.lastChapter, 3);
    });

    test('propaga exceções lançadas pelo repositório', () async {
      final repository = _FakeBibleRepository(
        errorToThrow: const BibleApiException('falha'),
      );
      final usecase = GetBibleChapter(repository);

      expect(
        () => usecase(bookId: 'gn', bookName: 'Gênesis', chapter: 1),
        throwsA(isA<BibleApiException>()),
      );
    });
  });
}
