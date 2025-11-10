import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:traineasy/core/config/environment_config.dart';

class GeminiService {
  // Modelo principal recomendado para v1beta
  static const String _primaryModel = 'gemini-1.5-flash-latest';
  // Fallbacks amplos para compatibilidade
  static const List<String> _fallbackModels = [
    'gemini-1.5-pro-latest',
    'gemini-1.5-flash',
    'gemini-1.5-pro',
    'gemini-1.0-pro-latest',
    'gemini-1.0-pro',
  ];

  GenerativeModel _buildModel(String model) {
    final key = EnvironmentConfig.geminiApiKey;
    if (key.isEmpty) {
      throw StateError('GEMINI_API_KEY ausente. Configure no arquivo .env.');
    }
    return GenerativeModel(model: model, apiKey: key);
  }

  Future<String> generateText(String prompt) async {
    // Se definido via .env, tenta primeiro; depois tenta descobrir via ListModels
    final override = EnvironmentConfig.geminiModel;
    final discovered = await _discoverCompatibleModel();
    final models = <String>{
      if (override.isNotEmpty) override,
      if (discovered != null) discovered,
      _primaryModel,
      ..._fallbackModels,
    }.toList();
    Object? lastError;
    for (final m in models) {
      try {
        if (EnvironmentConfig.enableGeminiLogs) debugPrint('[Gemini] Tentando modelo: $m');
        final model = _buildModel(m);
        final response = await model.generateContent([Content.text(prompt)]);
        final text = response.text;
        if (text != null && text.isNotEmpty) {
          if (EnvironmentConfig.enableGeminiLogs) debugPrint('[Gemini] Sucesso com modelo: $m');
          return text;
        }
        if (EnvironmentConfig.enableGeminiLogs) debugPrint('[Gemini] Resposta vazia com modelo: $m');
        // Se vier vazio, tenta próximo modelo
      } catch (e) {
        lastError = e;
        if (EnvironmentConfig.enableGeminiLogs) debugPrint('[Gemini] Erro com modelo $m: $e');
        // Tenta próximo modelo em caso de erro (ex.: modelo não suportado)
      }
    }
    // Se todos falharem, propaga um erro amigável
    throw StateError(
      'Falha ao gerar texto com Gemini. Último erro: $lastError',
    );
  }

  /// Descobre um modelo compatível usando o endpoint ListModels da API.
  /// Retorna o id do modelo (sem o prefixo 'models/') ou null se não encontrar.
  Future<String?> _discoverCompatibleModel() async {
    final key = EnvironmentConfig.geminiApiKey;
    if (key.isEmpty) return null;
    // Usa cabeçalho em vez de query string para evitar vazamento acidental da API key
    final uri = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models');
    try {
      if (EnvironmentConfig.enableGeminiLogs) debugPrint('[Gemini] Consultando ListModels...');
      final resp = await http.get(uri, headers: {'x-goog-api-key': key});
      if (resp.statusCode != 200) {
        if (EnvironmentConfig.enableGeminiLogs) debugPrint('[Gemini] ListModels status ${resp.statusCode}: ${resp.body}');
        return null;
      }
      final data = convert.jsonDecode(resp.body) as Map<String, dynamic>;
      final models = (data['models'] as List?) ?? const [];
      if (EnvironmentConfig.enableGeminiLogs) debugPrint('[Gemini] ListModels retornou ${models.length} modelos');
      for (final m in models) {
        if (m is Map<String, dynamic>) {
          final name = (m['name'] as String?) ?? '';
          // Campo pode vir em camelCase (supportedGenerationMethods) ou snake_case em alguns exemplos
          final rawMethods = m.containsKey('supportedGenerationMethods')
              ? m['supportedGenerationMethods']
              : m['supported_generation_methods'];
          final methods = List<String>.from(rawMethods ?? const []);
          if (EnvironmentConfig.enableGeminiLogs) debugPrint('[Gemini] Modelo: $name, métodos: $methods');
          // Aceita modelos que suportam generateContent (v1beta) ou generateText (modelos antigos)
          final supports = methods.contains('generateContent') || methods.contains('generateText');
          if (name.isNotEmpty && supports) {
            final id = name.startsWith('models/') ? name.substring('models/'.length) : name;
            if (EnvironmentConfig.enableGeminiLogs) debugPrint('[Gemini] Modelo compatível encontrado via ListModels: $id');
            return id;
          }
        }
      }
      if (EnvironmentConfig.enableGeminiLogs) debugPrint('[Gemini] Nenhum modelo com generateContent/generateText encontrado na lista.');
      return null;
    } catch (e) {
      if (EnvironmentConfig.enableGeminiLogs) debugPrint('[Gemini] Falha ao consultar ListModels: $e');
      return null;
    }
  }
}