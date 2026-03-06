import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class QuestStepsScreen extends StatefulWidget {
  final Map<String, dynamic> quest;

  const QuestStepsScreen({super.key, required this.quest});

  @override
  State<QuestStepsScreen> createState() => _QuestStepsScreenState();
}

class _QuestStepsScreenState extends State<QuestStepsScreen> {
  final _supabase = Supabase.instance.client;

List<Map<String, dynamic>> steps = [];
  int currentStep = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadSteps();
  }

Future<void> loadSteps() async {
  final response = await _supabase
      .from('practical_steps')
      .select()
      .eq('quest_id', widget.quest['id'].toString())
      .order('step_order', ascending: true);

  final result = List<Map<String, dynamic>>.from(response);

  setState(() {
    steps = result;
    loading = false;
  });

  print("Quest ID: ${widget.quest['id']}");
  print("Steps loaded: ${steps.length}");

  if (steps.isEmpty) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No steps found for this quest")),
      );
    }
  }
}


  void nextStep() {
    if (currentStep < steps.length - 1) {
      setState(() {
        currentStep++;
      });
    } else {
      Navigator.pushNamed(context, '/quest-detail', arguments: widget.quest);
    }
  }
      String getStepImage(int stepOrder) {
        switch (stepOrder) {
          case 1:
            return "assets/images/rivet_step1_safety.png";
          case 2:
            return "assets/images/rivet_step2_identify.png";
          case 3:
            return "assets/images/rivet_step3_center_punch.png";
          case 4:
            return "assets/images/rivet_step4_drill.png";
          case 5:
            return "assets/images/rivet_step5_inspect.png";
          default:
            return "assets/images/rivet_steps.png";
        }
      }
  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (steps.isEmpty) {
  return const Scaffold(
    body: Center(
      child: Text(
        "No steps available for this quest",
        style: TextStyle(color: Colors.white),
      ),
    ),
  );
}

final step = steps[currentStep];

    return Scaffold(
      backgroundColor: const Color(0xFF070A12),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1220),
        title: Text("Step ${currentStep + 1} of ${steps.length}"),
      ),
              body: Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      /// STEP PROGRESS BAR
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: (currentStep + 1) / steps.length,
                          minHeight: 8,
                          backgroundColor: Colors.white.withOpacity(0.1),
                          valueColor: const AlwaysStoppedAnimation(Color(0xFFE1B04A)),
                        ),
                      ),

                      const SizedBox(height: 25),

                      /// STEP TITLE
                      Text(
                        step['title'],
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// STEP IMAGE
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          getStepImage(step['step_order']),
                          height: 220,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),

                      const SizedBox(height: 25),

                      /// STEP DESCRIPTION
                      Text(
                        step['description'] ?? '',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 40),

                      /// NEXT BUTTON
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: nextStep,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE1B04A),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(
                            currentStep == steps.length - 1
                                ? "Finish Steps"
                                : "Next Step",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ), 
            );
          }
        }