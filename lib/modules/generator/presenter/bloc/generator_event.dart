// =========================================================================
// ARQUIVO: lib/modules/generator/presenter/bloc/generator_event.dart
// =========================================================================
part of 'generator_bloc.dart';

abstract class GeneratorEvent extends Equatable {
  const GeneratorEvent();

  @override
  List<Object> get props => [];
}

class BetsGenerated extends GeneratorEvent {
  final LotteryType lotteryType;
  final int numberOfBets;
  final GenerationStrategy strategy;

  const BetsGenerated({
    required this.lotteryType,
    required this.numberOfBets,
    this.strategy = GenerationStrategy.frequentOnly,
  });

  @override
  List<Object> get props => [lotteryType, numberOfBets, strategy];
}

// Evento disparado ao trocar de tipo de loteria — reseta o estado para limpar apostas antigas
class LotteryTypeChanged extends GeneratorEvent {
  final LotteryType lotteryType;

  const LotteryTypeChanged({required this.lotteryType});

  @override
  List<Object> get props => [lotteryType];
}