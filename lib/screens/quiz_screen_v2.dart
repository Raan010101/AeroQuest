import 'package:flutter/material.dart';
import '../services/learning_service.dart';

class QuizScreenV2 extends StatefulWidget {
  final String lessonId;
  final String lessonTitle;

  const QuizScreenV2({
    super.key,
    required this.lessonId,
    required this.lessonTitle,
  });

  @override
  State<QuizScreenV2> createState() => _QuizScreenV2State();
}

class _QuizScreenV2State extends State<QuizScreenV2> {
  final _service = LearningService();
  late Future<List<Map<String, dynamic>>> _questionsFuture;

  int _current = 0;
  int _correctCount = 0;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _questionsFuture = _service.fetchQuestions(widget.lessonId);
  }


  Future<void> _answer(
  Map<String, dynamic> q,
  int selectedIndex,
  String selectedValue,
  int total,
) async {
  if (_saving) return;
  setState(() => _saving = true);

  try {
    final correct = (q['correct_answer'] as Map<String, dynamic>);
    final correctIndex = (correct['index'] as int);
    final isCorrect = selectedIndex == correctIndex;

    await _service.upsertAttempt(
      questionId: q['id'] as String,
      selectedIndex: selectedIndex,
      selectedValue: selectedValue,
      isCorrect: isCorrect,
    );

    if (!mounted) return;

    setState(() {
      if (isCorrect) _correctCount++;
      _current++;
    });

    if (_current >= total) {
      await _finish(total);
    }
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to save attempt: $e')),
    );
  } finally {
    if (mounted) setState(() => _saving = false);
  }
}

  Future<void> _finish(int total) async {
    final scorePct = total == 0 ? 0 : ((_correctCount / total) * 100).round();

    await _service.upsertLessonProgress(
      lessonId: widget.lessonId,
      status: 'completed',
      progressPct: scorePct,
    );

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Quiz Completed'),
        content: Text('Score: $scorePct% ($_correctCount/$total)'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // dialog
              Navigator.pop(context); // quiz screen
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quiz: ${widget.lessonTitle}')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _questionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final questions = snapshot.data ?? [];
          if (questions.isEmpty) {
            return const Center(child: Text('No questions found for this lesson.'));
          }

          if (_current >= questions.length) {
            return const Center(child: CircularProgressIndicator());
          }

          final q = questions[_current];
          final options = List<String>.from(q['options'] as List);

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Question ${_current + 1}/${questions.length}',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 10),
                Text(
                  q['question_text']?.toString() ?? '',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 20),
                ...List.generate(options.length, (i) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saving
                            ? null
                            : () => _answer(
                                  q,
                                  i,
                                  options[i],
                                  questions.length,
                                ),
                        child: Text(options[i]),
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}