# Repository Guidelines

## Project Structure & Module Organization

`rxdart_ext` is a Dart library extending RxDart. Public entry points live in `lib/*.dart`; implementations are grouped under `lib/src/` into `single`, `operators`, `state_stream`, `not_replay_value_stream`, and `utils`. Expose new APIs through the corresponding `index.dart` and public library exports.

`test/` mirrors those modules. `example/lib/` contains runnable examples and snippets. `screenshots/` holds package imagery; `check_urls/` contains a separate README link checker. CI workflows live in `.github/workflows/`.

## Build, Test, and Development Commands

Use Dart 3; CI covers Dart 3.0.0, stable, and beta. Run these from the repository root:

- `dart pub get` — install library and test dependencies.
- `dart analyze lib --fatal-infos --fatal-warnings` — run the CI analyzer gate.
- `dart format . --set-exit-if-changed` — format code and flag formatting changes.
- `dart run test test/rxdart_ext_test.dart --chain-stack-traces` — run the CI test suite.
- `dart run test test/operators/distinct_by_test.dart` — run a focused test file.
- `dart run build_runner build --delete-conflicting-outputs` — regenerate Mockito mocks after annotation changes.

On stable/beta, CI runs `sh tool/override_frontend_server_client_version.sh` before dependency resolution. This appends a dependency override to `pubspec.yaml`; apply once and keep that temporary change out of commits.

To run examples, enter `example/`, run `dart pub get`, then `dart run lib/rxdart_ext_example.dart`.

## Coding Style & Naming Conventions

Use two-space indentation, `snake_case.dart` filenames, `UpperCamelCase` types, and `lowerCamelCase` members. Follow `analysis_options.yaml`: recommended lints, strict typing, single quotes, relative internal imports, explicit return types, and final locals where possible. Document public APIs with `///` comments and handle unawaited futures explicitly.

## Testing Guidelines

Use `package:test` and Mockito. Name tests `*_test.dart`, group by API, and cover stream events, errors, completion, cancellation, and subscription behavior as applicable. Register new test files in `test/rxdart_ext_test.dart` with an import and a `main()` call so CI includes them. CI uploads coverage to Codecov; no numeric coverage threshold is configured.

## Commit & Pull Request Guidelines

History includes imperative subjects (`Update dependencies…`) and scoped Conventional Commits (`feat(single): …`). Use `<type>(<scope>): <summary>` for new commits. Keep PRs focused; describe behavior changes, link relevant issues, and list validation commands and results. For public API changes, update exports, tests, `README.md`, `CHANGELOG.md`, and relevant examples.
