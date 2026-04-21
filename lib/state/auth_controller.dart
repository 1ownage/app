import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_client.dart';
import '../services/apple_auth_service.dart';
import '../services/google_auth_service.dart';

enum AuthPhase { booting, loggedOut, loggedIn }

sealed class SocialSignInOutcome {
  const SocialSignInOutcome();
}

class SocialCancelled extends SocialSignInOutcome {
  const SocialCancelled();
}

class SocialAuthenticated extends SocialSignInOutcome {
  const SocialAuthenticated();
}

class SocialNeedsBirthDate extends SocialSignInOutcome {
  final String tempToken;
  final String email;
  const SocialNeedsBirthDate({required this.tempToken, required this.email});
}

// Backwards-compatible aliases (onboarding still pattern-matches Google*)
typedef GoogleSignInOutcome = SocialSignInOutcome;
typedef GoogleCancelled = SocialCancelled;
typedef GoogleAuthenticated = SocialAuthenticated;
typedef GoogleNeedsBirthDate = SocialNeedsBirthDate;

class AuthController extends ChangeNotifier {
  AuthController({
    ApiClient? api,
    GoogleAuthService? google,
    AppleAuthService? apple,
  })  : api = api ?? ApiClient(),
        _google = google ?? GoogleAuthService(),
        _apple = apple ?? AppleAuthService();

  final ApiClient api;
  final GoogleAuthService _google;
  final AppleAuthService _apple;
  static const _kTokens = 'ownage.tokens.v1';

  AuthPhase phase = AuthPhase.booting;
  AuthTokens? tokens;
  UserProfile? user;
  String? lastError;

  Future<void> bootstrap() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kTokens);
    if (raw == null) {
      phase = AuthPhase.loggedOut;
      notifyListeners();
      return;
    }
    try {
      tokens = AuthTokens.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      api.setAccessToken(tokens!.accessToken);
      user = await api.me();
      phase = AuthPhase.loggedIn;
    } on ApiException catch (e) {
      if (e.status == 401 && tokens != null) {
        try {
          final refreshed = await api.refresh(tokens!.refreshToken);
          tokens = AuthTokens(
            accessToken: refreshed['accessToken'] as String,
            refreshToken: tokens!.refreshToken,
          );
          api.setAccessToken(tokens!.accessToken);
          user = await api.me();
          await _persist();
          phase = AuthPhase.loggedIn;
        } catch (_) {
          await logout();
          return;
        }
      } else {
        await logout();
        return;
      }
    } catch (_) {
      phase = AuthPhase.loggedOut;
    }
    notifyListeners();
  }

  Future<void> registerAndClaim({
    required String email,
    required String password,
    required DateTime birthDate,
  }) async {
    lastError = null;
    final resp = await api.register(
      email: email,
      password: password,
      birthDate: birthDate,
    );
    tokens = AuthTokens.fromJson(resp);
    api.setAccessToken(tokens!.accessToken);
    await _persist();

    try {
      final claim = await api.candidateRegister();
      // candidateRegister returns fresh tokens with updated type
      if (claim['accessToken'] is String) {
        tokens = AuthTokens.fromJson(claim);
        api.setAccessToken(tokens!.accessToken);
        await _persist();
      }
    } on ApiException catch (e) {
      // 409 = age already claimed; we stay as fan and continue
      if (e.status != 409) rethrow;
      lastError = e.message;
    }

    user = await api.me();
    phase = AuthPhase.loggedIn;
    notifyListeners();
  }

  Future<void> login({required String email, required String password}) async {
    final resp = await api.login(email: email, password: password);
    tokens = AuthTokens.fromJson(resp);
    api.setAccessToken(tokens!.accessToken);
    await _persist();
    user = await api.me();
    phase = AuthPhase.loggedIn;
    notifyListeners();
  }

  Future<SocialSignInOutcome> signInWithApple() async {
    lastError = null;
    final idToken = await _apple.getIdToken();
    if (idToken == null) return const SocialCancelled();
    return _consumeSocialResponse(await api.appleToken(idToken));
  }

  Future<SocialSignInOutcome> signInWithGoogle() async {
    lastError = null;
    final idToken = await _google.getIdToken();
    if (idToken == null) return const SocialCancelled();
    return _consumeSocialResponse(await api.googleToken(idToken));
  }

  Future<SocialSignInOutcome> _consumeSocialResponse(
      Map<String, dynamic> resp) async {
    if (resp['kind'] == 'authenticated') {
      final t = resp['tokens'] as Map<String, dynamic>;
      tokens = AuthTokens.fromJson(t);
      api.setAccessToken(tokens!.accessToken);
      await _persist();
      try {
        final claim = await api.candidateRegister();
        if (claim['accessToken'] is String) {
          tokens = AuthTokens.fromJson(claim);
          api.setAccessToken(tokens!.accessToken);
          await _persist();
        }
      } on ApiException catch (e) {
        if (e.status != 409) rethrow;
        lastError = e.message;
      }
      user = await api.me();
      phase = AuthPhase.loggedIn;
      notifyListeners();
      return const SocialAuthenticated();
    }

    return SocialNeedsBirthDate(
      tempToken: resp['tempToken'] as String,
      email: resp['email'] as String,
    );
  }

  Future<void> completeSocialProfile({
    required String tempToken,
    required DateTime birthDate,
  }) async {
    lastError = null;
    final resp = await api.completeProfile(
      tempToken: tempToken,
      birthDate: birthDate,
    );
    tokens = AuthTokens.fromJson(resp);
    api.setAccessToken(tokens!.accessToken);
    await _persist();
    try {
      final claim = await api.candidateRegister();
      if (claim['accessToken'] is String) {
        tokens = AuthTokens.fromJson(claim);
        api.setAccessToken(tokens!.accessToken);
        await _persist();
      }
    } on ApiException catch (e) {
      if (e.status != 409) rethrow;
      lastError = e.message;
    }
    user = await api.me();
    phase = AuthPhase.loggedIn;
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kTokens);
    await _google.signOut();
    tokens = null;
    user = null;
    api.setAccessToken(null);
    phase = AuthPhase.loggedOut;
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kTokens, jsonEncode(tokens!.toJson()));
  }
}
