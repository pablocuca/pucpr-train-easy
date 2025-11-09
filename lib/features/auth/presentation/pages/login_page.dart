import 'package:flutter/material.dart';
import 'package:train_easy_design_system/train_easy_design_system.dart';

import 'package:traineasy/core/di/injector.dart';
import 'package:traineasy/features/auth/presentation/controllers/auth_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late final AuthController _controller;
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late final AnimationController _anim;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AuthController(
      Injector.signInWithEmailPassword,
      Injector.registerWithEmailPassword,
      Injector.sendPasswordReset,
      Injector.signOut,
    );
    _anim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600))
      ..forward();
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _anim.dispose();
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
    await _controller.signIn(_email.text.trim(), _password.text);
    if (mounted && _controller.error != null) {
      _showSnack(_controller.error!);
    }
  }

  Future<void> _onRegister() async {
    if (!_formKey.currentState!.validate()) return;
    await _controller.register(_email.text.trim(), _password.text);
    if (mounted && _controller.error != null) {
      _showSnack(_controller.error!);
    }
  }

  Future<void> _onForgot() async {
    final email = _email.text.trim();
    if (_validateEmail(email) != null) {
      _showSnack('Informe um e-mail válido para recuperar a senha');
      return;
    }
    final ok = await _controller.sendReset(email);
    if (mounted) {
      _showSnack(ok
          ? 'E-mail de recuperação enviado'
          : (_controller.error ?? 'Falha ao enviar e-mail'));
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: AppTypography.body.copyWith(color: AppColors.accent),
        ),
        backgroundColor: AppColors.surface2,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.surface2, AppColors.surface],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: const EdgeInsets.only(top: 100),
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s5, vertical: AppSpacing.s3),
              decoration: BoxDecoration(
                color: AppColors.surface2,
                borderRadius: BorderRadius.circular(AppRadius.r2),
              ),
              child: const Text('Train Easy', style: AppTypography.h1),
            ),
          ),
          Center(
            child: FadeTransition(
              opacity: _fade,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.s5),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.s5),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.r3),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.fitness_center,
                              color: AppColors.accent, size: 40),
                          const SizedBox(height: AppSpacing.s4),
                          TextFormField(
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            validator: _validateEmail,
                            decoration: const InputDecoration(
                              labelText: 'E-mail',
                              prefixIcon:
                                  Icon(Icons.mail, color: AppColors.accent),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.s4),
                          TextFormField(
                            controller: _password,
                            obscureText: true,
                            validator: _validatePassword,
                            decoration: const InputDecoration(
                              labelText: 'Senha',
                              prefixIcon:
                                  Icon(Icons.lock, color: AppColors.accent),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.s5),
                          Row(
                            children: [
                              Expanded(
                                child: PrimaryButton(
                                  label: _controller.loading
                                      ? 'Entrando...'
                                      : 'Entrar',
                                  onPressed:
                                      _controller.loading ? null : _onLogin,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.s2),
                          Row(
                            children: [
                              Expanded(
                                child: PrimaryButton(
                                  label: _controller.loading
                                      ? 'Criando...'
                                      : 'Criar conta',
                                  isFilled: false,
                                  onPressed:
                                      _controller.loading ? null : _onRegister,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.s3),
                          TextButton(
                            onPressed: _controller.loading ? null : _onForgot,
                            child: const Text('Esqueci minha senha',
                                style: AppTypography.caption),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
