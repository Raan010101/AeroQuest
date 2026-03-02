import 'package:flutter/material.dart';
import '../services/learning_service.dart';
import 'quiz_screen_v2.dart';

class LessonDetailScreen extends StatefulWidget {
  final Map<String, dynamic> lesson;

  const LessonDetailScreen({super.key, required this.lesson});

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  final _service = LearningService();

  @override
  void initState() {
    super.initState();
    _service.upsertLessonProgress(
      lessonId: widget.lesson['id'],
      status: 'in_progress',
      progressPct: 10,
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.lesson['title'] ?? 'Lesson';
    final content = widget.lesson['content_md'] ?? '';
    final videoUrl = widget.lesson['video_url'] ?? '';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            if (videoUrl.toString().isNotEmpty)
              Text('Video: $videoUrl', style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 12),
            Text(content.toString()),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => QuizScreenV2(
                      lessonId: widget.lesson['id'],
                      lessonTitle: title,
                    ),
                  ),
                );
              },
              child: const Text('Start Quiz'),
            ),
          ],
        ),
      ),
    );
  }
}