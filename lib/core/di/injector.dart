import 'package:firebase_auth/firebase_auth.dart' as fb;

import 'package:traineasy/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:traineasy/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:traineasy/features/auth/domain/repositories/auth_repository.dart';
import 'package:traineasy/features/auth/domain/usecases/observe_auth_state.dart';
import 'package:traineasy/features/auth/domain/usecases/register_with_email_password.dart';
import 'package:traineasy/features/auth/domain/usecases/send_password_reset.dart';
import 'package:traineasy/features/auth/domain/usecases/sign_in_with_email_password.dart';
import 'package:traineasy/features/auth/domain/usecases/sign_out.dart';

class Injector {
  static late final AuthRepository authRepository;

  // Use cases
  static late final ObserveAuthState observeAuthState;
  static late final SignInWithEmailPassword signInWithEmailPassword;
  static late final RegisterWithEmailPassword registerWithEmailPassword;
  static late final SendPasswordReset sendPasswordReset;
  static late final SignOut signOut;

  static Future<void> init() async {
    final fbAuth = fb.FirebaseAuth.instance;
    final remote = FirebaseAuthRemoteDataSource(fbAuth);
    authRepository = AuthRepositoryImpl(remote);

    observeAuthState = ObserveAuthState(authRepository);
    signInWithEmailPassword = SignInWithEmailPassword(authRepository);
    registerWithEmailPassword = RegisterWithEmailPassword(authRepository);
    sendPasswordReset = SendPasswordReset(authRepository);
    signOut = SignOut(authRepository);
  }
}
