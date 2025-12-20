// =========================================================================
// ARQUIVO: lib/modules/generator/domain/entities/bet_statistics.dart
// =========================================================================

class BetStatistics {
  final int totalBets;
  final int totalNumbers;
  final int evenCount;
  final int oddCount;
  final int highCount;
  final int lowCount;
  final Map<int, int> numberFrequency;
  final List<int> mostFrequentNumbers;
  final List<int> leastFrequentNumbers;

  BetStatistics({
    required this.totalBets,
    required this.totalNumbers,
    required this.evenCount,
    required this.oddCount,
    required this.highCount,
    required this.lowCount,
    required this.numberFrequency,
    required this.mostFrequentNumbers,
    required this.leastFrequentNumbers,
  });

  double get evenPercentage => totalNumbers > 0 ? (evenCount / totalNumbers) * 100 : 0;
  double get oddPercentage => totalNumbers > 0 ? (oddCount / totalNumbers) * 100 : 0;
  double get highPercentage => totalNumbers > 0 ? (highCount / totalNumbers) * 100 : 0;
  double get lowPercentage => totalNumbers > 0 ? (lowCount / totalNumbers) * 100 : 0;

  static BetStatistics analyze(List<List<int>> bets, int maxNumber, {bool isTimemania = false}) {
    if (bets.isEmpty) {
      return BetStatistics(
        totalBets: 0,
        totalNumbers: 0,
        evenCount: 0,
        oddCount: 0,
        highCount: 0,
        lowCount: 0,
        numberFrequency: {},
        mostFrequentNumbers: [],
        leastFrequentNumbers: [],
      );
    }

    final Map<int, int> frequency = {};
    int evenCount = 0;
    int oddCount = 0;
    int highCount = 0;
    int lowCount = 0;
    int totalNumbers = 0;

    final int midPoint = (maxNumber / 2).ceil();

    // Analisar todas as apostas
    for (final bet in bets) {
      // Se for Timemania, ignorar o último número (que é o Time do Coração)
      final List<int> numbersToAnalyze = isTimemania ? bet.sublist(0, bet.length - 1) : bet;

      for (final number in numbersToAnalyze) {
        totalNumbers++;
        
        // Contar frequência
        frequency[number] = (frequency[number] ?? 0) + 1;
        
        // Par ou ímpar
        if (number % 2 == 0) {
          evenCount++;
        } else {
          oddCount++;
        }
        
        // Alto ou baixo
        if (number > midPoint) {
          highCount++;
        } else {
          lowCount++;
        }
      }
    }

    // Ordenar por frequência
    final sortedByFrequency = frequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final mostFrequent = sortedByFrequency.take(5).map((e) => e.key).toList();
    final leastFrequent = sortedByFrequency.reversed.take(5).map((e) => e.key).toList();

    return BetStatistics(
      totalBets: bets.length,
      totalNumbers: totalNumbers,
      evenCount: evenCount,
      oddCount: oddCount,
      highCount: highCount,
      lowCount: lowCount,
      numberFrequency: frequency,
      mostFrequentNumbers: mostFrequent,
      leastFrequentNumbers: leastFrequent,
    );
  }
}
