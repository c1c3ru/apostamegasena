// =========================================================================
// ARQUIVO: lib/modules/generator/domain/entities/bet_history.dart
// =========================================================================
import 'package:equatable/equatable.dart';
import 'lottery.dart';

class BetHistory extends Equatable {
  final String id;
  final LotteryType lotteryType;
  final String lotteryName;
  final List<List<int>> bets;
  final DateTime timestamp;
  final String strategy;

  const BetHistory({
    required this.id,
    required this.lotteryType,
    required this.lotteryName,
    required this.bets,
    required this.timestamp,
    required this.strategy,
  });

  // Converter para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lotteryType': lotteryType.name,
      'lotteryName': lotteryName,
      'bets': bets,
      'timestamp': timestamp.toIso8601String(),
      'strategy': strategy,
    };
  }

  // Criar a partir de JSON
  factory BetHistory.fromJson(Map<String, dynamic> json) {
    return BetHistory(
      id: json['id'] as String,
      lotteryType: LotteryType.values.firstWhere(
        (e) => e.name == json['lotteryType'],
      ),
      lotteryName: json['lotteryName'] as String,
      bets: (json['bets'] as List)
          .map((bet) => (bet as List).map((n) => n as int).toList())
          .toList(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      strategy: json['strategy'] as String,
    );
  }

  @override
  List<Object?> get props => [id, lotteryType, lotteryName, bets, timestamp, strategy];
}
