// =========================================================================
// ARQUIVO: lib/modules/generator/data/repositories/bet_history_repository.dart
// =========================================================================
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/bet_history.dart';

class BetHistoryRepository {
  static const String _historyKey = 'bet_history';
  static const int _maxHistoryItems = 50;

  // Salvar aposta no histórico
  Future<void> saveBetHistory(BetHistory history) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Carregar histórico existente
    final currentHistory = await loadBetHistory();
    
    // Adicionar nova aposta no início
    currentHistory.insert(0, history);
    
    // Limitar a 50 itens
    if (currentHistory.length > _maxHistoryItems) {
      currentHistory.removeRange(_maxHistoryItems, currentHistory.length);
    }
    
    // Converter para JSON e salvar
    final jsonList = currentHistory.map((h) => h.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await prefs.setString(_historyKey, jsonString);
  }

  // Carregar histórico de apostas
  Future<List<BetHistory>> loadBetHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_historyKey);
    
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    
    try {
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.map((json) => BetHistory.fromJson(json)).toList();
    } catch (e) {
      // Se houver erro ao decodificar, retornar lista vazia
      return [];
    }
  }

  // Deletar uma aposta específica do histórico
  Future<void> deleteBetHistory(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final currentHistory = await loadBetHistory();
    
    // Remover aposta com o ID especificado
    currentHistory.removeWhere((h) => h.id == id);
    
    // Salvar histórico atualizado
    final jsonList = currentHistory.map((h) => h.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await prefs.setString(_historyKey, jsonString);
  }

  // Limpar todo o histórico
  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  // Obter quantidade de itens no histórico
  Future<int> getHistoryCount() async {
    final history = await loadBetHistory();
    return history.length;
  }
}
