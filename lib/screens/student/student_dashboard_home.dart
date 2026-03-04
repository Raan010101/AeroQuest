import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/routes.dart';
enum QuestStatus { locked, assigned, completed, expired }

class QuestItem {
  final String code;
  final String title;
  final String subtitle;
  final String imageAsset; // or network url later
  final QuestStatus status;

  const QuestItem({
    required this.code,
    required this.title,
    required this.subtitle,
    required this.imageAsset,
    required this.status,
  });

  bool get isTapEnabled => status == QuestStatus.assigned;
}

class StudentDashboardScreen extends StatefulWidget {
  final String name;
  final String idNumber;
  final String role;

  const StudentDashboardScreen({
    super.key,
    required this.name,
    required this.idNumber,
    required this.role,
  });

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}
class _StudentDashboardScreenState extends State<StudentDashboardScreen> with WidgetsBindingObserver {
  final _supabase = Supabase.instance.client;
  late final RealtimeChannel profileChannel;
  int xp = 0;
  int streakDays = 0;
  int progressPct = 0;
  String badgeLabel = "BEGINNER";
  List<QuestItem> quests = [];

  bool loading = true;

@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  if (state == AppLifecycleState.resumed) {
    _loadDashboard();
  }
}

@override
void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadDashboard();
    _subscribeToProfile();
}

