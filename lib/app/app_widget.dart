// =========================================================================
// ARQUIVO: lib/app/app_widget.dart
// =========================================================================
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'theme_manager.dart';

class AppWidget extends StatefulWidget {
  const AppWidget({Key? key}) : super(key: key);

  @override
  State<AppWidget> createState() => _AppWidgetState();
}

class _AppWidgetState extends State<AppWidget> {
  final ThemeManager _themeManager = ThemeManager();

  @override
  void dispose() {
    _themeManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _themeManager,
      builder: (context, _) {
        return MaterialApp.router(
          title: 'Gerador Mega Sena',
          debugShowCheckedModeBanner: false,
          theme: ThemeManager.lightTheme,
          darkTheme: ThemeManager.darkTheme,
          themeMode: _themeManager.themeMode,
          routerConfig: Modular.routerConfig,
          builder: (context, child) {
            // Disponibilizar ThemeManager para toda a árvore de widgets
            return ThemeManagerProvider(
              themeManager: _themeManager,
              child: child!,
            );
          },
        );
      },
    );
  }
}

// Provider para disponibilizar ThemeManager
class ThemeManagerProvider extends InheritedWidget {
  final ThemeManager themeManager;

  const ThemeManagerProvider({
    super.key,
    required this.themeManager,
    required super.child,
  });

  static ThemeManager? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ThemeManagerProvider>()?.themeManager;
  }

  @override
  bool updateShouldNotify(ThemeManagerProvider oldWidget) {
    return themeManager != oldWidget.themeManager;
  }
}
