import '../domain/dictionary_term.dart';

class LocalDictionaryRepository {
  const LocalDictionaryRepository();

  DictionaryTerm? lookup(String rawToken) {
    final key = normalizeToken(rawToken);
    if (key.isEmpty) return null;
    return _terms[key];
  }
}

String normalizeToken(String token) {
  final lower = token.toLowerCase().trim();
  // Keep letters + apostrophes (for we're), drop other punctuation.
  final cleaned = lower.replaceAll(RegExp(r"[^a-z']+"), '');
  return cleaned;
}

const _terms = <String, DictionaryTerm>{
  'trail': DictionaryTerm(
    word: 'trail',
    pronunciation: '/trāl/',
    meaning: 'A path or track made by the passage of people or animals.',
    example: 'We stayed on the trail until the trees opened to a clearing.',
  ),
  'narrator': DictionaryTerm(
    word: 'narrator',
    pronunciation: '/ˈnarˌādər/',
    meaning: 'A person who tells a story, especially in a book or movie.',
    example: 'The narrator describes what the characters cannot see.',
  ),
  'pebbles': DictionaryTerm(
    word: 'pebbles',
    pronunciation: '/ˈpebəlz/',
    meaning: 'Small smooth stones.',
    example: 'He filled his pockets with pebbles from the river.',
  ),
};

