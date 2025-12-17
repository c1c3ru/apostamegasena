// =========================================================================
// ARQUIVO: test/domain/entities/lottery_test.dart
// =========================================================================
import 'package:flutter_test/flutter_test.dart';
import 'package:gerador_de_apostas/modules/generator/domain/entities/lottery.dart';

void main() {
  group('Lottery', () {
    test('deve criar instância de Lottery corretamente', () {
      // Arrange & Act
      const lottery = Lottery(
        type: LotteryType.megaSena,
        name: 'Mega-Sena',
        numbersToPick: 6,
        mostFrequentNumbers: [10, 53, 5, 42, 34, 33],
      );

      // Assert
      expect(lottery.type, LotteryType.megaSena);
      expect(lottery.name, 'Mega-Sena');
      expect(lottery.numbersToPick, 6);
      expect(lottery.mostFrequentNumbers, [10, 53, 5, 42, 34, 33]);
    });

    test('fromType deve retornar Mega-Sena corretamente', () {
      // Act
      final lottery = Lottery.fromType(LotteryType.megaSena);

      // Assert
      expect(lottery.type, LotteryType.megaSena);
      expect(lottery.name, 'Mega-Sena');
      expect(lottery.numbersToPick, 6);
      expect(lottery.mostFrequentNumbers.isNotEmpty, true);
    });

    test('fromType deve retornar Lotofácil corretamente', () {
      // Act
      final lottery = Lottery.fromType(LotteryType.lotofacil);

      // Assert
      expect(lottery.type, LotteryType.lotofacil);
      expect(lottery.name, 'Lotofácil');
      expect(lottery.numbersToPick, 15);
      expect(lottery.mostFrequentNumbers.isNotEmpty, true);
    });

    test('fromType deve retornar Quina corretamente', () {
      // Act
      final lottery = Lottery.fromType(LotteryType.quina);

      // Assert
      expect(lottery.type, LotteryType.quina);
      expect(lottery.name, 'Quina');
      expect(lottery.numbersToPick, 5);
      expect(lottery.mostFrequentNumbers.isNotEmpty, true);
    });

    test('fromType deve retornar Dupla Sena corretamente', () {
      // Act
      final lottery = Lottery.fromType(LotteryType.duplaSena);

      // Assert
      expect(lottery.type, LotteryType.duplaSena);
      expect(lottery.name, 'Dupla Sena');
      expect(lottery.numbersToPick, 6);
      expect(lottery.mostFrequentNumbers.isNotEmpty, true);
    });

    test('Equatable deve comparar loterias iguais corretamente', () {
      // Arrange
      const lottery1 = Lottery(
        type: LotteryType.megaSena,
        name: 'Mega-Sena',
        numbersToPick: 6,
        mostFrequentNumbers: [10, 53, 5],
      );
      const lottery2 = Lottery(
        type: LotteryType.megaSena,
        name: 'Mega-Sena',
        numbersToPick: 6,
        mostFrequentNumbers: [10, 53, 5],
      );

      // Assert
      expect(lottery1, lottery2);
      expect(lottery1.hashCode, lottery2.hashCode);
    });

    test('Equatable deve comparar loterias diferentes corretamente', () {
      // Arrange
      const lottery1 = Lottery(
        type: LotteryType.megaSena,
        name: 'Mega-Sena',
        numbersToPick: 6,
        mostFrequentNumbers: [10, 53, 5],
      );
      const lottery2 = Lottery(
        type: LotteryType.lotofacil,
        name: 'Lotofácil',
        numbersToPick: 15,
        mostFrequentNumbers: [20, 10, 25],
      );

      // Assert
      expect(lottery1, isNot(lottery2));
      expect(lottery1.hashCode, isNot(lottery2.hashCode));
    });

    test('props deve conter todas as propriedades', () {
      // Arrange
      const lottery = Lottery(
        type: LotteryType.megaSena,
        name: 'Mega-Sena',
        numbersToPick: 6,
        mostFrequentNumbers: [10, 53, 5],
      );

      // Assert
      expect(lottery.props, [
        LotteryType.megaSena,
        'Mega-Sena',
        6,
        [10, 53, 5],
      ]);
    });
  });

  group('LotteryType', () {
    test('deve ter todos os tipos de loteria', () {
      // Assert
      expect(LotteryType.values.length, 4);
      expect(LotteryType.values.contains(LotteryType.megaSena), true);
      expect(LotteryType.values.contains(LotteryType.lotofacil), true);
      expect(LotteryType.values.contains(LotteryType.quina), true);
      expect(LotteryType.values.contains(LotteryType.duplaSena), true);
    });
  });
}
