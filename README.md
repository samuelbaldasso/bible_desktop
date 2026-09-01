# Bíblia ARC — Linux Desktop

Aplicativo Flutter para desktop Linux que exibe a Bíblia Almeida Revista e Corrigida (ARC), com seleção de livro/capítulo e leitura de versículos consumidos via JSON remoto.

## Stack

- **Flutter** (SDK `>=3.9.0 <4.0.0`), Material 3
- **window_manager** — controle de janela nativa (tamanho, centralização, foco)
- **http** — cliente HTTP para consumo da API de texto bíblico
- Fonte de dados: JSON público em [`MaatheusGois/bible`](https://github.com/MaatheusGois/bible) (versão `pt-br/arc`)

## Arquitetura

O projeto segue **Clean Architecture** em três camadas, sob `lib/`:

```
lib/
├── domain/                  # regras de negócio, sem dependência de Flutter/HTTP
│   ├── entities/             # BibleBook, BibleChapter, Verse
│   ├── repositories/         # contrato BibleRepository (abstrato)
│   ├── usecases/             # GetBibleChapter
│   └── errors/                # BibleApiException
├── data/                    # implementação concreta de acesso a dados
│   ├── datasources/           # BibleRemoteDataSource (HTTP + parsing do JSON bruto)
│   └── repositories/          # BibleRepositoryImpl (traduz dado bruto → entidade de domínio)
└── presentation/            # UI
    └── screens/                # HomeScreen
```

Fluxo de dependência: `presentation → domain ← data`. A `HomeScreen` depende apenas do usecase `GetBibleChapter`; o usecase depende da abstração `BibleRepository`; a implementação concreta (`BibleRepositoryImpl` + `BibleRemoteDataSource`) é montada e injetada manualmente em `main.dart`. Não há uso de service locator ou framework de DI — a injeção é feita por construtor, no ponto de composição da aplicação.

## Executar

```bash
flutter pub get
flutter run -d linux
```

## Build de produção

```bash
flutter build linux --release
```

## Preview local

A pasta `preview/` é uma prévia HTML para inspeção visual quando o Flutter SDK não está disponível no ambiente de execução.

```bash
python3 -m http.server 4173 --directory preview
```

Abra `http://127.0.0.1:4173`.

## Testes

```bash
flutter test
```

Suíte de testes unitários e de widget, organizada espelhando `lib/`:

```
test/
├── domain/
│   ├── entities/bible_book_test.dart        # integridade do catálogo dos 66 livros
│   └── usecases/get_bible_chapter_test.dart  # delegação de parâmetros e propagação de erro
├── data/
│   ├── datasources/bible_remote_data_source_test.dart  # parsing do JSON via MockClient (http/testing)
│   └── repositories/bible_repository_impl_test.dart    # tradução RawChapter → BibleChapter/Verse
├── presentation/screens/home_screen_test.dart  # renderização, busca, navegação de capítulo e estado de erro
└── widget_test.dart                            # smoke test do app completo
```

Nenhuma requisição de rede real é feita: `BibleRemoteDataSource` recebe um `http.Client` injetável, e os testes de `data`/`presentation` usam `MockClient` (de `package:http/testing.dart`, já incluso na dependência `http`) ou fakes manuais de `BibleRepository` — sem necessidade de `mockito`/`build_runner`.

---

## Architecture Decision Records (ADRs)

### ADR-001 — Adotar Clean Architecture em três camadas

**Status:** Aceito

**Contexto:** O app precisa buscar dados de uma API externa (JSON estático via GitHub raw), transformá-los em algo exibível e reagir a mudanças de fonte de dados ou formato sem reescrever a UI.

**Decisão:** Separar o código em `domain` (entidades e regras de negócio, sem dependências externas), `data` (acesso a dados e tradução para entidades de domínio) e `presentation` (widgets Flutter). Dependências apontam sempre para dentro (`data`/`presentation` → `domain`), nunca o contrário.

**Consequências:**
- `domain` pode ser testado sem mockar HTTP ou Flutter.
- Trocar a fonte de dados (ex.: outra API, banco local, arquivo embarcado) exige apenas uma nova implementação de `BibleRepository`, sem tocar em `presentation`.
- Custo: mais arquivos/indireção para um app deste porte — aceito como investimento para evolução futura (múltiplas versões da Bíblia, cache, favoritos).

### ADR-002 — Repositório como camada de tradução, não de passagem

**Status:** Aceito

**Contexto:** `BibleRemoteDataSource` retorna `RawChapter`, uma estrutura fiel ao formato do JSON da API (lista de strings por capítulo, sem tipagem de domínio).

**Decisão:** `BibleRepositoryImpl` é responsável por converter `RawChapter` em `BibleChapter`/`Verse` (entidades de domínio). O formato bruto da API nunca vaza para `domain` ou `presentation`.

**Consequências:**
- Mudanças no formato do JSON de origem ficam isoladas em `data/`.
- Entidades de domínio podem ter nomes e forma mais adequados ao app do que os do JSON.

### ADR-003 — Injeção de dependência manual via construtor

**Status:** Aceito

**Contexto:** O app é pequeno (uma tela, uma fonte de dados) e não há necessidade, ainda, de um grafo de dependências complexo.

**Decisão:** A composição das dependências (`BibleRemoteDataSource → BibleRepositoryImpl → GetBibleChapter → HomeScreen`) é feita explicitamente em `main.dart`, sem service locator (`get_it`) ou biblioteca de DI.

**Consequências:**
- Sem "magia": o grafo de dependências é legível lendo um único arquivo.
- Se o app crescer (mais usecases, múltiplas telas), reavaliar a introdução de um service locator para evitar repetição de wiring manual.

### ADR-004 — Consumo direto de JSON estático via GitHub raw, sem backend próprio

**Status:** Aceito

**Contexto:** O texto da ARC está disponível publicamente como JSON estático no repositório `MaatheusGois/bible`, versionado por livro (`versions/pt-br/arc/<bookId>/<bookId>.json`).

**Decisão:** O app consome esses arquivos diretamente via HTTP, sem backend intermediário (BFF/API própria).

**Consequências:**
- Zero infraestrutura de backend para manter.
- Acopla o app à estrutura de diretórios e ao schema desse repositório externo — uma mudança de formato lá quebra `BibleRemoteDataSource` (mitigado pela tradução do ADR-002, mas não pela disponibilidade do serviço).
- Sem cache local: cada troca de capítulo/livro é uma nova requisição de rede. Não há suporte offline. Se isso se tornar um requisito, é uma decisão a ser revisitada (cache em disco, dados embarcados no app).

### ADR-005 — Janela nativa via `window_manager`

**Status:** Aceito

**Contexto:** O app é uma aplicação desktop Linux e deve se comportar como tal (tamanho de janela definido, mínimo, centralização), não como um app mobile redimensionado.

**Decisão:** Usar o pacote `window_manager` para configurar tamanho inicial (1200x800), tamanho mínimo (900x600) e centralização, exibindo a janela apenas após pronta (`waitUntilReadyToShow`) para evitar flash de conteúdo não estilizado.

**Consequências:**
- Comportamento de janela consistente e previsível no Linux.
- Acopla o bootstrap (`main.dart`) a uma API assíncrona de inicialização antes do `runApp`.
