import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/errors/bible_api_exception.dart';

/// Dados brutos de um capítulo, ainda no formato da API.
class RawChapter {
  final List<String> verseTexts;

  const RawChapter(this.verseTexts);
}

class BibleRemoteDataSource {
  static const String _baseUrl =
      'https://raw.githubusercontent.com/MaatheusGois/bible/main';

  final http.Client client;

  BibleRemoteDataSource({http.Client? client}) : client = client ?? http.Client();

  Future<RawChapter> fetchChapter({
    required String bookId,
    required String bookName,
    required int chapter,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/versions/pt-br/arc/$bookId/$bookId.json',
    );

    final response = await client.get(uri);

    if (response.statusCode != 200) {
      throw BibleApiException(
        'Erro ao consultar a API: HTTP ${response.statusCode}',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const BibleApiException('Resposta inválida recebida da API.');
    }

    final chapters = decoded['chapters'];
    if (chapters is! List) {
      throw const BibleApiException('A resposta não contém capítulos válidos.');
    }

    final index = chapter - 1;
    if (index < 0 || index >= chapters.length) {
      throw BibleApiException('O capítulo $chapter não existe em $bookName.');
    }

    final rawChapter = chapters[index];
    if (rawChapter is! List) {
      throw const BibleApiException('Formato de capítulo inválido.');
    }

    final verseTexts = <String>[
      for (final value in rawChapter)
        if (value is String) value,
    ];

    return RawChapter(verseTexts);
  }

  void dispose() => client.close();
}
