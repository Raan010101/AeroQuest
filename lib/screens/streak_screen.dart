import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StreakScreen extends StatefulWidget {
  const StreakScreen({super.key});

  @override
  State<StreakScreen> createState() => _StreakScreenState();
}

class _StreakScreenState extends State<StreakScreen> {
  final _supabase = Supabase.instance.client;

  bool loading = true;
  bool started = false;
  bool completed = false;

  int streakDays = 0;

  List<Map<String, dynamic>> questions = [];
  int currentIndex = 0;
  int correctCount = 0;
  String? selectedAnswer;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

Future<void> _loadProfile() async {
  try {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      setState(() => loading = false);
      return;
    }

    final profile = await _supabase
        .from('profiles')
        .select('streak_days')
        .eq('id', user.id)
        .maybeSingle();

    setState(() {
      streakDays = profile?['streak_days'] ?? 0;
      loading = false;
    });
  } catch (e) {
    print("Streak load error: $e");
    setState(() => loading = false);
  }
}
Future<void> _startQuiz() async {
  try {
    final res = await _supabase
        .from('questions')
        .select()
        .limit(5);

    setState(() {
      questions = (res as List).cast<Map<String, dynamic>>();
      started = true;
      completed = false;
      currentIndex = 0;
      correctCount = 0;
      selectedAnswer = null;
    });
  } catch (e) {
    print("Question load error: $e");
  }
}

  Future<void> _submitAnswer() async {
    if (selectedAnswer == null) return;

    final correctAnswer = questions[currentIndex]['correct_answer'];

    if (selectedAnswer == correctAnswer) {
      correctCount++;
    }

    if (currentIndex < questions.length - 1) {
      setState(() {
        currentIndex++;
        selectedAnswer = null;
      });
    } else {
      await _completeQuiz();
    }
  }

  Future<void> _completeQuiz() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final earnedPoints = correctCount * 5;

    final profile = await _supabase
        .from('profiles')
        .select('xp, streak_days')
        .eq('id', user.id)
        .single();

    await _supabase
        .from('profiles')
        .update({
          'xp': (profile['xp'] ?? 0) + earnedPoints,
          'streak_days': (profile['streak_days'] ?? 0) + 1,
        })
        .eq('id', user.id);

    setState(() {
      completed = true;
    });
  }

  @override
Widget build(BuildContext context) {
  // ================= LOADING =================
  if (loading) {
    return const Scaffold(
      backgroundColor: Color(0xFF0B1220),
      body: Center(child: CircularProgressIndicator()),
    );
  }

  // ================= ENTRY SCREEN =================
  if (!started) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.local_fire_department,
                size: 80, color: Color(0xFFE1B04A)),
            const SizedBox(height: 20),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                    color: const Color(0xFFE1B04A).withOpacity(0.4)),
              ),
              child: Text(
                "$streakDays Day Streak",
                style: const TextStyle(
                  color: Color(0xFFE1B04A),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Daily Streak",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "5 aviation questions • 5 pts each\nMax 25 pts today",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE1B04A),
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 56),
              ),
              onPressed: _startQuiz,
              child: const Text(
                "START TODAY'S QUIZ",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ),
    );
  }

  // ================= COMPLETION SCREEN =================
  if (completed) {
    final earnedPoints = correctCount * 5;

    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.emoji_events,
                  size: 70, color: Color(0xFFE1B04A)),
              const SizedBox(height: 20),
              const Text(
                "Quiz Complete",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "$correctCount / ${questions.length} correct",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "+$earnedPoints XP",
                style: const TextStyle(
                  fontSize: 24,
                  color: Color(0xFFE1B04A),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= SAFETY CHECK =================
  if (questions.isEmpty) {
    return const Scaffold(
      backgroundColor: Color(0xFF0B1220),
      body: Center(
        child: Text(
          "No questions found",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  // ================= QUIZ SCREEN =================
final question = questions[currentIndex];
final options = List<String>.from(question['options']);
final correctAnswer = question['correct_answer'];

return Scaffold(
  backgroundColor: const Color(0xFF0B1220),
  appBar: AppBar(
    backgroundColor: const Color(0xFF0B1220),
    elevation: 0,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        setState(() {
          started = false;   // go back to entry screen
        });
      },
    ),
  ),
 body: SafeArea(
  child: Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // TOP BAR
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Question ${currentIndex + 1}/${questions.length}",
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
              ),
            ),
            Text(
              "${correctCount * 5} pts",
              style: const TextStyle(
                color: Color(0xFFE1B04A),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        LinearProgressIndicator(
          value: (currentIndex + 1) / questions.length,
          minHeight: 6,
          backgroundColor: Colors.white.withOpacity(0.1),
          valueColor: const AlwaysStoppedAnimation(Color(0xFFE1B04A)),
        ),

        const SizedBox(height: 25),

        Text(
          question['category'] ?? "AIRCRAFT SYSTEMS",
          style: const TextStyle(
            color: Color(0xFFE1B04A),
            fontSize: 12,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 8),

        // Question text (limit lines to avoid overflow)
        Text(
          question['question_text'],
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 20),

        // OPTIONS AREA
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(options.length, (index) {
              final option = options[index];
              final letter = String.fromCharCode(65 + index);

              bool isSelected = selectedAnswer == option;
              bool isCorrectOption = option == correctAnswer;
              bool showCorrect = selectedAnswer != null;

              Color borderColor = Colors.white.withOpacity(0.1);
              Color bgColor = const Color(0xFF141923);

              if (showCorrect) {
                if (isCorrectOption) {
                  borderColor = const Color(0xFF3DDC84);
                  bgColor = const Color(0xFF1F3A2E);
                } else if (isSelected) {
                  borderColor = const Color(0xFFFF5A5A);
                  bgColor = const Color(0xFF3A1F1F);
                }
              } else if (isSelected) {
                borderColor = const Color(0xFFE1B04A);
              }

              return GestureDetector(
                onTap: showCorrect
                    ? null
                    : () {
                        setState(() {
                          selectedAnswer = option;
                        });
                      },
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.08),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          letter,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          option,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),

        const SizedBox(height: 10),

        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: currentIndex == questions.length - 1
                  ? const Color(0xFF3DDC84)
                  : const Color(0xFF2F32FF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: selectedAnswer == null ? null : _submitAnswer,
            child: Text(
              currentIndex == questions.length - 1
                  ? "FINISH"
                  : "NEXT QUESTION",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),

      ],
    ),
  ),
),
);
} // END build
} // END _StreakScreenState
// END StreakScreen