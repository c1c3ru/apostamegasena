// =========================================================================
// ARQUIVO: lib/modules/generator/presenter/bloc/generator_bloc.dart
// =========================================================================
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/lottery.dart';
import '../../domain/usecases/generate_bets.dart';

part 'generator_event.dart';
part 'generator_state.dart';

class GeneratorBloc extends Bloc<GeneratorEvent, GeneratorState> {
  final GenerateBetsUsecase _generateBetsUsecase;

  GeneratorBloc(this._generateBetsUsecase) : super(GeneratorInitial()) {
    on<BetsGenerated>(_onBetsGenerated);
  }

  Future<void> _onBetsGenerated(
    BetsGenerated event,
    Emitter<GeneratorState> emit,
  ) async {
    emit(GeneratorLoading());
    try {
      final lottery = Lottery.fromType(event.lotteryType);
      final bets = _generateBetsUsecase(
        lottery: lottery,
        numberOfBets: event.numberOfBets,
      );
      emit(GeneratorSuccess(bets: bets, lotteryName: lottery.name));
    } catch (e) {
      emit(GeneratorFailure(message: 'Erro ao gerar apostas: ${e.toString()}'));
    }
  }
}
