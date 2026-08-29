// =========================================================================
// ARQUIVO: test/data/repositories/lottery_repository_test.dart
// =========================================================================
import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gerador_de_apostas/modules/generator/data/datasources/caixa_api_provider.dart';
import 'package:gerador_de_apostas/modules/generator/data/number_lists.dart';
import 'package:gerador_de_apostas/modules/generator/data/repositories/lottery_repository.dart';
import 'package:gerador_de_apostas/modules/generator/domain/entities/mega_sena_draw.dart';

/// Provider de teste que sempre lança a exceção informada — simula API fora
/// do ar, timeout, ou payload mudando de formato.
class _FailingProvider extends CaixaApiProvider {
  final Exception Function() build;
  int callCount = 0;

  _FailingProvider(this.build);

  @override
  Future<MegaSenaDraw> fetchLatestMegaSena() async {
    callCount++;
    throw build();
  }
}

/// Provider de teste que sempre retorna o concurso informado.
class _SucceedingProvider extends CaixaApiProvider {
  final MegaSenaDraw draw;
  int callCount = 0;

  _SucceedingProvider(this.draw);

  @override
  Future<MegaSenaDraw> fetchLatestMegaSena() async {
    callCount++;
    return draw;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    const channel = MethodChannel('plugins.flutter.io/shared_preferences');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
      if (call.method == 'getAll') return <String, Object>{};
      if (call.method == 'setString') return true;
      if (call.method == 'remove') return true;
      return null;
    });
  });

  group('LotteryRepository', () {
    test('em caso de sucesso, calcula frequências a partir do concurso retornado', () async {
      final provider = _SucceedingProvider(
        const MegaSenaDraw(concurso: 1, dezenas: [1, 2, 3, 4, 5, 6], dataApuracao: '01/01/2000'),
      );
      final repository = LotteryRepository(provider);

      final result = await repository.refreshMegaSenaFrequencies();

      expect(result.fromCache, isFalse);
      expect(result.lastDraw?.concurso, 1);
      // As 6 dezenas sorteadas ficam empatadas em frequência 1 e vêm primeiro;
      // o restante (frequência 0) completa a lista de 60 números.
      expect(result.mostFrequentNumbers.take(6).toSet(), {1, 2, 3, 4, 5, 6});
      expect(result.mostFrequentNumbers.length, 60);
    });

    test('em erro 404, tenta até o limite e cai para os dados estáticos quando não há cache', () async {
      final provider = _FailingProvider(() => CaixaApiException('não encontrado', statusCode: 404));
      final repository = LotteryRepository(provider);

      final result = await repository.refreshMegaSenaFrequencies();

      expect(result.fromCache, isTrue);
      expect(provider.callCount, LotteryRepository.maxRetryAttempts);
      expect(result.mostFrequentNumbers, LotteryData.megaSena.mostFrequentNumbers);
    });

    test('em erro 500, cai para o cache após esgotar as tentativas', () async {
      final provider = _FailingProvider(() => CaixaApiException('erro interno', statusCode: 500));
      final repository = LotteryRepository(provider);

      final result = await repository.refreshMegaSenaFrequencies();

      expect(result.fromCache, isTrue);
      expect(provider.callCount, LotteryRepository.maxRetryAttempts);
    });

    test('em timeout, cai para o cache após esgotar as tentativas', () async {
      final provider = _FailingProvider(() => TimeoutException('demorou demais'));
      final repository = LotteryRepository(provider);

      final result = await repository.refreshMegaSenaFrequencies();

      expect(result.fromCache, isTrue);
      expect(provider.callCount, LotteryRepository.maxRetryAttempts);
    });

    test('limite de tentativas configurado é 5', () {
      expect(LotteryRepository.maxRetryAttempts, 5);
    });

    test('usa o cache do último concurso válido quando uma atualização posterior falha', () async {
      final succeeding = _SucceedingProvider(
        const MegaSenaDraw(concurso: 42, dezenas: [7, 8, 9, 10, 11, 12], dataApuracao: '02/02/2020'),
      );
      final firstRepository = LotteryRepository(succeeding);
      final firstResult = await firstRepository.refreshMegaSenaFrequencies();
      expect(firstResult.fromCache, isFalse);

      // Nova instância do repositório (simula um novo app start) com a API fora do ar.
      final failing = _FailingProvider(() => const SocketException('sem rede'));
      final secondRepository = LotteryRepository(failing);
      final secondResult = await secondRepository.refreshMegaSenaFrequencies();

      expect(secondResult.fromCache, isTrue);
      expect(secondResult.lastDraw?.concurso, 42);
      expect(secondResult.mostFrequentNumbers.take(6).toSet(), {7, 8, 9, 10, 11, 12});
    });

    test('não insiste quando o payload vem em formato inesperado (FormatException)', () async {
      final provider = _FailingProvider(() => const FormatException('json mudou'));
      final repository = LotteryRepository(provider);

      final result = await repository.refreshMegaSenaFrequencies();

      expect(result.fromCache, isTrue);
      expect(provider.callCount, 1);
    });
  });
}
