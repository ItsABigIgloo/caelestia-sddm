#!/usr/bin/env bash
# Generate Xsetup for SDDM based on Hyprland monitor configuration
# Generates dynamic Xsetup that discovers X11 output names at SDDM login time

set -euo pipefail

# --- Colors ---
readonly RED=$'\033[0;31m'
readonly GREEN=$'\033[0;32m'
readonly YELLOW=$'\033[1;33m'
readonly CYAN=$'\033[0;36m'
readonly RESET=$'\033[0m'

# --- Privilege Escalation ---
if [[ $EUID -ne 0 ]]; then
	exec sudo "$0" "$@"
fi

# --- Constants ---
XSETUP_FILE="/usr/share/sddm/scripts/Xsetup"
SDDM_CONF="/etc/sddm.conf.d/caelestia.conf"

# --- Get Monitor Config Path ---
get_monitor_config_path() {
	if [[ -n "${1:-}" ]]; then
		printf '%s' "$1"
	elif [[ -n "${MONITOR_CONFIG:-}" ]]; then
		printf '%s' "${MONITOR_CONFIG}"
	else
		read -p "Path to monitor config: " MONITOR_CONFIG
		printf '%s' "${MONITOR_CONFIG}"
	fi
}

MONITOR_CONFIG=$(get_monitor_config_path "$@")

# --- Cleanup ---
cleanup() { return 0; }
trap cleanup EXIT

# --- Logging ---
log_info() { printf '%b[INFO]%b %s\n' "${CYAN}" "${RESET}" "$1"; }
log_success() { printf '%b[OK]%b %s\n' "${GREEN}" "${RESET}" "$1"; }
log_warn() { printf '%b[WARN]%b %s\n' "${YELLOW}" "${RESET}" "$1" >&2; }

# --- Validation ---
if [[ ! -f "${MONITOR_CONFIG}" ]]; then
	printf '%bError:%b config not found at %s\n' "${RED}" "${RESET}" "${MONITOR_CONFIG}" >&2
	printf 'Usage: %s [/path/to/monitor/config]\n' "$0" >&2
	exit 1
fi

log_info "Generating Xsetup from ${MONITOR_CONFIG}..."

# --- Detect config format (Lua since Hyprland 0.55, else hyprlang) ---
is_lua_config() {
	[[ "${MONITOR_CONFIG}" == *.lua ]] && return 0
	grep -q 'hl\.monitor(' "${MONITOR_CONFIG}" 2>/dev/null
}

# --- Extract a field value from a flattened hl.monitor({...}) block ---
get_lua_field() {
	local block="$1" key="$2" re
	re="${key}[[:space:]]*=[[:space:]]*[\"']?([^,\"'{}[:space:]]*)"
	[[ "$block" =~ $re ]]
	printf '%s' "${BASH_REMATCH[1]:-}"
}

