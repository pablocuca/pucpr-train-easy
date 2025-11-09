import 'package:traineasy/core/result/result.dart';
import 'package:traineasy/core/usecase/usecase.dart';
import 'package:traineasy/features/auth/domain/entities/auth_user.dart';
import 'package:traineasy/features/auth/domain/repositories/auth_repository.dart';

class SignInWithEmailPassword
    implements UseCase<AuthUser, SignInWithEmailPasswordParams> {
  final AuthRepository _repo;
  SignInWithEmailPassword(this._repo);

  @override
  Future<Result<AuthUser>> call(SignInWithEmailPasswordParams params) {
    return _repo.signInWithEmailPassword(
      email: params.email,
      password: params.password,
    );
  }
}

class SignInWithEmailPasswordParams {
  final String email;
  final String password;
  const SignInWithEmailPasswordParams({required this.email, required this.password});
}
