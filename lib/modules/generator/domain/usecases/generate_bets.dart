// =========================================================================
// ARQUIVO: lib/modules/generator/domain/usecases/generate_bets.dart
// OPERAÇÕES 3 e 4 do REASONS Canvas — Expande enum e adiciona pipeline
// =========================================================================
import 'dart:math';
import '../entities/filtro_estatistico.dart';
import '../entities/lottery.dart';
import 'validar_aposta.dart';

/// Estratégias de geração de apostas disponíveis no app.
enum GenerationStrategy {
  /// Apenas números mais sorteados historicamente
  frequentOnly,

  /// Todos os números disponíveis (aleatoriedade total)
  allNumbers,

  /// Combinação de 50% frequentes + 50% aleatórios
  mixed,

  /// Sistema Matemático: wheeling abreviado + filtros par/ímpar + soma ótima
  sistemaMatematico,
}

/// Resultado da geração de apostas, incluindo métricas de auditoria.
class ResultadoGeracao {
  /// Lista de apostas aprovadas pelos filtros
  final List<List<int>> apostas;

  /// Quantidade de apostas candidatas rejeitadas pelos filtros
  final int apostasRejeitadas;

  /// Estratégia utilizada na geração
  final GenerationStrategy estrategia;

  const ResultadoGeracao({
    required this.apostas,
    required this.apostasRejeitadas,
    required this.estrategia,
  });
}

/// Use case responsável por gerar apostas para qualquer loteria suportada.
///
/// Suporta múltiplas estratégias de geração, incluindo o Sistema Matemático
/// que aplica filtros estatísticos (balanceamento par/ímpar, soma no range
/// ótimo e cobertura de quadrantes) sobre cada aposta candidata.
class GenerateBetsUsecase {
  /// Máximo de tentativas para estratégias sem filtro (evita loop infinito)
  static const int _maxTentativasSimples = 100;

  /// Máximo de tentativas para Sistema Matemático (filtros reduzem o pool válido)
  static const int _maxTentativasMatematico = 200;

  final ValidarApostaUsecase _validador;

  GenerateBetsUsecase({ValidarApostaUsecase? validador})
      : _validador = validador ?? const ValidarApostaUsecase();

  /// Gera apostas e retorna `List<List<int>>` para compatibilidade retroativa.
  List<List<int>> call({
    required Lottery lottery,
    required int numberOfBets,
    GenerationStrategy strategy = GenerationStrategy.frequentOnly,
  }) {
    return gerarComResultado(
      lottery: lottery,
      numberOfBets: numberOfBets,
      strategy: strategy,
    ).apostas;
  }

  /// Gera apostas e retorna [ResultadoGeracao] com métricas de auditoria.
  ResultadoGeracao gerarComResultado({
    required Lottery lottery,
    required int numberOfBets,
    GenerationStrategy strategy = GenerationStrategy.frequentOnly,
  }) {
    final List<int> listaOrigem = _obterListaOrigem(lottery, strategy);
    final int quantidadeAEscolher = lottery.numbersToPick;
    final List<List<int>> apostas = [];
    final Set<String> apostasUnicas = {};
    int contadorRejeitadas = 0;

    if (listaOrigem.length < quantidadeAEscolher) {
      throw Exception(
        'Lista de números de origem insuficiente para ${lottery.name}.',
      );
    }

    // Filtro estatístico só é criado para a estratégia matemática
    final FiltroEstatistico? filtro =
        strategy == GenerationStrategy.sistemaMatematico
            ? FiltroEstatistico.paraLoteria(lottery.type)
            : null;

    final bool isTimemania = lottery.type == LotteryType.timemania;
    final int maxTentativas = strategy == GenerationStrategy.sistemaMatematico
        ? _maxTentativasMatematico
        : _maxTentativasSimples;

    int tentativas = 0;

    while (apostas.length < numberOfBets) {
      // Safeguard: evitar loop infinito
      if (tentativas >= maxTentativas) {
        throw Exception(
          'Não foi possível gerar $numberOfBets apostas únicas após '
          '$maxTentativas tentativas. Tente reduzir a quantidade ou '
          'usar outra estratégia.',
        );
      }

      final List<int> candidata = _gerarCandidata(
        listaOrigem,
        quantidadeAEscolher,
        lottery,
        isTimemania,
      );

      tentativas++;

      final String chave = candidata.join(',');
      if (!apostasUnicas.contains(chave)) {
        // Aplicar pipeline de filtros quando estratégia matemática está ativa
        if (filtro != null) {
          final resultado = _validador.validarCompleto(
            numeros: candidata,
            filtro: filtro,
            maxNumero: lottery.maxNumber,
            isTimemania: isTimemania,
          );

          if (!resultado.aprovada) {
            contadorRejeitadas++;
            continue;
          }
        }

        apostasUnicas.add(chave);
        apostas.add(candidata);
      }
    }

    return ResultadoGeracao(
      apostas: apostas,
      apostasRejeitadas: contadorRejeitadas,
      estrategia: strategy,
    );
  }

  // ── Métodos privados ───────────────────────────────────────────────────

  /// Gera uma aposta candidata aleatória dentro do pool de origem.
  List<int> _gerarCandidata(
    List<int> listaOrigem,
    int quantidadeAEscolher,
    Lottery lottery,
    bool isTimemania,
  ) {
    final List<int> pool = List.from(listaOrigem);
    final List<int> candidata = [];
    final Random random = Random();

    for (int j = 0; j < quantidadeAEscolher; j++) {
      final int indiceAleatorio = random.nextInt(pool.length);
      candidata.add(pool.removeAt(indiceAleatorio));
    }

    candidata.sort();

    // Timemania: adicionar time do coração como último elemento (11º)
    if (isTimemania) {
      final int indiceTime = random.nextInt(80) + 1;
      candidata.add(indiceTime);
    }

    return candidata;
  }

  /// Determina a lista de origem conforme a estratégia escolhida.
  List<int> _obterListaOrigem(Lottery lottery, GenerationStrategy strategy) {
    switch (strategy) {
      case GenerationStrategy.frequentOnly:
        return lottery.mostFrequentNumbers;

      case GenerationStrategy.allNumbers:
        return lottery.allNumbers;

      case GenerationStrategy.mixed:
        final quantFrequentes =
            (lottery.mostFrequentNumbers.length * 0.5).round();
        final frequentes =
            lottery.mostFrequentNumbers.take(quantFrequentes).toList();
        final todosNumeros = lottery.allNumbers;
        final restantes =
            todosNumeros.where((n) => !frequentes.contains(n)).toList();

        final random = Random();
        final numerosAleatorios = <int>[];
        for (int i = 0; i < quantFrequentes && restantes.isNotEmpty; i++) {
          final indice = random.nextInt(restantes.length);
          numerosAleatorios.add(restantes.removeAt(indice));
        }
        return [...frequentes, ...numerosAleatorios]..shuffle();

      case GenerationStrategy.sistemaMatematico:
        // Pool: números mais frequentes (wheeling sobre os "quentes")
        return lottery.mostFrequentNumbers;
    }
  }
}