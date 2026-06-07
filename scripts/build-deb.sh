#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if ! command -v dpkg-buildpackage >/dev/null 2>&1; then
  echo "dpkg-buildpackage not found. Install Debian packaging tools first." >&2
  exit 1
fi

rm -rf "$ROOT_DIR"/../m-translate-qt_* "${ROOT_DIR}/debian/.debhelper" "${ROOT_DIR}/debian/files" "${ROOT_DIR}/debian/m-translate-qt" || true

mkdir -p "$ROOT_DIR"/debian
chmod 755 "$ROOT_DIR"/debian/rules

dpkg-buildpackage -us -uc -b

echo
printf 'Built package(s):\n'
ls -1 "$ROOT_DIR"/../m-translate-qt_*.deb 2>/dev/null || true
