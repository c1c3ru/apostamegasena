// =========================================================================
// ARQUIVO: lib/modules/generator/data/number_lists.dart
// =========================================================================

import '../domain/entities/lottery.dart';

class LotteryData {
  // Dados atualizados em: Dezembro/2025
  // Fonte: Estatísticas históricas dos concursos da Mega-Sena
  static const Lottery megaSena = Lottery(
    type: LotteryType.megaSena,
    name: 'Mega-Sena',
    numbersToPick: 6,
    minNumber: 1,
    maxNumber: 60,
    // Todos os 60 números ordenados por frequência (do mais ao menos sorteado)
    mostFrequentNumbers: [
      10, 53, 5, 37, 34, 33, 23, 4, 42, 30,  // Top 10
      44, 32, 35, 27, 41, 17, 38, 56, 43, 28, // Top 20
      16, 54, 11, 51, 29, 36, 52, 49, 2, 46,  // Top 30
      8, 59, 45, 50, 6, 40, 24, 58, 1, 13,    // Top 40
      20, 12, 18, 47, 31, 19, 60, 39, 7, 57,  // Top 50
      25, 48, 14, 9, 3, 22, 15, 55, 21, 26    // Top 60
    ],
  );

  // Dados atualizados em: Dezembro/2025
  // Fonte: Estatísticas históricas dos concursos
  static const Lottery lotofacil = Lottery(
    type: LotteryType.lotofacil,
    name: 'Lotofácil',
    numbersToPick: 15,
    minNumber: 1,
    maxNumber: 25,
    // Todos os 25 números ordenados por frequência
    mostFrequentNumbers: [
      20, 25, 10, 11, 13, 14, 24, 3, 5, 4,   // Top 10
      12, 9, 22, 2, 1, 19, 18, 15, 21, 23,  // Top 20
      6, 8, 17, 7, 16                        // Top 25
    ],
  );

  static const Lottery quina = Lottery(
    type: LotteryType.quina,
    name: 'Quina',
    numbersToPick: 5,
    minNumber: 1,
    maxNumber: 80,
    // Todos os 80 números ordenados por frequência
    mostFrequentNumbers: [
      4, 49, 26, 31, 39, 52, 53, 44, 16, 29,   // Top 10
      42, 56, 38, 61, 10, 18, 5, 66, 9, 13,    // Top 20
      73, 33, 15, 70, 37, 72, 64, 12, 74, 79,  // Top 30
      54, 14, 34, 40, 55, 71, 75, 46, 60, 11,  // Top 40
      76, 2, 28, 45, 27, 19, 36, 80, 8, 77,    // Top 50
      59, 6, 7, 21, 32, 69, 51, 20, 62, 63,    // Top 60
      35, 25, 50, 41, 43, 78, 1, 22, 57, 68,   // Top 70
      67, 30, 58, 17, 23, 65, 24, 48, 47, 3    // Top 80
    ],
  );

  static const Lottery duplaSena = Lottery(
    type: LotteryType.duplaSena,
    name: 'Dupla Sena',
    numbersToPick: 6,
    minNumber: 1,
    maxNumber: 50,
    // Todos os 50 números ordenados por frequência
    mostFrequentNumbers: [
      39, 14, 33, 42, 19, 4, 45, 11, 36, 13,   // Top 10
      3, 29, 31, 6, 46, 10, 37, 25, 8, 47,     // Top 20
      24, 2, 20, 34, 50, 16, 12, 49, 40, 28,   // Top 30
      35, 41, 18, 44, 26, 15, 38, 23, 5, 9,    // Top 40
      30, 27, 32, 17, 7, 43, 21, 48, 1, 22     // Top 50
    ],
  );

  static const Lottery timemania = Lottery(
    type: LotteryType.timemania,
    name: 'Timemania',
    numbersToPick: 10,
    minNumber: 1,
    maxNumber: 80,
    // Dados fornecidos pelo usuário
    mostFrequentNumbers: [
      21, 70, 20, 61, 71, 66, 72, 69, 80, 12, // Top 10
      4, 50, 28, 79, 6                        // Top 15
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