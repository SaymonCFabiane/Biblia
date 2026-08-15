# Bíblia Católica Offline 📖

App Flutter de leitura da bíblia (católica, com deuterocanônicos), com:
- Navegação por Testamento → Livro → Capítulo
- Busca por palavra/trecho em todos os versículos (full-text search)
- "Leitura do dia": um capítulo diferente destacado a cada dia, igual pra todo mundo que abrir naquele dia
- Fonte grande, modo escuro e interface simples (pensado pra facilitar a leitura)
- 100% offline: os textos ficam num banco SQLite embutido no app (`assets/db/biblia.db`), não precisa de internet

## O que já está pronto

Todo o código-fonte (`lib/`), o `pubspec.yaml` e o banco de dados (`assets/db/biblia.db`, já convertido a partir dos seus 3 arquivos SQL) estão prontos. **Falta só gerar as pastas de plataforma (Android) e compilar**, porque isso depende do Flutter SDK, que não está disponível neste ambiente.

## Passo a passo pra gerar o APK

### 1. Instalar as ferramentas (só na primeira vez)
- Instale o **Flutter SDK**: https://docs.flutter.dev/get-started/install
- Instale o **Android Studio** (ele já traz o Android SDK): https://developer.android.com/studio
- Rode no terminal para conferir se está tudo certo:
  ```
  flutter doctor
  ```
  Resolva qualquer "✗" que aparecer (geralmente é aceitar licenças do Android com `flutter doctor --android-licenses`).

### 2. Gerar as pastas de plataforma
Dentro da pasta `biblia_flutter_app` (a que eu te entreguei), rode:
```
flutter create --platforms=android .
```
Isso vai criar a pasta `android/` necessária pra compilar, **sem mexer** no `lib/`, `pubspec.yaml` ou `assets/` que já existem.

> Opcional: se quiser mudar o nome do app que aparece no celular, edite depois de rodar o comando acima o arquivo `android/app/src/main/AndroidManifest.xml`, o atributo `android:label="Bíblia Católica Offline"`.

### 3. Baixar as dependências
```
flutter pub get
```

### 4. Testar (opcional, mas recomendado)
Com um emulador Android aberto ou um celular conectado por USB (modo desenvolvedor + depuração USB ativados):
```
flutter run
```

### 5. Gerar o APK final
```
flutter build apk --release
```
O arquivo vai ficar em:
```
build/app/outputs/flutter-apk/app-release.apk
```

### 6. Instalar no celular do seu pai
- Envie esse `.apk` pro celular dele (WhatsApp, e-mail, cabo USB, etc.)
- No celular, ele vai precisar permitir "instalar de fontes desconhecidas" na primeira vez (o Android pede isso automaticamente ao tentar abrir o arquivo).

## Sobre o conteúdo do banco

Convertidos os 3 dumps que você me passou: **33.276 versículos**, 73 livros, 2 testamentos. Uma ressalva importante sobre os **dados de origem** (não é algo que eu quebrei na conversão — conferi bit a bit):

- Os livros **Atos dos Apóstolos**, **Filemom** e **2 São João** não têm nenhum versículo no seu arquivo `biblia_versiculos_sql.sql`. O app já trata isso: esses livros aparecem desabilitados na lista com "Conteúdo indisponível", em vez de dar erro.
- Se você conseguir um dump mais completo desses 3 livros no mesmo formato, é só rodar de novo o script `convert_to_sqlite.py` (que também te entreguei) apontando pro arquivo atualizado, substituir o `assets/db/biblia.db` e recompilar.

## Estrutura do projeto

```
lib/
  main.dart                    # tema (claro/escuro), tamanho de fonte
  models/bible_models.dart     # Testament, Book, Verse, ChapterRef
  db/database_helper.dart      # abre o SQLite, todas as queries
  providers/settings_provider.dart  # tema + fonte, salvos no aparelho
  screens/
    home_shell.dart            # navegação inferior: Hoje / Bíblia / Buscar
    daily_reading_screen.dart  # leitura do dia
    testaments_screen.dart     # lista de testamentos
    books_screen.dart          # lista de livros de um testamento
    chapters_screen.dart       # grade de capítulos de um livro
    reading_screen.dart        # texto dos versículos + anterior/próximo
    search_screen.dart         # busca por palavra/trecho
    settings_screen.dart       # tema e tamanho da fonte
assets/db/biblia.db             # banco SQLite pronto (dados já convertidos)
```

## Se quiser ajustar algo depois
Coisas fáceis de mudar:
- **Cor do app**: `main.dart`, variável `seedColor`.
- **Tamanhos de fonte disponíveis**: `providers/settings_provider.dart`, enum `AppFontSize`.
- **Tema padrão ao abrir pela primeira vez**: `providers/settings_provider.dart`, campo `_themeMode` (hoje é `ThemeMode.dark`).
