import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'quest_steps_screen.dart';
import '../core/routes.dart';

class QRScanScreen extends StatefulWidget {
  const QRScanScreen({super.key});

  @override
  State<QRScanScreen> createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> {

  final _supabase = Supabase.instance.client;
  final TextEditingController _codeController = TextEditingController();

  final MobileScannerController _scannerController = MobileScannerController();

  bool _handled = false;

  @override
  void dispose() {
    _scannerController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _handleCode(String code) async {

    if (_handled) return;
    _handled = true;

    try {

      final qrValue = code.trim().toUpperCase();

      final result = await _supabase
          .from('practical_quests')
          .select()
          .eq('qr_code_value', qrValue);

      if (result.isEmpty) {
        _showError("Quest not found"); 
        return;
      }

final quest = result.first;

      if (quest['is_active'] == false) {
        _showError("Quest locked. Contact lecturer.");
        return;
      }

      if (!mounted) return;

      await _scannerController.stop();

    Navigator.pushNamed(
      context,
      AppRoutes.questSteps,
      arguments: quest,
    );

    } catch (e) {
      _showError("Error loading quest");
    }
  }

  Future<void> _findQuestByCode() async {

    final code = _codeController.text.trim().toUpperCase();

    if (code.isEmpty) {
      _showError("Enter quest code");
      return;
    }

    try {

          final response = await _supabase
              .from('practical_quests')
              .select()
              .eq('code', code);

          final result = List<Map<String, dynamic>>.from(response);

          if (result.isEmpty) {
            _showError("Quest does not exist");
            return;
          }

          final quest = result.first;

      if (quest['is_active'] == false) {
        _showError("Quest locked. Contact lecturer.");
        return;
      }

      if (!mounted) return;

      await _scannerController.stop();

    Navigator.pushNamed(
      context,
      AppRoutes.questSteps,
      arguments: quest,
    );

    } catch (e) {
      _showError("Error loading quest");
    }
  }

  void _showError(String message) {

    if (!mounted) return;

    _handled = false;

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.black,

      body: Stack(
        children: [

          /// CAMERA
          MobileScanner(
            controller: _scannerController,
            onDetect: (capture) {
              for (final barcode in capture.barcodes) {
                final code = barcode.rawValue;
                if (code != null) {
                  _handleCode(code);
                  break;
                }
              }
            },
          ),

          /// DARK OVERLAY
          Container(
            color: Colors.black.withOpacity(0.45),
          ),

          /// SCAN FRAME
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFFE1B04A),
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),

          /// TEXT
          Positioned(
            bottom: 600,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "Scan Quest QR Code",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          /// INPUT AREA
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: SafeArea(
              child: Column(
                children: [

                  TextField(
                    controller: _codeController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Enter Quest Code (e.g. RIVET-01)",
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: const Color(0xFF0B1220),
                        border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _findQuestByCode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE1B04A),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                      ),
                      child: Text(
                        "Find Quest",
                        style: TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0).withOpacity(1),
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),

          /// BACK BUTTON
          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () async {
                await _scannerController.stop();
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}