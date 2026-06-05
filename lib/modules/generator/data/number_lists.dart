// =========================================================================
// ARQUIVO: lib/modules/generator/data/number_lists.dart
// =========================================================================

import '../domain/entities/lottery.dart';

class LotteryData {
  // Dados atualizados em: Junho/2026 (concurso 3014)
  // Fonte: https://www.somatematica.com.br/megasenaFrequentes.php
  static const Lottery megaSena = Lottery(
    type: LotteryType.megaSena,
    name: 'Mega-Sena',
    numbersToPick: 6,
    minNumber: 1,
    maxNumber: 60,
    // Todos os 60 números ordenados por frequência (do mais ao menos sorteado)
    mostFrequentNumbers: [
      10, 53, 37, 5, 27, 32, 34, 38, 42, 33,  // Top 10
      44, 17, 30, 4, 35, 46, 23, 56, 43, 11,  // Top 20
      41, 54, 28, 13, 16, 36, 49, 52, 6, 51,   // Top 30
      24, 2, 8, 29, 50, 14, 1, 25, 45, 20,    // Top 40
      19, 60, 9, 59, 58, 47, 18, 57, 39, 40,  // Top 50
      7, 12, 3, 48, 31, 15, 22, 55, 21, 26    // Top 60
    ],
  );

  // Dados atualizados em: Junho/2026 (concurso 3702)
  // Fonte: https://www.somatematica.com.br/lotofacilFrequentes.php
  static const Lottery lotofacil = Lottery(
    type: LotteryType.lotofacil,
    name: 'Lotofácil',
    numbersToPick: 15,
    minNumber: 1,
    maxNumber: 25,
    // Todos os 25 números ordenados por frequência
    mostFrequentNumbers: [
      20, 10, 25, 11, 13, 24, 1, 4, 14, 3,    // Top 10
      12, 5, 2, 22, 9, 15, 19, 18, 21, 7,    // Top 20
      6, 17, 23, 8, 16                        // Top 25
    ],
  );

  // Dados atualizados em: Junho/2026 (concurso 7042)
  // Fonte: https://www.somatematica.com.br/quinaFrequentes.php
  static const Lottery quina = Lottery(
    type: LotteryType.quina,
    name: 'Quina',
    numbersToPick: 5,
    minNumber: 1,
    maxNumber: 80,
    // Todos os 80 números ordenados por frequência
    mostFrequentNumbers: [
      4, 26, 52, 49, 44, 31, 29, 16, 56, 42,   // Top 10
      39, 53, 5, 15, 9, 33, 66, 18, 10, 37,    // Top 20
      73, 38, 13, 14, 61, 72, 40, 54, 70, 12,  // Top 30
      60, 45, 64, 74, 55, 6, 79, 75, 19, 71,   // Top 40
      78, 77, 59, 57, 62, 46, 24, 43, 34, 11,  // Top 50
      23, 51, 8, 21, 27, 76, 63, 80, 41, 32,   // Top 60
      36, 2, 7, 69, 28, 35, 17, 22, 50, 1,     // Top 70
      68, 30, 25, 20, 58, 67, 65, 48, 3, 47    // Top 80
    ],
  );

  // Dados atualizados em: Junho/2026 (concurso 2965)
  // Fonte: https://www.somatematica.com.br/duplasenaFrequentes.php
  // Nota: frequência agrega 1º e 2º sorteios de cada concurso
  static const Lottery duplaSena = Lottery(
    type: LotteryType.duplaSena,
    name: 'Dupla Sena',
    numbersToPick: 6,
    minNumber: 1,
    maxNumber: 50,
    // Todos os 50 números ordenados por frequência
    mostFrequentNumbers: [
      36, 30, 39, 35, 18, 46, 31, 49, 11, 9,   // Top 10
      33, 2, 5, 45, 42, 14, 10, 44, 6, 21,     // Top 20
      25, 3, 8, 20, 19, 41, 22, 12, 32, 47,    // Top 30
      34, 43, 4, 50, 23, 7, 38, 15, 13, 28,   // Top 40
      17, 16, 37, 26, 40, 48, 29, 24, 1, 27    // Top 50
    ],
  );

  // Dados atualizados em: Junho/2026 (concurso 2399)
  // Fonte: https://www.somatematica.com.br/timemaniaFrequentes.php
  static const Lottery timemania = Lottery(
    type: LotteryType.timemania,
    name: 'Timemania',
    numbersToPick: 10,
    minNumber: 1,
    maxNumber: 80,
    // Todos os 80 números ordenados por frequência
    mostFrequentNumbers: [
      21, 20, 61, 70, 35, 66, 71, 72, 12, 4,   // Top 10
      39, 65, 80, 44, 41, 48, 50, 6, 11, 79,   // Top 20
      13, 28, 57, 55, 60, 69, 51, 63, 40, 26,  // Top 30
      8, 3, 5, 49, 62, 67, 1, 34, 23, 15,      // Top 40
      27, 14, 56, 31, 33, 45, 10, 73, 32, 52,  // Top 50
      25, 36, 74, 47, 7, 64, 19, 30, 29, 16,   // Top 60
      17, 77, 42, 78, 22, 2, 37, 75, 24, 68,  // Top 70
      38, 43, 46, 18, 58, 59, 9, 76, 54, 53    // Top 80
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
}
