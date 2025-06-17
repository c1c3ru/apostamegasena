// =========================================================================
// ARQUIVO: lib/modules/generator/presenter/bloc/generator_state.dart
// =========================================================================
part of 'generator_bloc.dart';

abstract class GeneratorState extends Equatable {
  const GeneratorState();

  @override
  List<Object> get props => [];
}

class GeneratorInitial extends GeneratorState {}

class GeneratorLoading extends GeneratorState {}

class GeneratorSuccess extends GeneratorState {
  final List<List<int>> bets;
  final String lotteryName;

  const GeneratorSuccess({required this.bets, required this.lotteryName});

  @override
  List<Object> get props => [bets, lotteryName];
}

class GeneratorFailure extends GeneratorState {
  final String message;

  const GeneratorFailure({required this.message});

  @override
  List<Object> get props => [message];
}