// =========================================================================
// ARQUIVO: lib/modules/generator/domain/entities/lottery.dart
// =========================================================================
import 'package:equatable/equatable.dart';
import '../../data/number_lists.dart';

enum LotteryType { megaSena, lotofacil, quina, duplaSena }

class Lottery extends Equatable {
  final LotteryType type;
  final String name;
  final int numbersToPick;
  final List<int> mostFrequentNumbers;
  final int minNumber; // Número mínimo da loteria (ex: 1)
  final int maxNumber; // Número máximo da loteria (ex: 60 para Mega-Sena)

  const Lottery({
    required this.type,
    required this.name,
    required this.numbersToPick,
    required this.mostFrequentNumbers,
    this.minNumber = 1,
    this.maxNumber = 60,
  });

  // Retorna lista completa de números disponíveis (ex: [1, 2, 3, ..., 60])
  List<int> get allNumbers => List.generate(maxNumber - minNumber + 1, (i) => minNumber + i);

  static Lottery fromType(LotteryType type) {
    switch (type) {
      case LotteryType.megaSena:
        return LotteryData.megaSena;
      case LotteryType.lotofacil:
        return LotteryData.lotofacil;
      case LotteryType.quina:
        return LotteryData.quina;
      case LotteryType.duplaSena:
        return LotteryData.duplaSena;
    }
  }

  @override
  List<Object?> get props => [type, name, numbersToPick, mostFrequentNumbers, minNumber, maxNumber];
}