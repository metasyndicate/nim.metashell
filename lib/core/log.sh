#!/usr/bin/env bash

# another *righteous entropy synthesis* by ⎰𝙉𝙄𝙈⎰ ...
# ----------------------------------------------------------------------------
#   NIM Substation One | Planet Earth | https://github.com/metasyndicate
# ----------------------------------------------------------------------------
#   ... The NIM ***Metashell***: ***log***
#   structured logging. routes through logger(1) when available; falls back
#   to direct file append. mirrors WARN+ to stderr. NIM_LOGLEVEL gates
#   debug/info; error/warn always emit.
# ----------------------------------------------------------------------------

# === GLOBALS ===

# 0=off, 3=err, 4=warn, 6=info, 7=trace
[[ -z ${NIM_LOGLEVEL} ]] && declare -gx NIM_LOGLEVEL=4
[[ -z ${NIM_LOGTAG} ]]   && declare -gx NIM_LOGTAG="${NIM_TAG:-nim}"
[[ -z ${NIM_LOGFILE} ]] && \
    declare -gx NIM_LOGFILE="${NIM_OPS:-${HOME}/.nim}/log/nim.log"

# === PRIVATE ===

##! @function .nim.log.write.fn
##! @description low-level write: stamp, tag, route, mirror WARN+
##! @param <level>          error|warn|info|debug|trace
##! @param <msg>            message text
function .nim.log.write.fn() {
    local level="${1}"
    local msg="${2}"
    local stamp; stamp="$(date +'%Y-%m-%dT%H:%M:%S%z')"
    local caller="${FUNCNAME[2]:-${FUNCNAME[1]:-main}}"
    local line="[${stamp}] ${level^^} ${caller}: ${msg}"

    command -v logger >/dev/null 2>&1 \
        && logger -t "${NIM_LOGTAG}" -p "user.${level}" \
                  -- "${msg}" 2>/dev/null

    local dir; dir="$(dirname "${NIM_LOGFILE}")"
    [[ -d ${dir} ]] || mkdir -p "${dir}" 2>/dev/null
    printf "%s\n" "${line}" >> "${NIM_LOGFILE}" 2>/dev/null
    [[ ${level} =~ ^(error|warn)$ ]] && printf "%s\n" "${line}" >&2
    return 0; }

# === PUBLIC ===

##! @function nim.log.error
##! @description emit ERROR; always logged, always mirrored to stderr
##! @param <msg>...
function nim.log.error() { .nim.log.write.fn error "${*}"; }

##! @function nim.log.warn
##! @description emit WARN; always logged, always mirrored to stderr
##! @param <msg>...
function nim.log.warn() { .nim.log.write.fn warn "${*}"; }

##! @function nim.log.info
##! @description emit INFO; gated by NIM_LOGLEVEL >= 6
##! @param <msg>...
function nim.log.info() {
    (( NIM_LOGLEVEL >= 6 )) && .nim.log.write.fn info "${*}"
    return 0; }

##! @function nim.log.debug
##! @description emit DEBUG; gated by NIM_LOGLEVEL >= 7
##! @param <msg>...
function nim.log.debug() {
    (( NIM_LOGLEVEL >= 7 )) && .nim.log.write.fn debug "${*}"
    return 0; }

##! @function nim.log.trace
##! @description emit TRACE; gated by NIM_LOGLEVEL >= 7
##! @param <msg>...
function nim.log.trace() {
    (( NIM_LOGLEVEL >= 7 )) && .nim.log.write.fn trace "${*}"
    return 0; }

##! @function nim.log
##! @description generic dispatcher: nim.log <level> <msg>
##! @param <level>          error|warn|info|debug|trace (else: text)
##! @param <msg>...         message text
##! @example nim.log error "config validation failed"
function nim.log() {
    local level="${1}"
    shift
    case "${level}" in
        error|warn|info|debug|trace) "nim.log.${level}" "${*}" ;;
        *) nim.log.info "${level} ${*}" ;;
    esac
    return 0; }

##! @function nim.log.stamp.begin
##! @description mark session start in the logfile
function nim.log.stamp.begin() {
    local stamp; stamp="$(date +'%Y-%m-%dT%H:%M:%S%z')"
    printf "\n--- BEGIN %s ---\n" "${stamp}" >> "${NIM_LOGFILE}"
    return 0; }

##! @function nim.log.stamp.end
##! @description mark session end in the logfile
function nim.log.stamp.end() {
    local stamp; stamp="$(date +'%Y-%m-%dT%H:%M:%S%z')"
    printf "--- END   %s ---\n\n" "${stamp}" >> "${NIM_LOGFILE}"
    return 0; }
