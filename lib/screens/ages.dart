import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../widgets/primitives.dart';

class AgeTile extends StatelessWidget {
  final int age;
  final String? owner;
  final bool reigning;
  final bool unclaimed;
  final VoidCallback? onTap;

  const AgeTile({
    super.key,
    required this.age,
    this.owner,
    this.reigning = false,
    this.unclaimed = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(OA.radius3),
      child: Container(
        height: 130,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: OA.bg1,
          border: Border.all(
            color: reigning ? OA.gold1 : OA.stroke1,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(OA.radius3),
          boxShadow: reigning
              ? [
                  BoxShadow(
                      color: OA.gold1.withValues(alpha: 0.18), blurRadius: 24),
                ]
              : null,
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                reigning
                    ? GoldText('$age', size: 54, letterSpacing: -0.02)
                    : Text(
                        '$age',
                        style: OA.display(
                          size: 54,
                          color: unclaimed ? OA.fg3 : OA.fg1,
                          height: 0.85,
                          letterSpacing: -0.02,
                        ),
                      ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      unclaimed ? 'UNCLAIMED' : '@${owner ?? '—'}',
                      style: OA.body(
                        size: 12,
                        weight: FontWeight.w700,
                        color: unclaimed ? OA.fg3 : OA.fg1,
                        height: 1.0,
                      ).copyWith(
                        fontStyle:
                            unclaimed ? FontStyle.italic : FontStyle.normal,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      unclaimed
                          ? 'BE FIRST'
                          : (reigning ? 'REIGN' : 'HELD'),
                      style: OA.body(
                        size: 10,
                        weight: FontWeight.w700,
                        color: reigning ? OA.gold1 : OA.fg3,
                        letterSpacing: 0.06 * 10,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (reigning)
              const Positioned(
                top: 0,
                right: 0,
                child: Text('♛',
                    style: TextStyle(color: OA.gold1, fontSize: 13)),
              ),
          ],
        ),
      ),
    );
  }
}

class AgesScreen extends StatelessWidget {
  final ValueChanged<int> onOpen;
  const AgesScreen({super.key, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final cells = List.generate(36, (i) {
      final age = 20 + i;
      final unclaimed = const [22, 31, 39, 48, 51].contains(age);
      final reigning = age == 27;
      const owners = [
        'marz', 'silas', 'kova', 'june9', 'nix',
        'vox', 'echo', 'rune', 'aja', 'cyd'
      ];
      return AgeTile(
        age: age,
        reigning: reigning,
        unclaimed: unclaimed,
        owner: unclaimed ? null : owners[i % owners.length],
        onTap: () => onOpen(age),
      );
    });

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ALL AGES', style: OA.display(size: 32, height: 0.9)),
                const SizedBox(height: 2),
                Text(
                  '120 seats · 87 claimed · 33 open',
                  style: OA.body(size: 12, color: OA.fg2, height: 1.0),
                ),
              ],
            ),
            _JumpChip(),
          ],
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: ((390 - 32 - 16) / 3) / 130,
          children: cells,
        ),
      ],
    );
  }
}

class _JumpChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: OA.bg1,
        border: Border.all(color: OA.stroke2),
        borderRadius: BorderRadius.circular(OA.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search, size: 12, color: OA.fg1),
          const SizedBox(width: 6),
          Text(
            'JUMP',
            style: OA.body(
              size: 11,
              weight: FontWeight.w700,
              color: OA.fg1,
              letterSpacing: 0.06 * 11,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Leaderboard ───────────────────────────────────────────────────────
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});
  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final rows = const [
      (1, 'marz', 27, 4280, '+2'),
      (2, 'kova', 27, 4120, '-1'),
      (3, 'june9', 27, 3845, '='),
      (4, 'silas', 34, 3210, '+5'),
      (5, 'nix', 19, 2910, '+1'),
      (6, 'vox', 41, 2640, '-2'),
      (7, 'echo', 56, 2400, '+3'),
    ];

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('WEEK 41 LEADERBOARD',
                  style: OA.display(size: 32, height: 0.9)),
              const SizedBox(height: 8),
              Row(
                children: [
                  _LbTab(
                      label: 'This Week',
                      active: _tab == 0,
                      onTap: () => setState(() => _tab = 0)),
                  const SizedBox(width: 4),
                  _LbTab(
                      label: 'All Time',
                      active: _tab == 1,
                      onTap: () => setState(() => _tab = 1)),
                  const SizedBox(width: 4),
                  _LbTab(
                      label: 'Friends',
                      active: _tab == 2,
                      onTap: () => setState(() => _tab = 2)),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: BoxDecoration(
              color: OA.bg1,
              border: Border.all(color: OA.stroke1),
              borderRadius: BorderRadius.circular(OA.radius3),
            ),
            child: Column(
              children: [
                for (int i = 0; i < rows.length; i++)
                  _LbRow(
                    rank: rows[i].$1,
                    who: rows[i].$2,
                    age: rows[i].$3,
                    amt: rows[i].$4,
                    change: rows[i].$5,
                    isLast: i == rows.length - 1,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _LbTab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _LbTab(
      {required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? OA.bg2 : Colors.transparent,
          borderRadius: BorderRadius.circular(OA.radiusFull),
        ),
        child: Text(
          label.toUpperCase(),
          style: OA.body(
            size: 12,
            weight: FontWeight.w700,
            color: active ? OA.fg1 : OA.fg2,
            letterSpacing: 0.06 * 12,
            height: 1.0,
          ),
        ),
      ),
    );
  }
}

class _LbRow extends StatelessWidget {
  final int rank;
  final String who;
  final int age;
  final int amt;
  final String change;
  final bool isLast;
  const _LbRow({
    required this.rank,
    required this.who,
    required this.age,
    required this.amt,
    required this.change,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final top = rank == 1;
    final Color changeColor = change.startsWith('+')
        ? OA.electric1
        : change.startsWith('-')
            ? OA.blood1
            : OA.fg3;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: OA.stroke1)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              '#${rank.toString().padLeft(2, '0')}',
              style: OA.mono(
                size: 13,
                color: top ? OA.gold1 : OA.fg2,
              ),
            ),
          ),
          const SizedBox(width: 10),
          AvatarBubble(size: 32, reigning: top),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '@$who',
                      style: OA.body(
                          size: 14,
                          weight: FontWeight.w700,
                          color: OA.fg1,
                          height: 1.2),
                    ),
                    if (top)
                      const Padding(
                        padding: EdgeInsets.only(left: 6),
                        child: Text('♛',
                            style: TextStyle(color: OA.gold1, fontSize: 10)),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'REIGNING AGE $age',
                  style: OA.body(
                    size: 11,
                    color: OA.fg3,
                    letterSpacing: 0.06 * 11,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Text(
              change,
              style: OA.mono(size: 13, color: changeColor),
            ),
          ),
          SizedBox(
            width: 64,
            child: Text(
              '◆${_fmt(amt)}',
              textAlign: TextAlign.right,
              style: OA.mono(size: 13, color: OA.fg1),
            ),
          ),
        ],
      ),
    );
  }

  static String _fmt(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}
