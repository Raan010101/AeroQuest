import 'package:supabase_flutter/supabase_flutter.dart';

class LearningService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchModules() async {
    final res = await _supabase
        .from('modules')
        .select('id, code, title, description, order_no')
        .order('order_no', ascending: true);

    return (res as List).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> fetchLessons(String moduleId) async {
    final res = await _supabase
        .from('lessons')
        .select(
          'id, module_id, code, title, order_no, content_md, video_url, est_minutes',
        )
        .eq('module_id', moduleId)
        .order('order_no', ascending: true);

    return (res as List).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> fetchQuestions(String lessonId) async {
    final res = await _supabase
        .from('questions')
        .select(
          'id, lesson_id, module_id, difficulty, question_text, options, correct_answer, explanation',
        )
        .eq('lesson_id', lessonId);

    return (res as List).cast<Map<String, dynamic>>();
  }

  Future<void> upsertAttempt({
    required String questionId,
    required int selectedIndex,
    required String selectedValue,
    required bool isCorrect,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    final userId = user.id;

    await _supabase.from('attempts').upsert({
      'user_id': userId,
      'question_id': questionId,
      'selected_answer': {
        'index': selectedIndex,
        'value': selectedValue,
      },
      'is_correct': isCorrect,
      'answered_at': DateTime.now().toUtc().toIso8601String(),
    }, onConflict: 'user_id,question_id');
  }

  Future<void> upsertLessonProgress({
    required String lessonId,
    required String status, // not_started | in_progress | completed
    required int progressPct,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    final userId = user.id;

    await _supabase.from('lesson_progress').upsert({
      'user_id': userId,
      'lesson_id': lessonId,
      'status': status,
      'progress_pct': progressPct,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }, onConflict: 'user_id,lesson_id');
  }

  Future<Map<String, Map<String, dynamic>>> fetchProgressForLessons(
    List<String> lessonIds,
  ) async {
    if (lessonIds.isEmpty) return {};

    final res = await _supabase
        .from('lesson_progress')
        .select('lesson_id, status, progress_pct, updated_at')
        .inFilter('lesson_id', lessonIds);

    final list = (res as List).cast<Map<String, dynamic>>();
    return {for (final row in list) row['lesson_id'] as String: row};
  }
}