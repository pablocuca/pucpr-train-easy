import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:train_easy_design_system/train_easy_design_system.dart';
import 'package:traineasy/core/di/injector.dart';
import 'package:traineasy/core/telemetry/telemetry_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _name = TextEditingController();
  final _birthText = TextEditingController();
  DateTime? _birth;
  final _prompt = TextEditingController();
  bool _isPersonal = false;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _name.dispose();
    _birthText.dispose();
    _prompt.dispose();
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
        _name.text = (data['nome'] ?? '') as String;
        _isPersonal = ((data['role'] ?? '') as String) == 'personal';
        final raw = (data['birthDate'] ?? '') as String;
        if (raw.isNotEmpty) {
          _birth = DateTime.tryParse(raw);
          _birthText.text = _birth == null ? '' : _fmt(_birth!);
        }
        _prompt.text = (data['prompt_mestre'] ?? '') as String;
        _loading = false;
      });
    } else {
      setState(() { _loading = false; });
    }
  }

  String _fmt(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yyyy = d.year.toString();
    return '$dd/$mm/$yyyy';
  }

  Future<void> _pickBirth() async {
    final now = DateTime.now();
    final initial = _birth ?? DateTime(now.year - 18, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Data de Nascimento',
    );
    if (picked != null) {
      setState(() {
        _birth = picked;
        _birthText.text = _fmt(picked);
      });
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
        'nome': _name.text.trim(),
        'birthDate': _birth?.toIso8601String() ?? '',
        if (_isPersonal) 'prompt_mestre': _prompt.text.trim(),
      });
      await TelemetryService.trackEvent('profile_save', {'source': 'profile'});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Perfil salvo')));
    } catch (e) {
      await TelemetryService.recordError(e, StackTrace.current);
      setState(() { _error = 'Falha ao salvar perfil'; });
    } finally {
      setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Meu Perfil', style: AppTypography.h2),
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
              controller: _name,
              decoration: const InputDecoration(
                labelText: 'Nome',
                prefixIcon: Icon(Icons.person, color: AppColors.accent),
              ),
            ),
            const SizedBox(height: AppSpacing.s3),
            TextFormField(
              controller: _birthText,
              readOnly: true,
              onTap: _pickBirth,
              decoration: const InputDecoration(
                labelText: 'Data de Nascimento',
                prefixIcon: Icon(Icons.calendar_today, color: AppColors.accent),
              ),
            ),
            if (_isPersonal) ...[
              const SizedBox(height: AppSpacing.s3),
              TextFormField(
                controller: _prompt,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Metodologia (prompt_mestre)',
                  prefixIcon: Icon(Icons.tips_and_updates, color: AppColors.accent),
                ),
              ),
            ],
            const Spacer(),
            PrimaryButton(label: _loading ? 'Salvando...' : 'Salvar', onPressed: _loading ? null : _save),
          ],
        ),
      ),
    );
  }
}