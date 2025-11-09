import 'package:firebase_auth/firebase_auth.dart' as fb;

import 'package:traineasy/features/auth/domain/entities/auth_user.dart';

abstract class AuthRemoteDataSource {
  Stream<AuthUser?> observeAuthState();
  AuthUser? get currentUser;
  Future<AuthUser> signInWithEmailPassword({required String email, required String password});
  Future<AuthUser> registerWithEmailPassword({required String email, required String password});
  Future<void> sendPasswordReset({required String email});
  Future<void> signOut();
}

class FirebaseAuthRemoteDataSource implements AuthRemoteDataSource {
  final fb.FirebaseAuth _auth;
  FirebaseAuthRemoteDataSource(this._auth);

  AuthUser _map(fb.User user) => AuthUser(
        uid: user.uid,
        email: user.email,
        displayName: user.displayName,
        photoUrl: user.photoURL,
      );

  @override
  Stream<AuthUser?> observeAuthState() {
    return _auth.authStateChanges().map((u) => u == null ? null : _map(u));
  }

  @override
  AuthUser? get currentUser => _auth.currentUser == null ? null : _map(_auth.currentUser!);

  @override
  Future<AuthUser> registerWithEmailPassword({required String email, required String password}) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    final user = cred.user!;
    return _map(user);
  }

  @override
  Future<void> sendPasswordReset({required String email}) => _auth.sendPasswordResetEmail(email: email);

  @override
  Future<AuthUser> signInWithEmailPassword({required String email, required String password}) async {
    final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
    final user = cred.user!;
    return _map(user);
  }

  @override
  Future<void> signOut() => _auth.signOut();
}
