/// Cálculo do calendário litúrgico católico (Rito Romano) a partir da data.
///
/// Tudo aqui é matemática pura de datas — nenhuma fonte externa é necessária:
/// a Páscoa é calculada pelo algoritmo de Meeus/Jones/Butcher, e todas as
/// outras datas móveis (Cinzas, Ramos, Tríduo, Ascensão, Pentecostes, Corpus
/// Christi, Cristo Rei, Advento) são derivadas dela.
///
/// IMPORTANTE: isto calcula o TEMPO litúrgico do dia (estação, semana, cor,
/// ciclo) só para fins de exibição. NÃO é o Lecionário oficial — a leitura
/// bíblica específica de cada dia é uma tabela de referências definida pela
/// Igreja que não dá pra deduzir a partir do calendário. Veja
/// `lectionary_provider.dart` para o porquê e para o ponto de extensão
/// preparado pra quando houver uma fonte de dados real.
library;

/// Tempo litúrgico.
enum LiturgicalSeason { advento, natal, tempoComum, quaresma, triduoPascal, pascoa }

/// Cor litúrgica do dia.
enum LiturgicalColor { roxo, branco, verde, vermelho, rosa }

/// Ciclo dominical (leituras de domingo giram em 3 anos).
enum SundayCycle { a, b, c }

/// Ciclo ferial (leituras de dias de semana giram em 2 anos).
enum WeekdayCycle { i, ii }

class LiturgicalDay {
  final DateTime date;
  final LiturgicalSeason season;

  /// Número da semana dentro do tempo litúrgico atual. Em Natal e no Tríduo
  /// Pascal esse número não tem muito significado próprio (esses tempos não
  /// são organizados em semanas numeradas) e fica fixo em 1; use
  /// [displayName] para o texto correto desses dias.
  final int seasonWeek;
  final LiturgicalColor color;
  final SundayCycle sundayCycle;
  final WeekdayCycle weekdayCycle;
  final String displayName;

  const LiturgicalDay({
    required this.date,
    required this.season,
    required this.seasonWeek,
    required this.color,
    required this.sundayCycle,
    required this.weekdayCycle,
    required this.displayName,
  });

  factory LiturgicalDay.forDate(DateTime rawDate) {
    // Tudo em UTC: assim as somas/subtrações de dias nunca são afetadas por
    // horário de verão (o que quebraria as comparações de igualdade abaixo).
    final date = DateTime.utc(rawDate.year, rawDate.month, rawDate.day);
    final y = date.year;

    final christmasStartPrevYear = DateTime.utc(y - 1, 12, 25);
    final baptismCurrentYear = _baptismOfTheLord(y);
    final christmasStartThisYear = DateTime.utc(y, 12, 25);

    final ashWednesday = _ashWednesday(y);
    final easter = _easterSunday(y);
    final holyThursday = _holyThursday(y);
    final holySaturday = _holySaturday(y);
    final pentecost = _pentecost(y);
    final firstAdvent = _firstAdventSunday(y);

    late final LiturgicalSeason season;
    late final int seasonWeek;
    late final LiturgicalColor color;
    late final String displayName;

    if (!date.isBefore(christmasStartPrevYear) && !date.isAfter(baptismCurrentYear)) {
      season = LiturgicalSeason.natal;
      final info = _natalInfo(date, christmasStartPrevYear, baptismCurrentYear);
      seasonWeek = 1;
      color = info.$1;
      displayName = info.$2;
    } else if (!date.isBefore(christmasStartThisYear)) {
      season = LiturgicalSeason.natal;
      final baptismNextYear = _baptismOfTheLord(y + 1);
      final info = _natalInfo(date, christmasStartThisYear, baptismNextYear);
      seasonWeek = 1;
      color = info.$1;
      displayName = info.$2;
    } else if (!date.isBefore(firstAdvent)) {
      season = LiturgicalSeason.advento;
      final info = _adventoInfo(date, firstAdvent);
      seasonWeek = info.$1;
      color = info.$2;
      displayName = info.$3;
    } else if (!date.isBefore(ashWednesday) && date.isBefore(holyThursday)) {
      season = LiturgicalSeason.quaresma;
      final info = _quaresmaInfo(date, ashWednesday, easter);
      seasonWeek = info.$1;
      color = info.$2;
      displayName = info.$3;
    } else if (!date.isBefore(holyThursday) && !date.isAfter(holySaturday)) {
      season = LiturgicalSeason.triduoPascal;
      final info = _triduoInfo(date, holyThursday);
      seasonWeek = 1;
      color = info.$1;
      displayName = info.$2;
    } else if (!date.isBefore(easter) && !date.isAfter(pentecost)) {
      season = LiturgicalSeason.pascoa;
      final info = _pascoaInfo(date, easter, pentecost);
      seasonWeek = info.$1;
      color = info.$2;
      displayName = info.$3;
    } else if (date.isAfter(baptismCurrentYear) && date.isBefore(ashWednesday)) {
      season = LiturgicalSeason.tempoComum;
      final info = _tempoComumParte1Info(date, baptismCurrentYear);
      seasonWeek = info.$1;
      color = LiturgicalColor.verde;
      displayName = info.$2;
    } else {
      // pentecost < date < firstAdvent
      season = LiturgicalSeason.tempoComum;
      final info = _tempoComumParte2Info(date, firstAdvent);
      seasonWeek = info.$1;
      color = info.$2;
      displayName = info.$3;
    }

    return LiturgicalDay(
      date: date,
      season: season,
      seasonWeek: seasonWeek,
      color: color,
      sundayCycle: _sundayCycle(date),
      weekdayCycle: _weekdayCycle(date),
      displayName: displayName,
    );
  }
}

