// =========================================================================
// ARQUIVO: lib/modules/generator/domain/usecases/validar_aposta.dart
// OPERAÇÃO 2 do REASONS Canvas — Funções puras de validação estatística
// =========================================================================
import '../entities/filtro_estatistico.dart';
import '../entities/lottery.dart';

/// Resultado de uma validação de aposta, com motivo para debug/log
class ResultadoValidacao {
  final bool aprovada;
  final String? motivoRejeicao;

  const ResultadoValidacao({required this.aprovada, this.motivoRejeicao});

  /// Construtor conveniente para aprovação
  const ResultadoValidacao.aprovada() : aprovada = true, motivoRejeicao = null;

  /// Construtor conveniente para rejeição com motivo
  const ResultadoValidacao.rejeitada(String motivo)
      : aprovada = false,
        motivoRejeicao = motivo;

  @override
  String toString() => aprovada ? 'APROVADA' : 'REJEITADA: $motivoRejeicao';
}

/// Use case de validação estatística de apostas.
///
/// Contém apenas funções puras (sem efeitos colaterais) para verificar
/// se uma aposta atende aos critérios do Sistema Matemático.
class ValidarApostaUsecase {
  const ValidarApostaUsecase();

  // ── Funções de cálculo ─────────────────────────────────────────────────

  /// Soma todos os números de uma aposta.
  /// Para Timemania, o último elemento é o time — deve ser excluído antes de chamar.
  int calcularSoma(List<int> numeros) {
    return numeros.fold(0, (acumulado, numero) => acumulado + numero);
  }

  /// Conta quantos números pares existem na aposta.
  int contarPares(List<int> numeros) {
    return numeros.where((n) => n % 2 == 0).length;
  }

  /// Conta quantos números ímpares existem na aposta.
  int contarImpares(List<int> numeros) {
    return numeros.where((n) => n % 2 != 0).length;
  }

  /// Retorna em qual quadrante um número está.
  /// O volante é dividido em 4 quadrantes iguais baseados no maxNumero da loteria.
  int _quadranteDe(int numero, int maxNumero) {
    final tamQuadrante = maxNumero / 4;
    if (numero <= tamQuadrante) return 1;
    if (numero <= tamQuadrante * 2) return 2;
    if (numero <= tamQuadrante * 3) return 3;
    return 4;
  }

  /// Conta quantos quadrantes distintos uma aposta cobre.
  int contarQuadrantesDistintos(List<int> numeros, int maxNumero) {
    final quadrantesCobertos = numeros
        .map((n) => _quadranteDe(n, maxNumero))
        .toSet();
    return quadrantesCobertos.length;
  }

  // ── Filtros individuais ────────────────────────────────────────────────

  /// **Filtro 1 — Balanceamento Par/Ímpar**
  ///
  /// Valida se a quantidade de números pares está dentro da faixa ótima
  /// definida pelo [filtro] para aquela loteria.
  ResultadoValidacao validarBalanceamento(
    List<int> numeros,
    FiltroEstatistico filtro,
  ) {
    final quantPares = contarPares(numeros);

    if (quantPares < filtro.parMinimo) {
      return ResultadoValidacao.rejeitada(
        'Poucos pares: $quantPares (mínimo: ${filtro.parMinimo})',
      );
    }
    if (quantPares > filtro.parMaximo) {
      return ResultadoValidacao.rejeitada(
        'Muitos pares: $quantPares (máximo: ${filtro.parMaximo})',
      );
    }
    return const ResultadoValidacao.aprovada();
  }

  /// **Filtro 2 — Soma no Range Ótimo**
  ///
  /// Valida se a soma dos números da aposta está dentro da faixa histórica
  /// que concentra ~70% dos sorteios vencedores.
  ResultadoValidacao validarSoma(
    List<int> numeros,
    FiltroEstatistico filtro,
  ) {
    final soma = calcularSoma(numeros);

    if (soma < filtro.somaMinima) {
      return ResultadoValidacao.rejeitada(
        'Soma baixa: $soma (mínimo: ${filtro.somaMinima})',
      );
    }
    if (soma > filtro.somaMaxima) {
      return ResultadoValidacao.rejeitada(
        'Soma alta: $soma (máximo: ${filtro.somaMaxima})',
      );
    }
    return const ResultadoValidacao.aprovada();
  }

  /// **Filtro 3 — Cobertura de Quadrantes (Wheeling)**
  ///
  /// Valida se uma aposta cobre o mínimo de quadrantes distintos do volante,
  /// garantindo distribuição geográfica dos números.
  ResultadoValidacao validarQuadrantes(
    List<int> numeros,
    int maxNumero,
    FiltroEstatistico filtro,
  ) {
    final quadrantesDistintos = contarQuadrantesDistintos(numeros, maxNumero);

    if (quadrantesDistintos < filtro.minimoQuadrantesDistintos) {
      return ResultadoValidacao.rejeitada(
        'Poucos quadrantes: $quadrantesDistintos '
        '(mínimo: ${filtro.minimoQuadrantesDistintos})',
      );
    }
    return const ResultadoValidacao.aprovada();
  }

  // ── Pipeline completo ──────────────────────────────────────────────────

  /// Executa todos os filtros em sequência (pipeline).
  ///
  /// Para Timemania, [isTimemania] = true → o último elemento (time) é excluído
  /// antes de aplicar os filtros numéricos.
  ///
  /// Retorna o primeiro resultado de rejeição encontrado, ou `aprovada` se
  /// todos os filtros passarem.
  ResultadoValidacao validarCompleto({
    required List<int> numeros,
    required FiltroEstatistico filtro,
    required int maxNumero,
    bool isTimemania = false,
  }) {
    // Separar dezenas do time (Timemania tem o time como último elemento)
    final dezenas = isTimemania ? numeros.sublist(0, numeros.length - 1) : numeros;

    // Filtro 1: balanceamento par/ímpar
    final resultadoBalanco = validarBalanceamento(dezenas, filtro);
    if (!resultadoBalanco.aprovada) return resultadoBalanco;

    // Filtro 2: soma no range ótimo
    final resultadoSoma = validarSoma(dezenas, filtro);
    if (!resultadoSoma.aprovada) return resultadoSoma;

    // Filtro 3: cobertura de quadrantes
    final resultadoQuadrantes = validarQuadrantes(dezenas, maxNumero, filtro);
    if (!resultadoQuadrantes.aprovada) return resultadoQuadrantes;

    return const ResultadoValidacao.aprovada();
  }

  // ── Utilitários de análise ─────────────────────────────────────────────

  /// Verifica se uma aposta está no range ótimo de soma da sua loteria.
  /// Método utilitário para uso na UI (StatisticsPage).
  bool somaEstaNoRangeOtimo(List<int> numeros, LotteryType tipo) {
    final filtro = FiltroEstatistico.paraLoteria(tipo);
    final soma = calcularSoma(numeros);
    return soma >= filtro.somaMinima && soma <= filtro.somaMaxima;
  }

  /// Verifica se o balanceamento par/ímpar é ideal.
  /// Método utilitário para uso na UI (StatisticsPage).
  bool balancamentoEhIdeal(List<int> numeros, LotteryType tipo) {
    final filtro = FiltroEstatistico.paraLoteria(tipo);
    final quantPares = contarPares(numeros);
    return quantPares >= filtro.parMinimo && quantPares <= filtro.parMaximo;
  }
}
