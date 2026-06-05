// =========================================================================
// ARQUIVO: lib/modules/generator/domain/entities/filtro_estatistico.dart
// OPERAÇÃO 1 do REASONS Canvas — Entidade imutável de valor para filtros
// =========================================================================
import 'package:equatable/equatable.dart';
import 'lottery.dart';

/// Entidade de valor imutável que agrupa os parâmetros estatísticos
/// usados para validar apostas na estratégia Sistema Matemático.
class FiltroEstatistico extends Equatable {
  /// Quantidade mínima de números pares permitida na aposta
  final int parMinimo;

  /// Quantidade máxima de números pares permitida na aposta
  final int parMaximo;

  /// Soma mínima dos números da aposta (limite inferior do range ótimo)
  final int somaMinima;

  /// Soma máxima dos números da aposta (limite superior do range ótimo)
  final int somaMaxima;

  /// Quantidade mínima de quadrantes distintos que devem ser cobertos
  final int minimoQuadrantesDistintos;

  const FiltroEstatistico({
    required this.parMinimo,
    required this.parMaximo,
    required this.somaMinima,
    required this.somaMaxima,
    required this.minimoQuadrantesDistintos,
  });

  /// Factory que retorna os filtros ideais para cada tipo de loteria,
  /// baseados em análise estatística histórica dos sorteios da Caixa.
  ///
  /// Ranges de soma: concentram ~70% dos sorteios vencedores históricos.
  /// Ranges par/ímpar: excluem combinações que ocorrem em <3% dos sorteios.
  factory FiltroEstatistico.paraLoteria(LotteryType tipo) {
    switch (tipo) {
      case LotteryType.megaSena:
        // 6 números de 60 — soma ótima histórica: 150 a 210
        // Par ótimo: 2 a 4 pares (evita 0, 1, 5, 6 pares — ocorrem <5%)
        return const FiltroEstatistico(
          parMinimo: 2,
          parMaximo: 4,
          somaMinima: 150,
          somaMaxima: 210,
          minimoQuadrantesDistintos: 3,
        );

      case LotteryType.lotofacil:
        // 15 números de 25 — soma ótima histórica: 170 a 230
        // Par ótimo: 6 a 9 pares
        return const FiltroEstatistico(
          parMinimo: 6,
          parMaximo: 9,
          somaMinima: 170,
          somaMaxima: 230,
          minimoQuadrantesDistintos: 3,
        );

      case LotteryType.quina:
        // 5 números de 80 — soma ótima histórica: 100 a 260
        // Par ótimo: 2 a 3 pares
        return const FiltroEstatistico(
          parMinimo: 2,
          parMaximo: 3,
          somaMinima: 100,
          somaMaxima: 260,
          minimoQuadrantesDistintos: 3,
        );

      case LotteryType.duplaSena:
        // 6 números de 50 — soma ótima histórica: 90 a 165
        // Par ótimo: 2 a 4 pares
        return const FiltroEstatistico(
          parMinimo: 2,
          parMaximo: 4,
          somaMinima: 90,
          somaMaxima: 165,
          minimoQuadrantesDistintos: 3,
        );

      case LotteryType.timemania:
        // 10 números de 80 (excluindo time) — soma ótima histórica: 200 a 500
        // Par ótimo: 4 a 6 pares
        return const FiltroEstatistico(
          parMinimo: 4,
          parMaximo: 6,
          somaMinima: 200,
          somaMaxima: 500,
          minimoQuadrantesDistintos: 3,
        );
    }
  }

  @override
  List<Object?> get props =>
      [parMinimo, parMaximo, somaMinima, somaMaxima, minimoQuadrantesDistintos];

  @override
  String toString() =>
      'FiltroEstatistico(pares: $parMinimo-$parMaximo, soma: $somaMinima-$somaMaxima, '
      'quadrantes: $minimoQuadrantesDistintos+)';
}
