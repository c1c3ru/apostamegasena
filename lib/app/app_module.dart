// =========================================================================
// ARQUIVO: lib/app/app_module.dart
// =========================================================================
import 'package:flutter_modular/flutter_modular.dart';
import '../modules/generator/generator_module.dart';

class AppModule extends Module {
  @override
  void binds(i) {}

  @override
  void routes(r) {
    r.module('/', module: GeneratorModule());
  }
}