import 'package:flutter_test/flutter_test.dart';
import 'package:learning_dart/Services/auth/auth_exceptions.dart';
import 'package:learning_dart/Services/auth/auth_provider.dart';
import 'package:learning_dart/Services/auth/auth_user.dart';

void main() {
  group('Mock Authentication', () {
    final provider = MockAuthProvider();
    test('should not be initialized', () {
      expect(provider.isInitialized, false);
    });
    
    test('cannot log out if not initialized', () {
      expect(provider.logOut(),
      throwsA(const TypeMatcher<NotInitializedException>()),
      );
    });

    test('should be able to be initialized',() async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    });
    
    test('User should be null after initialization', () {
      expect(provider.currentUser, null);
    });
    
    
    test('should be able to initialize in 2 seconds', () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    },
    timeout: const Timeout(Duration(seconds: 2)),
    );
    
    test('create user should delegate to logIn function',() async {
      final badEmailUser = provider.createUser(
          email:"ankit@gmail.com",
          password: "password"
      );
      expect(badEmailUser,
          throwsA(const TypeMatcher<UserNotFoundAuthException>()));
      final badPasswordUser = provider.createUser(
          email:"someone@somewhere",
          password: "ankit"
      );
      expect(badPasswordUser,
          throwsA(const TypeMatcher<WrongPasswordAuthException>()));
      final user = await provider.createUser(
          email: "an",
          password: "kit"
      );
      expect(provider.currentUser, user);
      expect(user.isEmailVerified,false);
    });

    test('should be able to get verified',() {
      provider.sendEmailVerification();
      final user = provider.currentUser;
      expect(user, isNotNull);
      expect(user!.isEmailVerified, true);
    });

    test('should be able to login again', () async {
      await provider.logOut();
      await provider.logIn(email: 'email', password: 'password');
      final user = provider.currentUser;
      expect(user, isNotNull);
    });
  });
}

class NotInitializedException implements Exception {}

class MockAuthProvider implements AuthProvider{
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
    if(!_isInitialized) throw NotInitializedException();
    if(email == "ankit@gmail.com") throw UserNotFoundAuthException();
    if(password == "ankit") throw WrongPasswordAuthException();
    const user = AuthUser(isEmailVerified: false, email: 'ankit@gmail');
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> logOut() async {
    if(!_isInitialized) throw NotInitializedException();
    if(_user == null) throw UserNotFoundAuthException();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<void> sendEmailVerification()async {
    if(!_isInitialized) throw NotInitializedException();
    final user = _user;
    if (user == null) throw UserNotFoundAuthException();
    const newUser = AuthUser(isEmailVerified: true, email: 'ankit@gmail');
    _user = newUser;
  }

}