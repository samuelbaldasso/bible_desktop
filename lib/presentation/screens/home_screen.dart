import 'package:flutter/material.dart';

import '../../domain/entities/bible_book.dart';
import '../../domain/entities/bible_chapter.dart';
import '../../domain/entities/verse.dart';
import '../../domain/usecases/get_bible_chapter.dart';

class HomeScreen extends StatefulWidget {
  final GetBibleChapter getBibleChapter;

  const HomeScreen({super.key, required this.getBibleChapter});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  static const books = bibleBooks;

  late BibleBook _selectedBook = books.first;
  int _selectedChapter = 1;
  String _query = '';
  late Future<BibleChapter> _chapterFuture = _loadChapter();

  Future<BibleChapter> _loadChapter() => widget.getBibleChapter(
    bookId: _selectedBook.id,
    bookName: _selectedBook.name,
    chapter: _selectedChapter,
  );

  List<BibleBook> get _filteredBooks {
    if (_query.trim().isEmpty) return books;
    final normalized = _query.trim().toLowerCase();
    return books
        .where((b) => b.name.toLowerCase().contains(normalized))
        .toList();
  }

  void _changeBook(BibleBook book) {
    setState(() {
      _selectedBook = book;
      _selectedChapter = 1;
      _chapterFuture = _loadChapter();
    });
  }

  void _changeChapter(int chapter) {
    setState(() {
      _selectedChapter = chapter;
      _chapterFuture = _loadChapter();
    });
  }

  void _stepChapter(int delta) {
    final next = _selectedChapter + delta;
    if (next < 1 || next > _selectedBook.chapters) return;
    _changeChapter(next);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          _buildSidebar(),
          const VerticalDivider(width: 1),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    final colorScheme = Theme.of(context).colorScheme;
    final filtered = _filteredBooks;
    final oldTestament = filtered.where((b) => b.isOldTestament).toList();
    final newTestament = filtered.where((b) => !b.isOldTestament).toList();

    return SizedBox(
      width: 300,
      child: ColoredBox(
        color: const Color(0xFFFDFCFA),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 26, 20, 18),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.menu_book_rounded,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bíblia',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                            height: 1.1,
                          ),
                        ),
                        Text(
                          'Almeida Revista e Corrigida',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF8A8578),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Buscar livro...',
                  hintStyle: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFFAFA99A),
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    size: 20,
                    color: Color(0xFFAFA99A),
                  ),
                  isDense: true,
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close_rounded, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                        ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 12),
                children: [
                  if (oldTestament.isNotEmpty)
                    _buildTestamentSection('ANTIGO TESTAMENTO', oldTestament),
                  if (newTestament.isNotEmpty)
                    _buildTestamentSection('NOVO TESTAMENTO', newTestament),
                  if (filtered.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 24,
                      ),
                      child: Text(
                        'Nenhum livro encontrado.',
                        style: TextStyle(color: Color(0xFF8A8578)),
                      ),
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
              child: Text(
                'CAPÍTULO ${_selectedChapter.toString()} de ${_selectedBook.chapters}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: Color(0xFF8A8578),
                ),
              ),
            ),
            SizedBox(
              height: 108,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: List.generate(_selectedBook.chapters, (i) {
                      final chapter = i + 1;
                      final selected = chapter == _selectedChapter;
                      return InkWell(
                        borderRadius: BorderRadius.circular(7),
                        onTap: () => _changeChapter(chapter),
                        child: Container(
                          width: 34,
                          height: 30,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: selected
                                ? colorScheme.primary
                                : const Color(0xFFF1EEE7),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Text(
                            '$chapter',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: selected
                                  ? Colors.white
                                  : const Color(0xFF3E3B33),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _selectedChapter > 1
                          ? () => _stepChapter(-1)
                          : null,
                      icon: const Icon(Icons.chevron_left_rounded, size: 18),
                      label: const Text('Anterior'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _selectedChapter < _selectedBook.chapters
                          ? () => _stepChapter(1)
                          : null,
                      icon: const Icon(Icons.chevron_right_rounded, size: 18),
                      label: const Text('Próximo'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestamentSection(String title, List<BibleBook> sectionBooks) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
              color: Color(0xFF8A8578),
            ),
          ),
        ),
        ...sectionBooks.map((book) {
          final selected = book.id == _selectedBook.id;
          return InkWell(
            onTap: () => _changeBook(book),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
              decoration: BoxDecoration(
                color: selected
                    ? colorScheme.primary.withValues(alpha: 0.10)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      book.name,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: selected
                            ? colorScheme.primary
                            : const Color(0xFF3E3B33),
                      ),
                    ),
                  ),
                  Text(
                    '${book.chapters}',
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFFAFA99A),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildContent() {
    return FutureBuilder<BibleChapter>(
      future: _chapterFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _buildError(snapshot.error);
        }
        if (!snapshot.hasData) {
          return const Center(child: Text('Nenhum capítulo encontrado.'));
        }
        return _buildChapter(snapshot.data!);
      },
    );
  }

  Widget _buildChapter(BibleChapter chapter) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.clamp(520.0, 820.0).toDouble();
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 40),
          child: Center(
            child: SizedBox(
              width: width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chapter.bookName.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.6,
                      color: Color(0xFF9C978A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Capítulo ${chapter.chapterNumber}',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Divider(height: 1),
                  const SizedBox(height: 30),
                  for (final verse in chapter.verses) _buildVerse(verse),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildVerse(Verse verse) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 19,
            height: 1.65,
            color: Color(0xFF2A2822),
            fontFamily: 'Georgia',
          ),
          children: [
            TextSpan(
              text: '${verse.number}  ',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                fontFamily: 'Roboto',
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            TextSpan(text: verse.text),
          ],
        ),
      ),
    );
  }

  Widget _buildError(Object? error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFF1EEE7),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                size: 40,
                color: Color(0xFF9C978A),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Não foi possível carregar o capítulo.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              error?.toString() ?? 'Erro desconhecido',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF8A8578)),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => setState(() => _chapterFuture = _loadChapter()),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}
