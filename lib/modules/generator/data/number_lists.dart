// =========================================================================
// ARQUIVO: lib/modules/generator/data/number_lists.dart
// =========================================================================

import '../domain/entities/lottery.dart';

class LotteryData {
  // Dados atualizados em: Agosto/2026 (concurso 3049, 25/08/2026)
  // Fonte: dados oficiais fornecidos pelo usuário (contagem exata de sorteios
  // por dezena, banco de dados desde o concurso 1 de 11/03/1996)
  static const Lottery megaSena = Lottery(
    type: LotteryType.megaSena,
    name: 'Mega-Sena',
    numbersToPick: 6,
    minNumber: 1,
    maxNumber: 60,
    minNumbersToPick: 6,
    maxNumbersToPick: 20,
    // Todos os 60 números ordenados por frequência (do mais ao menos sorteado)
    mostFrequentNumbers: [
      10, 53, 5, 37, 27, 33, 42, 32, 17, 30,  // Top 10
      38, 34, 11, 4, 43, 44, 35, 23, 46, 56,  // Top 20
      54, 16, 28, 13, 41, 6, 49, 36, 52, 51,  // Top 30
      24, 2, 8, 29, 14, 58, 50, 45, 25, 1,    // Top 40
      20, 60, 19, 59, 39, 9, 18, 47, 40, 57,  // Top 50
      7, 31, 12, 3, 48, 22, 15, 55, 21, 26    // Top 60
    ],
  );

  // Dados atualizados em: Agosto/2026 (concurso 3772, 26/08/2026)
  // Fonte: dados oficiais fornecidos pelo usuário (contagem exata de sorteios
  // por dezena, banco de dados desde o concurso 1 de 29/09/2003)
  static const Lottery lotofacil = Lottery(
    type: LotteryType.lotofacil,
    name: 'Lotofácil',
    numbersToPick: 15,
    minNumber: 1,
    maxNumber: 25,
    minNumbersToPick: 15,
    maxNumbersToPick: 20,
    // Todos os 25 números ordenados por frequência
    mostFrequentNumbers: [
      20, 25, 10, 11, 13, 24, 1, 14, 4, 5,    // Top 10
      3, 12, 2, 9, 15, 22, 21, 18, 19, 7,     // Top 20
      6, 17, 23, 8, 16                        // Top 25
    ],
  );

  // Dados atualizados em: Agosto/2026 (concurso 7102, 26/08/2026)
  // Fonte: dados oficiais fornecidos pelo usuário (contagem exata de sorteios
  // por dezena, banco de dados desde o concurso 1 de 13/03/1994)
  static const Lottery quina = Lottery(
    type: LotteryType.quina,
    name: 'Quina',
    numbersToPick: 5,
    minNumber: 1,
    maxNumber: 80,
    minNumbersToPick: 6,
    maxNumbersToPick: 15,
    // Todos os 80 números ordenados por frequência
    mostFrequentNumbers: [
      4, 26, 52, 49, 44, 29, 16, 31, 56, 42,   // Top 10
      39, 5, 15, 53, 9, 66, 33, 18, 38, 10,    // Top 20
      14, 73, 37, 13, 61, 54, 72, 40, 70, 55,  // Top 30
      12, 74, 64, 45, 19, 60, 6, 79, 71, 75,   // Top 40
      78, 77, 46, 57, 34, 59, 24, 62, 11, 43,  // Top 50
      63, 27, 8, 23, 51, 21, 2, 76, 41, 80,    // Top 60
      36, 32, 69, 17, 7, 28, 50, 22, 35, 30,   // Top 70
      68, 1, 20, 25, 65, 58, 67, 48, 3, 47     // Top 80
    ],
  );

  // Dados atualizados em: Agosto/2026 (concurso 3001, 26/08/2026)
  // Fonte: dados oficiais fornecidos pelo usuário (contagem exata de sorteios
  // por dezena, banco de dados desde o concurso 1 de 06/11/2001)
  // Nota: frequência agrega 1º e 2º sorteios de cada concurso
  static const Lottery duplaSena = Lottery(
    type: LotteryType.duplaSena,
    name: 'Dupla Sena',
    numbersToPick: 6,
    minNumber: 1,
    maxNumber: 50,
    minNumbersToPick: 6,
    maxNumbersToPick: 15,
    // Todos os 50 números ordenados por frequência
    mostFrequentNumbers: [
      36, 30, 39, 18, 46, 35, 31, 11, 49, 33,  // Top 10
      2, 9, 42, 5, 45, 14, 44, 10, 21, 6,      // Top 20
      8, 41, 20, 25, 3, 19, 22, 12, 34, 32,    // Top 30
      4, 50, 47, 43, 23, 38, 7, 15, 13, 28,    // Top 40
      40, 16, 26, 37, 17, 48, 29, 24, 1, 27    // Top 50
    ],
  );

