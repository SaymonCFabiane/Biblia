/// Ponto de extensão para o Lecionário oficial da Igreja Católica.
///
/// O Lecionário define, para cada dia do ano, as leituras bíblicas
/// específicas da Missa (1ª leitura, salmo, 2ª leitura nos domingos,
/// evangelho), incluindo o ciclo dominical A/B/C e o ciclo ferial I/II.
/// São centenas de referências definidas pela CNBB/Vaticano — **não é algo
/// que dá pra calcular ou inferir** a partir do calendário litúrgico
/// ([liturgical_calendar.dart]) nem a partir dos versículos do banco local.
///
/// Hoje o app **não tem** essa fonte de dados, então `daily_reading_screen.dart`
/// usa uma rotação sequencial de capítulos (`DatabaseHelper.getTodayReading`)
/// como "leitura sugerida" — não a leitura oficial do dia.
///
/// Se no futuro você conseguir uma fonte confiável (ex.: um JSON
/// `"AAAA-MM-DD" -> referências`, exportado do Lecionário oficial),
/// implemente [LectionaryProvider] com essa fonte e passe a instância pra
/// tela no lugar de [NullLectionaryProvider], sem precisar reescrever a UI.
library;

/// Uma leitura litúrgica oficial (Lecionário) para um dia específico.
class LectionaryReading {
  final String label; // ex: "1ª Leitura", "Salmo", "2ª Leitura", "Evangelho"
  final String reference; // ex: "Mc 1,12-15"

  const LectionaryReading({required this.label, required this.reference});
}

/// Fonte de dados do Lecionário oficial. Ainda não há implementação real —
/// ver nota acima. [NullLectionaryProvider] é o placeholder usado enquanto
/// isso, e sempre retorna `null`.
abstract class LectionaryProvider {
  /// Leituras oficiais do dia, ou `null` se a fonte de dados não tiver
  /// informação para essa data (o chamador deve cair de volta pra leitura
  /// sugerida por rotação).
  Future<List<LectionaryReading>?> readingsFor(DateTime date);
}

class NullLectionaryProvider implements LectionaryProvider {
  const NullLectionaryProvider();

  @override
  Future<List<LectionaryReading>?> readingsFor(DateTime date) async => null;
}
