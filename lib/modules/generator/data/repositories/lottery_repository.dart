// =========================================================================
// ARQUIVO: lib/modules/generator/data/repositories/lottery_repository.dart
// =========================================================================
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/mega_sena_draw.dart';
import '../../domain/services/frequency_calculator.dart';
import '../datasources/caixa_api_provider.dart';
import '../number_lists.dart';

/// Resultado de uma tentativa de atualização das frequências da Mega-Sena.
class LotteryFrequencyResult {
  final List<int> mostFrequentNumbers;
  final bool fromCache;
  final MegaSenaDraw? lastDraw;

  const LotteryFrequencyResult({
    required this.mostFrequentNumbers,
    required this.fromCache,
    this.lastDraw,
  });
}

/// Busca o resultado mais recente da Mega-Sena na API da Caixa, acumula os
/// concursos em cache local e recalcula a frequência de cada dezena.
///
/// Se a API falhar (timeout, erro HTTP, payload em formato inesperado) após
/// [maxRetryAttempts] tentativas, cai silenciosamente para os últimos dados
/// válidos em cache — e, na ausência de qualquer cache (primeiro uso, offline),
/// para os dados estáticos embutidos em [LotteryData.megaSena]. Uma nova
/// tentativa junto à API ocorre naturalmente na próxima inicialização do app.
class LotteryRepository {
  static const String _drawsKey = 'mega_sena_draws_cache';
  static const String _frequenciesKey = 'mega_sena_frequencies_cache';
  static const String _lastAttemptKey = 'mega_sena_last_fetch_attempt';
  static const int maxRetryAttempts = 5;
  static const int _maxCachedDraws = 500;
  static const int _maxNumber = 60;

  final CaixaApiProvider apiProvider;

  LotteryRepository(this.apiProvider);

  Future<LotteryFrequencyResult> refreshMegaSenaFrequencies() async {
    for (var attempt = 1; attempt <= maxRetryAttempts; attempt++) {
      try {
        final draw = await apiProvider.fetchLatestMegaSena();
        await _appendDraw(draw);
        final frequencies = await _recalculateAndCacheFrequencies();
        return LotteryFrequencyResult(
          mostFrequentNumbers: frequencies,
          fromCache: false,
          lastDraw: draw,
        );
      } on FormatException {
        // Estrutura do payload mudou — tentar de novo agora não ajuda.
        break;
      } on TimeoutException {
        continue;
      } on SocketException {
        continue;
      } on CaixaApiException {
        continue;
      } catch (_) {
        continue;
      }
    }

    await _recordFailedAttempt();
    final cachedFrequencies = await _loadCachedFrequencies();
    final lastDraw = await _loadLastCachedDraw();
    return LotteryFrequencyResult(
      mostFrequentNumbers: cachedFrequencies ?? LotteryData.megaSena.mostFrequentNumbers,
      fromCache: true,
      lastDraw: lastDraw,
    );
  }

  Future<void> _appendDraw(MegaSenaDraw draw) async {
    final draws = await _loadCachedDraws();
    if (draws.any((d) => d.concurso == draw.concurso)) return;

    draws.add(draw);
    draws.sort((a, b) => a.concurso.compareTo(b.concurso));
    if (draws.length > _maxCachedDraws) {
      draws.removeRange(0, draws.length - _maxCachedDraws);
    }

    final prefs = await SharedPreferences.getInstance();
    final jsonList = draws.map((d) => d.toJson()).toList();
    await prefs.setString(_drawsKey, jsonEncode(jsonList));
  }

  Future<List<MegaSenaDraw>> _loadCachedDraws() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_drawsKey);
    if (jsonString == null || jsonString.isEmpty) return [];

    try {
      final list = jsonDecode(jsonString) as List;
      return list.map((e) => MegaSenaDraw.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<int>> _recalculateAndCacheFrequencies() async {
    final draws = await _loadCachedDraws();
    final counts = FrequencyCalculator.calculate(draws.map((d) => d.dezenas).toList());
    final sorted = FrequencyCalculator.sortByFrequency(counts, maxNumber: _maxNumber);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_frequenciesKey, jsonEncode(sorted));
    return sorted;
  }

  Future<List<int>?> _loadCachedFrequencies() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_frequenciesKey);
    if (jsonString == null || jsonString.isEmpty) return null;

    try {
      final list = jsonDecode(jsonString) as List;
      return list.map((e) => e as int).toList();
    } catch (_) {
      return null;
    }
  }

  Future<MegaSenaDraw?> _loadLastCachedDraw() async {
    final draws = await _loadCachedDraws();
    if (draws.isEmpty) return null;
    draws.sort((a, b) => b.concurso.compareTo(a.concurso));
    return draws.first;
  }

  Future<void> _recordFailedAttempt() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastAttemptKey, DateTime.now().toIso8601String());
  }

  /// Momento da última tentativa que precisou cair para o cache (falha na API).
  Future<DateTime?> getLastFailedAttempt() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_lastAttemptKey);
    if (value == null) return null;
    return DateTime.tryParse(value);
  }
}
