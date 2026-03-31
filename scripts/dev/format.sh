#!/usr/bin/env bash

# QML Formatter Script
# Usage: ./scripts/format.sh [-i] [-n] [files...]
#   -i  Format files in-place
#   -n  Do not sort imports (keep original order)
# If no files specified, formats all .qml files in the project

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
INPLACE=0
NO_SORT=0
FILES=()

for arg in "$@"; do
    case $arg in
        -i|--inplace)
            INPLACE=1
            shift
            ;;
        -n|--no-sort)
            NO_SORT=1
            shift
            ;;
        -*)
            echo "Unknown option: $arg" >&2
            echo "Usage: $0 [-i] [-n] [files...]" >&2
            exit 1
            ;;
        *)
            FILES+=("$arg")
            ;;
    esac
done

build_qmlformat_args() {
    local args=()
    [ "$INPLACE" -eq 1 ] && args+=("-i")
    [ "$NO_SORT" -eq 1 ] && args+=("-n")
    echo "${args[@]}"
}

main() {
    local files=()

    if [ ${#FILES[@]} -gt 0 ]; then
        files=("${FILES[@]}")
    else
        # Check if in git repo and only format changed files
        if git rev-parse --git-dir >/dev/null 2>&1; then
            # Only format staged or modified .qml files
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
            # Not in git repo, format all .qml files
            while IFS= read -r -d '' file; do
                files+=("$file")
            done < <(find "$PROJECT_ROOT" -name "*.qml" -print0 2>/dev/null)
        fi
    fi

    if [ ${#files[@]} -eq 0 ]; then
        echo "No QML files to format"
        exit 0
    fi

    local args
    args=$(build_qmlformat_args)
    local mode
    if [ "$INPLACE" -eq 1 ]; then
        mode="Formatting in-place"
    else
        mode="Previewing formatting"
    fi

    echo "=== QML Formatter ==="
    echo "$mode ${#files[@]} file(s)..."
    [ "$NO_SORT" -eq 1 ] && echo "(imports will not be sorted)"
    echo

    for file in "${files[@]}"; do
        if [ ! -f "$file" ]; then
            echo "✗ File not found: ${file#$PROJECT_ROOT/}"
            continue
        fi

        local file_display="${file#$PROJECT_ROOT/}"

        if [ "$INPLACE" -eq 1 ]; then
            qmlformat $args "$file" >/dev/null 2>&1
            echo "✓ Formatted: $file_display"
        else
            if ! qmlformat $args "$file" >/dev/null 2>&1; then
                echo "✗ Error formatting: $file_display"
            else
                local formatted
                formatted=$(qmlformat $args "$file" 2>/dev/null)

                if diff -q <(cat "$file") <(echo "$formatted") >/dev/null 2>&1; then
                    [ "$NO_SORT" -eq 0 ] && echo "✓ Already formatted: $file_display"
                else
                    echo "→ Needs formatting: $file_display"
                    echo "---"
                    echo "$formatted"
                    echo "---"
                fi
            fi
        fi
    done

    echo
    echo "✓ Done"
}

main "$@"