void _subscribeToProfile() {
  final user = _supabase.auth.currentUser;
  if (user == null) return;

  profileChannel = _supabase.channel('profile_updates')
    ..onPostgresChanges(
      event: PostgresChangeEvent.update,
      schema: 'public',
      table: 'profiles',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'id',
        value: user.id,
      ),
      callback: (payload) {
        final data = payload.newRecord;

        setState(() {
          xp = data['xp_total'] ?? xp;
          streakDays = data['streak_count'] ?? streakDays;
          badgeLabel = data['rank_title'] ?? badgeLabel;
        });
      },
    )
    ..subscribe();
}

  Future<void> _loadDashboard() async {
    try {
      final user = _supabase.auth.currentUser;
        if (user == null) return;
        final userId = user.id;
        

      // Fetch profile
      final profile = await _supabase
          .from('profiles')
          .select('xp_total, streak_count, rank_title')
          .eq('id', user.id)
          .single();

      // Fetch quests
      final questRes = await _supabase
          .from('practical_quests')
          .select('id, code, title, description, xp_reward, due_at, is_active')
          .eq('is_active', true);

      final loadedQuests = (questRes as List).map((q) {
        final statusString = q['status'] as String;

        QuestStatus status = switch (statusString) {
          'assigned' => QuestStatus.assigned,
          'completed' => QuestStatus.completed,
          'expired' => QuestStatus.expired,
          _ => QuestStatus.locked,
        };
        print("XP: ${profile['xp_total']}");
        print("Streak: ${profile['streak_count']}");

        return QuestItem(
            code: q['code'] ?? '',
            title: q['title'] ?? '',
            subtitle: q['description'] ?? '',
            imageAsset: '', // no image column in DB
            status: status,
                );
          }).toList();

      setState(() {
        xp = profile['xp_total'] ?? 0;
        streakDays = profile['streak_count'] ?? 0;
        badgeLabel = profile['rank_title'] ?? "BEGINNER";
        quests = loadedQuests;
        progressPct = _calculateProgress(loadedQuests);
        loading = false;
      });
    } catch (e) {
      print("Dashboard error: $e");
      setState(() => loading = false);
    }
    
  }

  int _calculateProgress(List<QuestItem> quests) {
    if (quests.isEmpty) return 0;
    final completed =
        quests.where((q) => q.status == QuestStatus.completed).length;
    return ((completed / quests.length) * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    
if (loading) {
  return const Scaffold(
    backgroundColor: Color(0xFF070A12),
    body: Center(child: CircularProgressIndicator()),
  );
}


return Scaffold(
  backgroundColor: const Color(0xFF070A12),
  extendBody: true,
  body: Stack(
    children: [
      Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0B1220), Color(0xFF070A12)],
          ),
        ),
      ),
      Positioned.fill(
        child: IgnorePointer(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topCenter,
                radius: 1.1,
                colors: [
                  const Color(0xFF2F5BFF).withOpacity(0.10),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ),

      SafeArea(
        child: DefaultTextStyle(
          style: const TextStyle(
            color: Colors.white,
            shadows: [
              Shadow(blurRadius: 10, color: Colors.black54, offset: Offset(0, 2)),
            ],
          ),
          child: IconTheme(
            data: const IconThemeData(color: Colors.white),
            child: ListView(
              padding: EdgeInsets.fromLTRB(  16,  10,  16,  16 + MediaQuery.of(context).padding.bottom + 72,),
              children: [
              _TopBar(
                onLogout: () async {
                  await Supabase.instance.client.auth.signOut();
                  if (!context.mounted) return;
                  Navigator.pushNamedAndRemoveUntil(context, AppRoutes.root, (_) => false);
                },
              ),
          const SizedBox(height: 14),
          
            _ProfileHeader(
              name: widget.name,
              idNumber: widget.idNumber,
              badge: badgeLabel,
            ),
          const SizedBox(height: 14),

          _StatsRow(xp: xp, streakDays: streakDays, progressPct: progressPct),
          const SizedBox(height: 10),

          _RankProgress(
              label: "Progress to Cadet",
              progress: progressPct / 100,
              rightText: "$progressPct%",
            ),
          const SizedBox(height: 18),

          const _SectionTitle(title: "QUICK ACCESS"),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _QuickAccessTile(
                  icon: Icons.qr_code_scanner,
                  title: "Scan Quest",
                  subtitle: "Scan QR code to start",
                  onTap: () {
                              Navigator.pushNamed(context, "/qr-scan");
                            },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickAccessTile(
                  icon: Icons.local_fire_department,
                  title: "Daily Streak",
                  subtitle: "Complete today’s quiz",
                  onTap: () async {
                    await Navigator.pushNamed(context, AppRoutes.streak);
                    await Future.delayed(const Duration(milliseconds: 300));
                    await _loadDashboard();
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const _SectionTitle(title: "QUESTS"),
              TextButton(onPressed: () {}, child: const Text("See all")),
            ],
          ),
          const SizedBox(height: 10),

          SizedBox(
            height: 210,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: quests.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, i) {
                final q = quests[i];
                return _QuestCard(
                  quest: q,
                  onTap: q.isTapEnabled ? () {} : null,
                );
              },
            ),
          ),

          const SizedBox(height: 18),
          _DailyStreakCard(
            streakDays: streakDays,
            completedToday: false,
            onStart: () {},
          ),

          const SizedBox(height: 18),
          const _SectionTitle(title: "UPCOMING QUESTS"),
          const SizedBox(height: 10),
          _UpcomingQuestRow(
            month: "OCT",
            day: "24",
            title: "Engine Quest Submission",
            subtitle: "Ends in 09:00 AM • Lab",
            urgent: true,
          ),
          const SizedBox(height: 10),
          _UpcomingQuestRow(
            month: "OCT",
            day: "28",
            title: "Airframe Checklist",
            subtitle: "Ends in 11:59 PM • Online",
            urgent: false,
          ),

          const SizedBox(height: 18),
          const _SectionTitle(title: "TOP PERFORMERS"),
          const SizedBox(height: 10),
          _LeaderboardEmpty(),
        ],
            ),
          ),
        ),
      ),
    ],
  ),
);

  }
  
@override
void dispose() {
  WidgetsBinding.instance.removeObserver(this);
  super.dispose();
}
}

