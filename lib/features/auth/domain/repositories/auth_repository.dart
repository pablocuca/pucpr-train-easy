import 'package:traineasy/core/result/result.dart';
import 'package:traineasy/features/auth/domain/entities/auth_user.dart';

abstract class AuthRepository {
  Stream<AuthUser?> observeAuthState();
  AuthUser? get currentUser;

  Future<Result<AuthUser>> signInWithEmailPassword({required String email, required String password});
  Future<Result<AuthUser>> registerWithEmailPassword({required String email, required String password});
  Future<Result<void>> sendPasswordReset({required String email});
  Future<Result<void>> signOut();
}
