import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../widgets/primitives.dart';

enum _MeTab { posts, reign, fans }

class MeScreen extends StatefulWidget {
  const MeScreen({super.key});

  @override
  State<MeScreen> createState() => _MeScreenState();
}

class _MeScreenState extends State<MeScreen> {
  _MeTab _tab = _MeTab.posts;

  static const _posts = <_Post>[
    _Post(
      text: '27 is mine. defending through sunday. tips keep me here ♛',
      likes: 184,
      comments: 22,
      when: '4h',
    ),
    _Post(
      text: 'shoutout to @nova, @kova for the defense squad this week',
      likes: 92,
      comments: 8,
      when: '1d',
    ),
    _Post(
      text: 'new share card dropped → link in bio',
      likes: 310,
      comments: 41,
      when: '2d',
    ),
  ];

  static const _reignLog = <_ReignRow>[
    _ReignRow(week: 'WK 41', held: true, amt: '◆4,280'),
    _ReignRow(week: 'WK 40', held: true, amt: '◆3,920'),
    _ReignRow(week: 'WK 39', held: false, amt: '◆2,100'),
    _ReignRow(week: 'WK 38', held: true, amt: '◆3,440'),
  ];

  static const _fans = <String>[
    'nova',
    'kova',
    'silas',
    'june9',
    'nix',
    'vox',
    'echo',
    'rune',
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        _Header(),
        _Composer(),
        _TabStrip(
          active: _tab,
          onTap: (t) => setState(() => _tab = t),
        ),
        if (_tab == _MeTab.posts) _PostsList(posts: _posts),
        if (_tab == _MeTab.reign) _ReignLog(rows: _reignLog),
        if (_tab == _MeTab.fans) _FansGrid(handles: _fans),
      ],
    );
  }
}

