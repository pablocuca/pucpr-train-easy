import 'package:flutter/material.dart';

import 'package:traineasy/core/di/injector.dart';
import 'package:traineasy/core/usecase/usecase.dart';
import 'package:traineasy/core/result/result.dart';
import 'package:traineasy/features/auth/domain/entities/auth_user.dart';
import 'package:traineasy/features/auth/presentation/pages/login_page.dart';

class AuthGate extends StatelessWidget {
  final Widget childWhenAuthed;
  final Widget? childWhenUnauthed;
  const AuthGate(
      {super.key, required this.childWhenAuthed, this.childWhenUnauthed});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Result<Stream<AuthUser?>>>(
      future: Injector.observeAuthState(const NoParams()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData) {
          return childWhenUnauthed ?? const LoginPage();
        }
        final res = snapshot.data!;
        if (res is Err<Stream<AuthUser?>>) {
          return childWhenUnauthed ?? const LoginPage();
        }
        final stream = (res as Ok<Stream<AuthUser?>>).data;
        return StreamBuilder<AuthUser?>(
          stream: stream,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final authed = snap.data != null;
            if (authed) return childWhenAuthed;
            return childWhenUnauthed ?? const LoginPage();
          },
        );
      },
    );
  }
}
