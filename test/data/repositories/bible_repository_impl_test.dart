import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:bible_desktop/data/datasources/bible_remote_data_source.dart';
import 'package:bible_desktop/data/repositories/bible_repository_impl.dart';
import 'package:bible_desktop/domain/errors/bible_api_exception.dart';

void main() {
  group('BibleRepositoryImpl', () {
    test('traduz o capítulo bruto em BibleChapter com Verse numeradas a partir de 1', () async {
      final client = MockClient(
        (request) async => http.Response(
          jsonEncode({
            'chapters': [
              ['primeiro versículo', 'segundo versículo', 'terceiro versículo'],
            ],
          }),
          200,
        ),
      );
      final repository = BibleRepositoryImpl(BibleRemoteDataSource(client: client));

      final chapter = await repository.getChapter(
        bookId: 'gn',
        bookName: 'Gênesis',
        chapter: 1,
      );

      expect(chapter.bookId, 'gn');
      expect(chapter.bookName, 'Gênesis');
      expect(chapter.chapterNumber, 1);
      expect(chapter.verses, hasLength(3));
      expect(chapter.verses[0].number, 1);
      expect(chapter.verses[0].text, 'primeiro versículo');
      expect(chapter.verses[2].number, 3);
      expect(chapter.verses[2].text, 'terceiro versículo');
    });

    test('propaga BibleApiException lançada pela fonte de dados', () async {
      final client = MockClient((request) async => http.Response('erro', 404));
      final repository = BibleRepositoryImpl(BibleRemoteDataSource(client: client));

      expect(
        () => repository.getChapter(bookId: 'gn', bookName: 'Gênesis', chapter: 1),
        throwsA(isA<BibleApiException>()),
      );
    });
  });
}