// ── Header ───────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: OA.stroke1)),
      ),
      child: Stack(
        children: [
          const Positioned.fill(child: HalftoneOverlay(opacity: 0.10)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _InitialAvatar(letter: 'M'),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '@marz',
                          style: OA.display(size: 28, height: 1.0),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: const [
                            OABadge(
                              kind: BadgeKind.reign,
                              child: Text('♛ AGE 27'),
                            ),
                            SizedBox(width: 6),
                            OABadge(
                              kind: BadgeKind.neutral,
                              child: Text('WK 41 · DAY 4'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '184 fans · 92 tips · 4 reigns',
                          style: OA.mono(size: 11, color: OA.fg2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              RichText(
                text: TextSpan(
                  style: OA.body(size: 14, color: OA.fg1, height: 1.5),
                  children: [
                    const TextSpan(
                      text: 'taking age 27 back every week. '
                          'dm for squad coords.\n',
                    ),
                    TextSpan(
                      text: 'linktr.ee/marz27',
                      style: OA.body(
                        size: 14,
                        color: OA.ice1,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OAButton(
                      variant: OAButtonVariant.primary,
                      expand: true,
                      child: const Text('EDIT PROFILE'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OAButton(
                      variant: OAButtonVariant.ghost,
                      expand: true,
                      leadingIcon: Icons.ios_share,
                      child: const Text('PROMOTE'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InitialAvatar extends StatelessWidget {
  final String letter;
  const _InitialAvatar({required this.letter});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 84,
      height: 84,
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
              color: OA.gold1.withValues(alpha: 0.3), blurRadius: 24),
        ],
      ),
      child: Center(
        child: Text(
          letter,
          style: OA.display(size: 44, color: OA.gold1, height: 1.0),
        ),
      ),
    );
  }
}

// ── Composer ─────────────────────────────────────────────────────────
class _Composer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: OA.stroke1)),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: OA.bg1,
          border: Border.all(color: OA.stroke1),
          borderRadius: BorderRadius.circular(OA.radius3),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 48,
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'rally your fans. post an update…',
                  style: OA.body(size: 14, color: OA.fg3, height: 1.4),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    _ComposerGlyph(glyph: '✦'),
                    SizedBox(width: 8),
                    _ComposerGlyph(icon: Icons.ios_share),
                    SizedBox(width: 8),
                    _ComposerGlyph(glyph: '◆'),
                  ],
                ),
                _PostChip(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ComposerGlyph extends StatelessWidget {
  final String? glyph;
  final IconData? icon;
  const _ComposerGlyph({this.glyph, this.icon});
  @override
  Widget build(BuildContext context) {
    if (icon != null) {
      return Icon(icon, size: 18, color: OA.fg2);
    }
    return Text(
      glyph!,
      style: TextStyle(
        color: OA.fg2,
        fontSize: 16,
        height: 1.0,
      ),
    );
  }
}

class _PostChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: OA.gold1,
        borderRadius: BorderRadius.circular(OA.radiusFull),
      ),
      child: Text(
        'POST',
        style: OA.body(
          size: 11,
          weight: FontWeight.w700,
          color: OA.fgInv,
          letterSpacing: 0.06 * 11,
          height: 1.0,
        ),
      ),
    );
  }
}

// ── Tabs ─────────────────────────────────────────────────────────────
class _TabStrip extends StatelessWidget {
  final _MeTab active;
  final ValueChanged<_MeTab> onTap;
  const _TabStrip({required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: OA.stroke1)),
      ),
      child: Row(
        children: [
          _tab(_MeTab.posts, 'Posts'),
          _tab(_MeTab.reign, 'Reign log'),
          _tab(_MeTab.fans, 'Fans'),
        ],
      ),
    );
  }

  Widget _tab(_MeTab id, String label) {
    final isActive = id == active;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap(id),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? OA.gold1 : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label.toUpperCase(),
            textAlign: TextAlign.center,
            style: OA.body(
              size: 12,
              weight: FontWeight.w700,
              color: isActive ? OA.fg1 : OA.fg3,
              letterSpacing: 0.08 * 12,
              height: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Posts ────────────────────────────────────────────────────────────
class _PostsList extends StatelessWidget {
  final List<_Post> posts;
  const _PostsList({required this.posts});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          for (int i = 0; i < posts.length; i++) ...[
            _PostCard(post: posts[i]),
            if (i != posts.length - 1) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final _Post post;
  const _PostCard({required this.post});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: OA.bg1,
        border: Border.all(color: OA.stroke1),
        borderRadius: BorderRadius.circular(OA.radius3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            post.text,
            style: OA.body(size: 14, color: OA.fg1, height: 1.5),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _MetaCount(
                    icon: Icons.favorite_border,
                    value: '${post.likes}',
                  ),
                  const SizedBox(width: 14),
                  _MetaCount(
                    icon: Icons.chat_bubble_outline,
                    value: '${post.comments}',
                  ),
                  const SizedBox(width: 14),
                  _MetaCount(glyph: '◆', value: 'tip'),
                ],
              ),
              Text(post.when, style: OA.mono(size: 11, color: OA.fg3)),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaCount extends StatelessWidget {
  final IconData? icon;
  final String? glyph;
  final String value;
  const _MetaCount({this.icon, this.glyph, required this.value});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null)
          Icon(icon, size: 12, color: OA.fg3)
        else
          Text(glyph ?? '',
              style: const TextStyle(color: OA.fg3, fontSize: 11, height: 1.0)),
        const SizedBox(width: 4),
        Text(value, style: OA.mono(size: 11, color: OA.fg3)),
      ],
    );
  }
}

// ── Reign log ────────────────────────────────────────────────────────
class _ReignLog extends StatelessWidget {
  final List<_ReignRow> rows;
  const _ReignLog({required this.rows});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: OA.bg1,
          border: Border.all(color: OA.stroke1),
          borderRadius: BorderRadius.circular(OA.radius3),
        ),
        child: Column(
          children: [
            for (int i = 0; i < rows.length; i++)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: i == rows.length - 1
                      ? null
                      : Border(bottom: BorderSide(color: OA.stroke1)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(rows[i].week,
                          style: OA.mono(size: 13, color: OA.fg2)),
                    ),
                    Expanded(
                      child: Text(
                        rows[i].held ? '♛ HELD' : 'DETHRONED',
                        textAlign: TextAlign.center,
                        style: OA.body(
                          size: 11,
                          weight: FontWeight.w700,
                          color: rows[i].held ? OA.gold1 : OA.blood1,
                          letterSpacing: 0.08 * 11,
                          height: 1.0,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        rows[i].amt,
                        textAlign: TextAlign.right,
                        style: OA.mono(size: 13, color: OA.fg1),
                      ),
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

// ── Fans ─────────────────────────────────────────────────────────────
class _FansGrid extends StatelessWidget {
  final List<String> handles;
  const _FansGrid({required this.handles});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
        children: [
          for (final h in handles)
            Column(
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF3A3A42), OA.bg1],
                      ),
                      border: Border.all(color: OA.stroke2),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '@$h',
                  style: OA.body(size: 11, color: OA.fg2, height: 1.0),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// ── Data classes ─────────────────────────────────────────────────────
class _Post {
  final String text;
  final int likes;
  final int comments;
  final String when;
  const _Post({
    required this.text,
    required this.likes,
    required this.comments,
    required this.when,
  });
}

class _ReignRow {
  final String week;
  final bool held;
  final String amt;
  const _ReignRow({
    required this.week,
    required this.held,
    required this.amt,
  });
}
