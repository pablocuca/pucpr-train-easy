import 'package:traineasy/core/error/failures.dart';
import 'package:traineasy/core/result/result.dart';
import 'package:traineasy/features/auth/domain/entities/auth_user.dart';
import 'package:traineasy/features/auth/domain/repositories/auth_repository.dart';
import 'package:traineasy/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  AuthRepositoryImpl(this._remote);

  @override
  Stream<AuthUser?> observeAuthState() => _remote.observeAuthState();

  @override
  AuthUser? get currentUser => _remote.currentUser;

  @override
  Future<Result<AuthUser>> registerWithEmailPassword({required String email, required String password}) async {
    try {
      final user = await _remote.registerWithEmailPassword(email: email, password: password);
      return Ok(user);
    } on fb.FirebaseAuthException catch (e, st) {
      return Err(Failure(_mapErrorMessage(e), cause: e, stackTrace: st));
    } catch (e, st) {
      return Err(Failure('Falha ao registrar', cause: e, stackTrace: st));
    }
  }

  @override
  Future<Result<void>> sendPasswordReset({required String email}) async {
    try {
      await _remote.sendPasswordReset(email: email);
      return Ok(null);
    } on fb.FirebaseAuthException catch (e, st) {
      return Err(Failure(_mapErrorMessage(e), cause: e, stackTrace: st));
    } catch (e, st) {
      return Err(Failure('Falha ao enviar recuperação de senha', cause: e, stackTrace: st));
    }
  }

  @override
  Future<Result<AuthUser>> signInWithEmailPassword({required String email, required String password}) async {
    try {
      final user = await _remote.signInWithEmailPassword(email: email, password: password);
      return Ok(user);
    } on fb.FirebaseAuthException catch (e, st) {
      return Err(Failure(_mapErrorMessage(e), cause: e, stackTrace: st));
    } catch (e, st) {
      return Err(Failure('Falha ao autenticar', cause: e, stackTrace: st));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _remote.signOut();
      return Ok(null);
    } on fb.FirebaseAuthException catch (e, st) {
      return Err(Failure(_mapErrorMessage(e), cause: e, stackTrace: st));
    } catch (e, st) {
      return Err(Failure('Falha ao sair', cause: e, stackTrace: st));
    }
  }

  String _mapErrorMessage(fb.FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'E-mail inválido';
      case 'user-disabled':
        return 'Usuário desativado';
      case 'user-not-found':
        return 'Usuário não encontrado';
      case 'wrong-password':
        return 'Senha incorreta';
      case 'email-already-in-use':
        return 'E-mail já está em uso';
      case 'operation-not-allowed':
        return 'Método de autenticação não habilitado no Firebase';
      case 'weak-password':
        return 'Senha muito fraca';
      case 'network-request-failed':
        return 'Falha de rede, verifique sua conexão';
      default:
        return 'Erro de autenticação (${e.code})';
    }
  }
}
