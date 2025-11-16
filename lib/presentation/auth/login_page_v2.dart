import 'package:flutter/material.dart';
import 'package:train_easy_design_system/train_easy_design_system.dart';

import 'package:traineasy/core/di/injector.dart';
import 'package:traineasy/features/auth/presentation/controllers/auth_controller.dart';
import 'package:traineasy/presentation/onboarding/role_selection_page.dart';
import 'package:traineasy/core/telemetry/telemetry_service.dart';

class LoginPageV2 extends StatefulWidget {
  const LoginPageV2({super.key});

  @override
  State<LoginPageV2> createState() => _LoginPageV2State();
}

class _LoginPageV2State extends State<LoginPageV2> {
  late final AuthController _controller;
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = AuthController(
      Injector.signInWithEmailPassword,
      Injector.registerWithEmailPassword,
      Injector.sendPasswordReset,
      Injector.signOut,
    );
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Informe seu e-mail';
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
    return ok ? null : 'E-mail inválido';
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Informe sua senha';
    if (value.length < 6) return 'Mínimo 6 caracteres';
    return null;
  }

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;
    await TelemetryService.trackEvent('auth_login_start', {'method': 'email_password'});
    await _controller.signIn(_email.text.trim(), _password.text);
    if (mounted && _controller.error != null) {
      await TelemetryService.trackEvent('auth_login_failure', {'method': 'email_password'});
      _showSnack(_controller.error!);
    } else {
      await TelemetryService.trackEvent('auth_login_success', {'method': 'email_password'});
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  void _goToRegisterFlow() {
    TelemetryService.trackEvent('navigate_role_selection', {});
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const RoleSelectionPage()),
    );
  }

  Future<void> _onForgot() async {
    final email = _email.text.trim();
    if (_validateEmail(email) != null) {
      _showSnack('Informe um e-mail válido para recuperar a senha');
      return;
    }
    await TelemetryService.trackEvent('auth_reset_request', {});
    final ok = await _controller.sendReset(email);
    if (mounted) {
      _showSnack(ok ? 'E-mail de recuperação enviado' : (_controller.error ?? 'Falha ao enviar e-mail'));
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: AppTypography.body.copyWith(color: AppColors.accent)),
        backgroundColor: AppColors.surface2,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Entrar', style: AppTypography.h2),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.s5),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.r3),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.s5),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.fitness_center, color: AppColors.accent, size: 40),
                          SizedBox(width: AppSpacing.s2),
                          Text('Train Easy', style: AppTypography.h1),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s5),
                      TextFormField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        validator: _validateEmail,
                        decoration: const InputDecoration(
                          labelText: 'E-mail',
                          prefixIcon: Icon(Icons.mail, color: AppColors.accent),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s4),
                      TextFormField(
                        controller: _password,
                        obscureText: true,
                        validator: _validatePassword,
                        decoration: const InputDecoration(
                          labelText: 'Senha',
                          prefixIcon: Icon(Icons.lock, color: AppColors.accent),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s5),
                      PrimaryButton(
                        label: _controller.loading ? 'Entrando...' : 'Entrar',
                        onPressed: _controller.loading ? null : _onLogin,
                      ),
                      const SizedBox(height: AppSpacing.s2),
                      PrimaryButton(
                        label: 'Criar conta',
                        isFilled: false,
                        onPressed: _goToRegisterFlow,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _controller.loading ? null : _onForgot,
                          child: const Text('Esqueci minha senha', style: AppTypography.caption),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}