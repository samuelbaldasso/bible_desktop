import '../../domain/entities/bible_chapter.dart';
import '../../domain/entities/verse.dart';
import '../../domain/repositories/bible_repository.dart';
import '../datasources/bible_remote_data_source.dart';

class BibleRepositoryImpl implements BibleRepository {
  final BibleRemoteDataSource remoteDataSource;

  const BibleRepositoryImpl(this.remoteDataSource);

  @override
  Future<BibleChapter> getChapter({
    required String bookId,
    required String bookName,
    required int chapter,
  }) async {
    final raw = await remoteDataSource.fetchChapter(
      bookId: bookId,
      bookName: bookName,
      chapter: chapter,
    );

    final verses = <Verse>[
      for (var i = 0; i < raw.verseTexts.length; i++)
        Verse(number: i + 1, text: raw.verseTexts[i]),
    ];

    return BibleChapter(
      bookId: bookId,
      bookName: bookName,
      chapterNumber: chapter,
      verses: verses,
    );
  }
}
