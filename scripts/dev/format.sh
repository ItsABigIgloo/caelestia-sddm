#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

BOLD="\033[1m"
GREEN="\033[0;32m"
RESET="\033[0m"

mapfile -t qml_files < <(find "$ROOT_DIR" -name '*.qml' -not -path '*/build/*' | sort)

if [ ${#qml_files[@]} -eq 0 ]; then
    echo "No QML files found."
    exit 0
fi

echo -e "${BOLD}=== Formatting QML files with qmlls ===${RESET}"
python3 "$SCRIPT_DIR/qmlformat.py" "${qml_files[@]}"
echo

echo -e "${BOLD}${GREEN}Done. Run scripts/check.sh to verify.${RESET}"
