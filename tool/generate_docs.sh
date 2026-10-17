#!/bin/sh
set -eu

# Usage: sh tool/generate_docs.sh [dartdoc options]
# Requires Dart 3.9+ for documentation tooling only; the package supports Dart 3.0.
# Dartdoc 9.0.0 bundled with Dart 3.10.3 generates broken RxDart re-export links.
# Use the fixed version without changing the package's SDK or dependencies.
# https://github.com/dart-lang/dartdoc/pull/4240
rxdart_ext_package_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
rxdart_ext_tool_dir="$rxdart_ext_package_dir/.dart_tool/dartdoc_tool"
rxdart_ext_dart=${RXDART_EXT_DART:-dart}

mkdir -p "$rxdart_ext_tool_dir"
cat > "$rxdart_ext_tool_dir/pubspec.yaml" <<'YAML'
name: rxdart_ext_dartdoc_tool
publish_to: none
environment:
  sdk: ^3.9.0
dependencies:
  dartdoc: 9.0.5
YAML

"$rxdart_ext_dart" --suppress-analytics pub get --directory "$rxdart_ext_tool_dir"
cd "$rxdart_ext_tool_dir"
"$rxdart_ext_dart" --suppress-analytics run dartdoc \
  --input "$rxdart_ext_package_dir" \
  --output "$rxdart_ext_package_dir/doc/api" \
  --validate-links \
  --errors=broken-link,no-library-level-docs,unresolved-doc-reference \
  "$@"
