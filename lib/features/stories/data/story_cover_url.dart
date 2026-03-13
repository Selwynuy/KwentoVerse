import 'package:supabase_flutter/supabase_flutter.dart';

const _bucket = 'story-files';

/// Returns the public URL for a story cover stored in Supabase storage.
/// Use this instead of passing the raw storage path to [NetworkImage].
String storyCoverPublicUrl(SupabaseClient client, String storagePath) {
  return client.storage.from(_bucket).getPublicUrl(storagePath);
}
