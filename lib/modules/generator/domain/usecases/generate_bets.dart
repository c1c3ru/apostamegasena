// =========================================================================
// ARQUIVO: lib/modules/generator/domain/usecases/generate_bets.dart
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

  /// Frequentes com peso ponderado pela Entropia de Shannon do "atraso" de cada dezena
  entropyFrequent,

  /// Misto com proporção e pool ajustados para maximizar a entropia da aposta candidata
  entropyMixed,
}

/// Resultado da geração de apostas, incluindo métricas de auditoria.
class ResultadoGeracao {
  /// Lista de apostas aprovadas pelos filtros
  final List<List<int>> apostas;

  /// Quantidade de apostas candidatas rejeitadas pelos filtros
  final int apostasRejeitadas;

  /// Estratégia utilizada na geração
  final GenerationStrategy estrategia;

  /// Aviso matemático sobre a estratégia (Falácia do Apostador, etc.)
  final String? avisoMatematico;

  const ResultadoGeracao({
    required this.apostas,
    required this.apostasRejeitadas,
    required this.estrategia,
    this.avisoMatematico,
  });
}

// ---------------------------------------------------------------------------
// Utilidades de Entropia de Shannon
// ---------------------------------------------------------------------------

/// Calcula a Entropia de Shannon H(X) = -Σ P(x_i) · log₂ P(x_i)
/// para uma distribuição de probabilidades fornecida como lista de pesos.
///
/// Retorna um valor entre 0 (completamente previsível) e log₂(n) (caos máximo).
double _shannonEntropy(List<double> pesos) {
  final total = pesos.fold(0.0, (a, b) => a + b);
  if (total == 0) return 0.0;
  double h = 0.0;
  for (final p in pesos) {
    if (p <= 0) continue;
    final px = p / total;
    h -= px * (log(px) / log(2)); // log₂(p) = ln(p)/ln(2)
  }
  return h;
}

/// Calcula a entropia de distribuição dos aparecimentos de um número ao longo
/// dos `totalSorteios` sorteios, dado que ele apareceu em `freq` deles.
///
/// Modelo de dois eventos: aparece (P=freq/total) ou não aparece (P=1-freq/total).
/// Alta entropia → aparecimentos bem distribuídos (imprevisível, caótico).
/// Baixa entropia → muito concentrado (quase sempre sai, ou quase nunca sai).
double _entropiaPorNumero(int freq, int totalSorteios) {
  if (totalSorteios <= 0 || freq <= 0 || freq >= totalSorteios) return 0.0;
  return _shannonEntropy([freq.toDouble(), (totalSorteios - freq).toDouble()]);
}

/// Calcula a entropia de uma aposta candidata como a entropia da distribuição
/// de frequências dos números selecionados dentro de uma lista de pesos.
double _entropiaAposta(List<int> aposta, List<double> pesos, List<int> universo) {
  final pesosAposta = aposta.map((n) {
    final idx = universo.indexOf(n);
    return idx >= 0 ? pesos[idx] : 0.0;
  }).toList();
  return _shannonEntropy(pesosAposta);
}

// ---------------------------------------------------------------------------
// Use case
// ---------------------------------------------------------------------------

/// Use case responsável por gerar apostas para qualquer loteria suportada.
///
/// Suporta múltiplas estratégias de geração, incluindo o Sistema Matemático
/// que aplica filtros estatísticos (balanceamento par/ímpar, soma no range
/// ótimo e cobertura de quadrantes) sobre cada aposta candidata, e as novas
/// estratégias baseadas em Entropia de Shannon.
class GenerateBetsUsecase {
  /// Máximo de tentativas para estratégias sem filtro (evita loop infinito)
  static const int _maxTentativasSimples = 100;

  /// Máximo de tentativas para Sistema Matemático (filtros reduzem o pool válido)
  static const int _maxTentativasMatematico = 200;

