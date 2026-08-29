import '../entities/bible_chapter.dart';
import '../repositories/bible_repository.dart';

class GetBibleChapter {
  final BibleRepository repository;

  const GetBibleChapter(this.repository);

  Future<BibleChapter> call({
    required String bookId,
    required String bookName,
    required int chapter,
  }) {
    return repository.getChapter(
      bookId: bookId,
      bookName: bookName,
      chapter: chapter,
    );
  }
}