// ---------- Nomes auxiliares ----------

const _weekdayNames = [
  'Segunda-feira',
  'Terça-feira',
  'Quarta-feira',
  'Quinta-feira',
  'Sexta-feira',
  'Sábado',
  'Domingo',
];

String _weekdayName(DateTime d) => _weekdayNames[d.weekday - 1];

String _ordinalMasc(int n) => '$nº';
String _ordinalFem(int n) => '$nª';

bool _isSunday(DateTime d) => d.weekday == DateTime.sunday;

// ---------- Advento ----------

(int, LiturgicalColor, String) _adventoInfo(DateTime date, DateTime firstAdvent) {
  final week = (date.difference(firstAdvent).inDays ~/ 7) + 1;
  if (_isSunday(date)) {
    if (week == 3) {
      return (week, LiturgicalColor.rosa, '${_ordinalMasc(week)} Domingo do Advento (Domingo de Gaudete)');
    }
    return (week, LiturgicalColor.roxo, '${_ordinalMasc(week)} Domingo do Advento');
  }
  return (week, LiturgicalColor.roxo, '${_weekdayName(date)} da ${_ordinalFem(week)} Semana do Advento');
}

// ---------- Natal ----------

(LiturgicalColor, String) _natalInfo(DateTime date, DateTime christmasStart, DateTime baptism) {
  if (date == christmasStart) {
    return (LiturgicalColor.branco, 'Natal do Senhor');
  }
  if (date.month == 1 && date.day == 1) {
    return (LiturgicalColor.branco, 'Solenidade de Santa Maria, Mãe de Deus');
  }
  if (date == baptism) {
    return (LiturgicalColor.branco, 'Batismo do Senhor');
  }
  final epiphany = _epiphanySunday(baptism.year);
  if (date == epiphany) {
    return (LiturgicalColor.branco, 'Epifania do Senhor');
  }
  final holyFamily = _holyFamily(christmasStart);
  if (date == holyFamily) {
    return (LiturgicalColor.branco, 'Sagrada Família de Jesus, Maria e José');
  }
  if (date.month == 12 && date.day == 31) {
    return (LiturgicalColor.branco, 'Oitava do Natal');
  }
  return (LiturgicalColor.branco, '${_weekdayName(date)} do Tempo do Natal');
}

DateTime _epiphanySunday(int year) {
  var d = DateTime.utc(year, 1, 2);
  while (!_isSunday(d)) {
    d = d.add(const Duration(days: 1));
  }
  return d;
}

DateTime _baptismOfTheLord(int year) {
  final epiphany = _epiphanySunday(year);
  // Se a Epifania cai em 7 ou 8/jan, o Batismo do Senhor é celebrado na
  // segunda-feira seguinte (não haveria mais domingo livre antes do início
  // do Tempo Comum).
  if (epiphany.day >= 7) {
    return epiphany.add(const Duration(days: 1));
  }
  return epiphany.add(const Duration(days: 7));
}

