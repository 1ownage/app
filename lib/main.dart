import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/tokens.dart';
import 'widgets/primitives.dart';
import 'screens/feed.dart';
import 'screens/ages.dart';
import 'screens/me.dart';
import 'screens/wallet.dart';
import 'screens/age_profile.dart';

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

class OwnAgeApp extends StatelessWidget {
  const OwnAgeApp({super.key});
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
      home: const RootShell(),
    );
  }
}

class RootShell extends StatefulWidget {
  const RootShell({super.key});
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
                const OAAppHeader(title: 'OWNAGE'),
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

  int _tabIndex(String id) => switch (id) {
        'feed' => 0,
        'ages' => 1,
        'me' => 2,
        'lb' => 3,
        'wallet' => 4,
        _ => 0,
      };
}
