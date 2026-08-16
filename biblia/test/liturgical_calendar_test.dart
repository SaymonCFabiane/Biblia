import 'package:flutter_test/flutter_test.dart';

import 'package:biblia_pai/liturgical/liturgical_calendar.dart';

void main() {
  group('Domingo de Páscoa (Meeus/Jones/Butcher)', () {
    // Datas conferidas contra o calendário público da Igreja.
    final cases = {
      2023: DateTime.utc(2023, 4, 9),
      2024: DateTime.utc(2024, 3, 31),
      2025: DateTime.utc(2025, 4, 20),
      2026: DateTime.utc(2026, 4, 5),
    };

    cases.forEach((year, expected) {
      test('Páscoa $year', () {
        final day = LiturgicalDay.forDate(expected);
        expect(day.season, LiturgicalSeason.pascoa);
        expect(day.displayName, contains('Páscoa'));
      });
    });
  });

  group('Datas móveis derivadas da Páscoa', () {
    // ano: [Cinzas, Ramos, Pentecostes, Corpus Christi, Cristo Rei, 1º Advento]
    final expectations = {
      2024: {
        'ashWednesday': DateTime.utc(2024, 2, 14),
        'palmSunday': DateTime.utc(2024, 3, 24),
        'pentecost': DateTime.utc(2024, 5, 19),
        'corpusChristi': DateTime.utc(2024, 5, 30),
        'christKing': DateTime.utc(2024, 11, 24),
        'firstAdvent': DateTime.utc(2024, 12, 1),
      },
      2025: {
        'ashWednesday': DateTime.utc(2025, 3, 5),
        'palmSunday': DateTime.utc(2025, 4, 13),
        'pentecost': DateTime.utc(2025, 6, 8),
        'corpusChristi': DateTime.utc(2025, 6, 19),
        'christKing': DateTime.utc(2025, 11, 23),
        'firstAdvent': DateTime.utc(2025, 11, 30),
      },
      2026: {
        'ashWednesday': DateTime.utc(2026, 2, 18),
        'palmSunday': DateTime.utc(2026, 3, 29),
        'pentecost': DateTime.utc(2026, 5, 24),
        'corpusChristi': DateTime.utc(2026, 6, 4),
        'christKing': DateTime.utc(2026, 11, 22),
        'firstAdvent': DateTime.utc(2026, 11, 29),
      },
    };

    expectations.forEach((year, dates) {
      test('Quarta-feira de Cinzas $year', () {
        final day = LiturgicalDay.forDate(dates['ashWednesday']!);
        expect(day.season, LiturgicalSeason.quaresma);
        expect(day.displayName, 'Quarta-feira de Cinzas');
        expect(day.color, LiturgicalColor.roxo);
      });

      test('Domingo de Ramos $year', () {
        final day = LiturgicalDay.forDate(dates['palmSunday']!);
        expect(day.season, LiturgicalSeason.quaresma);
        expect(day.displayName, contains('Domingo de Ramos'));
        expect(day.color, LiturgicalColor.vermelho);
      });

      test('Pentecostes $year', () {
        final day = LiturgicalDay.forDate(dates['pentecost']!);
        expect(day.season, LiturgicalSeason.pascoa);
        expect(day.displayName, 'Pentecostes');
        expect(day.color, LiturgicalColor.vermelho);
      });

      test('Corpus Christi $year', () {
        final day = LiturgicalDay.forDate(dates['corpusChristi']!);
        expect(day.season, LiturgicalSeason.tempoComum);
        expect(day.displayName, contains('Corpus Christi'));
        expect(day.color, LiturgicalColor.branco);
      });

      test('Cristo Rei $year', () {
        final day = LiturgicalDay.forDate(dates['christKing']!);
        expect(day.season, LiturgicalSeason.tempoComum);
        expect(day.displayName, contains('Cristo Rei'));
        expect(day.seasonWeek, 34);
        expect(day.color, LiturgicalColor.branco);
      });

      test('1º Domingo do Advento $year', () {
        final day = LiturgicalDay.forDate(dates['firstAdvent']!);
        expect(day.season, LiturgicalSeason.advento);
        expect(day.displayName, contains('1º Domingo do Advento'));
        expect(day.seasonWeek, 1);
        expect(day.color, LiturgicalColor.roxo);
      });
    });
  });

  group('Tempo do Natal e Quinta/Sexta-feira Santa', () {
    test('Quinta-feira Santa 2025 (véspera do Tríduo)', () {
      final day = LiturgicalDay.forDate(DateTime.utc(2025, 4, 17));
      expect(day.season, LiturgicalSeason.triduoPascal);
      expect(day.displayName, contains('Quinta-feira Santa'));
      expect(day.color, LiturgicalColor.branco);
    });

    test('Sexta-feira Santa 2025', () {
      final day = LiturgicalDay.forDate(DateTime.utc(2025, 4, 18));
      expect(day.season, LiturgicalSeason.triduoPascal);
      expect(day.displayName, contains('Sexta-feira Santa'));
      expect(day.color, LiturgicalColor.vermelho);
    });

    test('Natal do Senhor', () {
      final day = LiturgicalDay.forDate(DateTime.utc(2024, 12, 25));
      expect(day.season, LiturgicalSeason.natal);
      expect(day.displayName, 'Natal do Senhor');
      expect(day.color, LiturgicalColor.branco);
    });

    test('Solenidade de Santa Maria, Mãe de Deus (1º de janeiro)', () {
      final day = LiturgicalDay.forDate(DateTime.utc(2025, 1, 1));
      expect(day.season, LiturgicalSeason.natal);
      expect(day.displayName, contains('Santa Maria'));
    });
  });

  group('Ciclo dominical (A/B/C)', () {
    test('2023 é ano A', () {
      expect(LiturgicalDay.forDate(DateTime.utc(2023, 8, 15)).sundayCycle, SundayCycle.a);
    });

    test('2024 é ano B', () {
      expect(LiturgicalDay.forDate(DateTime.utc(2024, 8, 15)).sundayCycle, SundayCycle.b);
    });

    test('2025 é ano C', () {
      expect(LiturgicalDay.forDate(DateTime.utc(2025, 8, 15)).sundayCycle, SundayCycle.c);
    });

    test('Advento de 2025 já inicia o ciclo A de 2026', () {
      expect(LiturgicalDay.forDate(DateTime.utc(2025, 12, 7)).sundayCycle, SundayCycle.a);
    });
  });

  group('Ciclo ferial (I/II)', () {
    test('ano ímpar usa ciclo I', () {
      expect(LiturgicalDay.forDate(DateTime.utc(2025, 8, 15)).weekdayCycle, WeekdayCycle.i);
    });

    test('ano par usa ciclo II', () {
      expect(LiturgicalDay.forDate(DateTime.utc(2026, 8, 15)).weekdayCycle, WeekdayCycle.ii);
    });
  });
}
