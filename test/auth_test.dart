import 'package:test/test.dart';
import 'package:todo_app/services/auth/auth_exceptions.dart';
import 'package:todo_app/services/auth/auth_provider.dart';
import 'package:todo_app/services/auth/auth_user.dart';

void main() {
  group('Mock Authentication', () {
    final provider = MockAuthProvider();
    test('should not be initialized', () {
      expect(provider.isInitialized, false);
    });
    test('cannot login if not initialized', () {
      expect(
        provider.logOut(),
        throwsA(
          const TypeMatcher<NotInitializedException>(),
        ),
      );
      test('Should be able to be initialized', () async {
        await provider.initialize();
        expect(provider.isInitialized, true);
      });
      test('User should be null', () {
        expect(provider.currentUser, null);
      });
      test(
        'should be able to initialize in less than 2 seconds',
        () async {
          await provider.initialize();
          expect(provider.isInitialized, true);
        },
        timeout: const Timeout(Duration(seconds: 2)),
      );
      test('User should delegate to login function', () async {
        final badEmailUser =
            provider.createUser(email: 'foo@bar.com', password: 'password');
        expect(
            badEmailUser, throwsA(const TypeMatcher<UserNotFoundException>()));
        final badPasswordUser = provider.createUser(
          email: 'someone@bar.com',
          password: 'foobar',
        );
        expect(badPasswordUser,
            throwsA(const TypeMatcher<WrongPasswordAuthException>()));

        final user = await provider.createUser(email: 'foo', password: 'bar');
        expect(provider.currentUser, user);
        expect(user.isEmailVerified, false);
      });
    });
    test('logged in user ld be able to get ', () {
      provider.sendEmailVerification();
      final user = provider.currentUser;
      expect(user, isNotNull);
      expect(user!.isEmailVerified, true);
    });
    test('should be able to log out and login again', () async {
      await provider.logOut();
      await provider.logIn(
        email: 'user',
        password: 'password',
      );
      final user = provider.currentUser;
      expect(user, isNotNull);
    });
  });
}

class NotInitializedException implements Exception {}

class MockAuthProvider implements AuthProvider {
  AuthUser? _user;
  var _isInitialized = false;
  bool get isInitialized => _isInitialized;
  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    if (!isInitialized) throw NotInitializedException();
    await Future.delayed(const Duration(seconds: 1));
    return logIn(email: email, password: password);
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized = true;
  }

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) {
    if (email == 'foo@bar.com') throw UserNotFoundException();
    if (password == 'foobar') throw WrongPasswordAuthException();
    const user = AuthUser(isEmailVerified: false);
    _user = user;
    return Future.value(_user);
  }

  @override
  Future<void> logOut() async {
    if (!isInitialized) throw NotInitializedException();
    if (_user == null) throw UserNotFoundException();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!isInitialized) throw NotInitializedException();
    final user = _user;
    if (user == null) throw UserNotFoundException();
    const newUser = AuthUser(isEmailVerified: true);
    _user = newUser;
  }
}
