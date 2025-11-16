import 'package:flutter/material.dart';
import 'package:train_easy_design_system/train_easy_design_system.dart';
import 'package:traineasy/presentation/profile/profile_page.dart';
import 'package:traineasy/core/telemetry/telemetry_service.dart';
import 'package:traineasy/core/di/injector.dart';
import 'package:traineasy/core/usecase/usecase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:traineasy/presentation/marketplace/marketplace_page.dart';
import 'dart:convert' as convert;

class MeuTreinoPage extends StatefulWidget {
  const MeuTreinoPage({super.key});

  @override
  State<MeuTreinoPage> createState() => _MeuTreinoPageState();
}

class _MeuTreinoPageState extends State<MeuTreinoPage> {
  int _currentIndex = 0;
  bool _loading = true;
  bool _treinoAtivo = false;
  bool _anamnesePreenchida = false;
  bool _gerandoTreino = false;
  String _treinoStatus = '';
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _userSub;
  final _formKeyAnamnese = GlobalKey<FormState>();
  final _objetivo = TextEditingController();
  String? _nivel;
  final _dias = TextEditingController();
  final _restricoes = TextEditingController();
  String? _selectedDayLabel;

  @override
  void initState() {
    super.initState();
    _loadFlags();
    _startUserListener();
  }

  @override
  void dispose() {
    _objetivo.dispose();
    _dias.dispose();
    _restricoes.dispose();
    _userSub?.cancel();
    super.dispose();
  }

  void _onTab(int index) {
    setState(() => _currentIndex = index);
    final label = switch (index) {
      0 => 'home',
      1 => 'treino',
      2 => 'perfil',
      _ => 'config'
    };
    TelemetryService.trackEvent('meu_treino_tab', {'tab': label});
  }

  Future<void> _loadFlags() async {
    final u = Injector.authRepository.currentUser;
    if (u == null) {
      setState(() {
        _loading = false;
      });
      return;
    }
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(u.uid).get();
    final data = doc.data();
    setState(() {
      _treinoAtivo = (data?['treino_ativo'] ?? false) as bool;
      _anamnesePreenchida = (data?['anamnese_preenchida'] ?? false) as bool;
      _treinoStatus =
          ((data?['treino'] ?? {}) as Map)['status']?.toString() ?? '';
      _loading = false;
    });
  }

  void _startUserListener() {
    final u = Injector.authRepository.currentUser;
    if (u == null) return;
    _userSub = FirebaseFirestore.instance
        .collection('users')
        .doc(u.uid)
        .snapshots()
        .listen((snap) {
      final data = snap.data() ?? {};
      final treino = (data['treino'] ?? {}) as Map;
      final status = treino['status']?.toString() ?? '';
      final ativo = (data['treino_ativo'] ?? false) as bool;
      setState(() {
        _treinoStatus = status;
        _treinoAtivo =
            ativo || status == 'aprovado' || status == 'aprovado_modificado';
        _anamnesePreenchida = (data['anamnese_preenchida'] ?? false) as bool;
      });
    });
  }

  String? _validateObjetivo(String? v) {
    if (v == null || v.trim().isEmpty) return 'Informe seu objetivo';
    return null;
  }

  String? _validateNivel(String? v) {
    if (v == null || v.isEmpty) return 'Selecione seu nível';
    return null;
  }

  String? _validateDias(String? v) {
    if (v == null || v.isEmpty) return 'Informe dias por semana';
    final n = int.tryParse(v);
    if (n == null || n < 1 || n > 7) return 'Entre 1 e 7 dias';
    return null;
  }

  Future<void> _saveAnamnese() async {
    if (!_formKeyAnamnese.currentState!.validate()) return;
    final u = Injector.authRepository.currentUser;
    if (u == null) return;
    await FirebaseFirestore.instance.collection('users').doc(u.uid).update({
      'anamnese': {
        'objetivo': _objetivo.text.trim(),
        'nivel': _nivel,
        'dias_semana': int.parse(_dias.text),
        'restricoes': _restricoes.text.trim(),
      },
      'anamnese_preenchida': true,
    });
    await TelemetryService.trackEvent('anamnese_save', {'source': 'aluno'});
    setState(() {
      _anamnesePreenchida = true;
    });
  }

