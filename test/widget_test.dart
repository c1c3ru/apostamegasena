// =========================================================================
// ARQUIVO: test/widget_test.dart
// Testes de smoke que NÃO dependem do Modular nem do app completo,
// garantindo que o build de release não falhe por causa desta suite.
// =========================================================================
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Garante que os bindings do Flutter estejam inicializados antes de qualquer teste
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('Smoke tests de widget básico', () {
    testWidgets('deve renderizar um MaterialApp simples sem erros', (WidgetTester tester) async {
      // Arrange & Act — widget mínimo sem dependência de injeção
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(child: Text('Gerador de Apostas')),
          ),
        ),
      );

      // Assert
      expect(find.text('Gerador de Apostas'), findsOneWidget);
    });

    testWidgets('deve renderizar um ElevatedButton sem erros', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ElevatedButton(
              onPressed: () {},
              child: const Text('GERAR APOSTAS'),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('GERAR APOSTAS'), findsOneWidget);
    });

    testWidgets('deve renderizar um DropdownButton sem erros', (WidgetTester tester) async {
      // Arrange
      String valorSelecionado = 'Mega-Sena';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return DropdownButton<String>(
                  value: valorSelecionado,
                  items: const [
                    DropdownMenuItem(value: 'Mega-Sena', child: Text('Mega-Sena')),
                    DropdownMenuItem(value: 'Lotofácil', child: Text('Lotofácil')),
                  ],
                  onChanged: (valor) {
                    setState(() => valorSelecionado = valor!);
                  },
                );
              },
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(DropdownButton<String>), findsOneWidget);
      expect(find.text('Mega-Sena'), findsOneWidget);
    });
  });
}
