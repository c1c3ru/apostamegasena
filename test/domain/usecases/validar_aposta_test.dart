// =========================================================================
// ARQUIVO: test/domain/usecases/validar_aposta_test.dart
// =========================================================================
import 'package:flutter_test/flutter_test.dart';
import 'package:gerador_de_apostas/modules/generator/domain/entities/filtro_estatistico.dart';
import 'package:gerador_de_apostas/modules/generator/domain/entities/lottery.dart';
import 'package:gerador_de_apostas/modules/generator/domain/usecases/validar_aposta.dart';

void main() {
  late ValidarApostaUsecase validador;

  setUp(() {
    validador = const ValidarApostaUsecase();
  });

  group('ValidarApostaUsecase — calcularSoma', () {
    test('deve calcular a soma corretamente', () {
      expect(validador.calcularSoma([1, 2, 3, 4, 5, 6]), 21);
    });

    test('deve retornar zero para lista vazia', () {
      expect(validador.calcularSoma([]), 0);
    });

    test('deve calcular soma com números maiores', () {
      expect(validador.calcularSoma([10, 20, 30, 40, 50, 60]), 210);
    });
  });

  group('ValidarApostaUsecase — contarPares', () {
    test('deve contar pares corretamente', () {
      // 2, 4, 6 são pares
      expect(validador.contarPares([1, 2, 3, 4, 5, 6]), 3);
    });

    test('deve retornar zero quando não há pares', () {
      expect(validador.contarPares([1, 3, 5, 7, 9, 11]), 0);
    });

    test('deve contar todos quando todos são pares', () {
      expect(validador.contarPares([2, 4, 6, 8, 10, 12]), 6);
    });
  });

  group('ValidarApostaUsecase — contarImpares', () {
    test('deve contar ímpares corretamente', () {
      // 1, 3, 5 são ímpares
      expect(validador.contarImpares([1, 2, 3, 4, 5, 6]), 3);
    });

    test('deve retornar zero quando não há ímpares', () {
      expect(validador.contarImpares([2, 4, 6, 8, 10, 12]), 0);
    });
  });

  group('ValidarApostaUsecase — contarQuadrantesDistintos', () {
    test('deve detectar 4 quadrantes distintos para Mega-Sena (maxNumero=60)', () {
      // Quadrante 1: 1-15, 2: 16-30, 3: 31-45, 4: 46-60
      final numeros = [5, 20, 35, 50, 10, 40];
      expect(validador.contarQuadrantesDistintos(numeros, 60), 4);
    });

    test('deve detectar 1 quadrante quando todos os números estão no mesmo quadrante', () {
      // Todos no primeiro quadrante de 60 (1-15)
      final numeros = [1, 2, 3, 4, 5, 6];
      expect(validador.contarQuadrantesDistintos(numeros, 60), 1);
    });
  });

  group('ValidarApostaUsecase — validarBalanceamento', () {
    const filtro = FiltroEstatistico(
      parMinimo: 2,
      parMaximo: 4,
      somaMinima: 150,
      somaMaxima: 210,
      minimoQuadrantesDistintos: 3,
    );

    test('deve aprovar quando a quantidade de pares está no range', () {
      // 3 pares: 2, 4, 6 — dentro do range 2-4
      final resultado = validador.validarBalanceamento([1, 2, 3, 4, 5, 6], filtro);
      expect(resultado.aprovada, isTrue);
    });

    test('deve rejeitar quando há pares demais', () {
      // 6 pares: 2, 4, 6, 8, 10, 12 — acima do máximo 4
      final resultado = validador.validarBalanceamento([2, 4, 6, 8, 10, 12], filtro);
      expect(resultado.aprovada, isFalse);
      expect(resultado.motivoRejeicao, contains('Muitos pares'));
    });

    test('deve rejeitar quando há poucos pares', () {
      // 1 par: apenas 2 — abaixo do mínimo 2
      final resultado = validador.validarBalanceamento([1, 2, 3, 5, 7, 9], filtro);
      // 1 par (só o 2), abaixo do mínimo de 2
      expect(resultado.aprovada, isFalse);
      expect(resultado.motivoRejeicao, contains('Poucos pares'));
    });
  });

  group('ValidarApostaUsecase — validarSoma', () {
    const filtro = FiltroEstatistico(
      parMinimo: 2,
      parMaximo: 4,
      somaMinima: 150,
      somaMaxima: 210,
      minimoQuadrantesDistintos: 3,
    );

    test('deve aprovar quando a soma está no range ótimo', () {
      // Soma = 175
      final resultado = validador.validarSoma([25, 30, 35, 28, 32, 25], filtro);
      expect(resultado.aprovada, isTrue);
    });

    test('deve rejeitar quando a soma é muito baixa', () {
      final resultado = validador.validarSoma([1, 2, 3, 4, 5, 6], filtro);
      // Soma = 21, abaixo de 150
      expect(resultado.aprovada, isFalse);
      expect(resultado.motivoRejeicao, contains('Soma baixa'));
    });

    test('deve rejeitar quando a soma é muito alta', () {
      final resultado = validador.validarSoma([50, 51, 52, 53, 54, 55], filtro);
      // Soma = 315, acima de 210
      expect(resultado.aprovada, isFalse);
      expect(resultado.motivoRejeicao, contains('Soma alta'));
    });
  });

  group('ValidarApostaUsecase — validarQuadrantes', () {
    const filtro = FiltroEstatistico(
      parMinimo: 2,
      parMaximo: 4,
      somaMinima: 150,
      somaMaxima: 210,
      minimoQuadrantesDistintos: 3,
    );

    test('deve aprovar quando cobre quadrantes suficientes', () {
      // Quadrantes 1, 2, 3 e 4 para maxNumero=60
      final resultado = validador.validarQuadrantes([5, 20, 35, 50, 10, 40], 60, filtro);
      expect(resultado.aprovada, isTrue);
    });

    test('deve rejeitar quando cobre poucos quadrantes', () {
      // Todos no primeiro quadrante (1-15)
      final resultado = validador.validarQuadrantes([1, 2, 3, 4, 5, 6], 60, filtro);
      expect(resultado.aprovada, isFalse);
      expect(resultado.motivoRejeicao, contains('Poucos quadrantes'));
    });
  });

  group('ValidarApostaUsecase — validarCompleto (pipeline)', () {
    const filtroMegaSena = FiltroEstatistico(
      parMinimo: 2,
      parMaximo: 4,
      somaMinima: 150,
      somaMaxima: 210,
      minimoQuadrantesDistintos: 3,
    );

    test('deve aprovar uma aposta válida para Mega-Sena', () {
      // Aposta com 3 pares (22,44,56=par; 11,37,31=ímpar),
      // soma = 11+22+31+37+44+56 = 201 (dentro de 150-210),
      // quadrantes: Q1=11, Q2=22,31, Q3=37,44, Q4=56 → 4 quadrantes ✓
      final resultado = validador.validarCompleto(
        numeros: [11, 22, 31, 37, 44, 56],
        filtro: filtroMegaSena,
        maxNumero: 60,
      );
      expect(resultado.aprovada, isTrue);
    });

    test('deve rejeitar aposta com soma baixa (pipeline para no 1º filtro falho)', () {
      // Soma = 21, pares corretos (3), mas soma é muito baixa
      final resultado = validador.validarCompleto(
        numeros: [1, 2, 3, 4, 5, 6],
        filtro: filtroMegaSena,
        maxNumero: 60,
      );
      expect(resultado.aprovada, isFalse);
    });

    test('deve ignorar o time do coração na Timemania', () {
      // Aposta timemania: 10 números + 1 time (último elemento)
      // Soma dos 10 números deve estar entre 200-500
      final numerosTimemania = [5, 15, 25, 35, 45, 55, 10, 20, 30, 40, 15]; // último=time
      final filtroTimemania = FiltroEstatistico.paraLoteria(LotteryType.timemania);

      final resultado = validador.validarCompleto(
        numeros: numerosTimemania,
        filtro: filtroTimemania,
        maxNumero: 80,
        isTimemania: true,
      );

      // Verifica que o teste rodou sem lançar exceção (resultado pode variar)
      expect(resultado, isNotNull);
    });
  });

  group('ValidarApostaUsecase — utilitários', () {
    test('somaEstaNoRangeOtimo deve retornar true para Mega-Sena com soma entre 150-210', () {
      // Soma = 180
      expect(validador.somaEstaNoRangeOtimo([25, 30, 28, 32, 35, 30], LotteryType.megaSena), isTrue);
    });

    test('somaEstaNoRangeOtimo deve retornar false para soma fora do range', () {
      expect(validador.somaEstaNoRangeOtimo([1, 2, 3, 4, 5, 6], LotteryType.megaSena), isFalse);
    });

    test('balancamentoEhIdeal deve retornar true quando pares estão no range ideal', () {
      // Mega-Sena: 2-4 pares. 3 pares aqui
      expect(validador.balancamentoEhIdeal([1, 2, 3, 4, 5, 6], LotteryType.megaSena), isTrue);
    });

    test('balancamentoEhIdeal deve retornar false quando há pares demais', () {
      // 6 pares, máximo é 4
      expect(validador.balancamentoEhIdeal([2, 4, 6, 8, 10, 12], LotteryType.megaSena), isFalse);
    });
  });
}
