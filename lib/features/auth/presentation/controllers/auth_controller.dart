import 'package:flutter/foundation.dart';

import 'package:traineasy/core/result/result.dart';
import 'package:traineasy/core/usecase/usecase.dart';
import 'package:traineasy/features/auth/domain/entities/auth_user.dart';
import 'package:traineasy/features/auth/domain/usecases/register_with_email_password.dart';
import 'package:traineasy/features/auth/domain/usecases/send_password_reset.dart';
import 'package:traineasy/features/auth/domain/usecases/sign_in_with_email_password.dart';
import 'package:traineasy/features/auth/domain/usecases/sign_out.dart';

class AuthController extends ChangeNotifier {
  final SignInWithEmailPassword _signIn;
  final RegisterWithEmailPassword _register;
  final SendPasswordReset _reset;
  final SignOut _signOut;

  bool _loading = false;
  String? _error;
  bool get loading => _loading;
  String? get error => _error;

  AuthController(this._signIn, this._register, this._reset, this._signOut);

  Future<AuthUser?> signIn(String email, String password) async {
    _set(loading: true, error: null);
    final res = await _signIn(SignInWithEmailPasswordParams(email: email, password: password));
    String? err;
    if (res is Err<AuthUser>) err = res.failure.message;
    _set(loading: false, error: err);
    return res.value;
  }

  Future<AuthUser?> register(String email, String password) async {
    _set(loading: true, error: null);
    final res = await _register(RegisterWithEmailPasswordParams(email: email, password: password));
    String? err;
    if (res is Err<AuthUser>) err = res.failure.message;
    _set(loading: false, error: err);
    return res.value;
  }

  Future<bool> sendReset(String email) async {
    _set(loading: true, error: null);
    final res = await _reset(SendPasswordResetParams(email));
    String? err;
    if (res is Err<void>) err = res.failure.message;
    _set(loading: false, error: err);
    return res.isOk;
  }

  Future<bool> signOut() async {
    _set(loading: true, error: null);
    final res = await _signOut(const NoParams());
    String? err;
    if (res is Err<void>) err = res.failure.message;
    _set(loading: false, error: err);
    return res.isOk;
  }

  void _set({bool? loading, String? error}) {
    _loading = loading ?? _loading;
    _error = error;
    notifyListeners();
  }
}
