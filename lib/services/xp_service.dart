import 'package:supabase_flutter/supabase_flutter.dart';

class XPService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> awardXP({
    required String userId,
    required int xpAmount,
    required String sourceType,
    String? sourceId,
  }) async {
    // 1️⃣ Insert into xp_events
    await _supabase.from('xp_events').insert({
      'user_id': userId,
      'source_type': sourceType,
      'source_id': sourceId,
      'xp': xpAmount,
    });

    // 2️⃣ Update profile total XP
    await _supabase.rpc('increment_xp', params: {
      'user_id_input': userId,
      'xp_amount_input': xpAmount,
    });
  }
}