import 'package:flutter/material.dart';

import 'student_dashboard_home.dart';
import 'modules_screen.dart';
import '../qr_scan_screen.dart';
import '../streak_screen.dart';

class StudentShell extends StatefulWidget {
  final String name;
  final String idNumber;
  final String role;

  const StudentShell({
    super.key,
    required this.name,
    required this.idNumber,
    required this.role,
  });

  @override
  State<StudentShell> createState() => _StudentShellState();
}

class _StudentShellState extends State<StudentShell> {
  int _index = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _pages = [
      StudentDashboardScreen(
        name: widget.name,
        idNumber: widget.idNumber,
        role: widget.role,
      ),
      const QRScanScreen(),
      const ModulesScreen(),
      const StreakScreen(),
    ];
  }

  void _onTap(int newIndex) {
    if (newIndex == _index) return;
    setState(() => _index = newIndex);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _index,
        children: _pages,
      ),

      // Sleek custom bottom nav
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottomInset),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFF121826),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NavItem(
                icon: Icons.home,
                label: "HOME",
                active: _index == 0,
                onTap: () => _onTap(0),
              ),
              _NavItem(
                icon: Icons.qr_code_scanner,
                label: "QUEST",
                active: _index == 1,
                onTap: () => _onTap(1),
              ),
              _NavItem(
                icon: Icons.menu_book,
                label: "LEARN",
                active: _index == 2,
                onTap: () => _onTap(2),
              ),
              _NavItem(
                icon: Icons.local_fire_department,
                label: "STREAK",
                active: _index == 3,
                onTap: () => _onTap(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active
        ? const Color(0xFFE1B04A)
        : Colors.white.withOpacity(0.65);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}