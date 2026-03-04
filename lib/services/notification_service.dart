import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> createNotification({
    required String userId,
    required String type,
    required String title,
    String? body,
    String? refTable,
    String? refId,
  }) async {
    await _supabase.from('notifications').insert({
      'user_id': userId,
      'type': type,
      'title': title,
      'body': body,
      'ref_table': refTable,
      'ref_id': refId,
    });
  }
}