/* ---------------- UI Pieces ---------------- */

  class _TopBar extends StatelessWidget {
  final Future<void> Function() onLogout;

  const _TopBar({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _IconSquare(
          icon: Icons.menu,
          onTap: () {},
        ),
        const Spacer(),
        const Text(
          "AEROQUEST",
          style: TextStyle(
            letterSpacing: 2,
            fontWeight: FontWeight.w700,
            color: Color(0xFFE1B04A),
          ),
        ),
        const Spacer(),
        Row(
          children: [
            _IconSquare(
              icon: Icons.notifications_none,
              onTap: () {},
            ),
            const SizedBox(width: 10),
            _IconSquare(
              icon: Icons.logout,
              onTap: () async => onLogout(),
            ),
          ],
        ),
      ],
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String name;
  final String idNumber;
  final String badge;

  const _ProfileHeader({
    required this.name,
    required this.idNumber,
    required this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFF2F5BFF).withOpacity(0.25),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF2F5BFF).withOpacity(0.35)),
            ),
            alignment: Alignment.center,
            child: const Text(
              "R",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text("ID: $idNumber", style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.55))),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE1B04A).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: const Color(0xFFE1B04A).withOpacity(0.35)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.circle, size: 7, color: Color(0xFFE1B04A)),
                      const SizedBox(width: 6),
                      Text(
                        badge,
                        style: const TextStyle(
                          fontSize: 11,
                          letterSpacing: 1,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFE1B04A),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final int xp;
  final int streakDays;
  final int progressPct;

  const _StatsRow({required this.xp, required this.streakDays, required this.progressPct});

  @override

  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _StatCard(label: "POINTS", value: "$xp")),
        const SizedBox(width: 10),
        Expanded(child: _StatCard(label: "STREAK", value: "$streakDays", icon: Icons.local_fire_department)),
        const SizedBox(width: 10),
        Expanded(child: _StatCard(label: "PROGRESS", value: "$progressPct%")),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;

  const _StatCard({required this.label, required this.value, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 86,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: _cardDecoration(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 14, color: Colors.white.withOpacity(0.7)),
                const SizedBox(width: 4),
              ],
              Text(label, style: TextStyle(fontSize: 11, letterSpacing: 1.4, color: Colors.white.withOpacity(0.70))),
            ],
          ),
        ],
      ),
    );
  }
}

class _RankProgress extends StatelessWidget {
  final String label;
  final double progress;
  final String rightText;

  const _RankProgress({required this.label, required this.progress, required this.rightText});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(label, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.65))),
            const Spacer(),
            Text(rightText, style: const TextStyle(fontSize: 12, color: Color(0xFFE1B04A), fontWeight: FontWeight.w800)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress.clamp(0, 1),
            minHeight: 8,
            backgroundColor: Colors.white.withOpacity(0.08),
            valueColor: const AlwaysStoppedAnimation(Color(0xFFE1B04A)),
          ),
        ),
      ],
    );
  }
}

class _QuickAccessTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickAccessTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: _cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFFE1B04A)),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.55))),
          ],
        ),
      ),
    );
  }
}

class _QuestCard extends StatelessWidget {
  final QuestItem quest;
  final VoidCallback? onTap;

  const _QuestCard({required this.quest, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final borderColor = switch (quest.status) {
      QuestStatus.assigned => const Color(0xFF2F5BFF),
      QuestStatus.completed => const Color(0xFF3DDC84),
      QuestStatus.expired => const Color(0xFFFF5A5A),
      _ => Colors.white.withOpacity(0.12),
    };

    final isLocked = quest.status == QuestStatus.locked;
    final isCompleted = quest.status == QuestStatus.completed;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 260,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor, width: 1.2),
          color: const Color(0xFF141923),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              child: Stack(
                children: [
                  SizedBox(
                    height: 108,
                    width: double.infinity,
                    child: Image.network(
                      quest.imageAsset,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.white.withOpacity(0.06),
                        alignment: Alignment.center,
                        child: Icon(Icons.image, color: Colors.white.withOpacity(0.35)),
                      ),
                    ),
                  ),

                  // Blur overlay if locked
                  if (isLocked)
                    Positioned.fill(
                      child: Container(color: Colors.black.withOpacity(0.45)),
                    ),

                  // Gradient fade bottom
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.65),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Status badge
                  Positioned(
                    top: 10,
                    left: 10,
                    child: _StatusPill(status: quest.status),
                  ),

                  // Completed check
                  if (isCompleted)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.55),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: const Color(0xFF3DDC84).withOpacity(0.8)),
                        ),
                        child: const Icon(Icons.check, size: 16, color: Color(0xFF3DDC84)),
                      ),
                    ),

                  // Lock icon
                  if (isLocked)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.55),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: Colors.white.withOpacity(0.18)),
                        ),
                        child: Icon(Icons.lock, size: 16, color: Colors.white.withOpacity(0.8)),
                      ),
                    ),
                ],
              ),
            ),

            // Text area
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(quest.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text(
                    quest.subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.6)),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        quest.code,
                        style: TextStyle(fontSize: 11, letterSpacing: 1.1, color: Colors.white.withOpacity(0.55)),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.chevron_right,
                        color: onTap == null ? Colors.white.withOpacity(0.25) : Colors.white.withOpacity(0.65),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final QuestStatus status;
  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final (text, color) = switch (status) {
      QuestStatus.assigned => ("ASSIGNED", const Color(0xFF2F5BFF)),
      QuestStatus.completed => ("COMPLETED", const Color(0xFF3DDC84)),
      QuestStatus.expired => ("EXPIRED", const Color(0xFFFF5A5A)),
      _ => ("LOCKED", Colors.white),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.6)),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 10, letterSpacing: 1.2, fontWeight: FontWeight.w900, color: color),
      ),
    );
  }
}

