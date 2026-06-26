// =========================================================================
// ARQUIVO: lib/main.dart
// =========================================================================
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'app/app_module.dart';
import 'app/app_widget.dart';

// Necessário para garantir que os plugins (SharedPreferences, share_plus)
// sejam inicializados corretamente antes do runApp em modo release.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ModularApp(module: AppModule(), child: const AppWidget()));
}