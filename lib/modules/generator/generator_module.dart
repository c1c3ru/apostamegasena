// =========================================================================
// ARQUIVO: lib/modules/generator/generator_module.dart
// =========================================================================
import 'package:flutter_modular/flutter_modular.dart';
import './data/repositories/bet_history_repository.dart';
import './domain/usecases/generate_bets.dart';
import './presenter/bloc/generator_bloc.dart';
import './presenter/generator_page.dart';
import './presenter/history_page.dart';
import './presenter/statistics_page.dart';
import './presenter/comparison_page.dart';

class GeneratorModule extends Module {
  @override
  void binds(i) {
    // Repository
    i.addSingleton(BetHistoryRepository.new);
    // Usecase
    i.addSingleton(GenerateBetsUsecase.new);
    // BLoC
    i.addLazySingleton(GeneratorBloc.new);
  }

  @override
  void routes(r) {
    r.child('/', child: (context) => const GeneratorPage());
    r.child('/history', child: (context) => HistoryPage(repository: Modular.get<BetHistoryRepository>()));
    r.child('/statistics', child: (context) {
      final args = r.args.data as Map<String, dynamic>;
      return StatisticsPage(
        bets: args['bets'] as List<List<int>>,
        lottery: args['lottery'],
      );
    });
    r.child('/comparison', child: (context) {
      final args = r.args.data as Map<String, dynamic>;
      return ComparisonPage(
        bets: args['bets'] as List<List<int>>,
        lottery: args['lottery'],
      );
    });
  }
}