import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'state/auth_controller.dart';
import 'theme/tokens.dart';
import 'widgets/primitives.dart';
import 'screens/feed.dart';
import 'screens/ages.dart';
import 'screens/me.dart';
import 'screens/wallet.dart';
import 'screens/age_profile.dart';
import 'screens/onboarding/onboarding.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: OA.bg1,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const OwnAgeApp());
}

class OwnAgeApp extends StatefulWidget {
  const OwnAgeApp({super.key});
  @override
  State<OwnAgeApp> createState() => _OwnAgeAppState();
}

class _OwnAgeAppState extends State<OwnAgeApp> {
  final AuthController _auth = AuthController();

  @override
  void initState() {
    super.initState();
    _auth.bootstrap();
  }

  @override
  void dispose() {
    _auth.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OwnAge',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: OA.bg0,
        colorScheme: const ColorScheme.dark(
          primary: OA.gold1,
          secondary: OA.blood1,
          surface: OA.bg1,
        ),
        splashColor: Colors.white.withValues(alpha: 0.04),
        highlightColor: Colors.white.withValues(alpha: 0.02),
      ),
      home: AuthGate(auth: _auth),
    );
  }
}

class AuthGate extends StatelessWidget {
  final AuthController auth;
  const AuthGate({super.key, required this.auth});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: auth,
      builder: (context, _) {
        switch (auth.phase) {
          case AuthPhase.booting:
            return const _BootSplash();
          case AuthPhase.loggedOut:
            return OnboardingScreen(
              auth: auth,
              onComplete: () {
                // auth.phase flipped to loggedIn already; no-op triggers rebuild
              },
            );
          case AuthPhase.loggedIn:
            return RootShell(auth: auth);
        }
      },
    );
  }
}

class _BootSplash extends StatelessWidget {
  const _BootSplash();
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: OA.bg0,
      body: Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(OA.gold1),
          ),
        ),
      ),
    );
  }
}

class RootShell extends StatefulWidget {
  final AuthController auth;
  const RootShell({super.key, required this.auth});
  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  String _tab = 'feed';
  int? _openAge;
  int? _donateAge;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OA.bg0,
      body: SafeArea(
        top: true,
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                const OAStatusBar(),
                OAAppHeader(
                  title: 'OWNAGE',
                  onBell: () => _confirmLogout(context),
                ),
                Expanded(
                  child: IndexedStack(
                    index: _tabIndex(_tab),
                    children: [
                      FeedScreen(
                          onOpenAge: (a) => setState(() => _openAge = a)),
                      AgesScreen(
                          onOpen: (a) => setState(() => _openAge = a)),
                      const MeScreen(),
                      const LeaderboardScreen(),
                      const WalletScreen(),
                    ],
                  ),
                ),
                OATabBar(
                  active: _tab,
                  onChange: (id) => setState(() => _tab = id),
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom),
              ],
            ),
            if (_openAge != null)
              Positioned.fill(
                child: ColoredBox(
                  color: OA.bg0,
                  child: SafeArea(
                    top: true,
                    bottom: false,
                    child: Column(
                      children: [
                        const OAStatusBar(),
                        Expanded(
                          child: AgeProfileScreen(
                            age: _openAge!,
                            onClose: () =>
                                setState(() => _openAge = null),
                            onDethrone: () =>
                                setState(() => _donateAge = _openAge),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            if (_donateAge != null)
              Positioned.fill(
                child: DonateSheet(
                  age: _donateAge!,
                  owner: 'marz',
                  onClose: () => setState(() => _donateAge = null),
                  onSend: (_) => setState(() {
                    _donateAge = null;
                    _openAge = null;
                  }),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: OA.bg1,
        title: Text('Sign out?', style: OA.body(size: 16, color: OA.fg1)),
        content: Text(
          'You can log back in with the same email.',
          style: OA.body(size: 13, color: OA.fg2),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('SIGN OUT'),
          ),
        ],
      ),
    );
    if (ok == true) await widget.auth.logout();
  }

  int _tabIndex(String id) => switch (id) {
        'feed' => 0,
        'ages' => 1,
        'me' => 2,
        'lb' => 3,
        'wallet' => 4,
        _ => 0,
      };
}
