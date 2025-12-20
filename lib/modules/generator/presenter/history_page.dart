// =========================================================================
// ARQUIVO: lib/modules/generator/presenter/history_page.dart
// =========================================================================
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/repositories/bet_history_repository.dart';
import '../domain/entities/bet_history.dart';
import './widgets/bet_card.dart';
import '../domain/entities/lottery.dart';
import '../data/number_lists.dart';

class HistoryPage extends StatefulWidget {
  final BetHistoryRepository repository;

  const HistoryPage({Key? key, required this.repository}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<BetHistory> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    final history = await widget.repository.loadBetHistory();
    setState(() {
      _history = history;
      _isLoading = false;
    });
  }

  Future<void> _deleteItem(String id) async {
    await widget.repository.deleteBetHistory(id);
    await _loadHistory();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aposta removida do histórico'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _clearAllHistory() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpar Histórico'),
        content: const Text('Tem certeza que deseja limpar todo o histórico de apostas?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Limpar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await widget.repository.clearHistory();
      await _loadHistory();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Histórico limpo com sucesso'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Color _getLotteryColor(LotteryType type) {
    switch (type) {
      case LotteryType.megaSena:
        return Colors.green.shade700;
      case LotteryType.lotofacil:
        return Colors.purple.shade700;
      case LotteryType.quina:
        return Colors.blue.shade800;
      case LotteryType.duplaSena:
        return Colors.red.shade700;
      case LotteryType.timemania:
        return Colors.orange.shade800;
    }
  }

  String _formatStrategy(String strategy) {
    switch (strategy) {
      case 'frequentOnly':
        return 'Apenas frequentes';
      case 'allNumbers':
        return 'Todos os números';
      case 'mixed':
        return 'Misto';
      default:
        return strategy;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📜 Histórico de Apostas'),
        actions: [
          if (_history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: _clearAllHistory,
              tooltip: 'Limpar tudo',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _history.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Nenhuma aposta no histórico',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Suas apostas geradas aparecerão aqui',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _history.length,
                  itemBuilder: (context, index) {
                    final item = _history[index];
                    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Cabeçalho
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _getLotteryColor(item.lotteryType).withValues(alpha: 0.1),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                               ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.lotteryName,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: _getLotteryColor(item.lotteryType),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        dateFormat.format(item.timestamp),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Estratégia: ${_formatStrategy(item.strategy)}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteItem(item.id),
                                  tooltip: 'Remover',
                                ),
                              ],
                            ),
                          ),
                          // Apostas
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: item.bets.asMap().entries.map((entry) {
                                final betIndex = entry.key + 1;
                                final numbers = entry.value;

                                String? teamName;
                                if (item.lotteryType == LotteryType.timemania && numbers.length == 11) {
                                  final teamIndex = numbers.last;
                                  teamName = LotteryData.timemaniaClubs[teamIndex];
                                }
                                
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: BetCard(
                                    betIndex: betIndex,
                                    numbers: numbers,
                                    lotteryColor: _getLotteryColor(item.lotteryType),
                                    teamName: teamName,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