DateTime _holyFamily(DateTime christmasStart) {
  if (_isSunday(christmasStart)) {
    // Não sobra domingo entre 26 e 31/dez: a festa é fixada em 30/dez.
    return DateTime.utc(christmasStart.year, 12, 30);
  }
  var d = DateTime.utc(christmasStart.year, 12, 26);
  while (!_isSunday(d)) {
    d = d.add(const Duration(days: 1));
  }
  return d;
}

// ---------- Quaresma ----------

(int, LiturgicalColor, String) _quaresmaInfo(DateTime date, DateTime ashWednesday, DateTime easter) {
  final palmSunday = easter.subtract(const Duration(days: 7));
  final firstLentSunday = ashWednesday.add(const Duration(days: 4));

  if (date == ashWednesday) {
    return (0, LiturgicalColor.roxo, 'Quarta-feira de Cinzas');
  }
  if (date == palmSunday) {
    return (6, LiturgicalColor.vermelho, 'Domingo de Ramos da Paixão do Senhor');
  }
  if (date.isAfter(palmSunday)) {
    // Segunda, Terça e Quarta-feira Santas.
    return (6, LiturgicalColor.roxo, '${_weekdayName(date)} Santa da Semana Santa');
  }
  if (date.isBefore(firstLentSunday)) {
    return (0, LiturgicalColor.roxo, '${_weekdayName(date)} depois das Cinzas');
  }

  final week = (date.difference(firstLentSunday).inDays ~/ 7) + 1;
  if (_isSunday(date)) {
    if (week == 4) {
      return (week, LiturgicalColor.rosa, '${_ordinalMasc(week)} Domingo da Quaresma (Domingo de Laetare)');
    }
    return (week, LiturgicalColor.roxo, '${_ordinalMasc(week)} Domingo da Quaresma');
  }
  return (week, LiturgicalColor.roxo, '${_weekdayName(date)} da ${_ordinalFem(week)} Semana da Quaresma');
}

// ---------- Tríduo Pascal ----------

(LiturgicalColor, String) _triduoInfo(DateTime date, DateTime holyThursday) {
  final diff = date.difference(holyThursday).inDays;
  switch (diff) {
    case 0:
      return (LiturgicalColor.branco, 'Quinta-feira Santa (Missa da Ceia do Senhor)');
    case 1:
      return (LiturgicalColor.vermelho, 'Sexta-feira Santa (Paixão do Senhor)');
    default:
      return (LiturgicalColor.branco, 'Sábado Santo (Vigília Pascal)');
  }
}

// ---------- Páscoa ----------

(int, LiturgicalColor, String) _pascoaInfo(DateTime date, DateTime easter, DateTime pentecost) {
  if (date == easter) {
    return (1, LiturgicalColor.branco, 'Domingo de Páscoa da Ressurreição do Senhor');
  }
  final week = (date.difference(easter).inDays ~/ 7) + 1;
  final ascension = easter.add(const Duration(days: 39));
  if (date == ascension) {
    return (week, LiturgicalColor.branco, 'Ascensão do Senhor');
  }
  if (date == pentecost) {
    return (week, LiturgicalColor.vermelho, 'Pentecostes');
  }
  if (_isSunday(date)) {
    return (week, LiturgicalColor.branco, '${_ordinalMasc(week)} Domingo da Páscoa');
  }
  return (week, LiturgicalColor.branco, '${_weekdayName(date)} da ${_ordinalFem(week)} Semana da Páscoa');
}

// ---------- Tempo Comum ----------

(int, String) _tempoComumParte1Info(DateTime date, DateTime baptism) {
  final firstMonday = baptism.add(const Duration(days: 1));
  final sundayOfWeek2 = firstMonday.add(const Duration(days: 6));

  int week;
  if (date.isBefore(sundayOfWeek2)) {
    week = 1;
  } else {
    week = 2 + (date.difference(sundayOfWeek2).inDays ~/ 7);
  }

  if (_isSunday(date)) {
    return (week, '${_ordinalMasc(week)} Domingo do Tempo Comum');
  }
  return (week, '${_weekdayName(date)} da ${_ordinalFem(week)} Semana do Tempo Comum');
}

