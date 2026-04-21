import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AppleAuthService {
  /// Triggers the native Sign in with Apple UI.
  /// Returns the idToken (nullable — null if cancelled or unavailable).
  Future<String?> getIdToken() async {
    if (!await SignInWithApple.isAvailable()) return null;
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: const [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      return credential.identityToken;
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) return null;
      rethrow;
    }
  }
}
