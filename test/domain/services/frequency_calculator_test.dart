// =========================================================================
// ARQUIVO: test/domain/services/frequency_calculator_test.dart
// =========================================================================
import 'package:flutter_test/flutter_test.dart';
import 'package:gerador_de_apostas/modules/generator/domain/services/frequency_calculator.dart';

void main() {
  group('FrequencyCalculator.calculate', () {
    test('conta corretamente as dezenas de um array de mock', () {
      final draws = [
        [1, 2, 3, 4, 5, 6],
        [1, 2, 3, 7, 8, 9],
        [1, 10, 11, 12, 13, 14],
      ];

      final counts = FrequencyCalculator.calculate(draws);

      expect(counts[1], 3);
      expect(counts[2], 2);
      expect(counts[3], 2);
      expect(counts[4], 1);
      expect(counts[14], 1);
      expect(counts.containsKey(99), isFalse);
    });

    test('retorna mapa vazio para lista de sorteios vazia', () {
      expect(FrequencyCalculator.calculate([]), isEmpty);
    });
  });

  group('FrequencyCalculator.sortByFrequency', () {
    test('ordena da dezena mais frequente para a menos frequente', () {
      final counts = {1: 5, 2: 1, 3: 3};

      final sorted = FrequencyCalculator.sortByFrequency(counts, maxNumber: 5);

      // 1 (freq 5) > 3 (freq 3) > 2 (freq 1) > 4 e 5 (freq 0, desempate crescente)
      expect(sorted, [1, 3, 2, 4, 5]);
    });

    test('inclui dezenas nunca sorteadas ao final, em ordem crescente', () {
      final counts = {2: 1};

      final sorted = FrequencyCalculator.sortByFrequency(counts, maxNumber: 4);

      expect(sorted, [2, 1, 3, 4]);
    });

    test('respeita minNumber para loterias que não começam em 1', () {
      final counts = <int, int>{};

      final sorted = FrequencyCalculator.sortByFrequency(counts, minNumber: 3, maxNumber: 6);

      expect(sorted, [3, 4, 5, 6]);
    });
  });
}