(int, LiturgicalColor, String) _tempoComumParte2Info(DateTime date, DateTime firstAdvent) {
  final christKing = firstAdvent.subtract(const Duration(days: 7));
  final corpusChristi = _corpusChristiFor(firstAdvent);

  var nextSunday = date;
  while (!_isSunday(nextSunday)) {
    nextSunday = nextSunday.add(const Duration(days: 1));
  }
  final weeksToGo = christKing.difference(nextSunday).inDays ~/ 7;
  final week = 34 - weeksToGo;

  if (date == christKing) {
    return (week, LiturgicalColor.branco, 'Nosso Senhor Jesus Cristo, Rei do Universo (Cristo Rei)');
  }
  if (date == corpusChristi) {
    return (week, LiturgicalColor.branco, 'Corpo e Sangue de Cristo (Corpus Christi)');
  }
  if (_isSunday(date)) {
    return (week, LiturgicalColor.verde, '${_ordinalMasc(week)} Domingo do Tempo Comum');
  }
  return (week, LiturgicalColor.verde, '${_weekdayName(date)} da ${_ordinalFem(week)} Semana do Tempo Comum');
}

/// Corpus Christi (quinta-feira depois da Santíssima Trindade, 60 dias
/// depois da Páscoa) é calculado a partir da Páscoa do mesmo ano civil em
/// que este Advento vai começar em dezembro — por isso recebemos
/// `firstAdvent` (do ano Y) e voltamos ao ano civil Y para achar a Páscoa.
DateTime _corpusChristiFor(DateTime firstAdvent) {
  final easter = _easterSunday(firstAdvent.year);
  return easter.add(const Duration(days: 60));
}

// ---------- Ciclos ----------

SundayCycle _sundayCycle(DateTime date) {
  final n = _liturgicalYearNumber(date);
  switch (n % 3) {
    case 0:
      return SundayCycle.c;
    case 1:
      return SundayCycle.a;
    default:
      return SundayCycle.b;
  }
}

int _liturgicalYearNumber(DateTime date) {
  final y = date.year;
  final firstAdvent = _firstAdventSunday(y);
  if (!date.isBefore(firstAdvent)) {
    return y + 1;
  }
  return y;
}

WeekdayCycle _weekdayCycle(DateTime date) => date.year.isOdd ? WeekdayCycle.i : WeekdayCycle.ii;

// ---------- Datas móveis ----------

/// Domingo de Páscoa pelo algoritmo de Meeus/Jones/Butcher (calendário
/// gregoriano).
DateTime _easterSunday(int year) {
  final a = year % 19;
  final b = year ~/ 100;
  final c = year % 100;
  final d = b ~/ 4;
  final e = b % 4;
  final f = (b + 8) ~/ 25;
  final g = (b - f + 1) ~/ 3;
  final h = (19 * a + b - d - g + 15) % 30;
  final i = c ~/ 4;
  final k = c % 4;
  final l = (32 + 2 * e + 2 * i - h - k) % 7;
  final m = (a + 11 * h + 22 * l) ~/ 451;
  final month = (h + l - 7 * m + 114) ~/ 31;
  final day = ((h + l - 7 * m + 114) % 31) + 1;
  return DateTime.utc(year, month, day);
}

DateTime _ashWednesday(int year) => _easterSunday(year).subtract(const Duration(days: 46));

DateTime _holyThursday(int year) => _easterSunday(year).subtract(const Duration(days: 3));

DateTime _holySaturday(int year) => _easterSunday(year).subtract(const Duration(days: 1));

DateTime _pentecost(int year) => _easterSunday(year).add(const Duration(days: 49));

/// 4º Domingo do Advento = último domingo em ou antes de 24/dez.
DateTime _fourthAdventSunday(int year) {
  final dec24 = DateTime.utc(year, 12, 24);
  return dec24.subtract(Duration(days: dec24.weekday % 7));
}

/// 1º Domingo do Advento = 4º Domingo do Advento menos 3 semanas. Sempre
/// cai entre 27/nov e 3/dez.
DateTime _firstAdventSunday(int year) => _fourthAdventSunday(year).subtract(const Duration(days: 21));
