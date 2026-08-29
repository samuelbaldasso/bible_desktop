# Bíblia ARC — Linux Desktop MVP

Projeto Flutter para Linux desktop, com janela nativa, seleção de livro/capítulo e consumo de JSON da Almeida Revista e Corrigida.

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
