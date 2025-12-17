// =========================================================================
// ARQUIVO: lib/modules/generator/domain/usecases/generate_bets.dart
// =========================================================================
import 'dart:math';
import '../entities/lottery.dart';

enum GenerationStrategy {
  frequentOnly,    // Apenas números frequentes
  allNumbers,      // Todos os números disponíveis
  mixed,           // Misto: 50% frequentes + 50% aleatórios
}

class GenerateBetsUsecase {
  List<List<int>> call({
    required Lottery lottery,
    required int numberOfBets,
    GenerationStrategy strategy = GenerationStrategy.frequentOnly,
  }) {
    // Selecionar lista de números baseado na estratégia
    final List<int> sourceList = _getSourceList(lottery, strategy);
    final int numbersToPick = lottery.numbersToPick;
    final List<List<int>> bets = [];
    final Set<String> uniqueBets = {}; // Para verificar duplicatas

    if (sourceList.length < numbersToPick) {
      throw Exception('Lista de números de origem é insuficiente para ${lottery.name}.');
    }

    int tentativas = 0;
    const int maxTentativas = 100;

    while (bets.length < numberOfBets) {
      // Proteção contra loop infinito
      if (tentativas >= maxTentativas) {
        throw Exception(
          'Não foi possível gerar $numberOfBets apostas únicas após $maxTentativas tentativas. '
          'Tente reduzir a quantidade de apostas.',
        );
      }

      final List<int> numbers = List.from(sourceList);
      final List<int> singleBet = [];
      final Random random = Random();

      for (int j = 0; j < numbersToPick; j++) {
        final int randomIndex = random.nextInt(numbers.length);
        singleBet.add(numbers.removeAt(randomIndex));
      }

      singleBet.sort();
      
      // Converter aposta para string para verificar duplicata
      final String betKey = singleBet.join(',');
      
      // Adicionar apenas se não for duplicata
      if (uniqueBets.add(betKey)) {
        bets.add(singleBet);
      }
      
      tentativas++;
    }
    
    return bets;
  }

  List<int> _getSourceList(Lottery lottery, GenerationStrategy strategy) {
    switch (strategy) {
      case GenerationStrategy.frequentOnly:
        return lottery.mostFrequentNumbers;
      
      case GenerationStrategy.allNumbers:
        return lottery.allNumbers;
      
      case GenerationStrategy.mixed:
        // Combinar 50% dos números frequentes com 50% de números aleatórios
        final frequentCount = (lottery.mostFrequentNumbers.length * 0.5).round();
        final frequent = lottery.mostFrequentNumbers.take(frequentCount).toList();
        
        // Pegar números que não estão na lista de frequentes
        final allNums = lottery.allNumbers;
        final remaining = allNums.where((n) => !frequent.contains(n)).toList();
        
        // Adicionar números aleatórios da lista restante
        final random = Random();
        final randomCount = frequentCount;
        final randomNumbers = <int>[];
        
        for (int i = 0; i < randomCount && remaining.isNotEmpty; i++) {
          final index = random.nextInt(remaining.length);
          randomNumbers.add(remaining.removeAt(index));
        }
        
        return [...frequent, ...randomNumbers]..shuffle();
    }
  }
}