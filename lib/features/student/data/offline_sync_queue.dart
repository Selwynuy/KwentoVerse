import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Simple offline write queue stored in SharedPreferences.
/// Each entry is a {type, payload} map. Call [flush] when connectivity returns.
class OfflineSyncQueue {
  OfflineSyncQueue._();
  static final OfflineSyncQueue instance = OfflineSyncQueue._();

  static const _key = 'offline_sync_queue_v1';

  Future<void> enqueue(String type, Map<String, dynamic> payload) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_key);
    final list = existing != null
        ? (jsonDecode(existing) as List).cast<Map<String, dynamic>>()
        : <Map<String, dynamic>>[];
    list.add({'type': type, 'payload': payload});
    await prefs.setString(_key, jsonEncode(list));
  }

  Future<List<Map<String, dynamic>>> drain() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_key);
    if (existing == null) return const [];
    final list = (jsonDecode(existing) as List).cast<Map<String, dynamic>>();
    await prefs.remove(_key);
    return list;
  }

  Future<bool> hasItems() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_key);
    if (existing == null) return false;
    final list = jsonDecode(existing) as List;
    return list.isNotEmpty;
  }
}
