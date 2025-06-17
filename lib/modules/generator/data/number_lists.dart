// =========================================================================
// ARQUIVO: lib/modules/generator/data/number_lists.dart
// =========================================================================

import '../domain/entities/lottery.dart';

class LotteryData {
  static const Lottery megaSena = Lottery(
    type: LotteryType.megaSena,
    name: 'Mega-Sena',
    numbersToPick: 6,
    mostFrequentNumbers: [10, 53, 5, 42, 34, 33, 23, 4, 30, 37, 17, 41, 24, 43, 28, 38, 27, 35, 11, 44, 13, 54, 29, 16, 51, 49, 32, 52, 46, 56],
  );

  static const Lottery lotofacil = Lottery(
    type: LotteryType.lotofacil,
    name: 'Lotofácil',
    numbersToPick: 15,
    mostFrequentNumbers: [20, 10, 25, 11, 13, 14, 24, 3, 4, 1, 5, 12, 2, 9, 22, 18, 19, 15, 21, 7, 17],
  );

  static const Lottery quina = Lottery(
    type: LotteryType.quina,
    name: 'Quina',
    numbersToPick: 5,
    mostFrequentNumbers: [4, 49, 31, 39, 52, 53, 29, 16, 44, 15, 37, 26, 38, 5, 56, 10, 33, 18, 61, 42],
  );

  static const Lottery duplaSena = Lottery(
    type: LotteryType.duplaSena,
    name: 'Dupla Sena',
    numbersToPick: 6,
    mostFrequentNumbers: [39, 30, 45, 36, 14, 33, 42, 19, 41, 10, 47, 5, 3, 44, 46, 25, 35, 6, 2, 31],
  );

  static const List<Lottery> allLotteries = [megaSena, lotofacil, quina, duplaSena];
}