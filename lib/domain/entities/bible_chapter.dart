import 'verse.dart';

class BibleChapter {
  final String bookId;
  final String bookName;
  final int chapterNumber;
  final List<Verse> verses;

  const BibleChapter({
    required this.bookId,
    required this.bookName,
    required this.chapterNumber,
    required this.verses,
  });
}
