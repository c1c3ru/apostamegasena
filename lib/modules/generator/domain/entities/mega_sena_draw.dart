// =========================================================================
// ARQUIVO: lib/modules/generator/domain/entities/mega_sena_draw.dart
// =========================================================================
import 'package:equatable/equatable.dart';

/// Representa um concurso da Mega-Sena obtido da API da Caixa (ou do cache local).
class MegaSenaDraw extends Equatable {
  final int concurso;
  final List<int> dezenas;
  final String dataApuracao;

  const MegaSenaDraw({
    required this.concurso,
    required this.dezenas,
    required this.dataApuracao,
  });

  /// Constrói a partir do payload bruto da API da Caixa.
  /// Lança [FormatException] se a estrutura esperada não for encontrada —
  /// o chamador deve tratar isso como "API mudou/indisponível" e cair para o cache.
  factory MegaSenaDraw.fromJson(Map<String, dynamic> json) {
    try {
      final numero = json['numero'];
      final listaDezenas = json['listaDezenas'] as List<dynamic>;
      final dezenas = listaDezenas.map((d) => int.parse(d.toString())).toList();

      if (numero == null || dezenas.isEmpty) {
        throw const FormatException('Campos obrigatórios ausentes no payload da Mega-Sena');
      }

      return MegaSenaDraw(
        concurso: numero is int ? numero : int.parse(numero.toString()),
        dezenas: dezenas,
        dataApuracao: json['dataApuracao']?.toString() ?? '',
      );
    } on FormatException {
      rethrow;
    } catch (e) {
      throw FormatException('Payload da Mega-Sena em formato inesperado: $e');
    }
  }

  Map<String, dynamic> toJson() => {
        'numero': concurso,
        'listaDezenas': dezenas.map((d) => d.toString()).toList(),
        'dataApuracao': dataApuracao,
      };

  @override
  List<Object?> get props => [concurso, dezenas, dataApuracao];
}
