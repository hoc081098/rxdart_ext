#!/bin/bash --

if [ "$RXDART_VERSION" = "" ];then
  echo "Missing RXDART_VERSION environment variable"
  exit 1
fi

echo "Changes rxdart to $RXDART_VERSION"

pubspec=pubspec.yaml

cat >> "$pubspec" <<EOM
dependency_overrides:
EOM

cat >> "$pubspec" <<EOM
  rxdart: $RXDART_VERSION
EOM
