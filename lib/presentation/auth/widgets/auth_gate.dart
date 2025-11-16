import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:traineasy/core/di/injector.dart';
import 'package:traineasy/core/usecase/usecase.dart';
import 'package:traineasy/core/result/result.dart';
import 'package:traineasy/features/auth/domain/entities/auth_user.dart';
import 'package:traineasy/presentation/onboarding/welcome_page.dart';
// import 'package:traineasy/presentation/home/home_page.dart';
import 'package:traineasy/presentation/student/meu_treino_page.dart';
import 'package:traineasy/presentation/trainer/dashboard_page.dart';
import 'package:traineasy/presentation/onboarding/pending_validation_page.dart';
import 'package:traineasy/core/telemetry/telemetry_service.dart';

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
          return childWhenUnauthed ?? const WelcomePage();
        }
        final res = snapshot.data!;
        if (res is Err<Stream<AuthUser?>>) {
          return childWhenUnauthed ?? const WelcomePage();
        }
        final stream = (res as Ok<Stream<AuthUser?>>).data;
        return StreamBuilder<AuthUser?>(
          stream: stream,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final user = snap.data;
            final authed = user != null;
            if (authed) {
              return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .snapshots(),
                builder: (context, userDocSnap) {
                  if (userDocSnap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final data = userDocSnap.data?.data();
                  if (data == null) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final role = (data['role'] ?? '') as String;
                  final status = (data['status_validacao'] ?? '') as String;
                  TelemetryService.setUser(user.uid);
                  if (role == 'aluno') {
                    TelemetryService.trackEvent('role_routing', {'role': role, 'status': status, 'target': 'meu_treino'});
                    return const MeuTreinoPage();
                  }
                  if (role == 'personal' && status == 'validado') {
                    TelemetryService.trackEvent('role_routing', {'role': role, 'status': status, 'target': 'trainer_dashboard'});
                    return const TrainerDashboardPage();
                  }
                  if (role == 'personal') {
                    TelemetryService.trackEvent('role_routing', {'role': role, 'status': status, 'target': 'pending_validation'});
                    return const PendingValidationPage();
                  }
                  return childWhenAuthed;
                },
              );
            }
            return childWhenUnauthed ?? const WelcomePage();
          },
        );
      },
    );
  }
}
