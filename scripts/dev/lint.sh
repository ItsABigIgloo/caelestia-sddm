#!/usr/bin/env bash

# QML Linter Script
# Usage: ./scripts/lint.sh [-v] [files...]
#   -v  Verbose mode (show all files checked)
# If no files specified, checks all .qml files in the project

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
VERBOSE=0
FAILURES=0

for arg in "$@"; do
    case $arg in
        -v|--verbose)
            VERBOSE=1
            shift
            ;;
    esac
done

check_file() {
    local file="$1"
    local file_display="${file#$PROJECT_ROOT/}"

    if [ "$VERBOSE" -eq 1 ]; then
        echo "Checking: $file_display"
    fi

    if qmllint "$file" 2>&1 | grep -q "."; then
        echo "✗ Linting errors in: $file_display"
        qmllint "$file"
        FAILURES=$((FAILURES + 1))
        return 1
    else
        [ "$VERBOSE" -eq 1 ] && echo "✓ $file_display"
        return 0
    fi
}

main() {
    local files=()

    if [ $# -gt 0 ]; then
        files=("$@")
    else
        # Check if in git repo and only lint changed files
        if git rev-parse --git-dir >/dev/null 2>&1; then
            # Only lint staged or modified .qml files
            while IFS= read -r -d '' file; do
                if [[ "$file" == *.qml ]]; then
                    files+=("$file")
                fi
            done < <(git diff --cached --name-only -z --diff-filter=ACM 2>/dev/null)
            
            if [ ${#files[@]} -eq 0 ]; then
                # Fallback to all .qml files if no staged changes
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
    fi

    if [ ${#files[@]} -eq 0 ]; then
        echo "No QML files to lint"
        exit 0
    fi

    echo "=== QML Lint Check ==="
    echo "Checking ${#files[@]} file(s)..."
    echo

    for file in "${files[@]}"; do
        if [ -f "$file" ]; then
            check_file "$file"
        fi
    done

    echo
    echo "=== Result ==="
    if [ "$FAILURES" -gt 0 ]; then
        echo "✗ Failed: $FAILURES file(s) with linting errors"
        exit 1
    else
        echo "✓ All QML files passed linting"
        exit 0
    fi
}

main "$@"
