// =========================================================================
// ARQUIVO: lib/modules/generator/presenter/widgets/bet_card.dart
// =========================================================================
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BetCard extends StatelessWidget {
  final int betIndex;
  final List<int> numbers;
  final Color lotteryColor;

  const BetCard({
    Key? key,
    required this.betIndex,
    required this.numbers,
    required this.lotteryColor,
  }) : super(key: key);

  void _copiarAposta(BuildContext context) {
    // Formatar números com zero à esquerda e separar por vírgula
    final numerosFormatados = numbers.map((n) => n.toString().padLeft(2, '0')).join(', ');
    final textoAposta = 'Aposta #$betIndex: $numerosFormatados';
    
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
              children: numbers
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
          ],
        ),
      ),
    );
  }
}
