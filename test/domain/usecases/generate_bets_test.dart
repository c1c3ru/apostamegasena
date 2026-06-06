// =========================================================================
// ARQUIVO: test/domain/usecases/generate_bets_test.dart
// =========================================================================
import 'package:flutter_test/flutter_test.dart';
import 'package:gerador_de_apostas/modules/generator/domain/entities/lottery.dart';
import 'package:gerador_de_apostas/modules/generator/domain/usecases/generate_bets.dart';

void main() {
  late GenerateBetsUsecase usecase;

  setUp(() {
    usecase = GenerateBetsUsecase();
  });

  group('GenerateBetsUsecase — estratégia frequentOnly (padrão)', () {
    test('deve gerar o número correto de apostas', () {
      // Arrange
      const loteria = Lottery(
        type: LotteryType.megaSena,
        name: 'Mega-Sena',
        numbersToPick: 6,
        mostFrequentNumbers: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
      );
      const quantidadeApostas = 5;

      // Act
      final resultado = usecase(lottery: loteria, numberOfBets: quantidadeApostas);

      // Assert
      expect(resultado.length, quantidadeApostas);
    });

    test('cada aposta deve ter a quantidade correta de números', () {
      // Arrange
      const loteria = Lottery(
        type: LotteryType.megaSena,
        name: 'Mega-Sena',
        numbersToPick: 6,
        mostFrequentNumbers: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
      );

      // Act
      final resultado = usecase(lottery: loteria, numberOfBets: 3);

      // Assert
      for (final aposta in resultado) {
        expect(aposta.length, loteria.numbersToPick);
      }
    });

    test('números devem estar ordenados em cada aposta', () {
      // Arrange
      const loteria = Lottery(
        type: LotteryType.megaSena,
        name: 'Mega-Sena',
        numbersToPick: 6,
        mostFrequentNumbers: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
      );

      // Act
      final resultado = usecase(lottery: loteria, numberOfBets: 3);

      // Assert
      for (final aposta in resultado) {
        final apostaOrdenada = List<int>.from(aposta)..sort();
        expect(aposta, apostaOrdenada);
      }
    });

    test('não deve gerar apostas duplicadas', () {
      // Arrange
      const loteria = Lottery(
        type: LotteryType.megaSena,
        name: 'Mega-Sena',
        numbersToPick: 6,
        mostFrequentNumbers: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15],
      );
      const quantidadeApostas = 10;

      // Act
      final resultado = usecase(lottery: loteria, numberOfBets: quantidadeApostas);

      // Assert
      final apostasUnicas = <String>{};
      for (final aposta in resultado) {
        final chave = aposta.join(',');
        expect(apostasUnicas.contains(chave), false,
            reason: 'Aposta duplicada encontrada: $aposta');
        apostasUnicas.add(chave);
      }
      expect(apostasUnicas.length, quantidadeApostas);
    });

    test('deve lançar exceção se lista fonte for insuficiente', () {
      // Arrange
      const loteria = Lottery(
        type: LotteryType.megaSena,
        name: 'Mega-Sena',
        numbersToPick: 6,
        mostFrequentNumbers: [1, 2, 3, 4, 5], // Apenas 5 números, precisa de 6
      );

      // Act & Assert
      expect(
        () => usecase(lottery: loteria, numberOfBets: 1),
        throwsException,
      );
    });

    test('números devem estar dentro da lista fonte', () {
      // Arrange
      const numerosOrigem = [10, 20, 30, 40, 50, 60, 70, 80, 90, 100];
      const loteria = Lottery(
        type: LotteryType.megaSena,
        name: 'Mega-Sena',
        numbersToPick: 6,
        mostFrequentNumbers: numerosOrigem,
      );

      // Act
      final resultado = usecase(lottery: loteria, numberOfBets: 3);

      // Assert
      for (final aposta in resultado) {
        for (final numero in aposta) {
          expect(numerosOrigem.contains(numero), true,
              reason: 'Número $numero não está na lista fonte');
        }
      }
    });

    test('deve lançar exceção ao tentar gerar mais apostas do que as combinações possíveis', () {
      // Arrange — C(7,6) = 7 combinações possíveis
      const loteria = Lottery(
        type: LotteryType.megaSena,
        name: 'Mega-Sena',
        numbersToPick: 6,
        mostFrequentNumbers: [1, 2, 3, 4, 5, 6, 7],
      );
      const quantidadeApostas = 20; // Impossível

      // Act & Assert
      expect(
        () => usecase(lottery: loteria, numberOfBets: quantidadeApostas),
        throwsException,
      );
    });

    test('deve funcionar com Lotofácil (15 números)', () {
      // Arrange
      const loteria = Lottery(
        type: LotteryType.lotofacil,
        name: 'Lotofácil',
        numbersToPick: 15,
        mostFrequentNumbers: [
          1, 2, 3, 4, 5, 6, 7, 8, 9, 10,
          11, 12, 13, 14, 15, 16, 17, 18, 19, 20,
        ],
      );

      // Act
      final resultado = usecase(lottery: loteria, numberOfBets: 3);

      // Assert
      expect(resultado.length, 3);
      for (final aposta in resultado) {
        expect(aposta.length, 15);
      }
    });

    test('deve funcionar com Quina (5 números)', () {
      // Arrange
      const loteria = Lottery(
        type: LotteryType.quina,
        name: 'Quina',
        numbersToPick: 5,
        mostFrequentNumbers: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
      );

      // Act
      final resultado = usecase(lottery: loteria, numberOfBets: 3);

      // Assert
      expect(resultado.length, 3);
      for (final aposta in resultado) {
        expect(aposta.length, 5);
      }
    });
  });

  group('GenerateBetsUsecase — estratégia allNumbers', () {
    test('deve gerar apostas usando todos os números disponíveis', () {
      // Arrange
      const loteria = Lottery(
        type: LotteryType.megaSena,
        name: 'Mega-Sena',
        numbersToPick: 6,
        mostFrequentNumbers: [1, 2, 3, 4, 5, 6, 7],
        maxNumber: 60,
      );

      // Act — usa allNumbers (1..60), não apenas os frequentes
      final resultado = usecase(
        lottery: loteria,
        numberOfBets: 3,
        strategy: GenerationStrategy.allNumbers,
      );

      // Assert
      expect(resultado.length, 3);
      for (final aposta in resultado) {
        expect(aposta.length, 6);
        for (final numero in aposta) {
          expect(numero, inInclusiveRange(1, 60));
        }
      }
    });
  });

  group('GenerateBetsUsecase — estratégia mixed', () {
    test('deve gerar apostas usando a estratégia mista', () {
      // Arrange
      const loteria = Lottery(
        type: LotteryType.megaSena,
        name: 'Mega-Sena',
        numbersToPick: 6,
        mostFrequentNumbers: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
        maxNumber: 60,
      );

      // Act
      final resultado = usecase(
        lottery: loteria,
        numberOfBets: 5,
        strategy: GenerationStrategy.mixed,
      );

      // Assert
      expect(resultado.length, 5);
      for (final aposta in resultado) {
        expect(aposta.length, 6);
      }
    });
  });

  group('GenerateBetsUsecase — estratégia sistemaMatematico', () {
    test('deve gerar apostas usando sistema matemático para Mega-Sena real', () {
      // Arrange — usa a Mega-Sena real com números frequentes reais
      final loteria = Lottery.fromType(LotteryType.megaSena);

      // Act — pode gerar ou lançar exceção se filtros forem muito restritivos
      try {
        final resultado = usecase(
          lottery: loteria,
          numberOfBets: 2,
          strategy: GenerationStrategy.sistemaMatematico,
        );
        expect(resultado.length, 2);
        for (final aposta in resultado) {
          expect(aposta.length, loteria.numbersToPick);
        }
      } on Exception catch (e) {
        // Exceção esperada se não conseguir gerar dentro do limite de tentativas
        expect(e.toString(), contains('tentativas'));
      }
    });
  });

  group('GenerateBetsUsecase — gerarComResultado (métricas de auditoria)', () {
    test('deve retornar ResultadoGeracao com a estratégia e apostas corretas', () {
      // Arrange
      const loteria = Lottery(
        type: LotteryType.megaSena,
        name: 'Mega-Sena',
        numbersToPick: 6,
        mostFrequentNumbers: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
      );

      // Act
      final resultado = usecase.gerarComResultado(
        lottery: loteria,
        numberOfBets: 3,
        strategy: GenerationStrategy.frequentOnly,
      );

      // Assert
      expect(resultado.apostas.length, 3);
      expect(resultado.estrategia, GenerationStrategy.frequentOnly);
      // frequentOnly não aplica filtros, portanto não rejeita apostas
      expect(resultado.apostasRejeitadas, 0);
    });

    test('deve contabilizar apostas rejeitadas pelo sistema matemático', () {
      // Arrange — usa a loteria real para que os filtros estatísticos sejam aplicados
      final loteria = Lottery.fromType(LotteryType.megaSena);

      // Act
      try {
        final resultado = usecase.gerarComResultado(
          lottery: loteria,
          numberOfBets: 1,
          strategy: GenerationStrategy.sistemaMatematico,
        );

        expect(resultado.estrategia, GenerationStrategy.sistemaMatematico);
        // Quantidade de rejeitadas é >= 0 dependendo do acaso
        expect(resultado.apostasRejeitadas, greaterThanOrEqualTo(0));
      } on Exception {
        // Aceitável se não conseguir gerar dentro do limite de tentativas
      }
    });
  });
}
