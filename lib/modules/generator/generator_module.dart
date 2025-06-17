// =========================================================================
// ARQUIVO: lib/modules/generator/generator_module.dart
// =========================================================================
import 'package:flutter_modular/flutter_modular.dart';
import './domain/usecases/generate_bets.dart';
import './presenter/bloc/generator_bloc.dart';
import './presenter/generator_page.dart';

class GeneratorModule extends Module {
  @override
  void binds(i) {
    // Usecase
    i.addSingleton(GenerateBetsUsecase.new);
    // BLoC
    i.addLazySingleton(GeneratorBloc.new);
  }

  @override
  void routes(r) {
    r.child('/', child: (context) => const GeneratorPage());
  }
}