#!/usr/bin/env bash

# another *righteous entropy synthesis* by ⎰𝙉𝙄𝙈⎰ ...
# ----------------------------------------------------------------------------
#   NIM Substation One | Planet Earth | https://github.com/metasyndicate
# ----------------------------------------------------------------------------
#   ... The NIM ***Metashell***: ***cfg***
#   path and configuration resolution. builtins only — no external deps.
#   every other module asks nim.cfg.path / nim.cfg.get; path strings MUST NOT
#   appear outside this file. this is the floor of the dependency tree.
# ----------------------------------------------------------------------------

# === GLOBALS ===

# scope chain: ordered list of cfg files loaded so far (load order)
declare -ga _NIM_CFG_SCOPES=()

# === TIER-2: TRUNKS (derived from tier-1 roots set by nim.sh) ===

[[ -z ${NIM_METASHELL_ETC} ]] \
    && declare -gx NIM_METASHELL_ETC="${NIM_METASHELL}/etc"
[[ -z ${NIM_METASHELL_BIN} ]] \
    && declare -gx NIM_METASHELL_BIN="${NIM_METASHELL}/bin"
[[ -z ${NIM_METASHELL_LIB} ]] \
    && declare -gx NIM_METASHELL_LIB="${NIM_LIBPATH}"
[[ -z ${NIM_METASHELL_DAT} ]] \
    && declare -gx NIM_METASHELL_DAT="${NIM_METASHELL}/dat"
[[ -z ${NIM_METASHELL_SYS} ]] \
    && declare -gx NIM_METASHELL_SYS="${NIM_METASHELL}/sys"
[[ -z ${NIM_METASHELL_LOG} ]] \
    && declare -gx NIM_METASHELL_LOG="${NIM_OPS}/log"
[[ -z ${NIM_METASHELL_VAR} ]] \
    && declare -gx NIM_METASHELL_VAR="${NIM_OPS}/var"

# === FUNCTIONS ===
# NOTE: cfg.sh cannot use .nim.core.init.fn (core.sh is not loaded yet).
# Diagnostics use raw printf >&2.

##! @function nim.cfg.load
##! @description source a *.cfg.sh file and record it in the scope chain
##! @param <file>           absolute path to a cfg file
##! @return 0 on success, 1 if file missing/unreadable/source fails
##! @example nim.cfg.load /usr/local/nim/etc/nim.cfg
function nim.cfg.load() {
    local file="${1}"
    [[ -z ${file} ]] && {
        printf "cfg.load: file required\n" >&2
        return 1; }
    [[ -r ${file} ]] || return 1
    source "${file}" 2>/dev/null || {
        printf "cfg.load: failed to source %s\n" "${file}" >&2
        return 1; }
    _NIM_CFG_SCOPES+=( "${file}" )
    return 0; }

##! @function nim.cfg.get
##! @description resolve a config value; falls back to default if unset
##! @param <key>            variable name (e.g. NIM_LOGLEVEL)
##! @param [default=]       value if key resolves empty
##! @output resolved value on stdout
##! @return 0 always (prints default if unset)
##! @example nim.cfg.get NIM_LOGLEVEL 4
function nim.cfg.get() {
    local key="${1:-}"
    local default="${2:-}"
    [[ -z ${key} ]] && {
        printf "cfg.get: <key> required\n" >&2
        return 1; }
    printf "%s" "${!key:-${default}}"
    return 0; }

##! @function nim.cfg.path
##! @description resolve a path-bearing key with a filesystem test
##! @param <key>            path-bearing variable (e.g. NIM_METASHELL_ETC)
##! @param [test=-e]        bash test flag: -e -d -r -w -x
##! @output absolute path on stdout
##! @return 0 on success, 1 if unset or test fails
##! @example nim.cfg.path NIM_METASHELL_LIB -d
function nim.cfg.path() {
    local key="${1:-}"
    local flag="${2:--e}"
    [[ -z ${key} ]] && {
        printf "cfg.path: <key> required\n" >&2
        return 1; }
    local value="${!key}"
    [[ -z ${value} ]] && {
        printf "cfg.path: %s unset\n" "${key}" >&2
        return 1; }
    [ "${flag}" "${value}" ] || {
        printf "cfg.path: %s fails %s: %s\n" "${key}" "${flag}" "${value}" >&2
        return 1; }
    printf "%s" "${value}"
    return 0; }

##! @function nim.cfg.scopes
##! @description list cfg files loaded so far, in load order
##! @output one path per line on stdout
function nim.cfg.scopes() {
    local f
    for f in "${_NIM_CFG_SCOPES[@]}"; do
        printf "%s\n" "${f}"
    done
    return 0; }

##! @function nim.cfg.list
##! @description list all NIM_-prefixed env vars matching prefix
##! @param [prefix=NIM_]    grep prefix
##! @output formatted key=value lines on stdout
function nim.cfg.list() {
    local prefix="${1:-NIM_}"
    env | grep -E "^${prefix}" | sort
    return 0; }
