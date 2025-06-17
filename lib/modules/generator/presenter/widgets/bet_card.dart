// =========================================================================
// ARQUIVO: lib/modules/generator/presenter/widgets/bet_card.dart
// =========================================================================
import 'package:flutter/material.dart';

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
            Text(
              'Aposta ${betIndex.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: lotteryColor,
              ),
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
