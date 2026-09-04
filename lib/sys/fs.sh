#!/usr/bin/env bash

# another *righteous entropy synthesis* by ⎰𝙉𝙄𝙈⎰ ...
# ----------------------------------------------------------------------------
#   NIM Substation One | Planet Earth | https://github.com/metasyndicate
# ----------------------------------------------------------------------------
#   ... The NIM ***Metashell***: ***fs***
#   filesystem helpers with logging. mkdir-with-permissions, atomic writes,
#   timestamped backups, log rotation. wraps coreutils so failures are
#   loud and the audit trail captures every mutation.
# ----------------------------------------------------------------------------

nim.source core fn log

# === PUBLIC ===

##! @function nim.fs.mkdir
##! @description create a directory (with parents); validate it's writable
##! @param <path>
##! @param [mode=0755]
##! @return 0 on success, 1 on failure
##! @example nim.fs.mkdir "${NIM_OPS}/log" 0750
function nim.fs.mkdir() { .nim.core.init.fn || return 1
    nim.fn.validate.args "${@}" || return 1
    local path="${1}"
    local mode="${2:-0755}"
    [[ -d ${path} ]] && return 0
    mkdir -p "${path}" 2>/dev/null || {
        nim.log.error "fs.mkdir: failed: ${path}"
        return 1; }
    chmod "${mode}" "${path}" 2>/dev/null
    [[ -w ${path} ]] || {
        nim.log.error "fs.mkdir: not writable: ${path}"
        return 1; }
    nim.log.info "fs.mkdir: ${path} (${mode})"
    return 0; }

##! @function nim.fs.touch
##! @description create an empty file (with parent dirs) if it doesn't exist
##! @param <path>
function nim.fs.touch() { .nim.core.init.fn || return 1
    nim.fn.validate.args "${@}" || return 1
    local path="${1}"
    [[ -e ${path} ]] && return 0
    nim.fs.mkdir "$(dirname "${path}")" || return 1
    touch "${path}" 2>/dev/null || {
        nim.log.error "fs.touch: failed: ${path}"
        return 1; }
    nim.log.info "fs.touch: ${path}"
    return 0; }

##! @function nim.fs.backup
##! @description copy a file alongside itself with a timestamp suffix
##! @param <path>           file to back up
##! @output backup path on stdout
##! @return 0 on success, 1 if source missing
##! @example nim.fs.backup ~/.bashrc
function nim.fs.backup() { .nim.core.init.fn || return 1
    nim.fn.validate.args "${@}" || return 1
    local path="${1}"
    [[ -r ${path} ]] || {
        nim.log.error "fs.backup: not readable: ${path}"
        return 1; }
    local stamp
    stamp="$(date +'%Y%m%dT%H%M%S')"
    local backup="${path}.${stamp}.bak"
    cp -p "${path}" "${backup}" 2>/dev/null || {
        nim.log.error "fs.backup: cp failed: ${path}"
        return 1; }
    nim.log.info "fs.backup: ${path} → ${backup}"
    printf "%s" "${backup}"
    return 0; }

##! @function nim.fs.find
##! @description find files under a root matching a pattern
##! @param <root>           starting directory
##! @param <pattern>        find -name glob
##! @output one path per line on stdout
function nim.fs.find() { .nim.core.init.fn || return 1
    nim.fn.validate.args "${@}" || return 1
    local root="${1}"
    local pattern="${2}"
    [[ -d ${root} ]] || {
        nim.log.error "fs.find: not a directory: ${root}"
        return 1; }
    find "${root}" -type f -name "${pattern}" 2>/dev/null
    return 0; }

##! @function nim.fs.size
##! @description size of a file in bytes (portable across BSD/GNU stat)
##! @param <path>
##! @output integer byte count on stdout
function nim.fs.size() { .nim.core.init.fn || return 1
    nim.fn.validate.args "${@}" || return 1
    local path="${1}"
    [[ -e ${path} ]] || return 1
    local size
    size="$(stat -f '%z' "${path}" 2>/dev/null \
        || stat -c '%s' "${path}" 2>/dev/null)"
    printf "%s" "${size}"
    return 0; }
