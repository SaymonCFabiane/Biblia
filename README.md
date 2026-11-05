<div align="center">

# 📖 Bíblia Católica Offline

**Bíblia católica offline para Android, pensada para quem tem dificuldade de leitura no celular.**

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3-0175C2?logo=dart&logoColor=white)
![SQLite](https://img.shields.io/badge/SQLite-FTS4-003B57?logo=sqlite&logoColor=white)
![Android](https://img.shields.io/badge/Android-5.0%2B-3DDC84?logo=android&logoColor=white)
![Offline](https://img.shields.io/badge/100%25-offline-5B3A29)

</div>

---

## A história

Meu pai queria ler a Bíblia no celular, mas os apps que ele encontrava tinham
letra pequena, anúncios, cadastro obrigatório e precisavam de internet. Construí
este app para ele: abre direto no texto, letra grande, modo escuro, sem conta e
sem conexão.

Ele usa no dia a dia, o que fez dele meu primeiro "cliente real": cada decisão
de interface foi validada vendo uma pessoa de verdade usar.

<!--
  📸 Adicione aqui 3–4 capturas de tela (Hoje · Leitura · Busca · Configurações).
  Ex.: crie a pasta docs/screenshots/ e use:
  <p align="center">
    <img src="docs/screenshots/hoje.png" width="200">
    <img src="docs/screenshots/leitura.png" width="200">
    <img src="docs/screenshots/busca.png" width="200">
  </p>
-->

## Funcionalidades

| | |
|---|---|
| 📚 **Bíblia completa (católica)** | 73 livros, incluindo os deuterocanônicos, ~33 mil versículos |
| 🧭 **Navegação simples** | Testamento → Livro → Capítulo, com anterior/próximo na leitura |
| 🔍 **Busca em todo o texto** | Busca por palavra ou trecho em todos os versículos, instantânea |
| ☀️ **Leitura do dia** | Um capítulo por dia, o mesmo para todo mundo que abrir naquele dia |
| ⛪ **Calendário litúrgico** | Mostra o tempo litúrgico do dia ("Domingo de Ramos", "3ª Semana do Tempo Comum"…) com a cor litúrgica |
| 🔠 **Acessibilidade** | Tamanhos de fonte ajustáveis, modo claro/escuro, interface sem distrações |
| ✈️ **100% offline** | Nenhuma requisição de rede: todo o conteúdo está embutido no app |

## Destaques técnicos

**Banco SQLite pré-populado e versionado.**
O texto bíblico vem embarcado como asset (`assets/db/biblia.db`) e é copiado
para o armazenamento do app na primeira execução. O nome do arquivo inclui uma
versão (`kEmbeddedDbVersion`), então uma atualização do conteúdo força a
recópia sem precisar de migração.

**Busca full-text com FTS4.**
A busca usa uma tabela virtual `verses_fts` com prefix matching
(`palavra*`), o que deixa a pesquisa em ~33 mil versículos instantânea num
celular simples. Quando o FTS não encontra nada (termos muito curtos ou
acentuação parcial), cai num fallback com `LIKE`.

**Calendário litúrgico calculado, sem API.**
`lib/liturgical/liturgical_calendar.dart` calcula a Páscoa pelo algoritmo de
**Meeus/Jones/Butcher** e deriva dela todas as datas móveis: Cinzas, Ramos,
Tríduo Pascal, Ascensão, Pentecostes, Corpus Christi, Cristo Rei e Advento,
além dos ciclos dominical (A/B/C) e ferial (I/II). Todas as datas são
tratadas em UTC para evitar bugs de horário de verão nas comparações.

**Testes unitários do calendário.**
`test/liturgical_calendar_test.dart` confere as datas calculadas contra o
calendário oficial da Igreja para vários anos (2023–2026), incluindo tempo,
semana, nome exibido e cor litúrgica.

**Ponto de extensão para o Lecionário.**
As leituras oficiais da Missa de cada dia não são calculáveis: são uma tabela
definida pela Igreja. Em vez de inventar uma aproximação, o app expõe a
interface `LectionaryProvider` (hoje com uma implementação nula) e a tela
deixa claro que a leitura exibida é *sugerida*. Plugar uma fonte real no futuro
não exige mudar a interface.

**Leitura do dia determinística.**
`epochDay % totalDeCapítulos`: sem servidor e sem estado, todos os aparelhos
mostram o mesmo capítulo no mesmo dia, e o plano percorre a Bíblia inteira em
ordem.

## Arquitetura

```
biblia/lib/
├── main.dart                      # Tema Material 3 (claro/escuro) e escala de fonte
├── models/bible_models.dart       # Testament, Book, Verse, ChapterRef
├── db/database_helper.dart        # Singleton de acesso ao SQLite: todas as queries
├── providers/settings_provider.dart  # Tema e fonte (Provider + shared_preferences)
├── liturgical/
│   ├── liturgical_calendar.dart   # Cálculo do tempo litúrgico
│   └── lectionary_provider.dart   # Interface para o Lecionário oficial
└── screens/
    ├── home_shell.dart            # Navegação inferior: Hoje / Bíblia / Buscar
    ├── daily_reading_screen.dart
    ├── testaments_screen.dart → books_screen.dart → chapters_screen.dart → reading_screen.dart
    ├── search_screen.dart
    └── settings_screen.dart
```

**Stack:** Flutter · Dart 3 · `sqflite` · `provider` · `shared_preferences` · `path_provider`

**Fluxo de dados:** telas → `DatabaseHelper` (queries SQL) → modelos imutáveis.
Configurações do usuário ficam num `ChangeNotifier` que persiste em
`shared_preferences` e reconstrói o tema ao mudar.

## Como rodar

Pré-requisitos: [Flutter SDK](https://docs.flutter.dev/get-started/install) e Android SDK (`flutter doctor` sem erros).

```bash
git clone https://github.com/SaymonCFabiane/Biblia.git
cd Biblia/biblia
flutter pub get
flutter run                 # emulador ou celular conectado
flutter test                # testes do calendário litúrgico
flutter build apk --release # gera build/app/outputs/flutter-apk/app-release.apk
```

## Limitações conhecidas

- **Atos dos Apóstolos, Filemom e 2 São João** estão sem versículos no conjunto
  de dados de origem. O app detecta isso e mostra esses livros desabilitados
  com "Conteúdo indisponível", em vez de quebrar.
- A leitura do dia é uma rotação sequencial, não o Lecionário oficial (ver
  *Ponto de extensão* acima).

## Próximos passos

- [ ] Completar os três livros faltantes no banco
- [ ] Favoritos e marcadores de versículo
- [ ] Compartilhar versículo (texto/imagem) pelo WhatsApp
- [ ] Integrar uma fonte do Lecionário via `LectionaryProvider`
- [ ] Testes de widget para as telas principais

---

<div align="center">

Feito por **Saymon Calgarotto Fabiane** · [GitHub](https://github.com/SaymonCFabiane)

</div>
