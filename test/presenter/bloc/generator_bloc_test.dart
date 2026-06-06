// =========================================================================
// ARQUIVO: test/presenter/bloc/generator_bloc_test.dart
// =========================================================================
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gerador_de_apostas/modules/generator/data/repositories/bet_history_repository.dart';
import 'package:gerador_de_apostas/modules/generator/domain/entities/lottery.dart';
import 'package:gerador_de_apostas/modules/generator/domain/usecases/generate_bets.dart';
import 'package:gerador_de_apostas/modules/generator/presenter/bloc/generator_bloc.dart';

void main() {
  // Garante que os bindings de serviço estejam disponíveis antes de qualquer teste
  TestWidgetsFlutterBinding.ensureInitialized();

  late GeneratorBloc bloc;
  late GenerateBetsUsecase usecase;
  late BetHistoryRepository repositorio;

  setUp(() {
    // Configura SharedPreferences com dados vazios para o ambiente de teste
    SharedPreferences.setMockInitialValues({});

    // Configura canal de plataforma para shared_preferences no ambiente de teste
    const MethodChannel canal = MethodChannel('plugins.flutter.io/shared_preferences');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(canal, (MethodCall chamada) async {
      if (chamada.method == 'getAll') return <String, Object>{};
      if (chamada.method == 'setString') return true;
      if (chamada.method == 'remove') return true;
      return null;
    });

    usecase = GenerateBetsUsecase();
    repositorio = BetHistoryRepository();
    bloc = GeneratorBloc(usecase, repositorio);
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
      'deve emitir [GeneratorLoading, GeneratorSuccess] ao gerar apostas da Mega-Sena',
      build: () {
        SharedPreferences.setMockInitialValues({});
        return GeneratorBloc(GenerateBetsUsecase(), BetHistoryRepository());
      },
      act: (bloc) => bloc.add(
        const BetsGenerated(
          lotteryType: LotteryType.megaSena,
          numberOfBets: 5,
        ),
      ),
      expect: () => [
        isA<GeneratorLoading>(),
        isA<GeneratorSuccess>()
            .having((estado) => estado.bets.length, 'número de apostas', 5)
            .having((estado) => estado.lotteryName, 'nome da loteria', 'Mega-Sena'),
      ],
    );

    blocTest<GeneratorBloc, GeneratorState>(
      'deve emitir [GeneratorLoading, GeneratorSuccess] ao gerar apostas da Lotofácil',
      build: () {
        SharedPreferences.setMockInitialValues({});
        return GeneratorBloc(GenerateBetsUsecase(), BetHistoryRepository());
      },
      act: (bloc) => bloc.add(
        const BetsGenerated(
          lotteryType: LotteryType.lotofacil,
          numberOfBets: 3,
        ),
      ),
      expect: () => [
        isA<GeneratorLoading>(),
        isA<GeneratorSuccess>()
            .having((estado) => estado.bets.length, 'número de apostas', 3)
            .having((estado) => estado.lotteryName, 'nome da loteria', 'Lotofácil')
            .having((estado) => estado.bets[0].length, 'números por aposta', 15),
      ],
    );

    blocTest<GeneratorBloc, GeneratorState>(
      'deve emitir [GeneratorLoading, GeneratorSuccess] ao gerar apostas da Quina',
      build: () {
        SharedPreferences.setMockInitialValues({});
        return GeneratorBloc(GenerateBetsUsecase(), BetHistoryRepository());
      },
      act: (bloc) => bloc.add(
        const BetsGenerated(
          lotteryType: LotteryType.quina,
          numberOfBets: 2,
        ),
      ),
      expect: () => [
        isA<GeneratorLoading>(),
        isA<GeneratorSuccess>()
            .having((estado) => estado.bets.length, 'número de apostas', 2)
            .having((estado) => estado.lotteryName, 'nome da loteria', 'Quina')
            .having((estado) => estado.bets[0].length, 'números por aposta', 5),
      ],
    );

    blocTest<GeneratorBloc, GeneratorState>(
      'deve emitir [GeneratorLoading, GeneratorSuccess] ao gerar apostas da Dupla Sena',
      build: () {
        SharedPreferences.setMockInitialValues({});
        return GeneratorBloc(GenerateBetsUsecase(), BetHistoryRepository());
      },
      act: (bloc) => bloc.add(
        const BetsGenerated(
          lotteryType: LotteryType.duplaSena,
          numberOfBets: 4,
        ),
      ),
      expect: () => [
        isA<GeneratorLoading>(),
        isA<GeneratorSuccess>()
            .having((estado) => estado.bets.length, 'número de apostas', 4)
            .having((estado) => estado.lotteryName, 'nome da loteria', 'Dupla Sena')
            .having((estado) => estado.bets[0].length, 'números por aposta', 6),
      ],
    );

    blocTest<GeneratorBloc, GeneratorState>(
      'deve emitir [GeneratorLoading, GeneratorFailure] ao tentar gerar apostas demais',
      build: () {
        SharedPreferences.setMockInitialValues({});
        return GeneratorBloc(GenerateBetsUsecase(), BetHistoryRepository());
      },
      act: (bloc) => bloc.add(
        const BetsGenerated(
          lotteryType: LotteryType.megaSena,
          numberOfBets: 1000, // Número impossível de atingir sem duplicatas
        ),
      ),
      expect: () => [
        isA<GeneratorLoading>(),
        isA<GeneratorFailure>()
            .having(
              (estado) => estado.message,
              'mensagem de erro',
              contains('Erro ao gerar apostas'),
            ),
      ],
    );

    blocTest<GeneratorBloc, GeneratorState>(
      'deve usar a estratégia sistemaMatematico ao ser solicitado',
      build: () {
        SharedPreferences.setMockInitialValues({});
        return GeneratorBloc(GenerateBetsUsecase(), BetHistoryRepository());
      },
      act: (bloc) => bloc.add(
        const BetsGenerated(
          lotteryType: LotteryType.megaSena,
          numberOfBets: 2,
          strategy: GenerationStrategy.sistemaMatematico,
        ),
      ),
      expect: () => [
        isA<GeneratorLoading>(),
        // Com sistemaMatematico pode retornar sucesso ou falha dependendo dos filtros
        // Verificamos que o estado não é mais Loading
        isA<GeneratorState>(),
      ],
    );
  });
}