  /// Máximo de tentativas para estratégias de entropia
  static const int _maxTentativasEntropia = 1000;

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
    final int quantidadeAEscolher = lottery.numbersToPick;
    final List<List<int>> apostas = [];
    final Set<String> apostasUnicas = {};
    int contadorRejeitadas = 0;

    // ── Determina lista de origem e pesos de entropia ─────────────────────
    List<int> listaOrigem;
    List<double>? pesosEntropia; // apenas para estratégias de entropia

    switch (strategy) {
      case GenerationStrategy.entropyFrequent:
        final resultado = _obterListaEntropyFrequent(lottery);
        listaOrigem = resultado.$1;
        pesosEntropia = resultado.$2;
        break;
      case GenerationStrategy.entropyMixed:
        final resultado = _obterListaEntropyMixed(lottery);
        listaOrigem = resultado.$1;
        pesosEntropia = resultado.$2;
        break;
      default:
        listaOrigem = _obterListaOrigem(lottery, strategy);
    }

    if (listaOrigem.length < quantidadeAEscolher) {
      throw Exception(
        'Lista de números de origem insuficiente para ${lottery.name}.',
      );
    }

    // ── Filtro estatístico só é criado para a estratégia matemática ───────
    final FiltroEstatistico? filtro =
        strategy == GenerationStrategy.sistemaMatematico
            ? FiltroEstatistico.paraLoteria(lottery.type)
            : null;

    final bool isTimemania = lottery.type == LotteryType.timemania;

    final int maxTentativas = switch (strategy) {
      GenerationStrategy.sistemaMatematico => _maxTentativasMatematico,
      GenerationStrategy.entropyFrequent ||
      GenerationStrategy.entropyMixed =>
        _maxTentativasEntropia,
      _ => _maxTentativasSimples,
    };

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

      final List<int> candidata;

      if (pesosEntropia != null) {
        candidata = _gerarCandidataComEntropia(
          listaOrigem,
          pesosEntropia,
          quantidadeAEscolher,
          lottery,
          isTimemania,
          strategy,
        );
      } else {
        candidata = _gerarCandidata(
          listaOrigem,
          quantidadeAEscolher,
          lottery,
          isTimemania,
        );
      }

      tentativas++;

      // Sentinela: candidata inválida (tamanho errado) → rejeitar
      if (candidata.length != quantidadeAEscolher &&
          !(isTimemania && candidata.length == quantidadeAEscolher + 1)) {
        contadorRejeitadas++;
        continue;
      }

      final String chave = candidata.join(',');
      if (!apostasUnicas.contains(chave)) {
        // Para entropyMixed: verificar se a aposta tem entropia suficiente
        if (strategy == GenerationStrategy.entropyMixed &&
            pesosEntropia != null) {
          final double entropiaAposta =
              _entropiaAposta(candidata, pesosEntropia, listaOrigem);
          final double entropiaMaxima = log(listaOrigem.length) / log(2);
          // Rejeitar se entropia < 40% do máximo (limiar conservador e realista)
          if (entropiaAposta < entropiaMaxima * 0.40) {
            contadorRejeitadas++;
            continue;
          }
        }

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

    // ── Aviso da Falácia do Apostador ─────────────────────────────────────
    final String? aviso = _avisoFalaciaApostador(strategy);

    return ResultadoGeracao(
      apostas: apostas,
      apostasRejeitadas: contadorRejeitadas,
      estrategia: strategy,
      avisoMatematico: aviso,
    );
  }

  // ── Métodos privados ───────────────────────────────────────────────────

  /// Gera uma aposta candidata aleatória dentro do pool de origem (sem pesos).
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

