import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class QuestDetailScreen extends StatefulWidget {
  final Map<String, dynamic> quest;

  const QuestDetailScreen({super.key, required this.quest});

  @override
  State<QuestDetailScreen> createState() => _QuestDetailScreenState();
}

class _QuestDetailScreenState extends State<QuestDetailScreen> {
  final _supabase = Supabase.instance.client;
  bool submitting = false;

  Future<void> _submitQuest() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    setState(() => submitting = true);

    try {
      await _supabase.from('practical_submissions').insert({
        'quest_id': widget.quest['id'],
        'student_id': user.id,
        'submission_text': 'Submitted via mobile app',
        'status': 'pending',
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Submission sent for lecturer approval")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error submitting quest")),
      );
    }

    setState(() => submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final quest = widget.quest;

    return Scaffold(
      backgroundColor: const Color(0xFF070A12),
      appBar: AppBar(
        title: Text(quest['title'] ?? 'Quest'),
        backgroundColor: const Color(0xFF0B1220),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              quest['description'] ?? '',
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 20),

            if (quest['due_at'] != null)
              Text(
                "Due: ${quest['due_at']}",
                style: const TextStyle(color: Colors.orange),
              ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: submitting ? null : _submitQuest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE1B04A),
                  foregroundColor: Colors.black,
                ),
                child: submitting
                    ? const CircularProgressIndicator()
                    : const Text("Submit Practical"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}