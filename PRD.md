# PRD — Diagnóstico e Correção do Crash na Inicialização

## Problema
O APK fecha imediatamente ao ser aberto no celular Android.

## Arquivos Afetados
- `lib/main.dart` — entrypoint
- `lib/app/app_widget.dart` — widget raiz
- `lib/app/theme_manager.dart` — carregamento async de tema
- `lib/modules/generator/generator_module.dart` — registro de rotas (**JÁ CORRIGIDO**)
- `android/app/src/main/AndroidManifest.xml` — permissões
- `android/gradle.properties` — configuração de memória
- `android/key.properties` — assinatura

## Bugs Identificados

### BUG 1 — CRÍTICO (já corrigido) 
`r.args.data` nas rotas `/statistics` e `/comparison` era avaliado
no momento do registro do módulo (não na navegação), causando crash
por cast null na inicialização. Corrigido para `Modular.args.data`.

### BUG 2 — ThemeManager notifyListeners() em contexto async inseguro
`ThemeManager()` construtor chama `_loadTheme()` async. Em modo release,
o `notifyListeners()` pode ser chamado antes do widget tree estar pronto.
Padrão correto: inicializar SharedPreferences no `main()` com `WidgetsFlutterBinding.ensureInitialized()`.

### BUG 3 — main() sem ensureInitialized
```dart
// ATUAL (problemático em release):
void main() => runApp(ModularApp(module: AppModule(), child: const AppWidget()));

// CORRETO:
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ModularApp(module: AppModule(), child: const AppWidget()));
}
```
Sem `ensureInitialized()`, qualquer plugin (SharedPreferences, share_plus)
que tenta acessar platform channels antes do binding pode crashar o app.
Em debug isso às vezes funciona por acaso; em release é crash garantido.

### BUG 4 — share_plus versão desatualizada (7.2.2 vs 13.2.0 atual)
A versão 7.x do share_plus tem bugs conhecidos no Android 12+.
A versão atual é 13.x. O pubspec.yaml tem `^7.2.1`.

## Padrão existente no projeto
- Flutter 3.41.2 / Dart 3.11.0
- flutter_modular: ^6.3.2
- flutter_bloc: ^8.1.3
- SharedPreferences acessado sem await antes do runApp

## Snippets de referência

### Correção do main.dart (padrão Flutter para plugins):
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ModularApp(module: AppModule(), child: const AppWidget()));
}
```

### Atualizar share_plus no pubspec.yaml:
```yaml
share_plus: ^9.0.0  # versão estável compatível com Flutter 3.41
```

## Verificação
Após as correções:
1. `flutter clean && flutter pub get`
2. `flutter build apk --release`
3. Instalar no celular e verificar se abre normalmente
