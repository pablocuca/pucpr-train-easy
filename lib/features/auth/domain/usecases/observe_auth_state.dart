import 'package:traineasy/core/usecase/usecase.dart';
import 'package:traineasy/core/result/result.dart';
import 'package:traineasy/features/auth/domain/entities/auth_user.dart';
import 'package:traineasy/features/auth/domain/repositories/auth_repository.dart';

class ObserveAuthState implements UseCase<Stream<AuthUser?>, NoParams> {
  final AuthRepository _repo;
  ObserveAuthState(this._repo);

  @override
  Future<Result<Stream<AuthUser?>>> call(NoParams params) async {
    return Ok(_repo.observeAuthState());
  }
}
