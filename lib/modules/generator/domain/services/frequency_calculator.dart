// =========================================================================
// ARQUIVO: lib/modules/generator/domain/services/frequency_calculator.dart
// =========================================================================

/// Calcula a frequência de aparição de cada dezena a partir de uma lista de sorteios.
/// Função pura, sem dependências externas — facilmente testável isoladamente.
class FrequencyCalculator {
  const FrequencyCalculator._();

  /// Conta quantas vezes cada dezena apareceu no conjunto de sorteios informado.
  static Map<int, int> calculate(List<List<int>> draws) {
    final counts = <int, int>{};
    for (final draw in draws) {
      for (final number in draw) {
        counts[number] = (counts[number] ?? 0) + 1;
      }
    }
    return counts;
  }

  /// Retorna todas as dezenas do intervalo [minNumber, maxNumber] ordenadas da
  /// mais para a menos frequente. Dezenas nunca sorteadas (frequência 0)
  /// aparecem ao final, em ordem crescente entre si para desempate estável.
  static List<int> sortByFrequency(
    Map<int, int> counts, {
    required int maxNumber,
    int minNumber = 1,
  }) {
    final all = List.generate(maxNumber - minNumber + 1, (i) => minNumber + i);
    all.sort((a, b) {
      final freqCompare = (counts[b] ?? 0).compareTo(counts[a] ?? 0);
      if (freqCompare != 0) return freqCompare;
      return a.compareTo(b);
    });
    return all;
  }
}
