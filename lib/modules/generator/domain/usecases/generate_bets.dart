// =========================================================================
// ARQUIVO: lib/modules/generator/domain/usecases/generate_bets.dart
// =========================================================================
import 'dart:math';
import '../entities/lottery.dart';

class GenerateBetsUsecase {
  List<List<int>> call({
    required Lottery lottery,
    required int numberOfBets,
  }) {
    final List<int> sourceList = lottery.mostFrequentNumbers;
    final int numbersToPick = lottery.numbersToPick;
    final List<List<int>> bets = [];

    if (sourceList.length < numbersToPick) {
      throw Exception('Lista de números de origem é insuficiente para ${lottery.name}.');
    }

    for (int i = 0; i < numberOfBets; i++) {
      final List<int> numbers = List.from(sourceList);
      final List<int> singleBet = [];
      final Random random = Random();

      for (int j = 0; j < numbersToPick; j++) {
        final int randomIndex = random.nextInt(numbers.length);
        singleBet.add(numbers.removeAt(randomIndex));
      }

      singleBet.sort();
      bets.add(singleBet);
    }
    return bets;
  }
}