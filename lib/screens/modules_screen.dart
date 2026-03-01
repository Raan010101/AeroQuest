import 'package:flutter/material.dart';
import '../services/learning_service.dart';
import 'lessons_screen.dart';

class ModulesScreen extends StatefulWidget {
  const ModulesScreen({super.key});

  @override
  State<ModulesScreen> createState() => _ModulesScreenState();
}

class _ModulesScreenState extends State<ModulesScreen> {
  final _service = LearningService();
  late Future<List<Map<String, dynamic>>> _modulesFuture;

  @override
  void initState() {
    super.initState();
    _modulesFuture = _service.fetchModules();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cat A Modules')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _modulesFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final modules = snapshot.data!;
          if (modules.isEmpty) {
            return const Center(child: Text('No modules found.'));
          }

          return ListView.separated(
            itemCount: modules.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final m = modules[index];
              return ListTile(
                title: Text(m['title'] ?? ''),
                subtitle: Text(m['description'] ?? ''),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LessonsScreen(
                        moduleId: m['id'],
                        moduleTitle: m['title'] ?? 'Module',
                      ),
                    ),
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