class _DailyStreakCard extends StatelessWidget {
  final int streakDays;
  final bool completedToday;
  final VoidCallback onStart;

  const _DailyStreakCard({
    required this.streakDays,
    required this.completedToday,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: const Color(0xFF141923),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE1B04A).withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.local_fire_department, color: Color(0xFFE1B04A), size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("$streakDays Day Streak", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(
                  completedToday ? "Already completed today" : "5 aviation questions • +5 XP",
                  style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.6)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: completedToday ? null : onStart,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE1B04A),
              foregroundColor: Colors.black,
              disabledBackgroundColor: Colors.white.withOpacity(0.12),
              disabledForegroundColor: Colors.white.withOpacity(0.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(completedToday ? "Completed" : "Start"),
          ),
        ],
      ),
    );
  }
}

class _UpcomingQuestRow extends StatelessWidget {
  final String month;
  final String day;
  final String title;
  final String subtitle;
  final bool urgent;

  const _UpcomingQuestRow({
    required this.month,
    required this.day,
    required this.title,
    required this.subtitle,
    required this.urgent,
  });

  @override
  Widget build(BuildContext context) {
    final accent = urgent ? const Color(0xFFFF5A5A) : const Color(0xFFE1B04A);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Container(
            width: 62,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: accent.withOpacity(0.35)),
            ),
            child: Column(
              children: [
                Text(month, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: accent)),
                const SizedBox(height: 2),
                Text(day, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: accent)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.6))),
              ],
            ),
          ),
          Icon(urgent ? Icons.priority_high : Icons.schedule, color: accent),
        ],
      ),
    );
  }
}

class _LeaderboardEmpty extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      alignment: Alignment.center,
      decoration: _cardDecoration(),
      child: Text("No rankings yet", style: TextStyle(color: Colors.white.withOpacity(0.55))),
    );
  }
}

class BottomNav extends StatelessWidget {
  final int currentIndex;

  const BottomNav({super.key, required this.currentIndex});

  void _navigate(BuildContext context, int index) {
    if (index == currentIndex) return;

    switch (index) {
      case 0:
        Navigator.pushNamedAndRemoveUntil(
            context, "/", (route) => false);
        break;
      case 1:
        Navigator.pushNamed(context, "/quests");
        break;
      case 2:
        Navigator.pushNamed(context, "/learn");
        break;
      case 3:
        Navigator.pushNamed(context, "/streak");
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 12 + bottomInset),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 62,
          decoration: BoxDecoration(
            color: const Color(0xFF121826),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NavItem(
                icon: Icons.home,
                label: "HOME",
                active: currentIndex == 0,
                onTap: () => _navigate(context, 0),
              ),
              _NavItem(
                icon: Icons.qr_code_scanner,
                label: "QUEST",
                active: currentIndex == 1,
                onTap: () => _navigate(context, 1),
              ),
              _NavItem(
                icon: Icons.menu_book,
                label: "LEARN",
                active: currentIndex == 2,
                onTap: () => _navigate(context, 2),
              ),
              _NavItem(
                icon: Icons.local_fire_department,
                label: "STREAK",
                active: currentIndex == 3,
                onTap: () => _navigate(context, 3),
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
    final color = active ? const Color(0xFFE1B04A) : Colors.white70;

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
              letterSpacing: 1.1,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _IconSquare extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconSquare({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: Icon(icon, color: Colors.white.withOpacity(0.85)),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 11,
        letterSpacing: 2,
        fontWeight: FontWeight.w900,
        color: Colors.white.withOpacity(0.6),
      ),
    );
  }
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: const Color(0xFF151B2A), // solid surface (readable)
    borderRadius: BorderRadius.circular(18),
    border: Border.all(color: Colors.white.withOpacity(0.08)),
  );
}