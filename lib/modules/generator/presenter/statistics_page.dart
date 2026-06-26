// =========================================================================
// ARQUIVO: lib/modules/generator/presenter/statistics_page.dart
// =========================================================================
import 'package:flutter/material.dart';
import '../data/number_lists.dart';
import '../domain/entities/bet_statistics.dart';
import '../domain/entities/filtro_estatistico.dart';
import '../domain/entities/lottery.dart';
import '../domain/usecases/validar_aposta.dart';

class StatisticsPage extends StatelessWidget {
  final List<List<int>> bets;
  final Lottery lottery;

  const StatisticsPage({
    Key? key,
    required this.bets,
    required this.lottery,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isTimemania = lottery.type == LotteryType.timemania;

    final stats = BetStatistics.analyze(
      bets,
      lottery.maxNumber,
      isTimemania: isTimemania,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('📊 Estatísticas — ${lottery.name}'),
      ),
      body: bets.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  'Gere algumas apostas primeiro para ver as estatísticas',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSummaryCard(context, stats),
                  const SizedBox(height: 16),
                  _buildSomaCard(context),
                  const SizedBox(height: 16),
                  _buildBarraDistribuicao(
                    context,
                    titulo: 'Distribuição Par / Ímpar',
                    labelA: 'Pares',
                    countA: stats.evenCount,
                    percentA: stats.evenPercentage,
                    corA: Colors.blue,
                    labelB: 'Ímpares',
                    countB: stats.oddCount,
                    percentB: stats.oddPercentage,
                    corB: Colors.orange,
                  ),
                  const SizedBox(height: 16),
                  _buildBarraDistribuicao(
                    context,
                    titulo: 'Distribuição Alto / Baixo',
                    labelA: 'Altos (>${(lottery.maxNumber / 2).ceil()})',
                    countA: stats.highCount,
                    percentA: stats.highPercentage,
                    corA: Colors.green,
                    labelB: 'Baixos (≤${(lottery.maxNumber / 2).ceil()})',
                    countB: stats.lowCount,
                    percentB: stats.lowPercentage,
                    corB: Colors.purple,
                  ),
                  const SizedBox(height: 16),
                  _buildQuadrantesCard(context),
                  const SizedBox(height: 16),
                  _buildFrequencyCard(context, stats),
                  if (isTimemania) ...[
                    const SizedBox(height: 16),
                    _buildTimesCard(context),
                  ],
                ],
              ),
            ),
    );
  }

  // ── Resumo geral ──────────────────────────────────────────────────────────

  Widget _buildSummaryCard(BuildContext context, BetStatistics stats) {
    // Cobertura: quantos números únicos foram usados vs. total disponível
    final int numerosDisponiveis = lottery.maxNumber - lottery.minNumber + 1;
    final int numerosUnicos = stats.numberFrequency.length;
    final double coberturaPercent = numerosDisponiveis > 0
        ? (numerosUnicos / numerosDisponiveis) * 100
        : 0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumo Geral',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(context, 'Apostas', stats.totalBets.toString(), Icons.casino),
                _buildStatItem(context, 'Dezenas', stats.totalNumbers.toString(), Icons.numbers),
                _buildStatItem(context, 'Únicos', numerosUnicos.toString(), Icons.filter_list),
              ],
            ),
            const SizedBox(height: 16),
            // Barra de cobertura numérica
            Text(
              'Cobertura numérica: ${coberturaPercent.toStringAsFixed(1)}% '
              '($numerosUnicos de $numerosDisponiveis números)',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: coberturaPercent / 100,
                minHeight: 10,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.teal),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String valor, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 8),
        Text(
          valor,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  // ── Soma por aposta com indicador de range ótimo ──────────────────────────

  Widget _buildSomaCard(BuildContext context) {
    const validador = ValidarApostaUsecase();
    final bool isTimemania = lottery.type == LotteryType.timemania;

    // Calcular soma de cada aposta (excluindo o time no caso da Timemania)
    final List<Map<String, dynamic>> somasPorAposta = bets.asMap().entries.map((entry) {
      final int indice = entry.key;
      final List<int> aposta = entry.value;
      final List<int> dezenas = isTimemania
          ? aposta.sublist(0, aposta.length - 1)
          : aposta;
      final int soma = validador.calcularSoma(dezenas);
      final bool noRange = validador.somaEstaNoRangeOtimo(dezenas, lottery.type);
      return {'indice': indice, 'soma': soma, 'noRange': noRange, 'dezenas': dezenas};
    }).toList();

    final FiltroEstatistico filtro = FiltroEstatistico.paraLoteria(lottery.type);
    final int somaMin = filtro.somaMinima;
    final int somaMax = filtro.somaMaxima;

    final int minSomaGerada = somasPorAposta.map((e) => e['soma'] as int).reduce((a, b) => a < b ? a : b);
    final int maxSomaGerada = somasPorAposta.map((e) => e['soma'] as int).reduce((a, b) => a > b ? a : b);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Soma das Apostas',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Range ótimo histórico: $somaMin – $somaMax',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.green.shade700,
                  ),
            ),
            const SizedBox(height: 12),
            ...somasPorAposta.map((dados) {
              final int idx = dados['indice'] as int;
              final int soma = dados['soma'] as int;
              final bool noRange = dados['noRange'] as bool;
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    SizedBox(
                      width: 70,
                      child: Text(
                        'Aposta ${(idx + 1).toString().padLeft(2, '0')}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Stack(
                        children: [
                          // Barra de fundo
                          Container(
                            height: 22,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          // Barra de soma (proporcional ao max possível)
                          FractionallySizedBox(
                            widthFactor: (soma / (somaMax * 1.1)).clamp(0.0, 1.0),
                            child: Container(
                              height: 22,
                              decoration: BoxDecoration(
                                color: noRange
                                    ? Colors.green.shade400
                                    : Colors.red.shade300,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          // Texto centralizado
                          Positioned.fill(
                            child: Center(
                              child: Text(
                                soma.toString(),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      noRange ? Icons.check_circle : Icons.warning_amber,
                      size: 16,
                      color: noRange ? Colors.green : Colors.orange,
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Menor: $minSomaGerada', style: Theme.of(context).textTheme.bodySmall),
                Text('Maior: $maxSomaGerada', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(width: 12, height: 12, decoration: BoxDecoration(color: Colors.green.shade400, borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: 4),
                Text('No range ótimo', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(width: 12),
                Container(width: 12, height: 12, decoration: BoxDecoration(color: Colors.red.shade300, borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: 4),
                Text('Fora do range ótimo', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Barra de distribuição (corrigida: flex mínimo = 1) ────────────────────

  Widget _buildBarraDistribuicao(
    BuildContext context, {
    required String titulo,
    required String labelA,
    required int countA,
    required double percentA,
    required Color corA,
    required String labelB,
    required int countB,
    required double percentB,
    required Color corB,
  }) {
    // Garantir flex >= 1 para evitar crash quando uma das partes é 0%
    final int flexA = percentA.round().clamp(1, 99);
    final int flexB = percentB.round().clamp(1, 99);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            // Barra proporcional
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Row(
                children: [
                  Expanded(
                    flex: flexA,
                    child: Container(
                      height: 40,
                      color: corA,
                      child: Center(
                        child: Text(
                          '${percentA.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: flexB,
                    child: Container(
                      height: 40,
                      color: corB,
                      child: Center(
                        child: Text(
                          '${percentB.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLegendItem(labelA, countA, corA),
                _buildLegendItem(labelB, countB, corB),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, int count, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text('$label: $count', style: const TextStyle(fontSize: 13)),
      ],
    );
  }

  // ── Distribuição por quadrante ────────────────────────────────────────────

  Widget _buildQuadrantesCard(BuildContext context) {
    final bool isTimemania = lottery.type == LotteryType.timemania;
    // Contagem de números por quadrante em todas as apostas
    final int tamQuadrante = (lottery.maxNumber / 4).ceil();
    final Map<int, int> contagemQuadrante = {1: 0, 2: 0, 3: 0, 4: 0};

    for (final aposta in bets) {
      final List<int> dezenas = isTimemania
          ? aposta.sublist(0, aposta.length - 1)
          : aposta;
      for (final numero in dezenas) {
        final int q = numero <= tamQuadrante
            ? 1
            : numero <= tamQuadrante * 2
                ? 2
                : numero <= tamQuadrante * 3
                    ? 3
                    : 4;
        contagemQuadrante[q] = (contagemQuadrante[q] ?? 0) + 1;
      }
    }

    final int totalDezenas = contagemQuadrante.values.fold(0, (a, b) => a + b);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Distribuição por Quadrante',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Cada quadrante = $tamQuadrante números do volante',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 14),
            ...List.generate(4, (i) {
              final int q = i + 1;
              final int count = contagemQuadrante[q] ?? 0;
              final double percent =
                  totalDezenas > 0 ? (count / totalDezenas) * 100 : 0;
              final int inicio = (q - 1) * tamQuadrante + 1;
              final int fim = q == 4 ? lottery.maxNumber : q * tamQuadrante;
              final Color cor = [
                Colors.indigo,
                Colors.teal,
                Colors.deepOrange,
                Colors.pink,
              ][i];

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 72,
                      child: Text(
                        'Q$q ($inicio–$fim)',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Stack(
                        children: [
                          Container(
                            height: 22,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: (percent / 100).clamp(0.0, 1.0),
                            child: Container(
                              height: 22,
                              decoration: BoxDecoration(
                                color: cor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '$count (${percent.toStringAsFixed(1)}%)',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // ── Frequência de todos os números (gráfico de barras) ────────────────────

  Widget _buildFrequencyCard(BuildContext context, BetStatistics stats) {
    if (stats.numberFrequency.isEmpty) return const SizedBox.shrink();

    // Ordenar por número
    final List<MapEntry<int, int>> entradas =
        stats.numberFrequency.entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key));

    final int maxFreq = entradas.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Frequência dos Números Gerados',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Números que apareceram em suas apostas',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 14),
            // Gráfico de barras horizontal para cada número gerado
            ...entradas.map((entry) {
              final int numero = entry.key;
              final int freq = entry.value;
              final double percent = maxFreq > 0 ? freq / maxFreq : 0;

              // Cor por quadrante do número
              final int tamQ = (lottery.maxNumber / 4).ceil();
              final int q = numero <= tamQ ? 1 : numero <= tamQ * 2 ? 2 : numero <= tamQ * 3 ? 3 : 4;
              final Color cor = [
                Colors.indigo,
                Colors.teal,
                Colors.deepOrange,
                Colors.pink,
              ][q - 1];

              return Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Row(
                  children: [
                    SizedBox(
                      width: 28,
                      child: Text(
                        numero.toString().padLeft(2, '0'),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Stack(
                        children: [
                          Container(
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: percent,
                            child: Container(
                              height: 20,
                              decoration: BoxDecoration(
                                color: cor.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$freq×',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }),
            // Legenda de quadrantes
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 4,
              children: [
                for (int i = 0; i < 4; i++)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: [Colors.indigo, Colors.teal, Colors.deepOrange, Colors.pink][i],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 3),
                      Text('Q${i + 1}', style: const TextStyle(fontSize: 11)),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Times do coração (Timemania) ──────────────────────────────────────────

  Widget _buildTimesCard(BuildContext context) {
    // Coleta o time (último elemento de cada aposta da Timemania)
    final Map<int, String> times = {};
    for (final aposta in bets) {
      if (aposta.isNotEmpty) {
        final int indiceTime = aposta.last;
        final String nome = LotteryData.timemaniaClubs[indiceTime] ?? 'Time $indiceTime';
        times[indiceTime] = nome;
      }
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Times do Coração',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: bets.asMap().entries.map((entry) {
                final int idx = entry.key;
                final List<int> aposta = entry.value;
                final int indiceTime = aposta.last;
                final String nomeTime =
                    LotteryData.timemaniaClubs[indiceTime] ?? 'Time $indiceTime';
                return Chip(
                  avatar: CircleAvatar(
                    backgroundColor: Colors.orange.shade700,
                    child: Text(
                      (idx + 1).toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  label: Text(
                    '⚽ $nomeTime',
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: Colors.orange.shade50,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
