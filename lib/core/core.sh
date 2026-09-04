#!/usr/bin/env bash

# another *righteous entropy synthesis* by ⎰𝙉𝙄𝙈⎰ ...
# ----------------------------------------------------------------------------
#   NIM Substation One | Planet Earth | https://github.com/metasyndicate
# ----------------------------------------------------------------------------
#   ... The NIM ***Metashell***: ***core***
#   primitives. sourcing, path resolution, environment validation.
#   every higher function in the metashell begins by calling
#   .nim.core.init.fn.
# ----------------------------------------------------------------------------

# === GLOBALS ===

# Module-load registry. nim.source consults this for idempotency.
declare -gA _NIM_LOADED 2>/dev/null

# Library search paths. NIM_LIBPATH is element 0; subsystem registration
# via nim.mod.register appends additional paths. nim.source iterates this.
declare -ga _NIM_LIBPATHS 2>/dev/null
[[ ${#_NIM_LIBPATHS[@]} -eq 0 ]] && _NIM_LIBPATHS=( "${NIM_LIBPATH}" )

# === PRIVATE ===

##! @function .nim.core.init.fn
##! @description universal function prologue — env check + hook point
##! @description called by every public nim.* function as:
##!              .nim.core.init.fn || return 1
##! @return 0 if environment is valid, 1 otherwise (diagnostic to stderr)
function .nim.core.init.fn() {
    [[ -z ${NIM_LIBPATH} ]] && {
        printf "nim: NIM_LIBPATH undefined\n" >&2
        return 1; }
    [[ -d ${NIM_LIBPATH} ]] || {
        printf "nim: NIM_LIBPATH invalid (%s)\n" "${NIM_LIBPATH}" >&2
        return 1; }
    return 0; }

# === PUBLIC ===

##! @function nim.path.absolute
##! @description resolve an absolute path with cross-platform fallbacks
##! @param [path=${BASH_SOURCE}]    relative or absolute path
##! @output canonical absolute path on stdout
##! @return 0 on success, 1 if unable to resolve
##! @example nim.path.absolute ./foo.sh
function nim.path.absolute() { .nim.core.init.fn || return 1
    local path="${1:-${BASH_SOURCE[0]:-${PWD}}}"
    [[ -z ${path} ]] && return 1
    realpath "${path}" 2>/dev/null && return 0
    readlink -f "${path}" 2>/dev/null && return 0
    ( cd "$(dirname "${path}" 2>/dev/null)" 2>/dev/null \
        && printf "%s/%s" "${PWD}" "$(basename "${path}")" ) && return 0
    return 1; }

##! @function nim.path.init
##! @description create + validate a directory path
##! @param <path>           target directory
##! @return 0 on success, 1 if mkdir or validation fails
##! @example nim.path.init "${NIM_OPS}/log"
function nim.path.init() { .nim.core.init.fn || return 1
    local path="${1}"
    [[ -z ${path} ]] && {
        printf "path.init: path required\n" >&2
        return 1; }
    [[ -d ${path} ]] && return 0
    mkdir -p "${path}" 2>/dev/null || {
        printf "path.init: mkdir failed: %s\n" "${path}" >&2
        return 1; }
    [[ -w ${path} ]] || {
        printf "path.init: not writable: %s\n" "${path}" >&2
        return 1; }
    return 0; }

##! @function nim.source
##! @description resolve <name> against _NIM_LIBPATHS; source if not loaded
##! @param <name>...        bare module names (log, fn, colors, fs, …)
##! @return 0 on success, 1 if any module fails to resolve
##! @example nim.source log fn colors
function nim.source() { .nim.core.init.fn || return 1
    local script path libpath out=0
    (( ${NIM_LOGLEVEL:-4} >= 4 )) && out=1
    for script in "${@}"; do
        # idempotent
        [[ -n ${_NIM_LOADED[${script}]} ]] && continue
        path=""
        for libpath in "${_NIM_LIBPATHS[@]}"; do
            [[ -d ${libpath} ]] || continue
            path="$(find "${libpath}" -type f \
                \( -name "${script}.sh" -o -path "*/${script}.sh" \) \
                2>/dev/null | head -1)"
            [[ -n ${path} ]] && break
        done
        [[ -z ${path} ]] && {
            printf "nim.source: not found: %s\n" "${script}" >&2
            return 1; }
        (( out == 1 )) && printf "sourcing %s ... " "${path}" >&2
        # explicit if/else — `cmd && {a} || {b}` runs both blocks if {a}
        # returns nonzero; the success block here may end on a conditional.
        if source "${path}"; then
            _NIM_LOADED[${script}]="${path}"
            # onboarding: scan the just-loaded module's ##! metadata into
            # the cache. gated on nim.fn.scan being defined — early
            # bootstrap loads (cfg, core) precede fn.sh; nim.sh re-scans
            # them post-bootstrap.
            declare -F nim.fn.scan >/dev/null 2>&1 \
                && nim.fn.scan "${path}" 2>/dev/null
            (( out == 1 )) && printf "OK\n" >&2
        else
            (( out == 1 )) && printf "FAIL\n" >&2
            return 1
        fi
    done
    return 0; }

##! @function nim.source.loaded
##! @description list currently-loaded modules (name → path)
##! @output one line per module on stdout
function nim.source.loaded() { .nim.core.init.fn || return 1
    local k
    for k in "${!_NIM_LOADED[@]}"; do
        printf "%-24s %s\n" "${k}" "${_NIM_LOADED[${k}]}"
    done
    return 0; }

##! @function nim.env.validate
##! @description confirm runtime is suitable for metashell operation
##! @return 0 if valid, 1 otherwise (with diagnostic to stderr)
function nim.env.validate() { .nim.core.init.fn || return 1
    (( BASH_VERSINFO[0] >= 4 )) || {
        printf "nim: bash 4+ required (found %s)\n" "${BASH_VERSION}" >&2
        return 1; }
    return 0; }

##! @function nim.env.list
##! @description list NIM_-prefixed environment vars, sorted
##! @param [prefix=NIM_]
function nim.env.list() { .nim.core.init.fn || return 1
    local prefix="${1:-NIM_}"
    env | grep -E "^${prefix}" | sort
    return 0; }
