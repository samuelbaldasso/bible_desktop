import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bible_desktop/domain/entities/bible_chapter.dart';
import 'package:bible_desktop/domain/entities/verse.dart';
import 'package:bible_desktop/domain/errors/bible_api_exception.dart';
import 'package:bible_desktop/domain/repositories/bible_repository.dart';
import 'package:bible_desktop/domain/usecases/get_bible_chapter.dart';
import 'package:bible_desktop/presentation/screens/home_screen.dart';

class _FakeBibleRepository implements BibleRepository {
  _FakeBibleRepository({this.errorToThrow});

  final Object? errorToThrow;

  @override
  Future<BibleChapter> getChapter({
    required String bookId,
    required String bookName,
    required int chapter,
  }) async {
    if (errorToThrow != null) throw errorToThrow!;
    return BibleChapter(
      bookId: bookId,
      bookName: bookName,
      chapterNumber: chapter,
      verses: const [
        Verse(number: 1, text: 'No princípio, criou Deus os céus e a terra.'),
        Verse(number: 2, text: 'E a terra era sem forma e vazia...'),
      ],
    );
  }
}

Widget _wrap(GetBibleChapter usecase) {
  return MaterialApp(home: HomeScreen(getBibleChapter: usecase));
}

void main() {
  group('HomeScreen', () {
    testWidgets('mostra o capítulo carregado e a lista de livros', (tester) async {
      final usecase = GetBibleChapter(_FakeBibleRepository());

      await tester.pumpWidget(_wrap(usecase));
      await tester.pumpAndSettle();

      expect(find.text('Gênesis'), findsOneWidget);
      expect(find.text('Capítulo 1'), findsOneWidget);
      expect(
        find.textContaining(
          'No princípio, criou Deus os céus e a terra.',
          findRichText: true,
        ),
        findsOneWidget,
      );
    });

    testWidgets('filtra a lista de livros pela busca', (tester) async {
      final usecase = GetBibleChapter(_FakeBibleRepository());

      await tester.pumpWidget(_wrap(usecase));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'joão');
      await tester.pumpAndSettle();

      expect(find.text('João'), findsOneWidget);
      expect(find.text('Gênesis'), findsNothing);
    });

    testWidgets('troca de capítulo ao tocar em "Próximo"', (tester) async {
      final usecase = GetBibleChapter(_FakeBibleRepository());

      await tester.pumpWidget(_wrap(usecase));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Próximo'));
      await tester.pumpAndSettle();

      expect(find.text('Capítulo 2'), findsOneWidget);
    });

    testWidgets('mostra estado de erro quando o carregamento falha', (tester) async {
      final usecase = GetBibleChapter(
        _FakeBibleRepository(errorToThrow: const BibleApiException('Falha de rede')),
      );

      await tester.pumpWidget(_wrap(usecase));
      await tester.pumpAndSettle();

      expect(find.text('Não foi possível carregar o capítulo.'), findsOneWidget);
      expect(find.textContaining('Falha de rede'), findsOneWidget);
    });
  });
}
