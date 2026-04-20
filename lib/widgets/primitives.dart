import 'package:flutter/material.dart';
import '../theme/tokens.dart';

enum BadgeKind { reign, live, viral, info, neutral }

class OABadge extends StatelessWidget {
  final BadgeKind kind;
  final Widget child;
  final bool leadingDot;
  const OABadge({
    super.key,
    this.kind = BadgeKind.neutral,
    required this.child,
    this.leadingDot = false,
  });

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (kind) {
      BadgeKind.reign => (OA.gold1.withValues(alpha: 0.14), OA.gold1),
      BadgeKind.live => (OA.blood1.withValues(alpha: 0.14), OA.blood1),
      BadgeKind.viral => (OA.electric1.withValues(alpha: 0.12), OA.electric1),
      BadgeKind.info => (OA.ice1.withValues(alpha: 0.12), OA.ice1),
      BadgeKind.neutral => (Colors.white.withValues(alpha: 0.06), OA.fg2),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(OA.radius1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leadingDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: fg,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: fg, blurRadius: 4)],
              ),
            ),
            const SizedBox(width: 6),
          ],
          DefaultTextStyle(
            style: OA.body(
              size: 10,
              color: fg,
              weight: FontWeight.w700,
              letterSpacing: 0.08 * 10,
              height: 1.0,
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}

enum OAButtonVariant { primary, gold, blood, ghost }

class OAButton extends StatefulWidget {
  final OAButtonVariant variant;
  final Widget child;
  final IconData? leadingIcon;
  final String? leadingGlyph;
  final VoidCallback? onPressed;
  final bool expand;
  const OAButton({
    super.key,
    this.variant = OAButtonVariant.primary,
    required this.child,
    this.leadingIcon,
    this.leadingGlyph,
    this.onPressed,
    this.expand = false,
  });

  @override
  State<OAButton> createState() => _OAButtonState();
}

class _OAButtonState extends State<OAButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final content = Row(
      mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.leadingIcon != null) ...[
          Icon(widget.leadingIcon, size: 16),
          const SizedBox(width: 8),
        ] else if (widget.leadingGlyph != null) ...[
          Text(widget.leadingGlyph!, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
        ],
        DefaultTextStyle.merge(
          style: OA.body(
            size: 14,
            weight: FontWeight.w700,
            letterSpacing: 0.05 * 14,
            height: 1.0,
            color: _fgFor(widget.variant),
          ),
          child: widget.child,
        ),
      ],
    );

    final padding = const EdgeInsets.symmetric(horizontal: 22, vertical: 14);
    final radius = BorderRadius.circular(10);

    Decoration deco;
    switch (widget.variant) {
      case OAButtonVariant.primary:
        deco = BoxDecoration(color: OA.fg1, borderRadius: radius);
        break;
      case OAButtonVariant.gold:
        deco = BoxDecoration(
          gradient: OA.gradGold,
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
                color: OA.gold1.withValues(alpha: 0.3),
                blurRadius: 24,
                spreadRadius: 0)
          ],
        );
        break;
      case OAButtonVariant.blood:
        deco = BoxDecoration(
          color: OA.blood1,
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
                color: OA.blood1.withValues(alpha: 0.35),
                blurRadius: 24,
                spreadRadius: 0)
          ],
        );
        break;
      case OAButtonVariant.ghost:
        deco = BoxDecoration(
          color: Colors.transparent,
          borderRadius: radius,
          border: Border.all(color: OA.stroke2, width: 1),
        );
        break;
    }

    Widget btn = AnimatedScale(
      scale: _pressed ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 80),
      curve: Curves.easeOut,
      child: DecoratedBox(
        decoration: deco,
        child: Padding(
          padding: padding,
          child: DefaultTextStyle.merge(
            style: TextStyle(color: _fgFor(widget.variant)),
            child: IconTheme.merge(
              data: IconThemeData(color: _fgFor(widget.variant)),
              child: content,
            ),
          ),
        ),
      ),
    );

    if (widget.expand) {
      btn = SizedBox(width: double.infinity, child: btn);
    }

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onPressed,
      child: btn,
    );
  }

  Color _fgFor(OAButtonVariant v) {
    switch (v) {
      case OAButtonVariant.primary:
        return OA.fgInv;
      case OAButtonVariant.gold:
        return OA.fgInv;
      case OAButtonVariant.blood:
        return OA.fg1;
      case OAButtonVariant.ghost:
        return OA.fg1;
    }
  }
}

