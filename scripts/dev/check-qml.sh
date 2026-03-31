#!/usr/bin/env bash

# Combined QML Check Script
# Runs both linting and formatting checks
# Blocks on linting errors, warns on formatting differences

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

LINT_ERRORS=0
FORMAT_DIFFS=0
TOTAL_FILES=0

check_file() {
    local file="$1"
    local file_display="${file#$PROJECT_ROOT/}"
    TOTAL_FILES=$((TOTAL_FILES + 1))

    # Linting check
    if ! qmllint "$file" >/dev/null 2>&1; then
        echo "✗ Linting errors in: $file_display"
        qmllint "$file"
        LINT_ERRORS=$((LINT_ERRORS + 1))
        return 1
    fi

    # Formatting check
    local formatted
    formatted=$(qmlformat "$file" 2>/dev/null)

    if [ -z "$formatted" ]; then
        echo "✗ Could not format: $file_display"
        LINT_ERRORS=$((LINT_ERRORS + 1))
        return 1
    fi

    if ! diff -q <(cat "$file") <(echo "$formatted") >/dev/null 2>&1; then
        echo "⚠ Formatting differs: $file_display"
        FORMAT_DIFFS=$((FORMAT_DIFFS + 1))
        echo "   Run: ./scripts/format.sh -i \"$file\""
    fi

    echo "✓ $file_display"
    return 0
}

main() {
    local files=()

    # Get QML files to check
    if git rev-parse --git-dir >/dev/null 2>&1; then
        # Check staged or modified files
        while IFS= read -r -d '' file; do
            if [[ "$file" == *.qml ]]; then
                files+=("$file")
            fi
        done < <(git diff --cached --name-only -z --diff-filter=ACM 2>/dev/null)
        
        if [ ${#files[@]} -eq 0 ]; then
            # Fallback to all .qml files
            while IFS= read -r -d '' file; do
                files+=("$file")
            done < <(find "$PROJECT_ROOT" -name "*.qml" -print0 2>/dev/null)
        fi
    else
        # Not in git repo, check all .qml files
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
            check_file "$file"
        fi
    done

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
        echo "Run: ./scripts/format.sh -i to auto-format"
        exit 0
    else
        echo "✓ PASSED: All checks passed"
        exit 0
    fi
}

main "$@"
