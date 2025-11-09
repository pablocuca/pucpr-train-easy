import 'package:traineasy/core/result/result.dart';
import 'package:traineasy/core/usecase/usecase.dart';
import 'package:traineasy/features/auth/domain/entities/auth_user.dart';
import 'package:traineasy/features/auth/domain/repositories/auth_repository.dart';

class RegisterWithEmailPassword
    implements UseCase<AuthUser, RegisterWithEmailPasswordParams> {
  final AuthRepository _repo;
  RegisterWithEmailPassword(this._repo);

  @override
  Future<Result<AuthUser>> call(RegisterWithEmailPasswordParams params) {
    return _repo.registerWithEmailPassword(
      email: params.email,
      password: params.password,
    );
  }
}

class RegisterWithEmailPasswordParams {
  final String email;
  final String password;
  const RegisterWithEmailPasswordParams({required this.email, required this.password});
}
