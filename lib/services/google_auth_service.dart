import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// iOS client ID from Google Cloud Console.
/// Public (not a secret) — the matching URL scheme lives in Info.plist.
const String kGoogleIosClientId =
    '289892648045-0tnpqon81rdfr942jr68qqen660k84lh.apps.googleusercontent.com';

class GoogleAuthService {
  GoogleAuthService()
      : _signIn = GoogleSignIn(
          clientId:
              defaultTargetPlatform == TargetPlatform.iOS ? kGoogleIosClientId : null,
          scopes: const ['email', 'profile'],
        );

  final GoogleSignIn _signIn;

  /// Returns an idToken on success, null if the user cancelled.
  Future<String?> getIdToken() async {
    final account = await _signIn.signIn();
    if (account == null) return null;
    final auth = await account.authentication;
    return auth.idToken;
  }

  Future<void> signOut() => _signIn.signOut();
}
