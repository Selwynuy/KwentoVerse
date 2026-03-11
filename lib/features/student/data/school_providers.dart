import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/supabase/supabase_providers.dart';
import 'school_repository.dart';

final schoolRepositoryProvider = Provider<SchoolRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SchoolRepository(client);
});