  Widget _buildTreino() {
    final u = Injector.authRepository.currentUser;
    if (u == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.s4),
      child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(u.uid)
            .snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snap.data?.data() ?? {};
          final treino = (data['treino'] ?? {}) as Map;
          final planText = (treino['plano_texto'] ?? '') as String;
          Map<String, dynamic>? planMap =
              (treino['plan'] as Map?)?.cast<String, dynamic>();
          if (planMap == null && planText.isNotEmpty) {
            planMap = _tryParseJsonPlan(planText);
          }
          final status = (treino['status'] ?? '') as String;
          if (status == 'pendente') {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: const [
                Text('Aguardando Aprovação do Personal',
                    style: AppTypography.h3),
                SizedBox(height: AppSpacing.s2),
                Text('Seu treino será liberado após a aprovação.',
                    style: AppTypography.caption),
              ],
            );
          }
          if ((planMap == null ||
                  (planMap['days'] as List?)?.isEmpty != false) &&
              planText.isEmpty) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: const [
                Text('Treino do Dia', style: AppTypography.h3),
                SizedBox(height: AppSpacing.s2),
                Text('Nenhum plano encontrado. Gere um treino na Home.',
                    style: AppTypography.caption),
              ],
            );
          }
          final today = _ptWeekdayLabel(DateTime.now());
          String section = '';
          List<String> labels = const [];
          if (planMap != null) {
            final days = List<Map<String, dynamic>>.from(
                planMap['days'] as List? ?? const []);
            labels = days
                .map((d) => ((d['label'] ?? '') as String))
                .where((l) => l.isNotEmpty)
                .toList();
            final initial = labels.contains(_selectedDayLabel)
                ? _selectedDayLabel!
                : (labels.contains(today)
                    ? today
                    : (labels.isNotEmpty ? labels.first : today));
            _selectedDayLabel ??= initial;
            section = _sectionFromStructByLabel(planMap, _selectedDayLabel!);
          } else {
            final sections = _findDaySections(planText);
            labels = sections.keys.toList();
            final initial = labels.contains(_selectedDayLabel)
                ? _selectedDayLabel!
                : (labels.contains(today)
                    ? today
                    : (labels.isNotEmpty ? labels.first : today));
            _selectedDayLabel ??= initial;
            section = sections[_selectedDayLabel!] ?? '';
          }
          if (section.isEmpty) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Treino do Dia', style: AppTypography.h3),
                const SizedBox(height: AppSpacing.s3),
                Expanded(
                    child: SingleChildScrollView(
                        child: Text(planText, style: AppTypography.body))),
              ],
            );
          }
          final lines = section
              .split('\n')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(child: Text('Treino', style: AppTypography.h3)),
                  if (labels.isNotEmpty)
                    SizedBox(
                      width: 200,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedDayLabel,
                          isExpanded: true,
                          items: labels
                              .map((l) => DropdownMenuItem(
                                    value: l,
                                    child: Text(l,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1),
                                  ))
                              .toList(),
                          selectedItemBuilder: (context) => labels
                              .map((l) => Text(l,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1))
                              .toList(),
                          onChanged: (v) => setState(() => _selectedDayLabel = v),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.s3),
              Expanded(
                child: ListView.separated(
                  itemCount: lines.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.s2),
                  itemBuilder: (context, i) {
                    final l = lines[i];
                    final parts = l.split('•');
                    if (parts.length > 1) {
                      return ListTile(
                        leading: const Icon(Icons.fitness_center,
                            color: AppColors.accent),
                        title: Text(parts[0].trim(), style: AppTypography.body),
                        subtitle: Text(parts.sublist(1).join('•').trim(),
                            style: AppTypography.caption),
                      );
                    }
                    final colon = l.split(':');
                    if (colon.length > 1) {
                      return ListTile(
                        leading: const Icon(Icons.fitness_center,
                            color: AppColors.accent),
                        title: Text(colon[0].trim(), style: AppTypography.body),
                        subtitle: Text(colon.sublist(1).join(':').trim(),
                            style: AppTypography.caption),
                      );
                    }
                    return ListTile(
                      leading: const Icon(Icons.fitness_center,
                          color: AppColors.accent),
                      title: Text(l, style: AppTypography.body),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.s3),
              PrimaryButton(label: 'Iniciar Treino', onPressed: () {}),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPlanoCompleto() {
    final u = Injector.authRepository.currentUser;
    if (u == null) {
      return const Center(child: Text('Usuário não autenticado'));
    }
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.s4),
      child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(u.uid)
            .snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snap.data?.data() ?? {};
          final treino = (data['treino'] ?? {}) as Map;
          final planText = (treino['plano_texto'] ?? '') as String;
          Map<String, dynamic>? planMap =
              (treino['plan'] as Map?)?.cast<String, dynamic>();
          if (planMap == null && planText.isNotEmpty) {
            planMap = _tryParseJsonPlan(planText);
          }
          final status = (treino['status'] ?? '') as String;
          if (status == 'pendente') {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: const [
                Text('Aguardando Aprovação do Personal',
                    style: AppTypography.h3),
                SizedBox(height: AppSpacing.s2),
                Text('Assim que aprovado, seu plano completo aparecerá aqui.',
                    style: AppTypography.caption),
              ],
            );
          }
          if ((planMap == null ||
                  (planMap['days'] as List?)?.isEmpty != false) &&
              planText.isEmpty) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: const [
                Text('Nenhum treino disponível', style: AppTypography.h3),
                SizedBox(height: AppSpacing.s2),
                Text(
                    'Crie sua anamnese ou selecione um personal para gerar seu plano.',
                    style: AppTypography.caption),
              ],
            );
          }
          if (planMap != null) {
            final days =
                List<Map<String, dynamic>>.from(planMap['days'] as List);
            final orientation = (planMap['orientation'] ?? '') as String;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Plano Completo', style: AppTypography.h3),
                const SizedBox(height: AppSpacing.s3),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.sticky_note_2),
                    label: const Text('Orientações'),
                    onPressed: () {
                      if (orientation.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Sem orientações cadastradas')),
                        );
                        return;
                      }
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) {
                          return Padding(
                            padding: EdgeInsets.only(
                              left: AppSpacing.s4,
                              right: AppSpacing.s4,
                              top: MediaQuery.of(context).padding.top +
                                  AppSpacing.s4,
                              bottom: MediaQuery.of(context).viewInsets.bottom +
                                  AppSpacing.s4,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Text('Orientações do Plano',
                                    style: AppTypography.h3),
                                const SizedBox(height: AppSpacing.s2),
                                Text(orientation, style: AppTypography.body),
                                const SizedBox(height: AppSpacing.s3),
                                PrimaryButton(
                                    label: 'Fechar',
                                    onPressed: () =>
                                        Navigator.of(context).pop()),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    itemCount: days.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.s3),
                    itemBuilder: (context, idx) {
                      final day = days[idx];
                      final label = (day['label'] ?? 'Dia') as String;
                      final exercises = List<Map<String, dynamic>>.from(
                          day['exercises'] as List? ?? const []);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(label, style: AppTypography.h3),
                          const SizedBox(height: AppSpacing.s2),
                          ...exercises.map((ex) => ListTile(
                                leading: const Icon(Icons.fitness_center,
                                    color: AppColors.accent),
                                title: Text((ex['name'] ?? '') as String,
                                    style: AppTypography.body),
                                subtitle: Text(_formatExerciseSub(ex),
                                    style: AppTypography.caption),
                              )),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.s2),
                const SizedBox(height: AppSpacing.s2),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(status.isEmpty ? '' : 'Status: $status',
                      style: AppTypography.caption),
                ),
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Plano Completo', style: AppTypography.h3),
              const SizedBox(height: AppSpacing.s3),
              Expanded(
                child: SingleChildScrollView(
                    child: Text(planText, style: AppTypography.body)),
              ),
              const SizedBox(height: AppSpacing.s2),
              Align(
                alignment: Alignment.centerRight,
                child: Text(status.isEmpty ? '' : 'Status: $status',
                    style: AppTypography.caption),
              ),
            ],
          );
        },
      ),
    );
  }

  String _ptWeekdayLabel(DateTime d) {
    return switch (d.weekday) {
      DateTime.monday => 'Segunda',
      DateTime.tuesday => 'Terça',
      DateTime.wednesday => 'Quarta',
      DateTime.thursday => 'Quinta',
      DateTime.friday => 'Sexta',
      DateTime.saturday => 'Sábado',
      _ => 'Domingo',
    };
  }

  Map<String, String> _findDaySections(String text) {
    final lines = text.split('\n');
    final headers = <String>[
      'Segunda',
      'Terça',
      'Quarta',
      'Quinta',
      'Sexta',
      'Sábado',
      'Domingo'
    ];
    final out = <String, String>{};
    String? current;
    final buf = <String>[];
    for (final raw in lines) {
      final line = raw.trim();
      final isHeaderWeek =
          headers.any((h) => line.toLowerCase().startsWith(h.toLowerCase()));
      final diaMatch =
          RegExp(r'^Dia\s*(\d+)', caseSensitive: false).firstMatch(line);
      if (isHeaderWeek || diaMatch != null) {
        if (current != null) {
          out[current] = buf.join('\n');
          buf.clear();
        }
        current = isHeaderWeek
            ? headers.firstWhere(
                (h) => line.toLowerCase().startsWith(h.toLowerCase()))
            : 'Dia ${diaMatch!.group(1)}';
      } else {
        if (current != null) buf.add(line);
      }
    }
    if (current != null && buf.isNotEmpty) {
      out[current] = buf.join('\n');
    }
    return out;
  }

  Map<String, dynamic>? _tryParseJsonPlan(String text) {
    var s = text.trim();
    s = s.replaceAll(RegExp(r'```[a-zA-Z]*'), '').trim();
    final start = s.indexOf('{');
    final end = s.lastIndexOf('}');
    if (start != -1 && end != -1 && end > start) {
      s = s.substring(start, end + 1);
    }
    try {
      final obj = convert.jsonDecode(s);
      if (obj is Map<String, dynamic>) return obj;
    } catch (_) {}
    return null;
  }

  String _sectionFromStructByLabel(Map<String, dynamic> plan, String label) {
    final days =
        List<Map<String, dynamic>>.from(plan['days'] as List? ?? const []);
    final day = days.firstWhere(
        (d) =>
            ((d['label'] ?? '') as String).toLowerCase() == label.toLowerCase(),
        orElse: () => {});
    if (day.isEmpty) return '';
    final exercises =
        List<Map<String, dynamic>>.from(day['exercises'] as List? ?? const []);
    final lines = exercises.map((ex) {
      final name = (ex['name'] ?? '') as String;
      final sets = (ex['sets'] ?? '') as String;
      final notes = (ex['notes'] ?? '') as String;
      final sub = [sets, notes].where((s) => s.isNotEmpty).join(' • ');
      return sub.isEmpty ? name : '$name • $sub';
    }).toList();
    return lines.join('\n');
  }

  String _formatExerciseSub(Map<String, dynamic> ex) {
    final sets = (ex['sets'] ?? '') as String;
    final notes = (ex['notes'] ?? '') as String;
    final parts = [sets, notes].where((s) => s.isNotEmpty).toList();
    return parts.isEmpty ? '' : parts.join(' • ');
  }

  Widget _buildAnamneseForm() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.s4),
      child: Form(
        key: _formKeyAnamnese,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Questionário de Anamnese', style: AppTypography.h3),
            const SizedBox(height: AppSpacing.s3),
            TextFormField(
              controller: _objetivo,
              validator: _validateObjetivo,
              decoration: const InputDecoration(
                labelText: 'Objetivo Principal',
                prefixIcon: Icon(Icons.flag, color: AppColors.accent),
              ),
            ),
            const SizedBox(height: AppSpacing.s3),
            DropdownButtonFormField<String>(
              initialValue: _nivel,
              validator: _validateNivel,
              items: const [
                DropdownMenuItem(value: 'iniciante', child: Text('Iniciante')),
                DropdownMenuItem(
                    value: 'intermediario', child: Text('Intermediário')),
                DropdownMenuItem(value: 'avancado', child: Text('Avançado')),
              ],
              onChanged: (v) => setState(() => _nivel = v),
              decoration: const InputDecoration(
                labelText: 'Nível',
                prefixIcon:
                    Icon(Icons.stacked_bar_chart, color: AppColors.accent),
              ),
            ),
            const SizedBox(height: AppSpacing.s3),
            TextFormField(
              controller: _dias,
              keyboardType: TextInputType.number,
              validator: _validateDias,
              decoration: const InputDecoration(
                labelText: 'Dias por semana',
                prefixIcon: Icon(Icons.calendar_today, color: AppColors.accent),
              ),
            ),
            const SizedBox(height: AppSpacing.s3),
            TextFormField(
              controller: _restricoes,
              decoration: const InputDecoration(
                labelText: 'Restrições (opcional)',
                prefixIcon:
                    Icon(Icons.medical_information, color: AppColors.accent),
              ),
            ),
            const SizedBox(height: AppSpacing.s4),
            PrimaryButton(label: 'Salvar Anamnese', onPressed: _saveAnamnese),
          ],
        ),
      ),
    );
  }

  Widget _buildHome() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_treinoAtivo) {
      return _buildTreino();
    }
    if (!_anamnesePreenchida) {
      return _buildAnamneseForm();
    }
    if (_treinoStatus == 'pendente') {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.s4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            Text('Aguardando Aprovação do Personal', style: AppTypography.h3),
            SizedBox(height: AppSpacing.s2),
            Text('Você será notificado quando seu treino for aprovado.',
                style: AppTypography.caption),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Como deseja treinar?', style: AppTypography.h3),
          const SizedBox(height: AppSpacing.s3),
          PrimaryButton(
            label: _gerandoTreino
                ? 'Gerando treino...'
                : 'Gerar Treino com IA (Padrão)',
            onPressed: _gerandoTreino ? null : _generateTreinoIA,
          ),
          const SizedBox(height: AppSpacing.s2),
          OutlinedButton(
            onPressed: () {
              TelemetryService.trackEvent('mode_select', {'mode': 'personal'});
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MarketplacePage()),
              );
            },
            child: const Text('Selecionar um Personal'),
          ),
        ],
      ),
    );
  }

  Future<void> _generateTreinoIA() async {
    setState(() {
      _gerandoTreino = true;
    });
    TelemetryService.trackEvent('mode_select', {'mode': 'ia_padrao'});
    TelemetryService.trackEvent('generate_training_start', {'source': 'aluno'});
    final u = Injector.authRepository.currentUser;
    if (u == null) {
      setState(() {
        _gerandoTreino = false;
      });
      return;
    }
    try {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(u.uid).get();
      final data = doc.data() ?? {};
      final anamnese = (data['anamnese'] as Map?) ?? {};
      final objetivo = anamnese['objetivo'] ?? '';
      final nivel = anamnese['nivel'] ?? '';
      final dias = anamnese['dias_semana'] ?? 3;
      final restricoes = anamnese['restricoes'] ?? '';

      final prompt = 'Crie um plano SEMANAL estruturado apenas em JSON. '
          'Use o seguinte schema: {"orientation": string, "days": [{"label": string, "exercises": [{"name": string, "sets": string, "notes": string}]}]}. '
          'Sem texto fora do JSON. '
          'Objetivo: $objetivo. Nível: $nivel. Dias/semana: $dias. Restrições: $restricoes.';

      final planText = await Injector.gemini.generateText(prompt);
      Map<String, dynamic>? plan;
      try {
        plan = convert.jsonDecode(planText) as Map<String, dynamic>;
      } catch (_) {}
      plan ??= _tryParseJsonPlan(planText);

      await FirebaseFirestore.instance.collection('users').doc(u.uid).update({
        'treino_ativo': true,
        'treino': {
          'status': 'auto_aprovado',
          'gerado_em': DateTime.now().toIso8601String(),
          'fonte': 'ia_padrao',
          'plano_texto': planText,
          if (plan != null) 'plan': plan,
        },
      });

      await TelemetryService.trackEvent(
          'generate_training_success', {'mode': 'ia_padrao'});
      if (mounted) {
        setState(() {
          _treinoAtivo = true;
          _gerandoTreino = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Treino gerado!')),
        );
      }
    } catch (e) {
      await TelemetryService.recordError(e, StackTrace.current);
      await TelemetryService.trackEvent(
          'generate_training_failure', {'mode': 'ia_padrao'});
      if (mounted) {
        setState(() {
          _gerandoTreino = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Falha ao gerar treino')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Meu Treino', style: AppTypography.h2),
        centerTitle: true,
      ),
      body: switch (_currentIndex) {
        0 => _buildHome(),
        1 => _buildPlanoCompleto(),
        2 => const ProfilePage(),
        _ => Padding(
            padding: const EdgeInsets.all(AppSpacing.s4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Configurações', style: AppTypography.h3),
                const SizedBox(height: AppSpacing.s3),
                PrimaryButton(
                    label: 'Sair',
                    onPressed: () async {
                      await Injector.signOut(const NoParams());
                    }),
              ],
            ),
          ),
      },
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTab,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.surface2,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Treino'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Config'),
        ],
      ),
    );
  }
}
