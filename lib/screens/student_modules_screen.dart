import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'lessons_screen.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  final supabase = Supabase.instance.client;

  List modules = [];
  List lessons = [];
  List lessonProgress = [];
  Map profile = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    setState(() => loading = true);

    final modulesData = await supabase
        .from('modules')
        .select()
        .eq('is_published', true)
        .order('order_no');

    final lessonsData = await supabase
        .from('lessons')
        .select()
        .eq('is_published', true);

    final progressData = await supabase
        .from('lesson_progress')
        .select()
        .eq('user_id', user.id);

    final profileData = await supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .single();

    setState(() {
      modules = modulesData;
      lessons = lessonsData;
      lessonProgress = progressData;
      profile = profileData;
      loading = false;
    });
  }

  // ✅ Count only COMPLETED lessons
  double moduleCompletion(String moduleId) {
    final moduleLessons =
        lessons.where((l) => l['module_id'] == moduleId).toList();

    if (moduleLessons.isEmpty) return 0;

    final completedLessonIds = lessonProgress
        .where((p) => p['status'] == 'completed')
        .map((p) => p['lesson_id'])
        .toSet();

    final completedCount = moduleLessons
        .where((l) => completedLessonIds.contains(l['id']))
        .length;

    return completedCount / moduleLessons.length;
  }

  // ✅ Overall = completed lessons / total lessons
  double overallCompletion() {
    if (lessons.isEmpty) return 0;

    final completedLessonIds = lessonProgress
        .where((p) => p['status'] == 'completed')
        .map((p) => p['lesson_id'])
        .toSet();

    final completedCount = lessons
        .where((l) => completedLessonIds.contains(l['id']))
        .length;

    return completedCount / lessons.length;
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final overall = overallCompletion();

    return Scaffold(
      appBar: AppBar(title: const Text("AeroQuest Dashboard")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // Welcome
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Welcome, ${profile['name'] ?? 'Cadet'}",
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 16),

            // Overall Progress
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Overall Progress"),
                const SizedBox(height: 6),
                LinearProgressIndicator(value: overall),
                const SizedBox(height: 6),
                Text("${(overall * 100).toStringAsFixed(0)}% complete"),
              ],
            ),

            const SizedBox(height: 20),

            // Modules List
            Expanded(
              child: ListView.builder(
                itemCount: modules.length,
                itemBuilder: (context, index) {
                  final module = modules[index];
                  final completion =
                      moduleCompletion(module['id']);

                  return Card(
                    child: ListTile(
                      title: Text(module['title']),
                      subtitle: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: completion,
                          ),
                          const SizedBox(height: 4),
                          Text(
                              "${(completion * 100).toStringAsFixed(0)}% complete"),
                        ],
                      ),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LessonsScreen(
                              moduleId: module['id'],
                              moduleTitle: module['title'],
                            ),
                          ),
                        );

                        // ✅ Refresh when coming back
                        await fetchData();
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}