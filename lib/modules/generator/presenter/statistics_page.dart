// =========================================================================
// ARQUIVO: lib/modules/generator/presenter/statistics_page.dart
// =========================================================================
import 'package:flutter/material.dart';
import '../domain/entities/bet_statistics.dart';
import '../domain/entities/lottery.dart';

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
    final stats = BetStatistics.analyze(bets, lottery.maxNumber);

    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 Análise Estatística'),
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
                  _buildDistributionCard(context, stats, 'Par / Ímpar', 
                    stats.evenCount, stats.oddCount, 
                    stats.evenPercentage, stats.oddPercentage,
                    'Pares', 'Ímpares', Colors.blue, Colors.orange),
                  const SizedBox(height: 16),
                  _buildDistributionCard(context, stats, 'Alto / Baixo',
                    stats.highCount, stats.lowCount,
                    stats.highPercentage, stats.lowPercentage,
                    'Altos (>${(lottery.maxNumber / 2).ceil()})', 
                    'Baixos (≤${(lottery.maxNumber / 2).ceil()})',
                    Colors.green, Colors.purple),
                  const SizedBox(height: 16),
                  _buildFrequencyCard(context, stats),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, BetStatistics stats) {
    return Card(
      elevation: 2,
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
                _buildStatItem(context, 'Números', stats.totalNumbers.toString(), Icons.numbers),
                _buildStatItem(context, 'Únicos', stats.numberFrequency.length.toString(), Icons.filter_list),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildDistributionCard(
    BuildContext context,
    BetStatistics stats,
    String title,
    int count1,
    int count2,
    double percentage1,
    double percentage2,
    String label1,
    String label2,
    Color color1,
    Color color2,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: percentage1.round(),
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: color1,
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(8),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${percentage1.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: percentage2.round(),
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: color2,
                      borderRadius: const BorderRadius.horizontal(
                        right: Radius.circular(8),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${percentage2.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLegendItem(label1, count1, color1),
                _buildLegendItem(label2, count2, color2),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text('$label: $count'),
      ],
    );
  }

  Widget _buildFrequencyCard(BuildContext context, BetStatistics stats) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Frequência de Números',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Mais Frequentes',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: stats.mostFrequentNumbers.map((number) {
                final frequency = stats.numberFrequency[number] ?? 0;
                return Chip(
                  label: Text(
                    '${number.toString().padLeft(2, '0')} ($frequency)',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: Colors.green.shade100,
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Text(
              'Menos Frequentes',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: stats.leastFrequentNumbers.map((number) {
                final frequency = stats.numberFrequency[number] ?? 0;
                return Chip(
                  label: Text(
                    '${number.toString().padLeft(2, '0')} ($frequency)',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: Colors.orange.shade100,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
