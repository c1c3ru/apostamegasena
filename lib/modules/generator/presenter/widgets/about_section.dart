// =========================================================================
// ARQUIVO: lib/modules/generator/presenter/widgets/about_section.dart
// =========================================================================
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'api_status_dialog.dart';

/// Rodapé "Sobre" com nome e versão do app. Tocar 15 vezes seguidas (em até
/// 2s entre cada toque) revela o status ao vivo da API da Caixa — um
/// diagnóstico que não interessa ao usuário comum, por isso fica escondido
/// atrás do easter egg em vez de um botão visível.
class AboutSection extends StatefulWidget {
  const AboutSection({Key? key}) : super(key: key);

  @override
  State<AboutSection> createState() => _AboutSectionState();
}

class _AboutSectionState extends State<AboutSection> {
  static const int _tapsToUnlock = 15;
  static const Duration _tapTimeout = Duration(seconds: 2);

  PackageInfo? _packageInfo;
  int _tapCount = 0;
  DateTime? _lastTap;

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      if (mounted) setState(() => _packageInfo = info);
    });
  }

  void _onTap() {
    final now = DateTime.now();
    if (_lastTap == null || now.difference(_lastTap!) > _tapTimeout) {
      _tapCount = 0;
    }
    _lastTap = now;
    _tapCount++;

    final remaining = _tapsToUnlock - _tapCount;
    if (remaining <= 0) {
      _tapCount = 0;
      showApiStatusDialog(context);
      return;
    }
    if (remaining <= 5) {
      final label = remaining == 1 ? 'Falta 1 toque' : 'Faltam $remaining toques';
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('$label para ver o status da API'),
            duration: const Duration(milliseconds: 700),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final info = _packageInfo;
    final versionLabel =
        info == null ? '...' : 'Versão ${info.version} (build ${info.buildNumber})';

    return InkWell(
      onTap: _onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Text(
              'Gerador de Apostas',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 2),
            Text(versionLabel, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
