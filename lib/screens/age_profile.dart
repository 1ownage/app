import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../widgets/primitives.dart';

class AgeProfileScreen extends StatelessWidget {
  final int age;
  final VoidCallback onClose;
  final VoidCallback onDethrone;

  const AgeProfileScreen({
    super.key,
    required this.age,
    required this.onClose,
    required this.onDethrone,
  });

  @override
  Widget build(BuildContext context) {
    const contenders = [
      ('marz', 4280, true),
      ('kova', 4120, false),
      ('june9', 3845, false),
      ('silas', 2210, false),
      ('nix', 980, false),
    ];

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.only(bottom: 140),
          children: [
            // Hero
            Container(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: OA.stroke1)),
              ),
              child: Stack(
                children: [
                  const Positioned.fill(
                      child: HalftoneOverlay(opacity: 0.18)),
                  Column(
                    children: [
                      Row(
                        children: [
                          const Spacer(),
                          GestureDetector(
                            onTap: onClose,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: OA.bg1,
                                shape: BoxShape.circle,
                                border: Border.all(color: OA.stroke2),
                              ),
                              child: const Icon(Icons.close,
                                  size: 16, color: OA.fg1),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'AGE',
                        style: OA.body(
                          size: 11,
                          color: OA.fg2,
                          letterSpacing: 0.12 * 11,
                          weight: FontWeight.w700,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: GoldText('$age', size: 200),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          OABadge(
                              kind: BadgeKind.reign,
                              child: Text('♛ REIGNING')),
                          SizedBox(width: 8),
                          OABadge(
                            kind: BadgeKind.live,
                            leadingDot: true,
                            child: Text('LIVE'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '@marz',
                        style: OA.body(
                          size: 20,
                          weight: FontWeight.w700,
                          color: OA.fg1,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ends in 03d 04h 12m',
                        style: OA.mono(size: 13, color: OA.fg2),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Stats strip
            IntrinsicHeight(
              child: Container(
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: OA.stroke1)),
                ),
                child: Row(
                  children: const [
                    _Stat(label: 'THIS WEEK', value: '◆4,280', color: OA.gold1),
                    _StatDivider(),
                    _Stat(label: 'CHALLENGERS', value: '12', color: OA.fg1),
                    _StatDivider(),
                    _Stat(label: 'LEAD', value: '◆160', color: OA.electric1),
                  ],
                ),
              ),
            ),
            // Contenders
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CONTENDERS',
                      style: OA.display(size: 24, height: 0.9)),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: OA.bg1,
                      border: Border.all(color: OA.stroke1),
                      borderRadius: BorderRadius.circular(OA.radius3),
                    ),
                    child: Column(
                      children: [
                        for (int i = 0; i < contenders.length; i++)
                          _ContenderRow(
                            rank: i + 1,
                            who: contenders[i].$1,
                            amt: contenders[i].$2,
                            reigning: contenders[i].$3,
                            isLast: i == contenders.length - 1,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        // Sticky dethrone button
        Positioned(
          left: 16,
          right: 16,
          bottom: 20,
          child: Row(
            children: [
              OAButton(
                variant: OAButtonVariant.ghost,
                leadingIcon: Icons.ios_share,
                child: const Text('SHARE'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OAButton(
                  variant: OAButtonVariant.blood,
                  expand: true,
                  leadingGlyph: '▲',
                  onPressed: onDethrone,
                  child: const Text('DETHRONE @MARZ'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _Stat(
      {required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(value, style: OA.mono(size: 22, color: color)),
            const SizedBox(height: 2),
            Text(
              label,
              style: OA.body(
                size: 10,
                weight: FontWeight.w700,
                color: OA.fg3,
                letterSpacing: 0.08 * 10,
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, color: OA.stroke1);
  }
}

class _ContenderRow extends StatelessWidget {
  final int rank;
  final String who;
  final int amt;
  final bool reigning;
  final bool isLast;
  const _ContenderRow({
    required this.rank,
    required this.who,
    required this.amt,
    required this.reigning,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
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
            width: 28,
            child: Text(
              '#${rank.toString().padLeft(2, '0')}',
              style: OA.mono(
                size: 12,
                color: reigning ? OA.gold1 : OA.fg2,
              ),
            ),
          ),
          const SizedBox(width: 10),
          AvatarBubble(size: 28, reigning: reigning),
          const SizedBox(width: 10),
          Expanded(
            child: Row(
              children: [
                Text(
                  '@$who',
                  style: OA.body(
                    size: 14,
                    weight: FontWeight.w700,
                    color: OA.fg1,
                    height: 1.0,
                  ),
                ),
                if (reigning)
                  const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child:
                        Text('♛', style: TextStyle(color: OA.gold1, fontSize: 10)),
                  ),
              ],
            ),
          ),
          Text('◆${_fmt(amt)}', style: OA.mono(size: 13, color: OA.fg1)),
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

// ── Donate / tip modal ───────────────────────────────────────────────
class DonateSheet extends StatefulWidget {
  final int age;
  final String owner;
  final VoidCallback onClose;
  final ValueChanged<int> onSend;
  const DonateSheet({
    super.key,
    required this.age,
    required this.owner,
    required this.onClose,
    required this.onSend,
  });
  @override
  State<DonateSheet> createState() => _DonateSheetState();
}

class _DonateSheetState extends State<DonateSheet> {
  int _amt = 50;
  static const presets = [5, 20, 50, 100, 250];
  static const threshold = 161;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onClose,
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: Colors.black.withValues(alpha: 0.72),
        child: Column(
          children: [
            const Spacer(),
            GestureDetector(
              onTap: () {},
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: OA.bg1,
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(OA.radius4)),
                  border: Border.all(color: OA.stroke1),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: OA.stroke3,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'TIP TO DETHRONE @${widget.owner}'.toUpperCase(),
                      style: OA.body(
                        size: 11,
                        color: OA.fg2,
                        weight: FontWeight.w700,
                        letterSpacing: 0.12 * 11,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'FOR AGE ',
                            style: OA.display(size: 40, height: 1.0),
                          ),
                          TextSpan(
                            text: '${widget.age}',
                            style: OA.display(
                                size: 40, height: 1.0, color: OA.gold1),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: OA.bg2,
                        border: Border.all(color: OA.stroke1),
                        borderRadius: BorderRadius.circular(OA.radius3),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'YOUR TIP',
                            style: OA.body(
                              size: 10,
                              color: OA.fg3,
                              weight: FontWeight.w700,
                              letterSpacing: 0.08 * 10,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text('◆$_amt',
                              style: OA.mono(size: 48, color: OA.gold1)),
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            alignment: WrapAlignment.center,
                            children: [
                              for (final p in presets)
                                GestureDetector(
                                  onTap: () => setState(() => _amt = p),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: _amt == p
                                          ? OA.gold1
                                          : Colors.transparent,
                                      border: Border.all(
                                        color: _amt == p
                                            ? OA.gold1
                                            : OA.stroke2,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                          OA.radiusFull),
                                    ),
                                    child: Text(
                                      '◆$p',
                                      style: OA.mono(
                                        size: 13,
                                        color: _amt == p ? OA.fgInv : OA.fg1,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _helper(),
                    const SizedBox(height: 16),
                    OAButton(
                      variant: OAButtonVariant.blood,
                      expand: true,
                      leadingGlyph: '▲',
                      onPressed: () => widget.onSend(_amt),
                      child: Text('SEND ◆$_amt · ATTACK'),
                    ),
                    const SizedBox(height: 8),
                    OAButton(
                      variant: OAButtonVariant.ghost,
                      expand: true,
                      onPressed: widget.onClose,
                      child: const Text('CANCEL'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _helper() {
    if (_amt >= threshold) {
      return Text(
        '✦ This tip will dethrone @${widget.owner}',
        style: OA.body(size: 12, color: OA.electric1, height: 1.3),
      );
    }
    final remaining = threshold - _amt;
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: OA.body(size: 12, color: OA.fg2, height: 1.3),
        children: [
          const TextSpan(text: 'Need '),
          TextSpan(
            text: '◆$remaining',
            style: OA.body(
              size: 12,
              color: OA.gold1,
              weight: FontWeight.w700,
              height: 1.3,
            ),
          ),
          const TextSpan(text: ' more to dethrone'),
        ],
      ),
    );
  }
}
