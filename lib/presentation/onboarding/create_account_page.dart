import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:train_easy_design_system/train_easy_design_system.dart';
import 'package:traineasy/features/auth/presentation/controllers/auth_controller.dart';
import 'package:traineasy/core/di/injector.dart';
import 'package:traineasy/presentation/auth/login_page_v2.dart';
import 'role_selection_page.dart';
import 'package:traineasy/core/telemetry/telemetry_service.dart';

class CreateAccountPage extends StatefulWidget {
  final UserRole role;
  const CreateAccountPage({super.key, required this.role});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  late final AuthController _controller;
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _cref = TextEditingController();
  final _birthDateText = TextEditingController();
  DateTime? _birthDate;
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
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    _cref.dispose();
    _birthDateText.dispose();
    super.dispose();
  }

  String? _validateName(String? v) {
    if (v == null || v.trim().isEmpty) return 'Informe seu nome completo';
    return null;
  }

  String? _validateEmail(String? v) {
    if (v == null || v.isEmpty) return 'Informe seu e-mail';
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v);
    return ok ? null : 'E-mail inválido';
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Crie uma senha forte';
    if (v.length < 6) return 'Mínimo 6 caracteres';
    return null;
  }

  String? _validateConfirm(String? v) {
    if (v != _password.text) return 'Senhas não coincidem';
    return null;
  }

  String? _validateBirthDate() {
    if (_birthDate == null) return 'Selecione sua data de nascimento';
    return null;
  }

  String? _validateCref(String? v) {
    if (widget.role == UserRole.personal) {
      if (v == null || v.trim().isEmpty) return 'Informe seu número do CREF';
      // Validação simples: ao menos 5 caracteres (ajuste conforme regra real)
      if (v.trim().length < 5) return 'CREF inválido';
    }
    return null;
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final initial = DateTime(now.year - 18, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Data de Nascimento',
    );
    if (picked != null) {
      setState(() {
        _birthDate = picked;
        _birthDateText.text = _formatDate(picked);
      });
    }
  }

  String _formatDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yyyy = d.year.toString();
    return '$dd/$mm/$yyyy';
  }

  Future<void> _onCreateAccount() async {
    if (!_formKey.currentState!.validate()) return;
    // Validação adicional de data de nascimento fora dos TextFormField
    final bdErr = _validateBirthDate();
    if (bdErr != null) {
      _showSnack(bdErr);
      return;
    }
    await TelemetryService.trackEvent('auth_register_start', {
      'role': widget.role == UserRole.aluno ? 'aluno' : 'personal'
    });
    final user = await _controller.register(_email.text.trim(), _password.text);
    if (mounted) {
      if (_controller.error != null) {
        await TelemetryService.trackEvent('auth_register_failure', {
          'role': widget.role == UserRole.aluno ? 'aluno' : 'personal'
        });
        _showSnack(_controller.error!);
      } else {
        // Persistir documento do usuário em Firestore
        try {
          final uid = user!.uid;
          final data = <String, dynamic>{
            'uid': uid,
            'email': _email.text.trim(),
            'nome': _name.text.trim(),
            'role': widget.role == UserRole.aluno ? 'aluno' : 'personal',
            'birthDate': _birthDate!.toIso8601String(),
          };
          if (widget.role == UserRole.personal) {
            data['cref'] = _cref.text.trim();
            data['status_validacao'] = 'pendente';
          }
          await FirebaseFirestore.instance.collection('users').doc(uid).set(data);
          await TelemetryService.setUser(uid);
          await TelemetryService.trackEvent('auth_register_success', {
            'role': widget.role == UserRole.aluno ? 'aluno' : 'personal'
          });
          _showSnack('Conta criada com sucesso');
          if (!mounted) return;
          Navigator.of(context).popUntil((route) => route.isFirst);
        } catch (e) {
          await TelemetryService.recordError(e, StackTrace.current);
          await TelemetryService.trackEvent('user_doc_save_failure', {
            'role': widget.role == UserRole.aluno ? 'aluno' : 'personal',
            'error': e.toString(),
          });
          _showSnack('Falha ao salvar perfil no Firestore');
          if (!mounted) return;
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      }
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
        title: const Text('Criar Conta', style: AppTypography.h2),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
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
                      const Text('Crie sua conta', style: AppTypography.h2),
                      const SizedBox(height: AppSpacing.s2),
                      const Text('Preencha seus dados para começar a treinar.', style: AppTypography.caption),
                      const SizedBox(height: AppSpacing.s4),
                      TextFormField(
                        controller: _name,
                        validator: _validateName,
                        decoration: const InputDecoration(
                          labelText: 'Nome Completo',
                          prefixIcon: Icon(Icons.person, color: AppColors.accent),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s3),
                      TextFormField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        validator: _validateEmail,
                        decoration: const InputDecoration(
                          labelText: 'E-mail',
                          prefixIcon: Icon(Icons.mail, color: AppColors.accent),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s3),
                      TextFormField(
                        controller: _birthDateText,
                        readOnly: true,
                        onTap: _pickBirthDate,
                        decoration: const InputDecoration(
                          labelText: 'Data de Nascimento',
                          prefixIcon: Icon(Icons.calendar_today, color: AppColors.accent),
                        ),
                        validator: (_) => _validateBirthDate(),
                      ),
                      if (widget.role == UserRole.personal) ...[
                        const SizedBox(height: AppSpacing.s3),
                        TextFormField(
                          controller: _cref,
                          validator: _validateCref,
                          decoration: const InputDecoration(
                            labelText: 'Nº do CREF',
                            prefixIcon: Icon(Icons.badge, color: AppColors.accent),
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.s3),
                      TextFormField(
                        controller: _password,
                        obscureText: true,
                        validator: _validatePassword,
                        decoration: const InputDecoration(
                          labelText: 'Senha',
                          prefixIcon: Icon(Icons.lock, color: AppColors.accent),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s3),
                      TextFormField(
                        controller: _confirm,
                        obscureText: true,
                        validator: _validateConfirm,
                        decoration: const InputDecoration(
                          labelText: 'Confirmar Senha',
                          prefixIcon: Icon(Icons.lock, color: AppColors.accent),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s4),
                      PrimaryButton(
                        label: _controller.loading ? 'Criando...' : 'Criar Conta',
                        onPressed: _controller.loading ? null : _onCreateAccount,
                      ),
                      const SizedBox(height: AppSpacing.s2),
                      Align(
                        alignment: Alignment.center,
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (_) => const LoginPageV2()),
                            );
                          },
                          child: const Text('Já tem uma conta? Faça login', style: AppTypography.caption),
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