  // Dados atualizados em: Agosto/2026 (concurso 2433, 25/08/2026)
  // Fonte: dados oficiais fornecidos pelo usuário (contagem exata de sorteios
  // por dezena, banco de dados desde o concurso 1 de 01/03/2008)
  static const Lottery timemania = Lottery(
    type: LotteryType.timemania,
    name: 'Timemania',
    numbersToPick: 10,
    minNumber: 1,
    maxNumber: 80,
    minNumbersToPick: 10,
    maxNumbersToPick: 10, // Timemania não permite variação de quantidade
    // Todos os 80 números ordenados por frequência
    mostFrequentNumbers: [
      21, 20, 61, 70, 72, 71, 35, 80, 12, 66,  // Top 10
      4, 65, 50, 11, 6, 41, 44, 39, 79, 48,    // Top 20
      13, 60, 28, 51, 57, 8, 63, 55, 26, 69,   // Top 30
      49, 56, 67, 5, 40, 3, 23, 34, 15, 62,    // Top 40
      31, 1, 45, 27, 14, 52, 36, 25, 73, 33,   // Top 50
      10, 32, 64, 47, 7, 74, 19, 30, 16, 29,   // Top 60
      17, 42, 77, 78, 22, 37, 75, 43, 2, 24,   // Top 70
      38, 18, 68, 58, 9, 46, 59, 76, 54, 53    // Top 80
    ],
  );

  // Lista de Times do Coração (Biênio 2024-2026)
  static const Map<int, String> timemaniaClubs = {
    1: 'ABC/RN', 2: 'ALTOS/PI', 3: 'AMAZONAS/AM', 4: 'AMÉRICA/MG', 5: 'AMÉRICA/RN',
    6: 'APARECIDENSE/GO', 7: 'ATHLETIC CLUB/MG', 8: 'ATHLETICO/PR', 9: 'ATLÉTICO/GO', 10: 'ATLÉTICO MINEIRO/MG',
    11: 'AVAÍ/SC', 12: 'BAHIA/BA', 13: 'BAHIA DE FEIRA/BA', 14: 'BOTAFOGO/PB', 15: 'BOTAFOGO/RJ',
    16: 'BOTAFOGO/SP', 17: 'BRAGANTINO/SP', 18: 'BRASIL/RS', 19: 'BRASILIENSE/DF', 20: 'BRUSQUE/SC',
    21: 'CAMPINENSE/PB', 22: 'CASCAVEL/PR', 23: 'CAXIAS/RS', 24: 'CEARÁ/CE', 25: 'CEILÂNDIA/DF',
    26: 'CHAPECOENSE/SC', 27: 'CONFIANÇA/SE', 28: 'CORINTHIANS/SP', 29: 'CORITIBA/PR', 30: 'CRB/AL',
    31: 'CRICIÚMA/SC', 32: 'CRUZEIRO/MG', 33: 'CSA/AL', 34: 'CUIABÁ/MT', 35: 'FERROVIÁRIA/SP',
    36: 'FERROVIÁRIO/CE', 37: 'FIGUEIRENSE/SC', 38: 'FLAMENGO/RJ', 39: 'FLORESTA/CE', 40: 'FLUMINENSE/RJ',
    41: 'FORTALEZA/CE', 42: 'GOIÁS/GO', 43: 'GRÊMIO/RS', 44: 'GUARANI/SP', 45: 'INTERNACIONAL/RS',
    46: 'ITUANO/SP', 47: 'JACUIPENSE/BA', 48: 'JUAZEIRENSE/BA', 49: 'JUVENTUDE/RS', 50: 'LONDRINA/PR',
    51: 'MANAUS/AM', 52: 'MIRASSOL/SP', 53: 'NÁUTICO/PE', 54: 'NOVA IGUAÇU/RJ', 55: 'NOVORIZONTINO/SP',
    56: 'OESTE/SP', 57: 'OPERÁRIO/PR', 58: 'PALMEIRAS/SP', 59: 'PARANÁ/PR', 60: 'PAYSANDU/PA',
    61: 'PONTE PRETA/SP', 62: 'PORTUGUESA/RJ', 63: 'POUSO ALEGRE/MG', 64: 'REMO/PA', 65: 'RETRÔ/PE',
    66: 'SAMPAIO CORRÊA/MA', 67: 'SANTA CRUZ/PE', 68: 'SANTOS/SP', 69: 'SÃO BENTO/SP', 70: 'SÃO BERNARDO/SP',
    71: 'SÃO CAETANO/SP', 72: 'SÃO PAULO/SP', 73: 'SERGIPE/SE', 74: 'SPORT/PE', 75: 'TOMBENSE/MG',
    76: 'TREZE/PB', 77: 'TUNA LUSO/PA', 78: 'VASCO/RJ', 79: 'VILA NOVA/GO', 80: 'VITÓRIA/BA',
  };

