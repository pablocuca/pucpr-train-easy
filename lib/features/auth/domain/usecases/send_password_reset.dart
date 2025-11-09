import 'package:traineasy/core/result/result.dart';
import 'package:traineasy/core/usecase/usecase.dart';
import 'package:traineasy/features/auth/domain/repositories/auth_repository.dart';

class SendPasswordReset implements UseCase<void, SendPasswordResetParams> {
  final AuthRepository _repo;
  SendPasswordReset(this._repo);

  @override
  Future<Result<void>> call(SendPasswordResetParams params) {
    return _repo.sendPasswordReset(email: params.email);
  }
}

class SendPasswordResetParams {
  final String email;
  const SendPasswordResetParams(this.email);
}
