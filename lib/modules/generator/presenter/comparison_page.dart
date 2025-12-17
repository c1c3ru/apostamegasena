// =========================================================================
// ARQUIVO: lib/modules/generator/presenter/comparison_page.dart
// =========================================================================
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../domain/entities/lottery.dart';

class ComparisonPage extends StatefulWidget {
  final List<List<int>> bets;
  final Lottery lottery;

  const ComparisonPage({
    Key? key,
    required this.bets,
    required this.lottery,
  }) : super(key: key);

  @override
  State<ComparisonPage> createState() => _ComparisonPageState();
}

class _ComparisonPageState extends State<ComparisonPage> {
  final List<TextEditingController> _controllers = [];
  List<int> _drawnNumbers = [];
  Map<int, int> _matchCounts = {};
  bool _hasCompared = false;

  @override
  void initState() {
    super.initState();
    // Criar controllers para cada número
    for (int i = 0; i < widget.lottery.numbersToPick; i++) {
      _controllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _compareResults() {
    // Validar entrada
    final numbers = <int>[];
    for (var controller in _controllers) {
      final text = controller.text.trim();
      if (text.isEmpty) {
        _showError('Preencha todos os números');
        return;
      }
      final number = int.tryParse(text);
      if (number == null || number < widget.lottery.minNumber || number > widget.lottery.maxNumber) {
        _showError('Número inválido: $text (deve estar entre ${widget.lottery.minNumber} e ${widget.lottery.maxNumber})');
        return;
      }
      if (numbers.contains(number)) {
        _showError('Número $number repetido');
        return;
      }
      numbers.add(number);
    }

    // Comparar com apostas
    final matchCounts = <int, int>{};
    for (int i = 0; i < widget.bets.length; i++) {
      final bet = widget.bets[i];
      final matches = bet.where((n) => numbers.contains(n)).length;
      matchCounts[i] = matches;
    }

    setState(() {
      _drawnNumbers = numbers..sort();
      _matchCounts = matchCounts;
      _hasCompared = true;
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _reset() {
    setState(() {
      _hasCompared = false;
      _drawnNumbers = [];
      _matchCounts = {};
      for (var controller in _controllers) {
        controller.clear();
      }
    });
  }

  Color _getMatchColor(int matches) {
    if (matches >= widget.lottery.numbersToPick - 1) return Colors.green;
    if (matches >= widget.lottery.numbersToPick - 2) return Colors.orange;
    return Colors.grey;
  }

  String _getMatchLabel(int matches) {
    switch (widget.lottery.type) {
      case LotteryType.megaSena:
        if (matches == 6) return '🎉 SENA!';
        if (matches == 5) return '🎊 QUINA';
        if (matches == 4) return '👏 QUADRA';
        break;
      case LotteryType.lotofacil:
        if (matches == 15) return '🎉 15 PONTOS!';
        if (matches == 14) return '🎊 14 PONTOS';
        if (matches == 13) return '👏 13 PONTOS';
        if (matches == 12) return '12 PONTOS';
        if (matches == 11) return '11 PONTOS';
        break;
      case LotteryType.quina:
        if (matches == 5) return '🎉 QUINA!';
        if (matches == 4) return '🎊 QUADRA';
        if (matches == 3) return '👏 TERNO';
        if (matches == 2) return 'DUQUE';
        break;
      case LotteryType.duplaSena:
        if (matches == 6) return '🎉 SENA!';
        if (matches == 5) return '🎊 QUINA';
        if (matches == 4) return '👏 QUADRA';
        if (matches == 3) return 'TERNO';
        break;
    }
    return '$matches acertos';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎯 Comparar Resultados'),
        actions: [
          if (_hasCompared)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _reset,
              tooltip: 'Resetar',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Digite o resultado do sorteio',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${widget.lottery.name} - ${widget.lottery.numbersToPick} números',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(
                        widget.lottery.numbersToPick,
                        (index) => SizedBox(
                          width: 60,
                          child: TextField(
                            controller: _controllers[index],
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            maxLength: 2,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: InputDecoration(
                              counterText: '',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _compareResults,
                      icon: const Icon(Icons.check_circle, color: Colors.white),
                      label: const Text(
                        'COMPARAR',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_hasCompared) ...[
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Números Sorteados',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _drawnNumbers.map((number) {
                          return CircleAvatar(
                            radius: 20,
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            child: Text(
                              number.toString().padLeft(2, '0'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Suas Apostas',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...List.generate(widget.bets.length, (index) {
                final bet = widget.bets[index];
                final matches = _matchCounts[index] ?? 0;
                final matchedNumbers = bet.where((n) => _drawnNumbers.contains(n)).toList();
                
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Aposta ${(index + 1).toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _getMatchColor(matches),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _getMatchLabel(matches),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: bet.map((number) {
                            final isMatch = matchedNumbers.contains(number);
                            return CircleAvatar(
                              radius: 18,
                              backgroundColor: isMatch
                                  ? Colors.green
                                  : Colors.grey.shade300,
                              child: Text(
                                number.toString().padLeft(2, '0'),
                                style: TextStyle(
                                  color: isMatch ? Colors.white : Colors.black87,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}