  /// Gera uma aposta candidata usando amostragem ponderada pela entropia.
  ///
  /// Cada número tem um peso proporcional ao seu coeficiente de entropia de
  /// Shannon. Números com aparecimentos bem distribuídos ao longo do tempo
  /// (alta entropia = "caos bem espalhado") recebem peso maior.
  ///
  /// Para [GenerationStrategy.entropyMixed], adicionalmente rejeita candidatas
  /// cuja entropia total da aposta caia abaixo de 70% da entropia máxima
  /// possível (log₂ do tamanho do pool), garantindo apostas "matematicamente
  /// imprevisíveis" e evitando padrões óbvios.
  List<int> _gerarCandidataComEntropia(
    List<int> listaOrigem,
    List<double> pesos,
    int quantidadeAEscolher,
    Lottery lottery,
    bool isTimemania,
    GenerationStrategy strategy,
  ) {
    final Random random = Random();

    // Amostragem sem reposição, ponderada pelos pesos de entropia
    final List<int> pool = List.from(listaOrigem);
    final List<double> pesosPool = List.from(pesos);
    final List<int> candidata = [];

    while (candidata.length < quantidadeAEscolher && pool.isNotEmpty) {
      // Roulette-wheel selection: escolhe índice proporcional ao peso
      final double totalPeso = pesosPool.fold(0.0, (a, b) => a + b);
      double roleta = random.nextDouble() * totalPeso;
      int escolhido = pool.length - 1;
      for (int i = 0; i < pool.length; i++) {
        roleta -= pesosPool[i];
        if (roleta <= 0) {
          escolhido = i;
          break;
        }
      }
      candidata.add(pool.removeAt(escolhido));
      pesosPool.removeAt(escolhido);
    }

    candidata.sort();

    // Timemania: adicionar time do coração como último elemento (11º)
    if (isTimemania) {
      final int indiceTime = random.nextInt(80) + 1;
      candidata.add(indiceTime);
    }

    return candidata;
  }

  // ── Builders de lista de origem com pesos de entropia ─────────────────

  /// Retorna (pool, pesos) para a estratégia [GenerationStrategy.entropyFrequent].
  ///
  /// Pool: todos os números da loteria (não apenas os top-20 frequentes).
  /// Pesos: coeficiente de entropia de Shannon de cada número, calculado com
  /// base na sua frequência histórica relativa ao total estimado de sorteios.
  ///
  /// Números com aparecimentos altamente agrupados (baixa entropia) recebem
  /// peso menor; números com aparecimentos bem distribuídos no tempo (alta
  /// entropia) recebem peso maior.
  (List<int>, List<double>) _obterListaEntropyFrequent(Lottery lottery) {
    // Universo: lista completa de números (posição = ranking de frequência)
    final List<int> universo = lottery.mostFrequentNumbers;
    final int totalNumeros = universo.length;

    // Estimar total de sorteios com base no tipo de loteria
    final int totalSorteios = _estimarTotalSorteios(lottery.type);

    // Atribuir frequências estimadas: o número no rank i teve frequência
    // proporcional à sua posição inversa. Rank 0 = mais frequente.
    // Fórmula: freq_i ≈ totalSorteios * (totalNumeros - i) / Σ(ranks)
    final double somaRanks =
        List.generate(totalNumeros, (i) => totalNumeros - i)
            .fold(0.0, (a, b) => a + b);

    final List<double> pesos = List.generate(totalNumeros, (i) {
      final int freqEstimada =
          ((totalSorteios * (totalNumeros - i)) / somaRanks).round();
      return _entropiaPorNumero(freqEstimada.clamp(1, totalSorteios - 1), totalSorteios);
    });

    return (universo, pesos);
  }

