// =========================================================================
// ARQUIVO: test/domain/entities/filtro_estatistico_test.dart
// =========================================================================
import 'package:flutter_test/flutter_test.dart';
import 'package:gerador_de_apostas/modules/generator/domain/entities/filtro_estatistico.dart';
import 'package:gerador_de_apostas/modules/generator/domain/entities/lottery.dart';

void main() {
  group('FiltroEstatistico — factory paraLoteria', () {
    test('deve criar filtro correto para Mega-Sena', () {
      final filtro = FiltroEstatistico.paraLoteria(LotteryType.megaSena);

      expect(filtro.parMinimo, 2);
      expect(filtro.parMaximo, 4);
      expect(filtro.somaMinima, 150);
      expect(filtro.somaMaxima, 210);
      expect(filtro.minimoQuadrantesDistintos, 3);
    });

    test('deve criar filtro correto para Lotofácil', () {
      final filtro = FiltroEstatistico.paraLoteria(LotteryType.lotofacil);

      expect(filtro.parMinimo, 6);
      expect(filtro.parMaximo, 9);
      expect(filtro.somaMinima, 170);
      expect(filtro.somaMaxima, 230);
      expect(filtro.minimoQuadrantesDistintos, 3);
    });

    test('deve criar filtro correto para Quina', () {
      final filtro = FiltroEstatistico.paraLoteria(LotteryType.quina);

      // Quina: 5 números de 80 — filtros ajustados para não eliminar ~60% das apostas
      // par: 1 a 4 (cobre >95% dos sorteios reais)
      // quadrantes: mínimo 2 (matematicamente correto para N=5 em 4 quadrantes)
      expect(filtro.parMinimo, 1);
      expect(filtro.parMaximo, 4);
      expect(filtro.somaMinima, 100);
      expect(filtro.somaMaxima, 260);
      expect(filtro.minimoQuadrantesDistintos, 2);
    });

    test('deve criar filtro correto para Dupla Sena', () {
      final filtro = FiltroEstatistico.paraLoteria(LotteryType.duplaSena);

      expect(filtro.parMinimo, 2);
      expect(filtro.parMaximo, 4);
      expect(filtro.somaMinima, 90);
      expect(filtro.somaMaxima, 165);
      expect(filtro.minimoQuadrantesDistintos, 3);
    });

    test('deve criar filtro correto para Timemania', () {
      final filtro = FiltroEstatistico.paraLoteria(LotteryType.timemania);

      expect(filtro.parMinimo, 4);
      expect(filtro.parMaximo, 6);
      expect(filtro.somaMinima, 200);
      expect(filtro.somaMaxima, 500);
      expect(filtro.minimoQuadrantesDistintos, 3);
    });
  });

  group('FiltroEstatistico — Equatable', () {
    test('dois filtros com os mesmos valores devem ser iguais', () {
      const filtro1 = FiltroEstatistico(
        parMinimo: 2,
        parMaximo: 4,
        somaMinima: 150,
        somaMaxima: 210,
        minimoQuadrantesDistintos: 3,
      );
      const filtro2 = FiltroEstatistico(
        parMinimo: 2,
        parMaximo: 4,
        somaMinima: 150,
        somaMaxima: 210,
        minimoQuadrantesDistintos: 3,
      );

      expect(filtro1, equals(filtro2));
    });

    test('dois filtros com valores diferentes não devem ser iguais', () {
      final filtroMegaSena = FiltroEstatistico.paraLoteria(LotteryType.megaSena);
      final filtroQuina = FiltroEstatistico.paraLoteria(LotteryType.quina);

      expect(filtroMegaSena, isNot(equals(filtroQuina)));
    });
  });

  group('FiltroEstatistico — toString', () {
    test('deve retornar string representativa do filtro', () {
      final filtro = FiltroEstatistico.paraLoteria(LotteryType.megaSena);
      final textoFiltro = filtro.toString();

      expect(textoFiltro, contains('2-4'));    // parMinimo-parMaximo
      expect(textoFiltro, contains('150'));    // somaMinima
      expect(textoFiltro, contains('210'));    // somaMaxima
      expect(textoFiltro, contains('3'));      // minimoQuadrantesDistintos
    });
  });
}
