import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class QRScanScreen extends StatefulWidget {
  const QRScanScreen({super.key});

  @override
  State<QRScanScreen> createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> {
  bool _handled = false;
  final _supabase = Supabase.instance.client;

  void _handleCode(String code) async {
    if (_handled) return;
    _handled = true;

    try {
      if (!code.startsWith("AEROQUEST:QUEST:")) {
        _showError("Invalid QR Code");
        return;
      }

      final qrValue = code.split(":").last;

      final quest = await _supabase
          .from('practical_quests')
          .select()
          .eq('qr_code_value', qrValue)
          .eq('is_active', true)
          .maybeSingle();

      if (quest == null) {
        _showError("Quest not found");
        return;
      }

      if (!mounted) return;

      Navigator.pushReplacementNamed(
        context,
        "/quest-detail",
        arguments: quest,
      );
    } catch (e) {
      _showError("Error loading quest");
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
    Navigator.pop(context);
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.black,
    body: MobileScanner(
      controller: MobileScannerController(),
      onDetect: (capture) {
        final List<Barcode> barcodes = capture.barcodes;
        for (final barcode in barcodes) {
          final String? code = barcode.rawValue;
          if (code != null) {
            _handleCode(code);
            break;
          }
        }
      },
    ),
  );
}}