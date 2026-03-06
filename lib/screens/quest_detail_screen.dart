import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

class QuestDetailScreen extends StatefulWidget {
  final Map<String, dynamic> quest;

  const QuestDetailScreen({super.key, required this.quest});

  @override
  State<QuestDetailScreen> createState() => _QuestDetailScreenState();
}

class _QuestDetailScreenState extends State<QuestDetailScreen> {
  final _supabase = Supabase.instance.client;
  bool submitting = false;
  Uint8List? imageBytes;
  final ImagePicker _picker = ImagePicker();


Future<void> pickImage() async {
  final image = await _picker.pickImage(source: ImageSource.camera);

  if (image == null) return;

  final bytes = await image.readAsBytes();

  setState(() {
    imageBytes = bytes;
  });
}
Future<String> uploadEvidence(
    Uint8List bytes, String userId, String questId) async {

  final path = "$userId/$questId.jpg";

  await _supabase.storage
      .from('quest-evidence')
      .uploadBinary(path, bytes);

  final url = _supabase.storage
      .from('quest-evidence')
      .getPublicUrl(path);

  return url;
}
Future<void> _submitQuest() async {
  final user = _supabase.auth.currentUser;
  if (user == null) return;

  if (imageBytes == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Upload evidence photo first")),
    );
    return;
  }

  setState(() => submitting = true);

  try {

    final imageUrl = await uploadEvidence(
      imageBytes!,
      user.id,
      widget.quest['id'],
    );

await _supabase.from('practical_submissions').insert({
  'quest_id': widget.quest['id'],
  'student_id': user.id,
  'submission_text': 'Submitted via mobile app',
  'evidence_url': imageUrl,
  'status': 'pending',
});

await _updateStudentProgress();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Submission sent for lecturer approval")),
    );

    Navigator.pop(context);

  } catch (e) {

  if (e.toString().contains("duplicate")) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("You already submitted this quest")),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Error submitting quest")),
    );
  }

}

  setState(() => submitting = false);
}

Future<void> _updateStudentProgress() async {

  final user = _supabase.auth.currentUser;
  if (user == null) return;

  final userId = user.id;
  final questId = widget.quest['id'];

  try {

    /// mark quest as completed
    await _supabase.from('student_quest_status').upsert({
      'student_id': userId,
      'quest_id': questId,
      'status': 'completed',
      'completed_at': DateTime.now().toIso8601String()
    });

    /// add XP to profile
    await _supabase.rpc('add_xp', params: {
      'p_user_id': userId,
      'p_xp': 50
    });

  } catch (e) {
    debugPrint("Progress update failed: $e");
  }
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

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: pickImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B1220),
              ),
              child: const Text("Upload Evidence Photo"),
            ),

            const SizedBox(height: 12),

            if (imageBytes != null)
              Image.memory(imageBytes!, height: 200),

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