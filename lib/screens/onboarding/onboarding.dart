import 'package:flutter/material.dart';
import '../../api/api_client.dart';
import '../../state/auth_controller.dart';
import '../../theme/tokens.dart';
import '../../widgets/primitives.dart';

class OnboardingScreen extends StatefulWidget {
  final AuthController auth;
  final VoidCallback onComplete;
  const OnboardingScreen({
    super.key,
    required this.auth,
    required this.onComplete,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _step = 0;
  // Local email path
  String? _email;
  String? _password;
  // Google path — set when Google returns needsBirthDate
  String? _tempToken;
  DateTime? _birthDate;
  int? _claimedAge;
  String? _error;
  bool _submitting = false;

  void _go(int step) => setState(() => _step = step);

  Future<void> _submit() async {
    if (_birthDate == null) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      if (_tempToken != null) {
        await widget.auth.completeSocialProfile(
          tempToken: _tempToken!,
          birthDate: _birthDate!,
        );
      } else {
        if (_email == null || _password == null) return;
        await widget.auth.registerAndClaim(
          email: _email!,
          password: _password!,
          birthDate: _birthDate!,
        );
      }
      final user = widget.auth.user!;
      setState(() {
        _claimedAge = user.ownedAge ?? user.age ?? _computedAge(_birthDate!);
        _step = 3;
        _submitting = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _error = e.message;
        _submitting = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Could not reach the arena. $e';
        _submitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OA.bg0,
      body: SafeArea(
        top: true,
        bottom: false,
        child: Column(
          children: [
            const OAStatusBar(),
            Expanded(
              child: _buildStep(),
            ),
            if (_step > 0 && _step < 3)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: _Dots(total: 2, index: _step - 1),
              ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return _WelcomeStep(onNext: () => _go(1));
      case 1:
        return _SignInStep(
          auth: widget.auth,
          onBack: () => _go(0),
          onContinueEmail: (email, password) {
            setState(() {
              _email = email;
              _password = password;
              _tempToken = null;
              _step = 2;
            });
          },
          onGoogleNeedsBirthDate: (tempToken) {
            setState(() {
              _tempToken = tempToken;
              _email = null;
              _password = null;
              _step = 2;
            });
          },
        );
      case 2:
        return _VerifyAgeStep(
          onBack: () => _go(1),
          submitting: _submitting,
          error: _error,
          onSubmit: (birth) {
            _birthDate = birth;
            _submit();
          },
        );
      case 3:
        return _DoneStep(
          age: _claimedAge ?? 0,
          fallbackNotice: widget.auth.lastError,
          onDone: widget.onComplete,
        );
    }
    return const SizedBox.shrink();
  }

  static int _computedAge(DateTime birth) {
    final now = DateTime.now();
    int a = now.year - birth.year;
    if (now.month < birth.month ||
        (now.month == birth.month && now.day < birth.day)) {
      a -= 1;
    }
    return a;
  }
}

// ── Step 1: Welcome ─────────────────────────────────────────────────────
class _WelcomeStep extends StatelessWidget {
  final VoidCallback onNext;
  const _WelcomeStep({required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(child: HalftoneOverlay(opacity: 0.12)),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LogoMark(size: 56),
                    const SizedBox(height: 40),
                    Text(
                      'ONLY ONE PERSON CAN OWN',
                      style: OA.body(
                        size: 11,
                        color: OA.fg3,
                        weight: FontWeight.w700,
                        letterSpacing: 0.14 * 11,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    GoldText('27', size: 200, letterSpacing: -0.04),
                    Transform.translate(
                      offset: const Offset(0, -4),
                      child: Text(
                        'EACH AGE.',
                        style: OA.display(size: 48, height: 1.0),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'You represent your age. Fans decide who holds it. Every Sunday, a new reign begins.',
                      style: OA.body(size: 16, color: OA.fg2, height: 1.5),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'OWN YOURS. OR LET SOMEONE ELSE.',
                      style: OA.display(size: 28, height: 1.0),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
              child: Column(
                children: [
                  OAButton(
                    variant: OAButtonVariant.gold,
                    expand: true,
                    onPressed: onNext,
                    child: const Text('CLAIM YOUR AGE'),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Free to join · no payment required',
                    style: OA.body(size: 12, color: OA.fg3, height: 1.0),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Step 2: Sign In ─────────────────────────────────────────────────────
class _SignInStep extends StatefulWidget {
  final AuthController auth;
  final VoidCallback onBack;
  final void Function(String email, String password) onContinueEmail;
  final void Function(String tempToken) onGoogleNeedsBirthDate;
  const _SignInStep({
    required this.auth,
    required this.onBack,
    required this.onContinueEmail,
    required this.onGoogleNeedsBirthDate,
  });

  @override
  State<_SignInStep> createState() => _SignInStepState();
}

class _SignInStepState extends State<_SignInStep> {
  bool _emailMode = false;
  bool _googleBusy = false;
  bool _appleBusy = false;
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  String? _err;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _doSocial(
    String label,
    Future<SocialSignInOutcome> Function() action,
    void Function(bool) setBusy,
  ) async {
    setState(() {
      setBusy(true);
      _err = null;
    });
    try {
      final outcome = await action();
      switch (outcome) {
        case SocialCancelled():
          setState(() => setBusy(false));
        case SocialAuthenticated():
          // AuthController flips to loggedIn → AuthGate swaps to RootShell.
          break;
        case SocialNeedsBirthDate(:final tempToken):
          widget.onGoogleNeedsBirthDate(tempToken);
      }
    } on ApiException catch (e) {
      setState(() {
        _err = e.message;
        setBusy(false);
      });
    } catch (e) {
      setState(() {
        _err = '$label sign-in failed. $e';
        setBusy(false);
      });
    }
  }

  Future<void> _doApple() async {
    if (_appleBusy) return;
    await _doSocial(
      'Apple',
      widget.auth.signInWithApple,
      (v) => _appleBusy = v,
    );
  }

  Future<void> _doGoogle() async {
    if (_googleBusy) return;
    await _doSocial(
      'Google',
      widget.auth.signInWithGoogle,
      (v) => _googleBusy = v,
    );
  }

  void _tryContinue() {
    final email = _emailCtrl.text.trim();
    final pw = _passwordCtrl.text;
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      setState(() => _err = 'Enter a valid email');
      return;
    }
    if (pw.length < 8) {
      setState(() => _err = 'Password must be 8+ characters');
      return;
    }
    widget.onContinueEmail(email, pw);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _BackBtn(onTap: widget.onBack),
          const SizedBox(height: 48),
          Text(
            'ENTER THE\nARENA.',
            style: OA.display(size: 56, height: 0.9, letterSpacing: -0.02),
          ),
          const SizedBox(height: 12),
          Text(
            'One account per person. One age per account — the age you actually are.',
            style: OA.body(size: 15, color: OA.fg2, height: 1.5),
          ),
          const Spacer(),
          if (_emailMode) _buildEmailForm() else _buildSocial(),
          const SizedBox(height: 24),
          Center(
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: OA.body(size: 11, color: OA.fg3, height: 1.6),
                children: [
                  const TextSpan(text: 'By continuing, you agree to the '),
                  TextSpan(
                    text: 'Terms',
                    style: OA.body(
                      size: 11,
                      color: OA.fg1,
                      height: 1.6,
                    ).copyWith(decoration: TextDecoration.underline),
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy',
                    style: OA.body(
                      size: 11,
                      color: OA.fg1,
                      height: 1.6,
                    ).copyWith(decoration: TextDecoration.underline),
                  ),
                  const TextSpan(text: '.\nYou must be 13+ to join.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocial() {
    return Column(
      children: [
        _AppleBtn(onTap: _doApple, busy: _appleBusy),
        const SizedBox(height: 12),
        _GoogleBtn(onTap: _doGoogle, busy: _googleBusy),
        const SizedBox(height: 14),
        GestureDetector(
          onTap: () => setState(() {
            _emailMode = true;
            _err = null;
          }),
          child: Text(
            'USE EMAIL INSTEAD',
            style: OA.body(
              size: 12,
              weight: FontWeight.w700,
              color: OA.fg1,
              letterSpacing: 0.1 * 12,
              height: 1.0,
            ),
          ),
        ),
        if (_err != null) ...[
          const SizedBox(height: 10),
          Text(
            _err!,
            textAlign: TextAlign.center,
            style: OA.body(size: 12, color: OA.blood1, height: 1.4),
          ),
        ],
      ],
    );
  }

  Widget _buildEmailForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _OATextField(
          controller: _emailCtrl,
          label: 'EMAIL',
          hint: 'you@ownage.gg',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),
        _OATextField(
          controller: _passwordCtrl,
          label: 'PASSWORD',
          hint: '8+ characters',
          obscure: true,
        ),
        if (_err != null) ...[
          const SizedBox(height: 8),
          Text(
            _err!,
            style: OA.body(size: 12, color: OA.blood1, height: 1.4),
          ),
        ],
        const SizedBox(height: 16),
        OAButton(
          variant: OAButtonVariant.gold,
          expand: true,
          onPressed: _tryContinue,
          child: const Text('CONTINUE'),
        ),
        const SizedBox(height: 10),
        Center(
          child: GestureDetector(
            onTap: () => setState(() {
              _emailMode = false;
              _err = null;
            }),
            child: Text(
              'USE APPLE OR GOOGLE',
              style: OA.body(
                size: 12,
                weight: FontWeight.w700,
                color: OA.fg2,
                letterSpacing: 0.1 * 12,
                height: 1.0,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GoogleBtn extends StatelessWidget {
  final VoidCallback onTap;
  final bool busy;
  const _GoogleBtn({required this.onTap, this.busy = false});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: busy ? null : onTap,
      child: Opacity(
        opacity: busy ? 0.6 : 1.0,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: OA.fg1,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (busy)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.black),
                  ),
                )
              else
                const Icon(Icons.g_mobiledata,
                    size: 28, color: Colors.black),
              const SizedBox(width: 4),
              Text(
                busy ? 'CONNECTING…' : 'CONTINUE WITH GOOGLE',
                style: OA.body(
                  size: 15,
                  weight: FontWeight.w700,
                  color: OA.fgInv,
                  height: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppleBtn extends StatelessWidget {
  final VoidCallback onTap;
  final bool busy;
  const _AppleBtn({required this.onTap, this.busy = false});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: busy ? null : onTap,
      child: Opacity(
        opacity: busy ? 0.6 : 1.0,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: OA.bg0,
            border: Border.all(color: OA.stroke2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (busy)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(OA.fg1),
                  ),
                )
              else
                const Icon(Icons.apple, size: 22, color: OA.fg1),
              const SizedBox(width: 10),
              Text(
                busy ? 'CONNECTING…' : 'CONTINUE WITH APPLE',
                style: OA.body(
                  size: 15,
                  weight: FontWeight.w700,
                  color: OA.fg1,
                  height: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Step 3: Verify Age ──────────────────────────────────────────────────
class _VerifyAgeStep extends StatefulWidget {
  final VoidCallback onBack;
  final void Function(DateTime birthDate) onSubmit;
  final bool submitting;
  final String? error;
  const _VerifyAgeStep({
    required this.onBack,
    required this.onSubmit,
    required this.submitting,
    required this.error,
  });
  @override
  State<_VerifyAgeStep> createState() => _VerifyAgeStepState();
}

class _VerifyAgeStepState extends State<_VerifyAgeStep> {
  // Defaults: 1999-03-14
  final _month = TextEditingController(text: '3');
  final _day = TextEditingController(text: '14');
  final _year = TextEditingController(text: '1999');

  @override
  void dispose() {
    _month.dispose();
    _day.dispose();
    _year.dispose();
    super.dispose();
  }

  int? _tryAge() {
    final m = int.tryParse(_month.text);
    final d = int.tryParse(_day.text);
    final y = int.tryParse(_year.text);
    if (m == null || d == null || y == null) return null;
    if (m < 1 || m > 12 || d < 1 || d > 31 || y < 1905) return null;
    final birth = DateTime(y, m, d);
    if (birth.month != m || birth.day != d) return null;
    final now = DateTime.now();
    if (birth.isAfter(now)) return null;
    int age = now.year - y;
    if (now.month < m || (now.month == m && now.day < d)) age -= 1;
    return age;
  }

  @override
  Widget build(BuildContext context) {
    final age = _tryAge();
    final valid = age != null && age >= 13 && age <= 120;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _BackBtn(onTap: widget.onBack),
          const SizedBox(height: 20),
          Text(
            'STEP 2 OF 2 · VERIFY',
            style: OA.body(
              size: 11,
              color: OA.fg3,
              weight: FontWeight.w700,
              letterSpacing: 0.14 * 11,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'WHEN WERE\nYOU BORN?',
            style: OA.display(size: 44, height: 0.95, letterSpacing: -0.02),
          ),
          const SizedBox(height: 10),
          Text(
            "Your real age is the age you'll represent. "
            'You get one seat — make it count.',
            style: OA.body(size: 13, color: OA.fg2, height: 1.5),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: _DateField(
                  label: 'MONTH',
                  controller: _month,
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DateField(
                  label: 'DAY',
                  controller: _day,
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: _DateField(
                  label: 'YEAR',
                  controller: _year,
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          _AgePreview(age: age, valid: valid),
          if (widget.error != null) ...[
            const SizedBox(height: 12),
            Text(
              widget.error!,
              textAlign: TextAlign.center,
              style: OA.body(size: 12, color: OA.blood1, height: 1.4),
            ),
          ],
          const Spacer(),
          Opacity(
            opacity: valid && !widget.submitting ? 1 : 0.4,
            child: IgnorePointer(
              ignoring: !valid || widget.submitting,
              child: OAButton(
                variant: OAButtonVariant.gold,
                expand: true,
                onPressed: () {
                  final m = int.parse(_month.text);
                  final d = int.parse(_day.text);
                  final y = int.parse(_year.text);
                  widget.onSubmit(DateTime(y, m, d));
                },
                child: Text(
                  widget.submitting
                      ? 'ENTERING…'
                      : valid
                          ? 'ENTER AS AGE $age'
                          : 'ENTER A VALID DATE',
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Locked after entry. Your age rolls over automatically on your birthday.',
            textAlign: TextAlign.center,
            style: OA.body(size: 11, color: OA.fg3, height: 1.6),
          ),
        ],
      ),
    );
  }
}

class _AgePreview extends StatelessWidget {
  final int? age;
  final bool valid;
  const _AgePreview({required this.age, required this.valid});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: OA.bg1,
            border: Border.all(color: valid ? OA.gold1 : OA.stroke1),
            borderRadius: BorderRadius.circular(16),
            boxShadow: valid
                ? [
                    BoxShadow(
                        color: OA.gold1.withValues(alpha: 0.18),
                        blurRadius: 32),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Text(
                'YOU WILL REPRESENT',
                style: OA.body(
                  size: 10,
                  color: OA.fg3,
                  weight: FontWeight.w700,
                  letterSpacing: 0.1 * 10,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 4),
              valid
                  ? GoldText('$age', size: 140, letterSpacing: -0.04)
                  : Text(
                      '—',
                      style: OA.display(
                        size: 140,
                        height: 0.85,
                        color: OA.fg3,
                        letterSpacing: -0.04,
                      ),
                    ),
              const SizedBox(height: 4),
              if (valid)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: OA.blood1.withValues(alpha: 0.14),
                    border: Border.all(
                        color: OA.blood1.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: OA.blood1,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: OA.blood1, blurRadius: 4),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'CURRENTLY HELD BY @MARZ',
                        style: OA.body(
                          size: 10,
                          weight: FontWeight.w700,
                          color: OA.blood1,
                          letterSpacing: 0.1 * 10,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Text(
                  'Must be between 13 and 120.',
                  style: OA.body(size: 12, color: OA.blood1, height: 1.3),
                ),
            ],
          ),
        ),
        if (valid) const Positioned.fill(child: HalftoneOverlay(opacity: 0.12)),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  const _DateField({
    required this.label,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: OA.body(
            size: 10,
            color: OA.fg3,
            weight: FontWeight.w700,
            letterSpacing: 0.1 * 10,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          onChanged: onChanged,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: OA.mono(size: 22, color: OA.fg1),
          decoration: InputDecoration(
            filled: true,
            fillColor: OA.bg1,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: OA.stroke2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: OA.stroke2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: OA.gold1, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

class _OATextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool obscure;
  final TextInputType? keyboardType;
  const _OATextField({
    required this.controller,
    required this.label,
    this.hint,
    this.obscure = false,
    this.keyboardType,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: OA.body(
            size: 10,
            color: OA.fg3,
            weight: FontWeight.w700,
            letterSpacing: 0.1 * 10,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          style: OA.body(size: 15, color: OA.fg1, height: 1.0),
          decoration: InputDecoration(
            filled: true,
            fillColor: OA.bg1,
            hintText: hint,
            hintStyle: OA.body(size: 15, color: OA.fg3, height: 1.0),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: OA.stroke2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: OA.stroke2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: OA.gold1, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Step 4: Done ────────────────────────────────────────────────────────
class _DoneStep extends StatelessWidget {
  final int age;
  final String? fallbackNotice;
  final VoidCallback onDone;
  const _DoneStep({
    required this.age,
    required this.fallbackNotice,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(child: HalftoneOverlay(opacity: 0.14)),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "YOU'RE IN. YOUR SEAT IS",
                        textAlign: TextAlign.center,
                        style: OA.body(
                          size: 11,
                          color: OA.fg3,
                          weight: FontWeight.w700,
                          letterSpacing: 0.14 * 11,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      GoldText('$age', size: 220, letterSpacing: -0.04),
                      Transform.translate(
                        offset: const Offset(0, -4),
                        child: Text(
                          'FIGHT FOR IT.',
                          style: OA.display(
                              size: 40,
                              height: 1.0,
                              letterSpacing: -0.01),
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: 260,
                        child: Text(
                          'Your fans tip you to defend.\n'
                          "Challengers' fans tip to take it.\n"
                          'Whoever leads on Sunday reigns next week.',
                          textAlign: TextAlign.center,
                          style: OA.body(size: 14, color: OA.fg2, height: 1.5),
                        ),
                      ),
                      if (fallbackNotice != null) ...[
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: OA.blood1.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            fallbackNotice!.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: OA.body(
                              size: 10,
                              weight: FontWeight.w700,
                              color: OA.blood1,
                              letterSpacing: 0.08 * 10,
                              height: 1.0,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              OAButton(
                variant: OAButtonVariant.gold,
                expand: true,
                onPressed: onDone,
                child: const Text('SEE THE ARENA'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Shared small bits ───────────────────────────────────────────────────
class _Dots extends StatelessWidget {
  final int total;
  final int index;
  const _Dots({required this.total, required this.index});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < total; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == index ? 18 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: i == index ? OA.gold1 : OA.stroke3,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
      ],
    );
  }
}

class _BackBtn extends StatelessWidget {
  final VoidCallback onTap;
  const _BackBtn({required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.chevron_left, size: 18, color: OA.fg2),
          const SizedBox(width: 2),
          Text(
            'Back',
            style: OA.body(size: 14, color: OA.fg2, height: 1.0),
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
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: OA.gradGold,
        boxShadow: [
          BoxShadow(color: OA.gold1.withValues(alpha: 0.3), blurRadius: 16),
        ],
      ),
      child: Center(
        child: Text(
          '♛',
          style: TextStyle(
            color: OA.fgInv,
            fontSize: size * 0.6,
            fontWeight: FontWeight.w700,
            height: 1.0,
          ),
        ),
      ),
    );
  }
}
