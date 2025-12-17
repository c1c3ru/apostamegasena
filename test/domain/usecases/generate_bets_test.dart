// =========================================================================
// ARQUIVO: test/domain/usecases/generate_bets_test.dart
// =========================================================================
import 'package:flutter_test/flutter_test.dart';
import 'package:gerador_de_apostas/modules/generator/domain/entities/lottery.dart';
import 'package:gerador_de_apostas/modules/generator/domain/usecases/generate_bets.dart';

void main() {
  late GenerateBetsUsecase usecase;

  setUp(() {
    usecase = GenerateBetsUsecase();
  });

  group('GenerateBetsUsecase', () {
    test('deve gerar o número correto de apostas', () {
      // Arrange
      const lottery = Lottery(
        type: LotteryType.megaSena,
        name: 'Mega-Sena',
        numbersToPick: 6,
        mostFrequentNumbers: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
      );
      const numberOfBets = 5;

      // Act
      final result = usecase(lottery: lottery, numberOfBets: numberOfBets);

      // Assert
      expect(result.length, numberOfBets);
    });

    test('cada aposta deve ter a quantidade correta de números', () {
      // Arrange
      const lottery = Lottery(
        type: LotteryType.megaSena,
        name: 'Mega-Sena',
        numbersToPick: 6,
        mostFrequentNumbers: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
      );

      // Act
      final result = usecase(lottery: lottery, numberOfBets: 3);

      // Assert
      for (final bet in result) {
        expect(bet.length, lottery.numbersToPick);
      }
    });

    test('números devem estar ordenados em cada aposta', () {
      // Arrange
      const lottery = Lottery(
        type: LotteryType.megaSena,
        name: 'Mega-Sena',
        numbersToPick: 6,
        mostFrequentNumbers: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
      );

      // Act
      final result = usecase(lottery: lottery, numberOfBets: 3);

      // Assert
      for (final bet in result) {
        final sortedBet = List<int>.from(bet)..sort();
        expect(bet, sortedBet);
      }
    });

    test('não deve gerar apostas duplicadas', () {
      // Arrange
      const lottery = Lottery(
        type: LotteryType.megaSena,
        name: 'Mega-Sena',
        numbersToPick: 6,
        mostFrequentNumbers: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15],
      );
      const numberOfBets = 10;

      // Act
      final result = usecase(lottery: lottery, numberOfBets: numberOfBets);

      // Assert
      final uniqueBets = <String>{};
      for (final bet in result) {
        final betKey = bet.join(',');
        expect(uniqueBets.contains(betKey), false, reason: 'Aposta duplicada encontrada: $bet');
        uniqueBets.add(betKey);
      }
      expect(uniqueBets.length, numberOfBets);
    });

    test('deve lançar exceção se lista fonte for insuficiente', () {
      // Arrange
      const lottery = Lottery(
        type: LotteryType.megaSena,
        name: 'Mega-Sena',
        numbersToPick: 6,
        mostFrequentNumbers: [1, 2, 3, 4, 5], // Apenas 5 números, mas precisa de 6
      );

      // Act & Assert
      expect(
        () => usecase(lottery: lottery, numberOfBets: 1),
        throwsException,
      );
    });

    test('números devem estar dentro da lista fonte', () {
      // Arrange
      const sourceNumbers = [10, 20, 30, 40, 50, 60, 70, 80, 90, 100];
      const lottery = Lottery(
        type: LotteryType.megaSena,
        name: 'Mega-Sena',
        numbersToPick: 6,
        mostFrequentNumbers: sourceNumbers,
      );

      // Act
      final result = usecase(lottery: lottery, numberOfBets: 3);

      // Assert
      for (final bet in result) {
        for (final number in bet) {
          expect(sourceNumbers.contains(number), true, reason: 'Número $number não está na lista fonte');
        }
      }
    });

    test('deve lançar exceção ao tentar gerar mais apostas únicas do que possível', () {
      // Arrange
      // Com 7 números e escolhendo 6, há apenas C(7,6) = 7 combinações possíveis
      const lottery = Lottery(
        type: LotteryType.megaSena,
        name: 'Mega-Sena',
        numbersToPick: 6,
        mostFrequentNumbers: [1, 2, 3, 4, 5, 6, 7],
      );
      const numberOfBets = 20; // Tentando gerar mais do que as 7 combinações possíveis

      // Act & Assert
      expect(
        () => usecase(lottery: lottery, numberOfBets: numberOfBets),
        throwsException,
      );
    });

    test('deve gerar apostas diferentes em múltiplas execuções', () {
      // Arrange
      const lottery = Lottery(
        type: LotteryType.megaSena,
        name: 'Mega-Sena',
        numbersToPick: 6,
        mostFrequentNumbers: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20],
      );

      // Act
      final result1 = usecase(lottery: lottery, numberOfBets: 5);
      final result2 = usecase(lottery: lottery, numberOfBets: 5);

      // Assert
      // É extremamente improvável que duas execuções gerem exatamente as mesmas apostas
      final bets1Keys = result1.map((bet) => bet.join(',')).toSet();
      final bets2Keys = result2.map((bet) => bet.join(',')).toSet();
      
      // Pelo menos uma aposta deve ser diferente
      expect(bets1Keys.intersection(bets2Keys).length < 5, true);
    });

    test('deve funcionar com Lotofácil (15 números)', () {
      // Arrange
      const lottery = Lottery(
        type: LotteryType.lotofacil,
        name: 'Lotofácil',
        numbersToPick: 15,
        mostFrequentNumbers: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25],
      );

      // Act
      final result = usecase(lottery: lottery, numberOfBets: 3);

      // Assert
      expect(result.length, 3);
      for (final bet in result) {
        expect(bet.length, 15);
      }
    });

    test('deve funcionar com Quina (5 números)', () {
      // Arrange
      const lottery = Lottery(
        type: LotteryType.quina,
        name: 'Quina',
        numbersToPick: 5,
        mostFrequentNumbers: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
      );

      // Act
      final result = usecase(lottery: lottery, numberOfBets: 3);

      // Assert
      expect(result.length, 3);
      for (final bet in result) {
        expect(bet.length, 5);
      }
    });
  });
}
