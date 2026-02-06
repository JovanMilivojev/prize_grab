import 'package:flutter/material.dart';
import '../widgets/winter_background.dart';

/// ==============================
/// MODEL: jedan unos na tabeli
/// ==============================
class LeaderboardEntry {
  final int rank;
  final String username;
  final int score;

  const LeaderboardEntry({
    required this.rank,
    required this.username,
    required this.score,
  });
}

/// ==============================
/// SCREEN: Leaderboard (CP2 - UI)
/// ==============================
class Leaderboard extends StatelessWidget {
  const Leaderboard({super.key});

  static const route = '/leaderboard';

  /// CP2: Mock podaci (kasnije u CP3 iz Firestore-a)
  static const List<LeaderboardEntry> _mockData = [
    LeaderboardEntry(rank: 1, username: 'Jovan Milivojev', score: 1250),
    LeaderboardEntry(rank: 2, username: 'Igor Mirković', score: 980),
    LeaderboardEntry(rank: 3, username: 'Marko Petrović', score: 850),
    LeaderboardEntry(rank: 4, username: 'Ana Jovanović', score: 720),
    LeaderboardEntry(rank: 5, username: 'Stefan Nikolić', score: 650),
    LeaderboardEntry(rank: 6, username: 'Jelena Đorđević', score: 580),
    LeaderboardEntry(rank: 7, username: 'Nikola Stojanović', score: 510),
  ];

  /// CP2: gost vidi leaderboard ali ne učestvuje
  /// Kasnije u CP3 ovo dolazi iz Auth-a
  final bool isGuest = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// WinterBackground je wrapper:
      /// - postavlja sliku
      /// - overlay
      /// - SafeArea
      /// Zato sav sadržaj ekrana ide u child.
      body: WinterBackground(
        child: Column(
          children: [
            const SizedBox(height: 10),

            // ==============================
            // BACK dugme (gore levo)
            // ==============================
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 14),
                child: _BackButton(onTap: () => Navigator.pop(context)),
              ),
            ),

            const SizedBox(height: 10),

            // ==============================
            // NASLOV
            // ==============================
            const Text(
              'Leaderboard',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E3A8A),
              ),
            ),

            const SizedBox(height: 18),

            // ==============================
            // CENTRALNA KARTICA SA LISTOM
            // ==============================
            Expanded(
              child: Center(
                child: Container(
                  width: 300,
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 24,
                        offset: Offset(0, 14),
                        color: Colors.black26,
                      ),
                    ],
                    border: Border.all(
                      color: const Color(0xFFBBD7FF),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      // ==============================
                      // LISTA (scroll)
                      // ==============================
                      Expanded(
                        child: Scrollbar(
                          thumbVisibility: true,
                          child: ListView.builder(
                            itemCount: _mockData.length,
                            itemBuilder: (context, index) {
                              final entry = _mockData[index];
                              return _LeaderboardRow(entry: entry);
                            },
                          ),
                        ),
                      ),

                      // ==============================
                      // PORUKA ZA GOSTA (CP2 logika)
                      // ==============================
                      if (isGuest) ...[
                        const SizedBox(height: 10),
                        const Text(
                          'Login to compete on the leaderboard',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF2563EB),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ==============================
/// BACK BUTTON WIDGET
/// ==============================
class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.85),
      shape: const CircleBorder(),
      elevation: 4,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.all(10),
          child: Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: Color(0xFF1E3A8A),
          ),
        ),
      ),
    );
  }
}

/// ==============================
/// JEDAN RED U LEADERBOARD-U
/// ==============================
class _LeaderboardRow extends StatelessWidget {
  const _LeaderboardRow({required this.entry});

  final LeaderboardEntry entry;

  @override
  Widget build(BuildContext context) {
    final bool isTopThree = entry.rank <= 3;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: isTopThree ? const Color(0xFFE8F1FF) : const Color(0xFFF5F7FB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBBD7FF), width: 1),
      ),
      child: Row(
        children: [
          // Levo: ikonica za top 3 / rank broj
          SizedBox(
            width: 30,
            child: Center(
              child: isTopThree
                  ? Icon(
                      _topIcon(entry.rank),
                      size: 18,
                      color: _topColor(entry.rank),
                    )
                  : Text(
                      '${entry.rank}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2563EB),
                      ),
                    ),
            ),
          ),

          const SizedBox(width: 10),

          // Sredina: username
          Expanded(
            child: Text(
              entry.username,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isTopThree ? FontWeight.w800 : FontWeight.w600,
                color: const Color(0xFF1E3A8A),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Desno: score
          Text(
            entry.score.toString(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: isTopThree
                  ? const Color(0xFF2563EB)
                  : const Color(0xFF1E3A8A),
            ),
          ),
        ],
      ),
    );
  }

  // Ikonice za top 3
  IconData _topIcon(int rank) {
    if (rank == 1) return Icons.emoji_events;
    if (rank == 2) return Icons.military_tech;
    return Icons.workspace_premium;
  }

  // Boje za top 3 ikonice
  Color _topColor(int rank) {
    if (rank == 1) return const Color(0xFFF59E0B);
    if (rank == 2) return const Color(0xFF94A3B8);
    return const Color(0xFFFB7185);
  }
}