# --- Emit normalized monitor records: NAME|MODE|POS|TRANSFORM|DISABLED|MIRROR ---
parse_monitors() {
	if is_lua_config; then
		local block name mode pos transform disabled mirror
		while IFS= read -r block; do
			name=$(get_lua_field "$block" output)
			mode=$(get_lua_field "$block" mode)
			pos=$(get_lua_field "$block" position)
			transform=$(get_lua_field "$block" transform)
			disabled=$(get_lua_field "$block" disabled)
			mirror=$(get_lua_field "$block" mirror)
			printf '%s|%s|%s|%s|%s|%s\n' "$name" "$mode" "$pos" "$transform" "$disabled" "$mirror"
		done < <(awk '
			/hl\.monitor\(/ { inblock=1; buf=$0 }
			inblock && $0 !~ /hl\.monitor\(/ { buf=buf" "$0 }
			inblock && /\)/ { print buf; inblock=0 }
			' "${MONITOR_CONFIG}")
	else
		local line rest name mode pos transform
		while IFS= read -r line; do
			[[ "$line" =~ ^monitor[[:space:]]*= ]] || continue
			rest="${line#*=}"
			name=$(printf '%s' "$rest" | cut -d',' -f1 | xargs)
			mode=$(printf '%s' "$rest" | cut -d',' -f2 | xargs)
			pos=$(printf '%s' "$rest" | cut -d',' -f3 | xargs)
			transform=$(printf '%s' "$rest" | cut -d',' -f5 | xargs)
			printf '%s|%s|%s|%s||\n' "$name" "$mode" "$pos" "${transform:-}"
		done <"${MONITOR_CONFIG}"
	fi
}

# --- Find primary monitor (at position 0x0) ---
PRIMARY_TYPE=""
PRIMARY_RES=""
PRIMARY_RATE=""
PRIMARY_TRANSFORM=""

while IFS='|' read -r name mode pos transform disabled mirror; do
	[[ -z "$name" || "$disabled" == "true" || -n "$mirror" ]] && continue
	[[ "$pos" != "0x0" ]] && continue
	case "$mode" in preferred|auto|"") continue ;; esac

	PRIMARY_TYPE="${name%%-*}"
	PRIMARY_RES=${mode%%@*}
	PRIMARY_RATE=${mode##*@}
	[[ "$PRIMARY_RATE" == "$mode" ]] && PRIMARY_RATE=""
	PRIMARY_TRANSFORM="${transform:-}"
	break
done < <(parse_monitors)

if [[ -z "$PRIMARY_TYPE" ]]; then
	printf '%bError:%b no primary monitor (at position 0x0) found in config\n' "${RED}" "${RESET}" >&2
	exit 1
fi

# --- Build primary xrandr options ---
PRIMARY_OPTS="--mode ${PRIMARY_RES} --pos 0x0"
[[ -n "$PRIMARY_RATE" ]] && PRIMARY_OPTS="${PRIMARY_OPTS} --rate ${PRIMARY_RATE}"
case "${PRIMARY_TRANSFORM:-}" in
1) PRIMARY_OPTS="${PRIMARY_OPTS} --rotate left" ;;
2) PRIMARY_OPTS="${PRIMARY_OPTS} --rotate inverted" ;;
3) PRIMARY_OPTS="${PRIMARY_OPTS} --rotate right" ;;
4) PRIMARY_OPTS="${PRIMARY_OPTS} --reflect x" ;;
5) PRIMARY_OPTS="${PRIMARY_OPTS} --rotate left --reflect x" ;;
6) PRIMARY_OPTS="${PRIMARY_OPTS} --rotate inverted --reflect x" ;;
7) PRIMARY_OPTS="${PRIMARY_OPTS} --rotate right --reflect x" ;;
esac
PRIMARY_OPTS="${PRIMARY_OPTS} --primary"

log_info "Primary: ${PRIMARY_TYPE} ${PRIMARY_RES}${PRIMARY_RATE:+@${PRIMARY_RATE}}"

# --- Write dynamic Xsetup (discovers X11 output names at SDDM login time) ---
cat > "${XSETUP_FILE}" <<EOF
#!/bin/sh
# Xsetup - generated from Hyprland monitors.conf
# Primary: ${PRIMARY_TYPE} ${PRIMARY_RES}${PRIMARY_RATE:+@${PRIMARY_RATE}}
export DISPLAY=:0
xrandr > /tmp/xsetup.log 2>&1

# Find primary output by connector type, fallback to resolution match
PRIMARY_OUT=\$(awk '/ connected/ && /^${PRIMARY_TYPE}-[0-9]/{print \$1; exit}' /tmp/xsetup.log)
[ -z "\$PRIMARY_OUT" ] && PRIMARY_OUT=\$(awk '/ connected/{o=\$1} \$1=="${PRIMARY_RES}"{if(o){print o;exit}}' /tmp/xsetup.log)

# Turn off all others, enable primary only
[ -n "\$PRIMARY_OUT" ] && xrandr \$(awk -v p="\$PRIMARY_OUT" '/ connected/{if(\$1!=p) printf "--output %s --off ", \$1}' /tmp/xsetup.log) --output "\$PRIMARY_OUT" ${PRIMARY_OPTS}
EOF
chmod 755 "${XSETUP_FILE}"

# --- Update SDDM config ---
update_sddm_conf() {
	local section="$1"
	local key="$2"
	local value="$3"

	if grep -q "^\[${section}\]" "${SDDM_CONF}" 2>/dev/null; then
		grep -q "^${key}=" "${SDDM_CONF}" 2>/dev/null || printf '%s=%s\n' "$key" "$value" >>"${SDDM_CONF}"
	else
		printf '\n[%s]\n%s=%s\n' "$section" "$key" "$value" >>"${SDDM_CONF}"
	fi
}

update_sddm_conf "X11" "DisplayCommand" "${XSETUP_FILE}"

log_success "Xsetup generated at ${XSETUP_FILE}"
