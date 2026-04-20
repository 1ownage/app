import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../widgets/primitives.dart';

enum AgeStatus { reigning, held, lost }

class MeScreen extends StatelessWidget {
  const MeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const ages = [
      (27, AgeStatus.reigning),
      (28, AgeStatus.held),
      (44, AgeStatus.held),
      (61, AgeStatus.lost),
    ];
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        // Hero
        Container(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: OA.stroke1)),
          ),
          child: Stack(
            children: [
              const Positioned.fill(child: HalftoneOverlay(opacity: 0.12)),
              Column(
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF3A3A42), OA.bg1],
                      ),
                      border: Border.all(color: OA.gold1, width: 2),
                      boxShadow: [
                        BoxShadow(
                            color: OA.gold1.withValues(alpha: 0.3),
                            blurRadius: 24),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('@YOU',
                      style: OA.display(size: 32, height: 1.0)),
                  const SizedBox(height: 4),
                  Text(
                    'joined Week 12, 2026 · 4 reigns this year',
                    style: OA.body(size: 12, color: OA.fg2, height: 1.0),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('YOUR AGES', style: OA.display(size: 24, height: 0.9)),
              const SizedBox(height: 8),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: ((390 - 32 - 16) / 3) / 130,
                children: [
                  for (final a in ages)
                    _MyAgeTile(age: a.$1, status: a.$2),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MyAgeTile extends StatelessWidget {
  final int age;
  final AgeStatus status;
  const _MyAgeTile({required this.age, required this.status});

  @override
  Widget build(BuildContext context) {
    final reigning = status == AgeStatus.reigning;
    final lost = status == AgeStatus.lost;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: OA.bg1,
        border: Border.all(color: reigning ? OA.gold1 : OA.stroke1),
        borderRadius: BorderRadius.circular(OA.radius3),
        boxShadow: reigning
            ? [
                BoxShadow(
                    color: OA.gold1.withValues(alpha: 0.18), blurRadius: 24),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          reigning
              ? GoldText('$age', size: 56, letterSpacing: -0.02)
              : Text(
                  '$age',
                  style: OA.display(
                    size: 56,
                    height: 0.85,
                    color: lost ? OA.fg3 : OA.fg1,
                    letterSpacing: -0.02,
                  ),
                ),
          Text(
            switch (status) {
              AgeStatus.reigning => '♛ REIGNING',
              AgeStatus.held => 'HELD',
              AgeStatus.lost => 'DETHRONED',
            },
            style: OA.body(
              size: 10,
              weight: FontWeight.w700,
              color: switch (status) {
                AgeStatus.reigning => OA.gold1,
                AgeStatus.held => OA.fg2,
                AgeStatus.lost => OA.blood1,
              },
              letterSpacing: 0.08 * 10,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}
