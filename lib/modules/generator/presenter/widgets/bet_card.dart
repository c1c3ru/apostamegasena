// =========================================================================
// ARQUIVO: lib/modules/generator/presenter/widgets/bet_card.dart
// =========================================================================
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BetCard extends StatelessWidget {
  final int betIndex;
  final List<int> numbers;
  final Color lotteryColor;
  final String? teamName; // Adicionado para Timemania

  const BetCard({
    Key? key,
    required this.betIndex,
    required this.numbers,
    required this.lotteryColor,
    this.teamName,
  }) : super(key: key);

  void _copiarAposta(BuildContext context) {
    // Para Timemania, os números são os primeiros 10, o time é o último (se presente na lista)
    // ou usamos o teamName se passado.
    final List<int> dezenas = teamName != null ? numbers.sublist(0, numbers.length - 1) : numbers;
    final String? time = teamName;

    final numerosFormatados = dezenas.map((n) => n.toString().padLeft(2, '0')).join(', ');
    String textoAposta = 'Aposta #$betIndex: $numerosFormatados';
    
    if (time != null) {
      textoAposta += ' | Time: $time';
    }
    
    // Copiar para clipboard
    Clipboard.setData(ClipboardData(text: textoAposta));
    
    // Mostrar feedback visual
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Aposta #$betIndex copiada!'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: lotteryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Se for Timemania, o último número é o time
    final bool isTimemania = teamName != null;
    final List<int> dezenas = isTimemania ? numbers.sublist(0, numbers.length - 1) : numbers;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
          side: BorderSide(color: lotteryColor.withAlpha(128), width: 1),
          borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Aposta ${betIndex.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: lotteryColor,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.copy, color: lotteryColor, size: 20),
                  onPressed: () => _copiarAposta(context),
                  tooltip: 'Copiar aposta',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: dezenas
                  .map((number) => CircleAvatar(
                        radius: 18,
                        backgroundColor: lotteryColor,
                        child: Text(
                          number.toString().padLeft(2, '0'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ))
                  .toList(),
            ),
            if (isTimemania) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: lotteryColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: lotteryColor.withAlpha(100)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.favorite, color: Colors.red, size: 16),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Time: $teamName',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: lotteryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
