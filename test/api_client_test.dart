import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tamini/core/api/api_client.dart';

const _secureStorage = MethodChannel(
  'plugins.it_nomads.com/flutter_secure_storage',
);

/// In-memory stand-in for the secure-storage plugin so token flows can be
/// observed without the platform channel.
final Map<String, String> _store = <String, String>{};

const _json = {'content-type': 'application/json'};
const _html = {'content-type': 'text/html'};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    _store.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_secureStorage, (call) async {
      switch (call.method) {
        case 'read':
          return _store[call.arguments['key']];
        case 'readAll':
          return _store;
        case 'write':
          final value = call.arguments['value'] as String?;
          if (value == null) {
            _store.remove(call.arguments['key']);
          } else {
            _store[call.arguments['key']] = value;
          }
          return null;
        case 'delete':
          _store.remove(call.arguments['key']);
          return null;
        case 'deleteAll':
          _store.clear();
          return null;
      }
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_secureStorage, null);
  });

  test('a 401 refreshes the access token and retries the call once', () async {
    var profileCalls = 0;
    var refreshCalls = 0;
    final client = MockClient((request) async {
      if (request.url.path.endsWith('/auth/token/refresh/')) {
        refreshCalls++;
        return http.Response('{"access":"fresh-access"}', 200,
            headers: _json);
      }
      profileCalls++;
      if (profileCalls == 1) {
        return http.Response('{"detail":"Given token not valid"}', 401,
            headers: _json);
      }
      return http.Response('{"id":7}', 200, headers: _json);
    });
    _store['access_token'] = 'stale-access';
    _store['refresh_token'] = 'refresh-1';

    final api = ApiClient(client: client);
    final data = await api.get('/auth/profile/');

    expect(data['id'], 7);
    expect(profileCalls, 2, reason: 'the call must be retried after refresh');
    expect(refreshCalls, 1);
    expect(_store['access_token'], 'fresh-access',
        reason: 'the rotated access token must be persisted');
  });

  test('concurrent 401s share a single refresh (rotation safety)', () async {
    var refreshCalls = 0;
    final seen = <String>{};
    final client = MockClient((request) async {
      if (request.url.path.endsWith('/auth/token/refresh/')) {
        refreshCalls++;
        // Long enough that both 401 responses arrive while this refresh is
        // still in flight, which is the race the collapse exists for.
        await Future<void>.delayed(const Duration(milliseconds: 20));
        return http.Response('{"access":"fresh-access"}', 200,
            headers: _json);
      }
      if (seen.add(request.url.path)) {
        return http.Response('{"detail":"expired"}', 401, headers: _json);
      }
      return http.Response('{"path":"${request.url.path}"}', 200,
          headers: _json);
    });
    _store['access_token'] = 'stale-access';
    _store['refresh_token'] = 'refresh-1';

    final api = ApiClient(client: client);
    final results = await Future.wait([
      api.get('/orders/'),
      api.get('/cart/'),
    ]);

    expect(results, hasLength(2));
    expect(results[0]['path'], '/api/orders/');
    expect(results[1]['path'], '/api/cart/');
    expect(refreshCalls, 1,
        reason: 'two parallel refreshes could invalidate each other');
  });

  test('a rejected refresh ends the session and clears tokens', () async {
    var expired = 0;
    final client = MockClient((request) async {
      if (request.url.path.endsWith('/auth/token/refresh/')) {
        return http.Response('{"detail":"Token is invalid or expired"}', 400,
            headers: _json);
      }
      return http.Response('{"detail":"Given token not valid"}', 401,
          headers: _json);
    });
    _store['access_token'] = 'stale-access';
    _store['refresh_token'] = 'dead';
    final api = ApiClient(client: client);
    api.onAuthExpired = () => expired++;

    await expectLater(api.get('/auth/profile/'), throwsA(isA<ApiException>()));

    expect(expired, 1, reason: 'listeners must be told to log out');
    expect(_store.containsKey('access_token'), isFalse);
    expect(_store.containsKey('refresh_token'), isFalse);
  });

  test('PATCH/PUT/DELETE retry through a cold-start HTML page', () async {
    final attempts = <String, int>{};
    final client = MockClient((request) async {
      final key = '${request.method} ${request.url.path}';
      final attempt = (attempts[key] ?? 0) + 1;
      attempts[key] = attempt;
      if (attempt == 1) {
        return http.Response('<!DOCTYPE html><html><body>503</body></html>',
            503, headers: _html);
      }
      return http.Response('{"ok":true}', 200, headers: _json);
    });
    final api = ApiClient(client: client);

    expect((await api.patch('/restaurants/1/', body: {'name': 'x'}))['ok'],
        isTrue);
    expect(
        (await api.put('/settings/preferences/', body: <String, dynamic>{}))[
            'ok'],
        isTrue);
    expect((await api.delete('/cart/clear/'))['ok'], isTrue);

    expect(attempts, hasLength(3));
    expect(attempts.values, everyElement(2),
        reason: 'every verb must survive a Render cold start, not just GET/POST');
  });

  test('GET responses are cached until the session ends', () async {
    var networkCalls = 0;
    final client = MockClient((request) async {
      networkCalls++;
      return http.Response('{"results":[]}', 200, headers: _json);
    });
    _store['access_token'] = 'access-1';
    final api = ApiClient(client: client);

    await api.get('/restaurants/', cacheTtl: const Duration(minutes: 1));
    await api.get('/restaurants/', cacheTtl: const Duration(minutes: 1));
    expect(networkCalls, 1, reason: 'the second read should hit the cache');

    await api.clearTokens();

    await api.get('/restaurants/', cacheTtl: const Duration(minutes: 1));
    expect(networkCalls, 2,
        reason: "the next account must not see the previous account's cache");
  });
}
