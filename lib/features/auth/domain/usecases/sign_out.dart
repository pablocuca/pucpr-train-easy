import 'package:traineasy/core/result/result.dart';
import 'package:traineasy/core/usecase/usecase.dart';
import 'package:traineasy/features/auth/domain/repositories/auth_repository.dart';

class SignOut implements UseCase<void, NoParams> {
  final AuthRepository _repo;
  SignOut(this._repo);

  @override
  Future<Result<void>> call(NoParams params) => _repo.signOut();
}
