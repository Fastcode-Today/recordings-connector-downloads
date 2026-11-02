#!/usr/bin/env bash
set -Eeuo pipefail
umask 077
fail() { printf 'Error: %s\n' "$1" >&2; exit 1; }
fetch() { curl -q --fail --silent --show-error --location --proto '=https' --proto-redir '=https' --connect-timeout 15 --max-time 180 "$1" --output "$2"; }
value() { local n; n=$(awk -F= -v k="$1" '$1==k {n++} END {print n+0}' "$2"); [[ "$n" == 1 ]] || fail 'Invalid public release manifest'; awk -F= -v k="$1" '$1==k {print substr($0,length(k)+2)}' "$2"; }
[[ $# == 0 || ( $# == 1 && "$1" == --upgrade ) ]] || fail 'Usage: bash install.sh [--upgrade]'
for cmd in docker curl sha256sum awk flock; do command -v "$cmd" >/dev/null || fail "Missing dependency: $cmd"; done
docker compose version >/dev/null
docker info >/dev/null
ROOT="$PWD/recordings-connector"
if [[ "${1:-}" == --upgrade ]]; then
  if [[ -f .env && -f compose.yaml ]]; then ROOT=$PWD; fi
  [[ -f "$ROOT/.env" && -f "$ROOT/compose.yaml" ]] || fail 'Run from the existing installation or its parent directory'
elif [[ -e "$ROOT" ]]; then
  printf 'Installation already exists. Edit recordings-connector/.env and start Docker Compose, or use --upgrade.\n'; exit 0
fi
[[ ! -L "$ROOT" ]] || fail 'Installation path cannot be a symbolic link'
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT
fetch "https://raw.githubusercontent.com/Fastcode-Today/recordings-connector-downloads/main/channels/pilot.env?check=$RANDOM-$$" "$WORK/channel"
VERSION=$(value VERSION "$WORK/channel")
[[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[a-z0-9.-]+)?$ ]] || fail 'Invalid approved version'
BASE="https://github.com/Fastcode-Today/recordings-connector-downloads/releases/download/v$VERSION"
fetch "$BASE/update.env" "$WORK/update.env"
EXPECTED=$(value MANIFEST_SHA256 "$WORK/channel")
[[ "$EXPECTED" =~ ^[a-f0-9]{64}$ ]] || fail 'Invalid manifest checksum'
ACTUAL=$(sha256sum "$WORK/update.env"); [[ "${ACTUAL%% *}" == "$EXPECTED" ]] || fail 'Manifest checksum mismatch'
[[ "$(value FORMAT "$WORK/update.env")" == 1 && "$(value VERSION "$WORK/update.env")" == "$VERSION" ]] || fail 'Unsupported manifest'
DIGEST=$(value IMAGE_DIGEST "$WORK/update.env")
[[ "$DIGEST" =~ ^sha256:[a-f0-9]{64}$ ]] || fail 'Invalid image digest'
for NAME in connector compose.yaml; do
  fetch "$BASE/$NAME" "$WORK/$NAME"
  if [[ "$NAME" == connector ]]; then KEY=LAUNCHER_SHA256; else KEY=COMPOSE_SHA256; fi
  EXPECTED=$(value "$KEY" "$WORK/update.env")
  [[ "$EXPECTED" =~ ^[a-f0-9]{64}$ ]] || fail 'Invalid asset checksum'
  ACTUAL=$(sha256sum "$WORK/$NAME"); [[ "${ACTUAL%% *}" == "$EXPECTED" ]] || fail 'Downloaded asset checksum mismatch'
done
grep -Fxq "    image: ghcr.io/fastcode-today/recordings-connector:$VERSION@$DIGEST" "$WORK/compose.yaml" || fail 'Image does not match approved release'
chmod 700 "$WORK/connector"
if [[ "${1:-}" == --upgrade ]]; then
  # Do not overwrite credentials, Compose or a pending update journal here.
  cp "$WORK/connector" "$ROOT/.connector-launcher.next"
  chmod 700 "$ROOT/.connector-launcher.next"
  mv "$ROOT/.connector-launcher.next" "$ROOT/connector"
  "$ROOT/connector" update
else
  mkdir -m 700 "$ROOT"
  cp "$WORK/compose.yaml" "$WORK/connector" "$ROOT/"
  printf 'FASTVOICE_TOKEN=PEGUE_SU_TOKEN\nRECORDINGS_PATH=./recordings\n' > "$ROOT/.env"
  chmod 600 "$ROOT/.env"
  printf 'Prepared version %s in %s\n1. cd recordings-connector\n2. Edit .env: FASTVOICE_TOKEN and RECORDINGS_PATH\n3. docker compose up -d\nUpdates: ./connector update\n' "$VERSION" "$ROOT"
fi
