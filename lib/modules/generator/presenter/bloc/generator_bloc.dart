// =========================================================================
// ARQUIVO: lib/modules/generator/presenter/bloc/generator_bloc.dart
// =========================================================================
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/bet_history_repository.dart';
import '../../domain/entities/bet_history.dart';
import '../../domain/entities/lottery.dart';
import '../../domain/usecases/generate_bets.dart';

part 'generator_event.dart';
part 'generator_state.dart';

class GeneratorBloc extends Bloc<GeneratorEvent, GeneratorState> {
  final GenerateBetsUsecase _generateBetsUsecase;
  final BetHistoryRepository _historyRepository;

  GeneratorBloc(this._generateBetsUsecase, this._historyRepository) : super(GeneratorInitial()) {
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
        strategy: event.strategy,
      );
      
      // Salvar no histórico
      final history = BetHistory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        lotteryType: event.lotteryType,
        lotteryName: lottery.name,
        bets: bets,
        timestamp: DateTime.now(),
        strategy: event.strategy.name,
      );
      
      await _historyRepository.saveBetHistory(history);
      
      emit(GeneratorSuccess(bets: bets, lotteryName: lottery.name));
    } catch (e) {
      emit(GeneratorFailure(message: 'Erro ao gerar apostas: ${e.toString()}'));
    }
  }
}
