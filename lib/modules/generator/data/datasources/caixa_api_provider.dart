// =========================================================================
// ARQUIVO: lib/modules/generator/data/datasources/caixa_api_provider.dart
// =========================================================================
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/mega_sena_draw.dart';

/// Erro de negócio para respostas HTTP não-2xx da API da Caixa.
/// Não é [SocketException]/[TimeoutException]/[FormatException] pois essas já
/// têm significado próprio (rede indisponível, lenta, ou payload inesperado).
class CaixaApiException implements Exception {
  final String message;
  final int? statusCode;

  CaixaApiException(this.message, {this.statusCode});

  @override
  String toString() =>
      'CaixaApiException: $message${statusCode != null ? ' (status $statusCode)' : ''}';
}

/// Cliente HTTP para a API não-oficial (engenharia reversa) da Caixa.
/// Não possui documentação pública — a estrutura do payload pode mudar sem aviso,
/// por isso todo parsing fica isolado em [MegaSenaDraw.fromJson].
class CaixaApiProvider {
  static const String _megaSenaUrl =
      'https://servicebus2.caixa.gov.br/portaldeloterias/api/megasena';

  final http.Client _client;
  final Duration timeout;

  CaixaApiProvider({http.Client? client, this.timeout = const Duration(seconds: 8)})
      : _client = client ?? http.Client();

  /// Busca o último concurso da Mega-Sena.
  /// Lança [TimeoutException] em caso de demora excessiva, [CaixaApiException]
  /// para status HTTP != 200, e [FormatException] se o payload não puder ser
  /// interpretado — o repositório é responsável por tratar essas exceções.
  Future<MegaSenaDraw> fetchLatestMegaSena() async {
    final response = await _client.get(Uri.parse(_megaSenaUrl)).timeout(timeout);

    if (response.statusCode != 200) {
      throw CaixaApiException(
        'Resposta inesperada da API da Caixa',
        statusCode: response.statusCode,
      );
    }

    final Map<String, dynamic> json;
    try {
      json = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw const FormatException('Payload da API da Caixa não é um JSON válido');
    }

    return MegaSenaDraw.fromJson(json);
  }
}
