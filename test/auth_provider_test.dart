import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tamini/core/api/api_client.dart';
import 'package:tamini/core/models/models.dart';
import 'package:tamini/core/providers/providers.dart';
import 'package:tamini/core/repositories/auth_repository.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

Map<String, dynamic> _profile = {
  'id': 1,
  'email': 'a@test.com',
  'username': 'a',
  'role': 'customer',
};

void main() {
  late MockAuthRepository repo;

  setUp(() {
    repo = MockAuthRepository();
  });

  test('tryAutoLogin is false when no session was stored', () async {
    when(() => repo.hasSession()).thenAnswer((_) async => false);

    final auth = AuthProvider(repo);

    expect(await auth.tryAutoLogin(), isFalse);
    expect(auth.isLoggedIn, isFalse);
    verifyNever(() => repo.fetchProfile());
  });

  test('tryAutoLogin restores the profile when a session exists', () async {
    when(() => repo.hasSession()).thenAnswer((_) async => true);
    when(() => repo.fetchProfile()).thenAnswer((_) async => _profile);
    when(() => repo.saveUserData(any())).thenAnswer((_) async {});

    final auth = AuthProvider(repo);

    expect(await auth.tryAutoLogin(), isTrue);
    expect(auth.user?.email, 'a@test.com');
    verify(() => repo.saveUserData(any())).called(1);
  });

  test('tryAutoLogin drops the session when the profile fetch fails', () async {
    when(() => repo.hasSession()).thenAnswer((_) async => true);
    when(() => repo.fetchProfile()).thenThrow(
      ApiException(statusCode: 401, message: 'expired'),
    );
    when(() => repo.clearSession()).thenAnswer((_) async {});

    final auth = AuthProvider(repo);

    expect(await auth.tryAutoLogin(), isFalse);
    expect(auth.isLoggedIn, isFalse);
    verify(() => repo.clearSession()).called(1);
  });

  test('login falls back to the legacy password endpoint', () async {
    when(() => repo.loginWithPassword(any(), any())).thenAnswer(
      (_) async => AuthSession(access: 'a', refresh: 'r', user: _profile),
    );

    final auth = AuthProvider(repo);

    // Firebase is unavailable in the test environment, which is exactly the
    // situation the legacy fallback exists for.
    expect(await auth.login('a@test.com', 'pw'), isTrue);
    expect(auth.isLoggedIn, isTrue);
    verify(() => repo.loginWithPassword('a@test.com', 'pw')).called(1);
  });

  test('login failure surfaces the backend message', () async {
    when(() => repo.loginWithPassword(any(), any())).thenThrow(
      ApiException(statusCode: 401, message: 'No active account found'),
    );

    final auth = AuthProvider(repo);

    expect(await auth.login('a@test.com', 'wrong'), isFalse);
    expect(auth.error, 'No active account found');
    expect(auth.isLoggedIn, isFalse);
  });

  test('logout clears the session and fires onSessionEnded', () async {
    when(() => repo.clearSession()).thenAnswer((_) async {});

    final auth = AuthProvider(repo);
    var sessionEnded = false;
    auth.onSessionEnded = () => sessionEnded = true;
    auth.debugSetUser(
      User(id: 1, email: 'a@test.com', username: 'a', role: 'customer'),
    );

    await auth.logout();

    expect(auth.user, isNull);
    expect(sessionEnded, isTrue);
    verify(() => repo.clearSession()).called(1);
  });

  test('a backend session expiry clears the signed-in user', () {
    var sessionEnded = false;
    final auth = AuthProvider(repo);
    auth.onSessionEnded = () => sessionEnded = true;
    auth.debugSetUser(
      User(id: 1, email: 'a@test.com', username: 'a', role: 'customer'),
    );

    // AuthProvider wires its logout hook into the repository; replay the exact
    // handler the transport would invoke when a refresh is permanently dead.
    final handler =
        verify(() => repo.onAuthExpired = captureAny()).captured.single
            as void Function();
    handler();

    expect(auth.user, isNull);
    expect(sessionEnded, isTrue);
  });
}
