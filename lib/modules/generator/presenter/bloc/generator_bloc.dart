// =========================================================================
// ARQUIVO: lib/modules/generator/presenter/bloc/generator_bloc.dart
// =========================================================================
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/bet_history_repository.dart';
import '../../data/repositories/lottery_repository.dart';
import '../../domain/entities/bet_history.dart';
import '../../domain/entities/lottery.dart';
import '../../domain/usecases/generate_bets.dart';

part 'generator_event.dart';
part 'generator_state.dart';

class GeneratorBloc extends Bloc<GeneratorEvent, GeneratorState> {
  final GenerateBetsUsecase _generateBetsUsecase;
  final BetHistoryRepository _historyRepository;
  final LotteryRepository _lotteryRepository;

  // Frequências da Mega-Sena recalculadas a partir do último concurso buscado
  // na API da Caixa. Fica null até a primeira atualização bem-sucedida (ou
  // com fallback de cache) responder — até lá usa-se o valor estático padrão.
  List<int>? _freshMegaSenaFrequencies;

  GeneratorBloc(
    this._generateBetsUsecase,
    this._historyRepository,
    this._lotteryRepository,
  ) : super(GeneratorInitial()) {
    on<BetsGenerated>(_onBetsGenerated);
    on<LotteryTypeChanged>(_onLotteryTypeChanged);
    on<RefreshMegaSenaFrequencies>(_onRefreshMegaSenaFrequencies);
  }

  // Busca em segundo plano — não emite estados de loading/erro pois não deve
  // interferir na tela de geração de apostas; apenas atualiza o dado interno
  // usado na próxima geração da Mega-Sena.
  Future<void> _onRefreshMegaSenaFrequencies(
    RefreshMegaSenaFrequencies event,
    Emitter<GeneratorState> emit,
  ) async {
    try {
      final result = await _lotteryRepository.refreshMegaSenaFrequencies();
      _freshMegaSenaFrequencies = result.mostFrequentNumbers;
    } catch (_) {
      // Falha inesperada fora do fluxo de retry do repositório: mantém o
      // valor estático padrão (LotteryData.megaSena.mostFrequentNumbers).
    }
  }

  // Reseta o estado ao trocar de loteria para evitar exibir apostas da loteria anterior
  void _onLotteryTypeChanged(
    LotteryTypeChanged event,
    Emitter<GeneratorState> emit,
  ) {
    emit(GeneratorInitial());
  }

  Future<void> _onBetsGenerated(
    BetsGenerated event,
    Emitter<GeneratorState> emit,
  ) async {
    emit(GeneratorLoading());
    try {
      var lottery = Lottery.fromType(event.lotteryType);
      if (event.lotteryType == LotteryType.megaSena && _freshMegaSenaFrequencies != null) {
        lottery = lottery.copyWith(mostFrequentNumbers: _freshMegaSenaFrequencies);
      }
      final resultado = _generateBetsUsecase.gerarComResultado(
        lottery: lottery,
        numberOfBets: event.numberOfBets,
        strategy: event.strategy,
        numberOfNumbers: event.numberOfNumbers,
      );

      // Salvar no histórico
      final history = BetHistory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        lotteryType: event.lotteryType,
        lotteryName: lottery.name,
        bets: resultado.apostas,
        timestamp: DateTime.now(),
        strategy: event.strategy.name,
      );

      await _historyRepository.saveBetHistory(history);

      emit(GeneratorSuccess(
        bets: resultado.apostas,
        lotteryName: lottery.name,
        avisoMatematico: resultado.avisoMatematico,
      ));
    } catch (e) {
      emit(GeneratorFailure(message: 'Erro ao gerar apostas: ${e.toString()}'));
    }
  }
}
