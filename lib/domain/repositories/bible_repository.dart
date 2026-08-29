import '../entities/bible_chapter.dart';

abstract class BibleRepository {
  Future<BibleChapter> getChapter({
    required String bookId,
    required String bookName,
    required int chapter,
  });
}
