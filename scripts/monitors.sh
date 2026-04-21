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

# --- Generate xrandr command ---
XRANDR_CMD="xrandr"
PRIMARY_SET=false

while IFS= read -r line; do
	[[ "$line" =~ ^monitor[[:space:]]*= ]] || continue

	name=$(printf '%s' "$line" | sed 's/monitor = //' | cut -d',' -f1 | xargs)
	rate=$(printf '%s' "$line" | sed 's/monitor = //' | cut -d',' -f2 | xargs)
	pos=$(printf '%s' "$line" | sed 's/monitor = //' | cut -d',' -f3 | xargs)

	transform=""
	if [[ "$line" =~ transform.*[[:space:]]+[0-9] ]]; then
		transform=$(printf '%s' "$line" | sed -n 's/.*transform, *\([0-9]\).*/\1/p')
	fi

	XL_NAME=$(get_x11_name "$name")
	RES=${rate%%@*}
	RATE=${rate##*@}

	case "${transform:-}" in
	0) ROTATE="normal" ;;
	1) ROTATE="left" ;;
	2) ROTATE="inverted" ;;
	3) ROTATE="right" ;;
	*) ROTATE="" ;;
	esac

	if [[ -n "$transform" ]]; then
		XRANDR_CMD="${XRANDR_CMD} --output ${XL_NAME} --rotate ${ROTATE} --mode ${RES} --rate ${RATE} --pos ${pos}"
	else
		XRANDR_CMD="${XRANDR_CMD} --output ${XL_NAME} --mode ${RES} --rate ${RATE} --pos ${pos}"
	fi

	if [[ "$pos" == "0x0" && "$PRIMARY_SET" == "false" ]]; then
		XRANDR_CMD="${XRANDR_CMD} --primary"
		PRIMARY_SET=true
	fi
done <"${MONITOR_CONFIG}"

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