class OAStatusBar extends StatelessWidget {
  const OAStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '9:41',
            style: OA.body(
              size: 15,
              weight: FontWeight.w600,
              color: OA.fg1,
              height: 1.0,
            ),
          ),
          Row(
            children: [
              Text(
                '●●●●',
                style: OA.body(size: 12, color: OA.fg1, height: 1.0),
              ),
              const SizedBox(width: 6),
              Text(
                '5G',
                style: OA.body(size: 12, color: OA.fg1, height: 1.0),
              ),
              const SizedBox(width: 6),
              Container(
                width: 24,
                height: 11,
                decoration: BoxDecoration(
                  border: Border.all(color: OA.fg1, width: 1),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(1),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: 0.8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: OA.fg1,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class OAAppHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onBell;
  const OAAppHeader({super.key, required this.title, this.onBell});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: OA.stroke1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // Logo mark — chevron-crown stylized
              const _LogoMark(size: 28),
              const SizedBox(width: 10),
              Text(
                title,
                style: OA.display(size: 24, height: 1.0),
              ),
            ],
          ),
          GestureDetector(
            onTap: onBell,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: OA.stroke1, width: 1),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.notifications_none,
                      size: 18, color: OA.fg1),
                  Positioned(
                    top: 8,
                    right: 9,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: OA.blood1,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: OA.blood1, blurRadius: 6),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoMark extends StatelessWidget {
  final double size;
  const _LogoMark({required this.size});
  @override
  Widget build(BuildContext context) {
    // Crown ♛ inside a gold ring — wearable trophy seal from the chat.
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: OA.gradGold,
        boxShadow: [
          BoxShadow(
              color: OA.gold1.withValues(alpha: 0.3), blurRadius: 8),
        ],
      ),
      child: Center(
        child: Text(
          '♛',
          style: TextStyle(
            color: OA.fgInv,
            fontSize: size * 0.65,
            height: 1.0,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class TabSpec {
  final String id;
  final IconData icon;
  final String label;
  const TabSpec(this.id, this.icon, this.label);
}

const oaTabs = <TabSpec>[
  TabSpec('feed', Icons.home_outlined, 'Feed'),
  TabSpec('ages', Icons.grid_view_outlined, 'Ages'),
  TabSpec('me', Icons.person_outline, 'Me'),
  TabSpec('lb', Icons.emoji_events_outlined, 'Top'),
  TabSpec('wallet', Icons.account_balance_wallet_outlined, 'Wallet'),
];

class OATabBar extends StatelessWidget {
  final String active;
  final ValueChanged<String> onChange;
  const OATabBar({super.key, required this.active, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: OA.bg1,
        border: Border(top: BorderSide(color: OA.stroke1)),
      ),
      child: Row(
        children: [
          for (final t in oaTabs)
            Expanded(
              child: InkWell(
                onTap: () => onChange(t.id),
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(
                        t.icon,
                        size: 22,
                        color: active == t.id ? OA.gold1 : OA.fg3,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        t.label.toUpperCase(),
                        style: OA.body(
                          size: 10,
                          weight: FontWeight.w700,
                          letterSpacing: 0.06 * 10,
                          color: active == t.id ? OA.gold1 : OA.fg3,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class GoldText extends StatelessWidget {
  final String text;
  final double size;
  final double height;
  final double letterSpacing;
  const GoldText(
    this.text, {
    super.key,
    required this.size,
    this.height = 0.85,
    this.letterSpacing = -0.03,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (r) => OA.gradGold.createShader(r),
      child: Text(
        text,
        style: OA.display(
          size: size,
          height: height,
          letterSpacing: letterSpacing,
          color: Colors.white,
        ),
      ),
    );
  }
}

class AvatarBubble extends StatelessWidget {
  final double size;
  final Color? accent;
  final bool reigning;
  const AvatarBubble({
    super.key,
    this.size = 56,
    this.accent,
    this.reigning = false,
  });

  @override
  Widget build(BuildContext context) {
    final a = accent ?? OA.bg3;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [a, OA.bg1],
        ),
        border: Border.all(
          color: reigning ? OA.gold1 : a,
          width: reigning ? 2 : 1,
        ),
        boxShadow: reigning
            ? [
                BoxShadow(
                    color: OA.gold1.withValues(alpha: 0.35), blurRadius: 12),
              ]
            : null,
      ),
    );
  }
}

/// Subtle halftone / grain overlay — painted with CustomPainter since we
/// don't have the SVG texture wired as an asset.
class HalftoneOverlay extends StatelessWidget {
  final double opacity;
  const HalftoneOverlay({super.key, this.opacity = 0.12});
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Opacity(
        opacity: opacity,
        child: CustomPaint(
          painter: _HalftonePainter(),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _HalftonePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = OA.fg1;
    const step = 14.0;
    for (double y = 0; y < size.height + step; y += step) {
      for (double x = -step; x < size.width + step; x += step) {
        final ox = ((y / step).floor() % 2 == 0) ? 0.0 : step / 2;
        canvas.drawCircle(Offset(x + ox, y), 0.9, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Gold pulsing glow for reigning-age cards.
class ReignPulse extends StatefulWidget {
  final Widget child;
  final double radius;
  const ReignPulse({super.key, required this.child, this.radius = 20});

  @override
  State<ReignPulse> createState() => _ReignPulseState();
}

class _ReignPulseState extends State<ReignPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final t = _c.value;
        final blur = 24 + 24 * t;
        final alpha = 0.15 + 0.20 * t;
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            boxShadow: [
              BoxShadow(
                color: OA.gold1.withValues(alpha: alpha),
                blurRadius: blur,
              ),
            ],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class LiveDot extends StatefulWidget {
  final Color color;
  final double size;
  const LiveDot({super.key, this.color = OA.blood1, this.size = 8});
  @override
  State<LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<LiveDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        final t = _c.value;
        return Opacity(
          opacity: 1 - t * 0.5,
          child: Transform.scale(
            scale: 1 - t * 0.1,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: widget.color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: widget.color, blurRadius: 12),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
