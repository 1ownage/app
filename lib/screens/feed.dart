import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../widgets/primitives.dart';

class ReignBanner extends StatelessWidget {
  final int age;
  final String owner;
  final String donated;
  final String endsIn;

  const ReignBanner({
    super.key,
    required this.age,
    required this.owner,
    required this.donated,
    required this.endsIn,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ReignPulse(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(OA.radius4),
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: OA.bg1,
                  border: Border.all(color: OA.gold1, width: 1),
                  borderRadius: BorderRadius.circular(OA.radius4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const OABadge(
                          kind: BadgeKind.reign,
                          child: Text('♛ YOUR REIGN'),
                        ),
                        Text(
                          endsIn,
                          style: OA.mono(size: 12, color: OA.gold1),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        GoldText('$age', size: 140),
                        const SizedBox(width: 14),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'OWN AGE $age',
                                style: OA.display(size: 28, height: 1.0),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '@$owner · ◆$donated defended',
                                style: OA.body(size: 13, color: OA.fg2),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Positioned.fill(
                child: HalftoneOverlay(opacity: 0.08),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum FeedKind { dethrone, reign, challenge }

class FeedCard extends StatelessWidget {
  final FeedKind kind;
  final int age;
  final String? owner;
  final String who;
  final String time;
  final String? amount;
  final String? delta;

  const FeedCard({
    super.key,
    required this.kind,
    required this.age,
    this.owner,
    required this.who,
    required this.time,
    this.amount,
    this.delta,
  });

  @override
  Widget build(BuildContext context) {
    final (accent, headline, badgeKind) = switch (kind) {
      FeedKind.dethrone => (OA.blood1, 'DETHRONED', BadgeKind.live),
      FeedKind.reign => (OA.gold1, 'NEW REIGN', BadgeKind.reign),
      FeedKind.challenge => (OA.electric1, 'CHALLENGE', BadgeKind.viral),
    };

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: OA.bg1,
        border: Border.all(color: OA.stroke1),
        borderRadius: BorderRadius.circular(OA.radius3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OABadge(kind: badgeKind, child: Text(headline)),
              Text(time, style: OA.mono(size: 11, color: OA.fg3)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AvatarBubble(size: 56, accent: accent),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '@$who',
                      style: OA.body(
                        size: 15,
                        weight: FontWeight.w700,
                        color: OA.fg1,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    _subtitle(),
                  ],
                ),
              ),
              Text(
                '$age',
                style: OA.display(
                  size: 36,
                  color: accent,
                  height: 0.85,
                  letterSpacing: -0.02,
                ),
              ),
            ],
          ),
          if (amount != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: OA.stroke1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(amount!, style: OA.mono(size: 14, color: OA.fg1)),
                      if (delta != null) ...[
                        const SizedBox(width: 6),
                        Text(delta!,
                            style: OA.mono(size: 14, color: accent)),
                      ],
                    ],
                  ),
                  _TipChip(),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _subtitle() {
    final style = OA.body(size: 13, color: OA.fg2, height: 1.3);
    final boldStyle = style.copyWith(color: OA.fg1, fontWeight: FontWeight.w700);
    switch (kind) {
      case FeedKind.dethrone:
        return RichText(
          text: TextSpan(
            style: style,
            children: [
              const TextSpan(text: 'took '),
              TextSpan(text: 'age $age', style: boldStyle),
              TextSpan(text: ' from @${owner ?? '—'}'),
            ],
          ),
        );
      case FeedKind.reign:
        return RichText(
          text: TextSpan(
            style: style,
            children: [
              const TextSpan(text: 'started a reign on '),
              TextSpan(text: 'age $age', style: boldStyle),
            ],
          ),
        );
      case FeedKind.challenge:
        return RichText(
          text: TextSpan(
            style: style,
            children: [
              const TextSpan(text: 'is challenging for '),
              TextSpan(text: 'age $age', style: boldStyle),
            ],
          ),
        );
    }
  }
}

class _TipChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: OA.stroke2),
        borderRadius: BorderRadius.circular(OA.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('◆',
              style: TextStyle(color: OA.gold1, fontSize: 10, height: 1.0)),
          const SizedBox(width: 6),
          Text(
            'TIP',
            style: OA.body(
              size: 11,
              weight: FontWeight.w700,
              letterSpacing: 0.06 * 11,
              color: OA.fg1,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

class FeedScreen extends StatelessWidget {
  final ValueChanged<int> onOpenAge;
  const FeedScreen({super.key, required this.onOpenAge});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        const ReignBanner(
          age: 27,
          owner: 'you',
          donated: '4,280',
          endsIn: '03d 04h 12m',
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('LIVE', style: OA.display(size: 24, height: 1.0)),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: OA.blood1,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: OA.blood1, blurRadius: 4),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'REAL-TIME',
                    style: OA.body(
                      size: 11,
                      weight: FontWeight.w700,
                      color: OA.fg3,
                      letterSpacing: 0.08 * 11,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => onOpenAge(34),
          child: const FeedCard(
            kind: FeedKind.dethrone,
            age: 34,
            owner: 'vox',
            who: 'silas',
            time: '2m',
            amount: '◆3,210',
            delta: '+◆210',
          ),
        ),
        GestureDetector(
          onTap: () => onOpenAge(27),
          child: const FeedCard(
            kind: FeedKind.challenge,
            age: 27,
            owner: 'you',
            who: 'kova',
            time: '4m',
            amount: '◆4,120',
            delta: 'trailing ◆160',
          ),
        ),
        GestureDetector(
          onTap: () => onOpenAge(56),
          child: const FeedCard(
            kind: FeedKind.reign,
            age: 56,
            who: 'echo',
            time: '12m',
            amount: '◆2,400',
          ),
        ),
        GestureDetector(
          onTap: () => onOpenAge(19),
          child: const FeedCard(
            kind: FeedKind.dethrone,
            age: 19,
            owner: 'rune',
            who: 'nix',
            time: '38m',
            amount: '◆2,910',
          ),
        ),
      ],
    );
  }
}
