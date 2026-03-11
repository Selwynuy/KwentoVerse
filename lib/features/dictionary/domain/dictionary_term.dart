class DictionaryTerm {
  const DictionaryTerm({
    required this.word,
    required this.meaning,
    this.pronunciation,
    this.example,
  });

  final String word;
  final String meaning;
  final String? pronunciation;
  final String? example;
}

