import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/dictionary_term.dart';
import 'local_dictionary_repository.dart';

final localDictionaryRepositoryProvider = Provider<LocalDictionaryRepository>((ref) {
  return const LocalDictionaryRepository();
});

final dictionaryLookupProvider = Provider.family<DictionaryTerm?, String>((ref, token) {
  return ref.watch(localDictionaryRepositoryProvider).lookup(token);
});

