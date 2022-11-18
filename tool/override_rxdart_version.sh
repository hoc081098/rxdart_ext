#!/bin/bash --

if [ "$RXDART_VERSION" -eq "" ];then
  echo "Missing RXDART_VERSION environment variable"
  exit 1
fi

if [ $# -ne 0 ]; then
  echo "Changes rxdart to $RXDART_VERSION"
fi

pubspec=pubspec.yaml

cat >> "$pubspec" <<EOM
dependency_overrides:
EOM

cat >> "$pubspec" <<EOM
  rxdart: $RXDART_VERSION
EOM
