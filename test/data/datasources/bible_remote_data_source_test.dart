import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:bible_desktop/data/datasources/bible_remote_data_source.dart';
import 'package:bible_desktop/domain/errors/bible_api_exception.dart';

void main() {
  group('BibleRemoteDataSource', () {
    test('retorna os versículos do capítulo quando a API responde 200', () async {
      final client = MockClient((request) async {
        expect(
          request.url.toString(),
          'https://raw.githubusercontent.com/MaatheusGois/bible/main/versions/pt-br/arc/jo/jo.json',
        );
        return http.Response(
          jsonEncode({
            'chapters': [
              ['No princípio era o Verbo...', 'E o Verbo estava com Deus...'],
              ['Havia um homem...'],
            ],
          }),
          200,
        );
      });
      final dataSource = BibleRemoteDataSource(client: client);

      final result = await dataSource.fetchChapter(
        bookId: 'jo',
        bookName: 'João',
        chapter: 1,
      );

      expect(result.verseTexts, [
        'No princípio era o Verbo...',
        'E o Verbo estava com Deus...',
      ]);
    });

    test('lança BibleApiException quando o status HTTP não é 200', () async {
      final client = MockClient((request) async => http.Response('erro', 500));
      final dataSource = BibleRemoteDataSource(client: client);

      expect(
        () => dataSource.fetchChapter(bookId: 'jo', bookName: 'João', chapter: 1),
        throwsA(isA<BibleApiException>()),
      );
    });

    test('lança BibleApiException quando o corpo não é um mapa JSON', () async {
      final client = MockClient((request) async => http.Response(jsonEncode([1, 2, 3]), 200));
      final dataSource = BibleRemoteDataSource(client: client);

      expect(
        () => dataSource.fetchChapter(bookId: 'jo', bookName: 'João', chapter: 1),
        throwsA(isA<BibleApiException>()),
      );
    });

    test('lança BibleApiException quando "chapters" não é uma lista', () async {
      final client = MockClient(
        (request) async => http.Response(jsonEncode({'chapters': 'invalido'}), 200),
      );
      final dataSource = BibleRemoteDataSource(client: client);

      expect(
        () => dataSource.fetchChapter(bookId: 'jo', bookName: 'João', chapter: 1),
        throwsA(isA<BibleApiException>()),
      );
    });

    test('lança BibleApiException quando o capítulo pedido não existe', () async {
      final client = MockClient(
        (request) async => http.Response(
          jsonEncode({
            'chapters': [
              ['único capítulo'],
            ],
          }),
          200,
        ),
      );
      final dataSource = BibleRemoteDataSource(client: client);

      expect(
        () => dataSource.fetchChapter(bookId: 'jd', bookName: 'Judas', chapter: 2),
        throwsA(isA<BibleApiException>()),
      );
    });

    test('lança BibleApiException quando o capítulo bruto não é uma lista', () async {
      final client = MockClient(
        (request) async => http.Response(
          jsonEncode({
            'chapters': ['não é uma lista'],
          }),
          200,
        ),
      );
      final dataSource = BibleRemoteDataSource(client: client);

      expect(
        () => dataSource.fetchChapter(bookId: 'jd', bookName: 'Judas', chapter: 1),
        throwsA(isA<BibleApiException>()),
      );
    });

    test('ignora valores não-string dentro da lista de versículos', () async {
      final client = MockClient(
        (request) async => http.Response(
          jsonEncode({
            'chapters': [
              ['versículo válido', 42, null, 'outro versículo'],
            ],
          }),
          200,
        ),
      );
      final dataSource = BibleRemoteDataSource(client: client);

      final result = await dataSource.fetchChapter(
        bookId: 'jd',
        bookName: 'Judas',
        chapter: 1,
      );

      expect(result.verseTexts, ['versículo válido', 'outro versículo']);
    });
  });
}
