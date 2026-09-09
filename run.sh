#!/usr/bin/env bash
# flutter run -d chrome --dart-define-from-file=config.json
cd "$(dirname "$0")"
exec flutter run -d "${1:-chrome}" --dart-define-from-file=config.json
