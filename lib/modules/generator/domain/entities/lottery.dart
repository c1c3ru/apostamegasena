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

  const Lottery({
    required this.type,
    required this.name,
    required this.numbersToPick,
    required this.mostFrequentNumbers,
  });

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
  List<Object?> get props => [type, name, numbersToPick, mostFrequentNumbers];
}