#!/usr/bin/env bash

# another *righteous entropy synthesis* by ⎰𝙉𝙄𝙈⎰ ...
# ----------------------------------------------------------------------------
#   NIM Substation One | Planet Earth | https://github.com/metasyndicate
# ----------------------------------------------------------------------------
#   ... The NIM ***Metashell***: ***mod***
#   subsystem registration. resolves declared deps, extends _NIM_LIBPATHS,
#   sources the subsystem's modules, records the registration. extension
#   subsystems live at <system>/sys/<sub>/ with manifest at .nim/nim.sys.cfg.sh.
# ----------------------------------------------------------------------------

nim.source core fn log

# === GLOBALS ===

declare -gA _NIM_SYS=()    # name -> subsystem path
# _NIM_LIBPATHS is initialized in core/core.sh; we only append to it here.

# === PUBLIC ===

##! @function nim.mod.register
##! @description register a subsystem; resolve deps, append libpath, source mods
##! @param <path>          absolute subsystem dir (contains .nim/nim.sys.cfg.sh)
##! @return 0 on success, 1 if manifest missing, deps unmet, or write fails
##! @example nim.mod.register ${NIM_METASHELL_SYS}/crypt
function nim.mod.register() { .nim.core.init.fn || return 1
    nim.fn.validate.args "${@}" || return 1
    local path="${1}"
    [[ -d ${path} ]] || {
        nim.log.error "mod.register: path not found: ${path}"
        return 1; }

    local manifest="${path}/.nim/nim.sys.cfg.sh"
    [[ -r ${manifest} ]] || {
        nim.log.error "mod.register: no manifest at ${manifest}"
        return 1; }

    # source manifest in a controlled scope
    local NIM_SYS_NAME=""
    local NIM_SYS_VERSION="0.0.0"
    local -a NIM_SYS_DEPS=()
    local -a NIM_SYS_MODS=()
    local NIM_SYS_PATH="${path}"
    source "${manifest}"

    [[ -z ${NIM_SYS_NAME} ]] && {
        nim.log.error "mod.register: NIM_SYS_NAME unset in ${manifest}"
        return 1; }
    [[ -n ${_NIM_SYS[${NIM_SYS_NAME}]} ]] && {
        nim.log.warn "mod.register: ${NIM_SYS_NAME} already registered"
        return 0; }

    # 1. resolve declared dependencies (must already be reachable)
    local dep
    for dep in "${NIM_SYS_DEPS[@]}"; do
        nim.source "${dep}" || {
            nim.log.error "mod.register: ${NIM_SYS_NAME} dep ${dep} failed"
            return 1; }
    done

    # 2. extend the search path so nim.source finds this subsystem's modules
    _NIM_LIBPATHS+=( "${NIM_SYS_PATH}" )

    # 3. source declared modules (default = subsystem name if MODS empty)
    [[ ${#NIM_SYS_MODS[@]} -eq 0 ]] && NIM_SYS_MODS=( "${NIM_SYS_NAME}" )
    local mod
    for mod in "${NIM_SYS_MODS[@]}"; do
        nim.source "${mod}" || {
            nim.log.error "mod.register: ${NIM_SYS_NAME} module ${mod} failed"
            return 1; }
    done

    # 4. commit registration
    _NIM_SYS[${NIM_SYS_NAME}]="${path}"
    nim.log.info "mod.register: ${NIM_SYS_NAME} v${NIM_SYS_VERSION}"
    return 0; }

##! @function nim.mod.list
##! @description list registered subsystems
##! @output one line per subsystem: name, path
function nim.mod.list() { .nim.core.init.fn || return 1
    local name
    for name in "${!_NIM_SYS[@]}"; do
        printf "%-24s %s\n" "${name}" "${_NIM_SYS[${name}]}"
    done
    return 0; }

##! @function nim.mod.info
##! @description show manifest contents for a registered subsystem
##! @param <name>          subsystem name as registered
function nim.mod.info() { .nim.core.init.fn || return 1
    nim.fn.validate.args "${@}" || return 1
    local name="${1}"
    local path="${_NIM_SYS[${name}]}"
    [[ -z ${path} ]] && {
        nim.log.error "mod.info: ${name} not registered"
        return 1; }
    printf "name:    %s\n" "${name}"
    printf "path:    %s\n" "${path}"
    [[ -r "${path}/.nim/nim.sys.cfg.sh" ]] && {
        printf "manifest:\n"
        sed -E 's|^|  |' "${path}/.nim/nim.sys.cfg.sh"; }
    return 0; }
