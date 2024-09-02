#!/bin/bash --

echo "Changes frontend_server_client to ^4.0.0"

pubspec=pubspec.yaml

cat >> "$pubspec" <<EOM
dependency_overrides:
EOM

cat >> "$pubspec" <<EOM
  frontend_server_client: ^4.0.0
EOM
  