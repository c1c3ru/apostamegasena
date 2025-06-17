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

  const BetsGenerated({required this.lotteryType, required this.numberOfBets});

  @override
  List<Object> get props => [lotteryType, numberOfBets];
}