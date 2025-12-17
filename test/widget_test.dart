// =========================================================================
// ARQUIVO: test/widget_test.dart
// =========================================================================
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gerador_de_apostas/app/app_widget.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:gerador_de_apostas/app/app_module.dart';

void main() {
  testWidgets('Deve exibir título do app corretamente', (WidgetTester tester) async {
    // Arrange & Act
    await tester.pumpWidget(ModularApp(module: AppModule(), child: const AppWidget()));

    // Assert
    expect(find.text('🍀 Gerador de Apostas'), findsOneWidget);
  });

  testWidgets('Deve exibir botão de gerar apostas', (WidgetTester tester) async {
    // Arrange & Act
    await tester.pumpWidget(ModularApp(module: AppModule(), child: const AppWidget()));

    // Assert
    expect(find.text('GERAR APOSTAS'), findsOneWidget);
  });

  testWidgets('Deve exibir dropdown de seleção de loteria', (WidgetTester tester) async {
    // Arrange & Act
    await tester.pumpWidget(ModularApp(module: AppModule(), child: const AppWidget()));

    // Assert
    expect(find.byType(DropdownButtonFormField<dynamic>), findsOneWidget);
  });
}
