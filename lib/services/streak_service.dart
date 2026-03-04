import 'package:supabase_flutter/supabase_flutter.dart';
import 'xp_service.dart';

class StreakService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final XPService _xpService = XPService();

  Future<Map<String, dynamic>> getOrCreateTodayStreak(String userId) async {
    final today = DateTime.now().toUtc().toIso8601String().split("T").first;

    // 1️⃣ Check if streak exists
    final existing = await _supabase
        .from('daily_streaks')
        .select('*, questions(*)')
        .eq('user_id', userId)
        .eq('streak_date', today)
        .maybeSingle();

    if (existing != null) {
      return existing;
    }

    // 2️⃣ Pick random published question
    final questions = await _supabase
        .from('questions')
        .select()
        .eq('is_published', true);

    if ((questions as List).isEmpty) {
      throw Exception("No questions available");
    }

    questions.shuffle();
    final randomQuestion = questions.first;

    // 3️⃣ Insert streak row
    final inserted = await _supabase.from('daily_streaks').insert({
      'user_id': userId,
      'streak_date': today,
      'question_id': randomQuestion['id'],
    }).select('*, questions(*)').single();

    return inserted;
  }

  Future<void> completeStreak({
    required String userId,
    required String streakId,
    required bool isCorrect,
  }) async {
    int xpEarned = isCorrect ? 5 : 0;

    await _supabase.from('daily_streaks').update({
      'is_correct': isCorrect,
      'xp_earned': xpEarned,
      'completed_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', streakId);

    if (isCorrect) {
      await _xpService.awardXP(
        userId: userId,
        xpAmount: 5,
        sourceType: 'streak',
        sourceId: streakId,
      );

      await _supabase.rpc('increment_streak', params: {
        'user_id_input': userId,
      });
    }
  }
}