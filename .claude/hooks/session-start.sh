#!/bin/bash
# Prépare une session Claude Code dans le cloud : installe Flutter et les paquets
# pour pouvoir lancer `flutter analyze` et `flutter test`.
set -euo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

FLUTTER_VERSION="3.47.7"
FLUTTER_DIR="/opt/flutter"

if [ ! -x "$FLUTTER_DIR/bin/flutter" ]; then
  # Clone dans un dossier temporaire puis déplacement : un clone interrompu
  # ne laisse jamais un /opt/flutter à moitié rempli.
  rm -rf "$FLUTTER_DIR" "$FLUTTER_DIR.tmp"
  git clone --depth 1 -b "$FLUTTER_VERSION" https://github.com/flutter/flutter.git "$FLUTTER_DIR.tmp"
  mv "$FLUTTER_DIR.tmp" "$FLUTTER_DIR"
fi

export PATH="$FLUTTER_DIR/bin:$PATH"
if [ -n "${CLAUDE_ENV_FILE:-}" ]; then
  echo "export PATH=\"$FLUTTER_DIR/bin:\$PATH\"" >> "$CLAUDE_ENV_FILE"
fi

flutter config --no-analytics >/dev/null 2>&1 || true
flutter --version >/dev/null

cd "${CLAUDE_PROJECT_DIR:-$(pwd)}"
flutter pub get
flutter gen-l10n
