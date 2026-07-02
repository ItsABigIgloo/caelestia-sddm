#!/usr/bin/env bash
# Generate Xsetup for SDDM based on Hyprland monitor configuration
# Converts Wayland monitor names to X11 names for xrandr

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

# --- Map Wayland to X11 names ---
get_x11_name() {
	local wl_name="$1"
	case "${wl_name}" in
	DP-[0-9]*) printf "DP-%d" "${wl_name#DP-}" ;;
	HDMI-A-[0-9]*) printf "HDMI-%d" "${wl_name#HDMI-A-}" ;;
	HDMI-[0-9]*) printf "HDMI-%d" "${wl_name#HDMI-}" ;;
	eDP-[0-9]*) printf "eDP-%d" "${wl_name#eDP-}" ;;
	*) printf '%s' "$wl_name" ;;
	esac
}

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

# --- Generate xrandr command ---
XRANDR_CMD="xrandr"
PRIMARY_SET=false

while IFS='|' read -r name mode pos transform disabled mirror; do
	# Skip wildcard / disabled / mirrored entries — no concrete xrandr target
	[[ -z "$name" || "$disabled" == "true" || -n "$mirror" ]] && continue
	case "$mode" in preferred|auto|"") continue ;; esac
	case "$pos" in auto|"") continue ;; esac

	XL_NAME=$(get_x11_name "$name")
	RES=${mode%%@*}
	RATE=${mode##*@}
	[[ "$RATE" == "$mode" ]] && RATE=""

	ROTATE=""; REFLECT=""
	case "${transform:-}" in
	0) ROTATE="normal" ;;
	1) ROTATE="left" ;;
	2) ROTATE="inverted" ;;
	3) ROTATE="right" ;;
	4) ROTATE="normal"; REFLECT="x" ;;
	5) ROTATE="left"; REFLECT="x" ;;
	6) ROTATE="inverted"; REFLECT="x" ;;
	7) ROTATE="right"; REFLECT="x" ;;
	esac

	CMD_PART="--output ${XL_NAME}"
	[[ -n "$ROTATE" ]] && CMD_PART="${CMD_PART} --rotate ${ROTATE}"
	[[ -n "$REFLECT" ]] && CMD_PART="${CMD_PART} --reflect ${REFLECT}"
	CMD_PART="${CMD_PART} --mode ${RES} --pos ${pos}"
	[[ -n "$RATE" ]] && CMD_PART="${CMD_PART} --rate ${RATE}"
	XRANDR_CMD="${XRANDR_CMD} ${CMD_PART}"

	if [[ "$pos" == "0x0" && "$PRIMARY_SET" == "false" ]]; then
		XRANDR_CMD="${XRANDR_CMD} --primary"
		PRIMARY_SET=true
	fi
done < <(parse_monitors)

# --- Write Xsetup ---
OUTPUT="#!/bin/sh
# Xsetup - generated from Hyprland monitors.conf
export DISPLAY=:0
xrandr > /tmp/xsetup.log 2>&1
${XRANDR_CMD}
"

printf '%s' "$OUTPUT" | tee "${XSETUP_FILE}" >/dev/null
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
