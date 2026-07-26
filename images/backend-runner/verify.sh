#!/usr/bin/env bash
set -euo pipefail

if [[ $(id -u) != 1001 ]]; then
  echo "expected runner UID 1001, got $(id -u)" >&2
  exit 1
fi

sudo -n true
command -v docker
command -v curl

while IFS= read -r package; do
  [[ -z "$package" || "$package" == \#* ]] && continue
  dpkg-query --show --showformat='${Package} ${Version}\n' "$package"
done </usr/local/share/backend-runner-packages.txt

/home/runner/run.sh --version 2>&1 | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | tail -n 1
