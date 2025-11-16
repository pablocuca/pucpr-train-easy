import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:train_easy_design_system/train_easy_design_system.dart';
import 'package:traineasy/core/di/injector.dart';
import 'package:traineasy/core/telemetry/telemetry_service.dart';

class CrefValidationPage extends StatefulWidget {
  const CrefValidationPage({super.key});

  @override
  State<CrefValidationPage> createState() => _CrefValidationPageState();
}

class _CrefValidationPageState extends State<CrefValidationPage> {
  final _cref = TextEditingController();
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _cref.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final u = Injector.authRepository.currentUser;
    if (u == null) {
      setState(() { _loading = false; _error = 'Usuário não autenticado'; });
      return;
    }
    final doc = await FirebaseFirestore.instance.collection('users').doc(u.uid).get();
    final data = doc.data();
    if (data != null) {
      setState(() {
        _cref.text = (data['cref'] ?? '') as String;
        _loading = false;
      });
    } else {
      setState(() { _loading = false; });
    }
  }

  Future<void> _save() async {
    setState(() { _loading = true; _error = null; });
    final u = Injector.authRepository.currentUser;
    if (u == null) {
      setState(() { _loading = false; _error = 'Usuário não autenticado'; });
      return;
    }
    try {
      await FirebaseFirestore.instance.collection('users').doc(u.uid).update({
        'cref': _cref.text.trim(),
        'status_validacao': 'pendente',
      });
      await TelemetryService.trackEvent('cref_update', {'source': 'personal'});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('CREF enviado para validação')));
    } catch (e) {
      await TelemetryService.recordError(e, StackTrace.current);
      setState(() { _error = 'Falha ao salvar CREF'; });
    } finally {
      setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Validação do CREF', style: AppTypography.h2),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.s5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_error != null) ...[
              Text(_error!, style: AppTypography.caption),
              const SizedBox(height: AppSpacing.s3),
            ],
            TextFormField(
              controller: _cref,
              decoration: const InputDecoration(
                labelText: 'CREF',
                prefixIcon: Icon(Icons.badge, color: AppColors.accent),
              ),
            ),
            const Spacer(),
            PrimaryButton(label: _loading ? 'Enviando...' : 'Enviar para validação', onPressed: _loading ? null : _save),
          ],
        ),
      ),
    );
  }
}