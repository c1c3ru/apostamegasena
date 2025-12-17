// =========================================================================
// ARQUIVO: test/presenter/bloc/generator_bloc_test.dart
// =========================================================================
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gerador_de_apostas/modules/generator/data/repositories/bet_history_repository.dart';
import 'package:gerador_de_apostas/modules/generator/domain/entities/lottery.dart';
import 'package:gerador_de_apostas/modules/generator/domain/usecases/generate_bets.dart';
import 'package:gerador_de_apostas/modules/generator/presenter/bloc/generator_bloc.dart';

void main() {
  late GeneratorBloc bloc;
  late GenerateBetsUsecase usecase;
  late BetHistoryRepository repository;

  setUp(() {
    usecase = GenerateBetsUsecase();
    repository = BetHistoryRepository();
    bloc = GeneratorBloc(usecase, repository);
  });

  tearDown(() {
    bloc.close();
  });

  group('GeneratorBloc', () {
    test('estado inicial deve ser GeneratorInitial', () {
      // Assert
      expect(bloc.state, isA<GeneratorInitial>());
    });

    blocTest<GeneratorBloc, GeneratorState>(
      'deve emitir [GeneratorLoading, GeneratorSuccess] ao gerar apostas com sucesso',
      build: () => GeneratorBloc(usecase, repository),
      act: (bloc) => bloc.add(
        const BetsGenerated(
          lotteryType: LotteryType.megaSena,
          numberOfBets: 5,
        ),
      ),
      expect: () => [
        isA<GeneratorLoading>(),
        isA<GeneratorSuccess>()
            .having((state) => state.bets.length, 'número de apostas', 5)
            .having((state) => state.lotteryName, 'nome da loteria', 'Mega-Sena'),
      ],
    );

    blocTest<GeneratorBloc, GeneratorState>(
      'deve emitir [GeneratorLoading, GeneratorFailure] quando ocorrer erro',
      build: () {
        // Criar usecase que vai falhar (lista insuficiente)
        return GeneratorBloc(usecase, repository);
      },
      act: (bloc) => bloc.add(
        const BetsGenerated(
          lotteryType: LotteryType.megaSena,
          numberOfBets: 1000, // Número muito alto para gerar duplicatas
        ),
      ),
      expect: () => [
        isA<GeneratorLoading>(),
        isA<GeneratorFailure>()
            .having((state) => state.message, 'mensagem de erro', contains('Erro ao gerar apostas')),
      ],
    );

    blocTest<GeneratorBloc, GeneratorState>(
      'deve gerar apostas para Lotofácil corretamente',
      build: () => GeneratorBloc(usecase, repository),
      act: (bloc) => bloc.add(
        const BetsGenerated(
          lotteryType: LotteryType.lotofacil,
          numberOfBets: 3,
        ),
      ),
      expect: () => [
        isA<GeneratorLoading>(),
        isA<GeneratorSuccess>()
            .having((state) => state.bets.length, 'número de apostas', 3)
            .having((state) => state.lotteryName, 'nome da loteria', 'Lotofácil')
            .having((state) => state.bets[0].length, 'números por aposta', 15),
      ],
    );

    blocTest<GeneratorBloc, GeneratorState>(
      'deve gerar apostas para Quina corretamente',
      build: () => GeneratorBloc(usecase, repository),
      act: (bloc) => bloc.add(
        const BetsGenerated(
          lotteryType: LotteryType.quina,
          numberOfBets: 2,
        ),
      ),
      expect: () => [
        isA<GeneratorLoading>(),
        isA<GeneratorSuccess>()
            .having((state) => state.bets.length, 'número de apostas', 2)
            .having((state) => state.lotteryName, 'nome da loteria', 'Quina')
            .having((state) => state.bets[0].length, 'números por aposta', 5),
      ],
    );

    blocTest<GeneratorBloc, GeneratorState>(
      'deve gerar apostas para Dupla Sena corretamente',
      build: () => GeneratorBloc(usecase, repository),
      act: (bloc) => bloc.add(
        const BetsGenerated(
          lotteryType: LotteryType.duplaSena,
          numberOfBets: 4,
        ),
      ),
      expect: () => [
        isA<GeneratorLoading>(),
        isA<GeneratorSuccess>()
            .having((state) => state.bets.length, 'número de apostas', 4)
            .having((state) => state.lotteryName, 'nome da loteria', 'Dupla Sena')
            .having((state) => state.bets[0].length, 'números por aposta', 6),
      ],
    );
  });
}
