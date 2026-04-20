import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../widgets/primitives.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const rows = [
      ('Defended age 27', '-◆240', OA.fg1, '12m ago'),
      ('Tip from @nova', '+◆50', OA.electric1, '1h ago'),
      ('Attacked age 34', '-◆180', OA.blood1, '3h ago'),
    ];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: OA.bg1,
            border: Border.all(color: OA.stroke1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'BALANCE',
                style: OA.body(
                  size: 11,
                  color: OA.fg3,
                  weight: FontWeight.w700,
                  letterSpacing: 0.08 * 11,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 4),
              Text('◆1,240.00',
                  style: OA.mono(size: 44, color: OA.gold1)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OAButton(
                      variant: OAButtonVariant.primary,
                      expand: true,
                      child: const Text('LOAD UP'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OAButton(
                      variant: OAButtonVariant.ghost,
                      expand: true,
                      child: const Text('CASH OUT'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text('RECENT', style: OA.display(size: 24, height: 0.9)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: OA.bg1,
            border: Border.all(color: OA.stroke1),
            borderRadius: BorderRadius.circular(OA.radius3),
          ),
          child: Column(
            children: [
              for (int i = 0; i < rows.length; i++)
                _TxRow(
                  title: rows[i].$1,
                  amount: rows[i].$2,
                  amountColor: rows[i].$3,
                  when: rows[i].$4,
                  isLast: i == rows.length - 1,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TxRow extends StatelessWidget {
  final String title;
  final String amount;
  final Color amountColor;
  final String when;
  final bool isLast;
  const _TxRow({
    required this.title,
    required this.amount,
    required this.amountColor,
    required this.when,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border:
            isLast ? null : Border(bottom: BorderSide(color: OA.stroke1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: OA.body(size: 14, color: OA.fg1, height: 1.2)),
                const SizedBox(height: 2),
                Text(
                  when.toUpperCase(),
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
          Text(amount, style: OA.mono(size: 14, color: amountColor)),
        ],
      ),
    );
  }
}
