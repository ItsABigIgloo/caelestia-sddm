#!/usr/bin/env bash

# Combined QML Check Script
# Runs both linting and formatting checks
# Usage: ./scripts/dev/check-qml.sh [files...]
#   If no files specified, checks all .qml files in the project

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

LINT_ERRORS=0
FORMAT_DIFFS=0
TOTAL_FILES=0

# Prefer the Qt 6 qmllint; /usr/bin/qmllint may be the Qt 5 one (e.g. Arch)
QMLLINT="/usr/lib/qt6/bin/qmllint"
[ -x "$QMLLINT" ] || QMLLINT="qmllint"

check_file() {
    local file="$1"
    local file_display="${file#$PROJECT_ROOT/}"
    TOTAL_FILES=$((TOTAL_FILES + 1))

    # Linting check
    if ! "$QMLLINT" "$file" >/dev/null 2>&1; then
        echo "✗ Linting errors in: $file_display"
        "$QMLLINT" "$file"
        LINT_ERRORS=$((LINT_ERRORS + 1))
        return 1
    fi

    echo "✓ $file_display"
    return 0
}

main() {
    local files=()

    if [ $# -gt 0 ]; then
        # Use files provided as arguments
        files=("$@")
    else
        # Find all .qml files in the project
        while IFS= read -r -d '' file; do
            files+=("$file")
        done < <(find "$PROJECT_ROOT" -name "*.qml" -print0 2>/dev/null)
    fi

    if [ ${#files[@]} -eq 0 ]; then
        echo "No QML files to check"
        exit 0
    fi

    echo "=== QML Code Quality Check ==="
    echo "Checking ${#files[@]} file(s)..."
    echo

    for file in "${files[@]}"; do
        if [ -f "$file" ]; then
            check_file "$file" || true
        fi
    done

    echo
    echo "--- Formatting check ---"
    if ! python3 "$SCRIPT_DIR/qmlformat.py" --check "${files[@]}"; then
        FORMAT_DIFFS=$((FORMAT_DIFFS + 1))
    fi

    echo
    echo "=== Summary ==="
    echo "Files checked: $TOTAL_FILES"
    echo "Linting errors: $LINT_ERRORS"
    echo "Formatting differences: $FORMAT_DIFFS"
    echo

    if [ "$LINT_ERRORS" -gt 0 ]; then
        echo "✗ FAILED: Linting errors found"
        echo "Please fix the linting errors before continuing"
        exit 1
    elif [ "$FORMAT_DIFFS" -gt 0 ]; then
        echo "⚠ PASSED: Files need formatting"
        echo "Run: ./scripts/dev/format.sh to auto-format"
        exit 0
    else
        echo "✓ PASSED: All checks passed"
        exit 0
    fi
}

main "$@"
