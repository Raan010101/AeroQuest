import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ogslnmrggqbjxmntotnx.supabase.co',
    anonKey: 'sb_publishable_ImFJLCIHiEVM9PI5-PKHIQ_yfcnJqd1',
  );

  runApp(const AeroQuestApp());
}

class AeroQuestApp extends StatelessWidget {
  const AeroQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}