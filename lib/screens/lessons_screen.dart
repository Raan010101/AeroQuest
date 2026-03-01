import 'package:flutter/material.dart';
import '../services/learning_service.dart';
import 'lesson_detail_screen.dart';

class LessonsScreen extends StatefulWidget {
  final String moduleId;
  final String moduleTitle;

  const LessonsScreen({
    super.key,
    required this.moduleId,
    required this.moduleTitle,
  });

  @override
  State<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen> {
  final _service = LearningService();
  late Future<List<Map<String, dynamic>>> _lessonsFuture;

  @override
  void initState() {
    super.initState();
    _lessonsFuture = _service.fetchLessons(widget.moduleId);
  }

  Future<Map<String, Map<String, dynamic>>> _loadProgress(
    List<Map<String, dynamic>> lessons,
  ) async {
    final ids = lessons.map((l) => l['id'] as String).toList();
    return _service.fetchProgressForLessons(ids);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.moduleTitle)),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _lessonsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final lessons = snapshot.data!;
          if (lessons.isEmpty) {
            return const Center(child: Text('No lessons found.'));
          }

          return FutureBuilder<Map<String, Map<String, dynamic>>>(
            future: _loadProgress(lessons),
            builder: (context, progressSnap) {
              final progressMap = progressSnap.data ?? {};

              return ListView.separated(
                itemCount: lessons.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final l = lessons[index];
                  final p = progressMap[l['id']] ?? {};
                  final pct = (p['progress_pct'] ?? 0) as int;

                  return ListTile(
                    title: Text(l['title'] ?? ''),
                    subtitle: Text('Progress: $pct%'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LessonDetailScreen(lesson: l),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}