  /// Retorna (pool, pesos) para a estratégia [GenerationStrategy.entropyMixed].
  ///
  /// Pool: todos os números disponíveis da loteria.
  /// Pesos: baseados em entropia, como em [_obterListaEntropyFrequent], mas
  /// aplicados sobre o universo completo para permitir que números menos
  /// frequentes (com entropia diferente de zero) também sejam selecionados.
  ///
  /// A proporção frequente/não-frequente NÃO é fixa em 50/50; é determinada
  /// dinamicamente pelos pesos de entropia. Adicionalmente, o método
  /// [_gerarCandidataComEntropia] rejeita apostas cuja entropia total seja
  /// abaixo de 70% do máximo, garantindo que a aposta final seja
  /// "matematicamente imprevisível".
  (List<int>, List<double>) _obterListaEntropyMixed(Lottery lottery) {
    // Pool completo: todos os números, ordenados por frequência histórica
    final List<int> universo = lottery.mostFrequentNumbers;
    final int totalNumeros = universo.length;
    final int totalSorteios = _estimarTotalSorteios(lottery.type);

    final double somaRanks =
        List.generate(totalNumeros, (i) => totalNumeros - i)
            .fold(0.0, (a, b) => a + b);

    final List<double> pesos = List.generate(totalNumeros, (i) {
      final int freqEstimada =
          ((totalSorteios * (totalNumeros - i)) / somaRanks).round();
      return _entropiaPorNumero(freqEstimada.clamp(1, totalSorteios - 1), totalSorteios);
    });

    return (universo, pesos);
  }

  /// Estima o total histórico de sorteios por tipo de loteria.
  int _estimarTotalSorteios(LotteryType tipo) {
    return switch (tipo) {
      LotteryType.megaSena => 3014,
      LotteryType.lotofacil => 3702,
      LotteryType.quina => 7042,
      LotteryType.duplaSena => 2965,
      LotteryType.timemania => 2399,
    };
  }

  /// Determina a lista de origem conforme a estratégia escolhida (estratégias clássicas).
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

      // Entropia é tratada separadamente — não deve chegar aqui
      case GenerationStrategy.entropyFrequent:
      case GenerationStrategy.entropyMixed:
        return lottery.mostFrequentNumbers;
    }
  }

  // ── Aviso da Falácia do Apostador ──────────────────────────────────────

  /// Retorna um aviso matemático contextualizado para estratégias que
  /// baseiam a seleção em frequência histórica (Falácia do Apostador).
  ///
  /// Retorna `null` para [GenerationStrategy.allNumbers] (estratégia honesta).
  String? _avisoFalaciaApostador(GenerationStrategy strategy) {
    switch (strategy) {
      case GenerationStrategy.frequentOnly:
        return '⚠️ Falácia do Apostador: as bolas não têm memória. '
            'Um número que saiu 100× tem exatamente a mesma probabilidade '
            'de sair no próximo sorteio que um número que saiu apenas 10×. '
            'Esta estratégia não aumenta suas chances de acerto.';

      case GenerationStrategy.mixed:
        return '⚠️ Falácia do Apostador: mesclar frequentes com aleatórios '
            'não altera a probabilidade individual de cada combinação. '
            'Cada aposta de 6 dezenas tem 1 chance em ~50 milhões, '
            'independentemente de como o pool foi selecionado.';

      case GenerationStrategy.sistemaMatematico:
        return '⚠️ Ilusão de Controle: os filtros estatísticos eliminam '
            'combinações que "parecem feias", mas a combinação 01-02-03-04-05-06 '
            'tem exatamente a mesma probabilidade (1 em ~50 milhões) que '
            'qualquer aposta "balanceada" gerada por este sistema.';

      case GenerationStrategy.entropyFrequent:
        return '⚠️ Aviso matemático: a Entropia de Shannon mede a qualidade '
            'do caos histórico de cada dezena, mas a máquina de sorteio é '
            'fisicamente independente do passado. Mesmo com pesos dinâmicos '
            'por entropia, cada combinação tem 1 em ~50 milhões de chance.';

      case GenerationStrategy.entropyMixed:
        return '⚠️ Aviso matemático: garantir alta entropia na aposta '
            'a torna "matematicamente imprevisível" dentro do modelo '
            'histórico, mas a sorteadeira é aleatória por natureza física. '
            'Não há estratégia que eleve a probabilidade de acerto.';

      case GenerationStrategy.allNumbers:
        return null; // Estratégia honesta — sem falácia
    }
  }
}