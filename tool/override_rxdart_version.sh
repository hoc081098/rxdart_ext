#!/bin/bash --

if [ $# -ne 0 ]; then
  echo "Changes rxdart to $RXDART_VERSION"
fi


pubspec=./pubspec.yaml
echo pubspec

if grep -qv dependency_overrides "$pubspec"; then
  cat >> "$pubspec" <<EOM
dependency_overrides:
EOM

      cat >> "$pubspec" <<EOM
  rxdart: $RXDART_VERSION
EOM
fi
