// =========================================================================
// ARQUIVO: lib/modules/generator/presenter/generator_page.dart
// =========================================================================
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import '../data/number_lists.dart';
import './bloc/generator_bloc.dart';
import '../domain/entities/lottery.dart';
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

  @override
  void dispose() {
    _numberOfBetsController.dispose();
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('🍀 Gerador de Apostas'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
              value: _selectedLottery,
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
                }
              },
            ),
            const SizedBox(height: 20),
            Text('2. Quantas apostas? (1-20)', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'As apostas são geradas usando os números mais recorrentes de cada concurso.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
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
               Text(
                'Apostas Geradas (${state.lotteryName})',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: state.bets.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final lottery = Lottery.fromType(_selectedLottery);
                  return BetCard(
                    betIndex: index + 1,
                    numbers: state.bets[index],
                    lotteryColor: lottery.type == LotteryType.lotofacil ? Colors.purple.shade700 : lottery.type == LotteryType.quina ? Colors.blue.shade800 : Theme.of(context).colorScheme.primary,
                  );
                },
              ),
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