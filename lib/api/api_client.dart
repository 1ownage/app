import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Base URL for the ownage backend. Override via --dart-define at build time.
const String kApiBase = String.fromEnvironment(
  'OWNAGE_API_BASE',
  defaultValue: 'http://localhost:3000',
);

class ApiException implements Exception {
  final int status;
  final String message;
  final Map<String, dynamic>? body;
  ApiException(this.status, this.message, [this.body]);
  @override
  String toString() => 'ApiException($status): $message';
}

class AuthTokens {
  final String accessToken;
  final String refreshToken;
  const AuthTokens({required this.accessToken, required this.refreshToken});
  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
      };
  factory AuthTokens.fromJson(Map<String, dynamic> j) => AuthTokens(
        accessToken: j['accessToken'] as String,
        refreshToken: j['refreshToken'] as String,
      );
}

class UserProfile {
  final int id;
  final String email;
  final String type;
  final int coinBalance;
  final int? age;
  final int? ownedAge;
  const UserProfile({
    required this.id,
    required this.email,
    required this.type,
    required this.coinBalance,
    this.age,
    this.ownedAge,
  });
  factory UserProfile.fromJson(Map<String, dynamic> j) => UserProfile(
        id: (j['id'] as num).toInt(),
        email: j['email'] as String,
        type: j['type'] as String,
        coinBalance: (j['coinBalance'] as num?)?.toInt() ?? 0,
        age: (j['age'] as num?)?.toInt(),
        ownedAge: (j['ownedAge'] as num?)?.toInt(),
      );
}

class ApiClient {
  ApiClient({http.Client? http, String? baseUrl})
      : _http = http ?? _defaultClient(),
        _base = baseUrl ?? kApiBase;

  final http.Client _http;
  final String _base;
  String? _accessToken;

  static http.Client _defaultClient() => http.Client();

  void setAccessToken(String? token) {
    _accessToken = token;
  }

  Uri _url(String path) => Uri.parse('$_base$path');

  Map<String, String> _headers({bool auth = false}) => {
        'content-type': 'application/json',
        if (auth && _accessToken != null)
          'authorization': 'Bearer $_accessToken',
      };

  Future<Map<String, dynamic>> _decode(http.Response res) async {
    final decoded =
        res.body.isEmpty ? <String, dynamic>{} : jsonDecode(res.body) as dynamic;
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (decoded is Map<String, dynamic>) return decoded;
      return {'value': decoded};
    }
    final body = decoded is Map<String, dynamic> ? decoded : null;
    final msg = body?['message'] is String
        ? body!['message'] as String
        : body?['message'] is List
            ? (body!['message'] as List).join(', ')
            : res.reasonPhrase ?? 'HTTP ${res.statusCode}';
    throw ApiException(res.statusCode, msg, body);
  }

  // ── Auth ────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required DateTime birthDate,
  }) async {
    final res = await _http.post(
      _url('/auth/register'),
      headers: _headers(),
      body: jsonEncode({
        'email': email,
        'password': password,
        'birthDate': _fmtDate(birthDate),
      }),
    );
    return _decode(res);
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final res = await _http.post(
      _url('/auth/login'),
      headers: _headers(),
      body: jsonEncode({'email': email, 'password': password}),
    );
    return _decode(res);
  }

  Future<Map<String, dynamic>> refresh(String refreshToken) async {
    final res = await _http.post(
      _url('/auth/refresh'),
      headers: _headers(),
      body: jsonEncode({'refreshToken': refreshToken}),
    );
    return _decode(res);
  }

  Future<Map<String, dynamic>> appleToken(String idToken) async {
    final res = await _http.post(
      _url('/auth/apple/token'),
      headers: _headers(),
      body: jsonEncode({'idToken': idToken}),
    );
    return _decode(res);
  }

  Future<Map<String, dynamic>> googleToken(String idToken) async {
    final res = await _http.post(
      _url('/auth/google/token'),
      headers: _headers(),
      body: jsonEncode({'idToken': idToken}),
    );
    return _decode(res);
  }

  Future<Map<String, dynamic>> completeProfile({
    required String tempToken,
    required DateTime birthDate,
  }) async {
    final res = await _http.post(
      _url('/auth/complete-profile'),
      headers: _headers(),
      body: jsonEncode({
        'tempToken': tempToken,
        'birthDate': _fmtDate(birthDate),
      }),
    );
    return _decode(res);
  }

  Future<Map<String, dynamic>> candidateRegister() async {
    final res = await _http.post(
      _url('/auth/candidate/register'),
      headers: _headers(auth: true),
    );
    return _decode(res);
  }

  Future<UserProfile> me() async {
    final res = await _http.get(
      _url('/users/me'),
      headers: _headers(auth: true),
    );
    return UserProfile.fromJson(await _decode(res));
  }

  static String _fmtDate(DateTime d) {
    String p(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${p(d.month)}-${p(d.day)}';
  }
}

/// Web-safe debug log helper.
void logApi(Object? msg) {
  if (kDebugMode) debugPrint('[api] $msg');
}
