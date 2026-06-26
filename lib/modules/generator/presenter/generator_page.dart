// =========================================================================
// ARQUIVO: lib/modules/generator/presenter/generator_page.dart
// =========================================================================
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:share_plus/share_plus.dart';
import '../../../app/app_widget.dart';
import '../data/number_lists.dart';
import './bloc/generator_bloc.dart';
import '../domain/entities/lottery.dart';
import '../domain/usecases/generate_bets.dart';
import './widgets/bet_card.dart';

class GeneratorPage extends StatefulWidget {
  const GeneratorPage({Key? key}) : super(key: key);

  @override
  State<GeneratorPage> createState() => _GeneratorPageState();
}

class _GeneratorPageState extends State<GeneratorPage> {
  final _bloc = Modular.get<GeneratorBloc>();
  final _numberOfBetsController = TextEditingController(text: '1');
  LotteryType _selectedLottery = LotteryType.megaSena;
  GenerationStrategy _selectedStrategy = GenerationStrategy.frequentOnly;

  @override
  void dispose() {
    _numberOfBetsController.dispose();
    _bloc.close();
    super.dispose();
  }

  Widget _buildDisclaimerBanner(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFB71C1C), Color(0xFFE53935)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x55B71C1C),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '⚠️ AVISO IMPORTANTE',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Este aplicativo NÃO garante ganhos. '
                    'Jogue com responsabilidade. '
                    'A probabilidade de acertar a Mega-Sena é de 1 em 50 milhões — '
                    'nenhuma estratégia altera esse número.',
                    style: TextStyle(
                      color: Colors.red.shade50,
                      fontSize: 12,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _copiarPix(BuildContext context) {
    Clipboard.setData(const ClipboardData(text: 'ed6bc858-5f8b-466d-b212-d0f59b583238'));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Chave Pix copiada! 💚'),
          ],
        ),
        backgroundColor: const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildPixCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF43A047)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x441B5E20),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _copiarPix(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('💚', style: TextStyle(fontSize: 22)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ganhou? Me presenteie com qualquer valor! 🎉',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 12.5,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'ed6bc858-5f8b-466d-b212-d0f59b583238',
                        style: TextStyle(
                          color: Colors.green.shade100,
                          fontSize: 11,
                          fontFamily: 'monospace',
                          letterSpacing: 0.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '👆 Toque para copiar',
                        style: TextStyle(
                          color: Colors.green.shade200,
                          fontSize: 10,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  children: [
                    Icon(Icons.copy, color: Colors.green.shade100, size: 18),
                    const SizedBox(height: 2),
                    Text(
                      'Copiar',
                      style: TextStyle(color: Colors.green.shade100, fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _compartilharApostas(List<List<int>> bets, String lotteryName) {
    final buffer = StringBuffer();
    buffer.writeln('🍀 Minhas Apostas - $lotteryName');
    buffer.writeln('');
    
    for (int i = 0; i < bets.length; i++) {
      final numerosFormatados = bets[i].map((n) => n.toString().padLeft(2, '0')).join(', ');
      buffer.writeln('Aposta ${(i + 1).toString().padLeft(2, '0')}: $numerosFormatados');
    }
    
    buffer.writeln('');
    buffer.writeln('Gerado pelo app Gerador de Apostas');
    
    Share.share(buffer.toString(), subject: 'Minhas Apostas - $lotteryName');
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('🍀 Gerador de Apostas'),
        actions: [
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              final themeManager = ThemeManagerProvider.of(context);
              themeManager?.toggleTheme();
            },
            tooltip: Theme.of(context).brightness == Brightness.dark
                ? 'Modo claro'
                : 'Modo escuro',
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Modular.to.pushNamed('/history');
            },
            tooltip: 'Histórico',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildDisclaimerBanner(context),
            const SizedBox(height: 12),
            _buildPixCard(context),
            const SizedBox(height: 16),
            _buildOptionsCard(context),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.casino, color: Colors.white),
              label: const Text('GERAR APOSTAS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                final int numberOfBets = int.tryParse(_numberOfBetsController.text) ?? 1;
                _bloc.add(BetsGenerated(
                  lotteryType: _selectedLottery,
                  numberOfBets: numberOfBets.clamp(1, 20),
                  strategy: _selectedStrategy,
                ));
              },
            ),
            const SizedBox(height: 24),
            _buildResults(),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionsCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('1. Escolha a loteria', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<LotteryType>(
              initialValue: _selectedLottery,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              items: LotteryData.allLotteries.map((lottery) {
                return DropdownMenuItem(
                  value: lottery.type,
                  child: Text(lottery.name),
                );
              }).toList(),
              onChanged: (type) {
                if (type != null) {
                  setState(() => _selectedLottery = type);
                  // Dispara evento no BLoC para limpar apostas da loteria anterior
                  _bloc.add(LotteryTypeChanged(lotteryType: type));
                }
              },
            ),
            const SizedBox(height: 20),
            Text('2. Estratégia de geração', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<GenerationStrategy>(
              initialValue: _selectedStrategy,
              // isExpanded permite que o texto ocupe toda a largura sem estourar
              isExpanded: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              items: const [
                DropdownMenuItem(
                  value: GenerationStrategy.frequentOnly,
                  child: Text(
                    'Apenas números frequentes',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                DropdownMenuItem(
                  value: GenerationStrategy.allNumbers,
                  child: Text(
                    'Todos os números',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                DropdownMenuItem(
                  value: GenerationStrategy.mixed,
                  child: Text(
                    'Misto (50% frequentes + 50% aleatórios)',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                DropdownMenuItem(
                  value: GenerationStrategy.sistemaMatematico,
                  child: Text(
                    '🎯 Sistema Matemático (Wheeling + Filtros)',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                DropdownMenuItem(
                  value: GenerationStrategy.entropyFrequent,
                  child: Text(
                    '🔢 Entropia Shannon — Frequentes Ponderados',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                DropdownMenuItem(
                  value: GenerationStrategy.entropyMixed,
                  child: Text(
                    '🌀 Entropia Shannon — Misto Caótico',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              onChanged: (strategy) {
                if (strategy != null) {
                  setState(() => _selectedStrategy = strategy);
                }
              },
            ),
            const SizedBox(height: 8),
            Text(
              _getStrategyDescription(),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 20),
            Text('3. Quantas apostas? (1-20)', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: _numberOfBetsController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                hintText: 'Ex: 5',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStrategyDescription() {
    switch (_selectedStrategy) {
      case GenerationStrategy.frequentOnly:
        return 'Usa apenas os números mais sorteados historicamente.';
      case GenerationStrategy.allNumbers:
        return 'Usa todos os números disponíveis da loteria (mais honesto matematicamente).';
      case GenerationStrategy.mixed:
        return 'Combina 50% de frequentes com 50% de números aleatórios.';
      case GenerationStrategy.sistemaMatematico:
        return '🎯 Wheeling + Filtros: garante balanceamento par/ímpar e '
            'soma no range ótimo histórico. Maximiza acertos de quadra/quina.';
      case GenerationStrategy.entropyFrequent:
        return '🔢 Entropia de Shannon: pondera cada dezena pelo grau de '
            '"caos" histórico de seus aparecimentos (H = -ΣP·log₂P). '
            'Dezenas com frequência bem distribuída no tempo recebem peso maior.';
      case GenerationStrategy.entropyMixed:
        return '🌀 Entropia Mista: usa pesos de entropia sobre todo o universo '
            'e rejeita apostas cuja entropia total seja < 70% do máximo possível, '
            'garantindo combinações matematicamente imprevisíveis.';
    }
  }

  Widget _buildResults() {
    return BlocBuilder<GeneratorBloc, GeneratorState>(
      bloc: _bloc,
      builder: (context, state) {
        if (state is GeneratorLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is GeneratorSuccess) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Apostas Geradas (${state.lotteryName})',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.compare_arrows),
                        onPressed: () {
                          final lottery = Lottery.fromType(_selectedLottery);
                          Modular.to.pushNamed('/comparison', arguments: {
                            'bets': state.bets,
                            'lottery': lottery,
                          });
                        },
                        tooltip: 'Comparar com resultado',
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      IconButton(
                        icon: const Icon(Icons.bar_chart),
                        onPressed: () {
                          final lottery = Lottery.fromType(_selectedLottery);
                          Modular.to.pushNamed('/statistics', arguments: {
                            'bets': state.bets,
                            'lottery': lottery,
                          });
                        },
                        tooltip: 'Ver estatísticas',
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      IconButton(
                        icon: const Icon(Icons.share),
                        onPressed: () => _compartilharApostas(state.bets, state.lotteryName),
                        tooltip: 'Compartilhar todas',
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: state.bets.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final lottery = Lottery.fromType(_selectedLottery);
                  final lotteryColor = lottery.type == LotteryType.lotofacil 
                      ? Colors.purple.shade700 
                      : lottery.type == LotteryType.quina 
                          ? Colors.blue.shade800 
                          : lottery.type == LotteryType.timemania
                              ? Colors.orange.shade800
                              : Theme.of(context).colorScheme.primary;

                  String? teamName;
                  if (lottery.type == LotteryType.timemania) {
                    final bet = state.bets[index];
                    final teamIndex = bet.last;
                    teamName = LotteryData.timemaniaClubs[teamIndex];
                  }

                  return BetCard(
                    betIndex: index + 1,
                    numbers: state.bets[index],
                    lotteryColor: lotteryColor,
                    teamName: teamName,
                  );
                },
              ),
              if (state.avisoMatematico != null) ...[  
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    border: Border.all(color: Colors.amber.shade700),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, color: Colors.amber.shade800, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          state.avisoMatematico!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.amber.shade900,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          );
        }
        if (state is GeneratorFailure) {
          return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
        }
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Escolha a loteria, a quantidade e pressione o botão para gerar suas apostas.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
        );
      },
    );
  }
}