  static const List<Lottery> allLotteries = [megaSena, lotofacil, quina, duplaSena, timemania];

  /// Tabela oficial de preços e probabilidades por quantidade de dezenas.
  /// Fonte: Caixa Econôm Federal — reajuste de 9 de julho de 2025 (vigente em 2026).
  /// Chave: LotteryType → (dezenas → ({custo em R$, probabilidade de ganhar o prêmio principal}))
  static const Map<LotteryType, Map<int, ({double cost, String odds})>> betPriceTable = {
    // Mega-Sena: aposta mínima passou de R$5,00 para R$6,00 em jul/2025
    LotteryType.megaSena: {
      6:  (cost: 6.00,       odds: '1 em 50.063.860'),
      7:  (cost: 42.00,      odds: '1 em 7.151.980'),
      8:  (cost: 168.00,     odds: '1 em 1.787.995'),
      9:  (cost: 504.00,     odds: '1 em 595.998'),
      10: (cost: 1260.00,    odds: '1 em 238.399'),
      11: (cost: 2772.00,    odds: '1 em 108.363'),
      12: (cost: 5544.00,    odds: '1 em 54.182'),
      13: (cost: 10296.00,   odds: '1 em 29.175'),
      14: (cost: 18018.00,   odds: '1 em 16.671'),
      15: (cost: 30030.00,   odds: '1 em 10.003'),
      16: (cost: 48048.00,   odds: '1 em 6.252'),
      17: (cost: 74256.00,   odds: '1 em 4.042'),
      18: (cost: 111384.00,  odds: '1 em 2.695'),
      19: (cost: 162792.00,  odds: '1 em 1.843'),
      20: (cost: 232560.00,  odds: '1 em 1.292'),
    },
    // Lotofácil: aposta mínima passou de R$3,00 para R$3,50 em jul/2025
    LotteryType.lotofacil: {
      15: (cost: 3.50,       odds: '1 em 3.268.760'),
      16: (cost: 56.00,      odds: '1 em 204.298'),
      17: (cost: 476.00,     odds: '1 em 24.035'),
      18: (cost: 2856.00,    odds: '1 em 4.807'),
      19: (cost: 13566.00,   odds: '1 em 1.602'),
      20: (cost: 46512.00,   odds: '1 em 801'),
    },
    // Quina: aposta de 5 dezenas passou para R$3,00 em jul/2025 (exibimos a partir de 6)
    LotteryType.quina: {
      6:  (cost: 18.00,      odds: '1 em 4.006.669'),
      7:  (cost: 63.00,      odds: '1 em 1.144.762'),
      8:  (cost: 168.00,     odds: '1 em 429.286'),
      9:  (cost: 378.00,     odds: '1 em 200.267'),
      10: (cost: 756.00,     odds: '1 em 105.140'),
      11: (cost: 1386.00,    odds: '1 em 57.347'),
      12: (cost: 2376.00,    odds: '1 em 31.836'),
      13: (cost: 3861.00,    odds: '1 em 17.974'),
      14: (cost: 6006.00,    odds: '1 em 10.270'),
      15: (cost: 9009.00,    odds: '1 em 5.888'),
    },
    // Dupla Sena: aposta mínima passou de R$2,50 para R$3,00 em jul/2025
    LotteryType.duplaSena: {
      6:  (cost: 3.00,       odds: '1 em 15.890.700'),
      7:  (cost: 21.00,      odds: '1 em 2.270.100'),
      8:  (cost: 84.00,      odds: '1 em 567.525'),
      9:  (cost: 252.00,     odds: '1 em 189.175'),
      10: (cost: 630.00,     odds: '1 em 75.670'),
      11: (cost: 1386.00,    odds: '1 em 34.395'),
      12: (cost: 2772.00,    odds: '1 em 17.198'),
      13: (cost: 5148.00,    odds: '1 em 9.261'),
      14: (cost: 9009.00,    odds: '1 em 5.292'),
      15: (cost: 15015.00,   odds: '1 em 3.175'),
    },
    // Timemania: R$3,00 — não houve alteração no reajuste de jul/2025
    LotteryType.timemania: {
      10: (cost: 3.00, odds: '1 em 26.827.140'),
    },
  };
}

