// =========================================================================
// ARQUIVO: lib/modules/generator/presenter/widgets/api_status_dialog.dart
// =========================================================================
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import '../../data/datasources/caixa_api_provider.dart';
import '../../domain/entities/mega_sena_draw.dart';

/// Diagnóstico ao vivo da API da Caixa — acionado pelo easter egg de 15
/// toques no rodapé "Sobre" (ver [AboutSection]).
Future<void> showApiStatusDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (_) => const ApiStatusDialog(),
  );
}

class ApiStatusDialog extends StatefulWidget {
  const ApiStatusDialog({Key? key}) : super(key: key);

  @override
  State<ApiStatusDialog> createState() => _ApiStatusDialogState();
}

class _ApiStatusDialogState extends State<ApiStatusDialog> {
  late final CaixaApiProvider _apiProvider = Modular.get<CaixaApiProvider>();

  bool _loading = true;
  bool _online = false;
  String _message = '';
  int? _responseMs;
  MegaSenaDraw? _draw;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    final stopwatch = Stopwatch()..start();
    bool online = false;
    MegaSenaDraw? draw;
    String message = '';

    try {
      draw = await _apiProvider.fetchLatestMegaSena();
      online = true;
    } on CaixaApiException catch (e) {
      message = 'HTTP ${e.statusCode ?? "desconhecido"} — ${e.message}';
    } on FormatException {
      message = 'Resposta em formato inesperado.';
    } on TimeoutException {
      message = 'Tempo limite excedido.';
    } on SocketException {
      message = 'Sem conexão com a internet.';
    } catch (e) {
      message = e.toString();
    }

    stopwatch.stop();
    if (!mounted) return;
    setState(() {
      _loading = false;
      _online = online;
      _draw = draw;
      _message = message;
      _responseMs = stopwatch.elapsedMilliseconds;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.dns_outlined, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          const Text('Status da API'),
        ],
      ),
      content: SizedBox(
        width: 320,
        child: _loading ? _buildLoading() : _buildResult(context),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fechar'),
        ),
      ],
    );
  }

  Widget _buildLoading() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Row(
        children: [
          SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5)),
          SizedBox(width: 16),
          Expanded(child: Text('Consultando API da Caixa...')),
        ],
      ),
    );
  }

  Widget _buildResult(BuildContext context) {
    final color = _online ? Colors.green.shade700 : Colors.red.shade700;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(_online ? Icons.check_circle : Icons.error, color: color),
            const SizedBox(width: 8),
            Text(
              _online ? 'Online' : 'Indisponível',
              style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _statusRow('Endpoint', _apiProvider.megaSenaEndpoint),
        if (_responseMs != null) _statusRow('Tempo de resposta', '$_responseMs ms'),
        if (_online && _draw != null) ...[
          _statusRow('Último concurso', '${_draw!.concurso}'),
          _statusRow('Data do sorteio', _draw!.dataApuracao),
        ],
        if (!_online) ...[
          _statusRow('Motivo', _message),
          const SizedBox(height: 8),
          Text(
            'O app continua funcionando normalmente com os dados salvos em cache.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }

  Widget _statusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
