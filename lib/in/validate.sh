#!/bin/bash

# another *righteous entropy synthesis* by ⎰𝙉𝙄𝙈⎰ ...
# ----------------------------------------------------------------------------
#   NIM Substation One | Planet Earth | https://github.com/metasyndicate
# ----------------------------------------------------------------------------
#   ... The NIM ***Metashell***: ***validate***
#   input shape validators. each returns 0/1; no stdout. compose via &&/||.
#   diagnostics to stderr only when NIM_VALIDATE_LOUD=1 is set.
# ----------------------------------------------------------------------------

# === PUBLIC ===

##! @function nim.validate.path
##! @description test whether a path exists (or matches a specific test flag)
##! @param <path>           filesystem path
##! @param [flag=-e]        bash test flag: -e -d -f -r -w -x
##! @return 0 if test passes, 1 otherwise
function nim.validate.path() { nim.fn.validate.args "${@}" || return 1
    local path="${1}"; local flag="${2:--e}"
    [ "${flag}" "${path}" ] || return 1
    return 0; }

##! @function nim.validate.number
##! @description test whether input is an integer (optionally within bounds)
##! @param <value>          input
##! @param [min=]           minimum allowed (inclusive)
##! @param [max=]           maximum allowed (inclusive)
##! @return 0 if valid, 1 otherwise
function nim.validate.number() { nim.fn.validate.args "${@}" || return 1
    local value="${1}"; local min="${2:-}"; local max="${3:-}"
    [[ ${value} =~ ^-?[0-9]+$ ]] || return 1
    [[ -n ${min} ]] && (( value < min )) && return 1
    [[ -n ${max} ]] && (( value > max )) && return 1
    return 0; }

##! @function nim.validate.enum
##! @description test whether <value> matches one of <option>...
##! @param <value>          candidate
##! @param <option>...      allowed values
##! @return 0 if match, 1 otherwise
##! @example nim.validate.enum "${level}" debug info warn error
function nim.validate.enum() { nim.fn.validate.args "${@}" || return 1
    local value="${1}"; shift
    local opt
    for opt in "${@}"; do [[ ${value} == "${opt}" ]] && return 0; done
    return 1; }

##! @function nim.validate.url
##! @description shallow URL shape check (scheme + host)
##! @param <value>
function nim.validate.url() { nim.fn.validate.args "${@}" || return 1
    local re='^[a-zA-Z][a-zA-Z0-9+.-]*://[^[:space:]]+$'
    [[ ${1} =~ ${re} ]] && return 0 || return 1; }

##! @function nim.validate.email
##! @description shallow email shape check (local@domain.tld)
##! @param <value>
function nim.validate.email() { nim.fn.validate.args "${@}" || return 1
    local re='^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
    [[ ${1} =~ ${re} ]] && return 0 || return 1; }

##! @function nim.validate.identifier
##! @description valid NIM identifier (lowercase, underscores; no lead digit)
##! @param <value>
function nim.validate.identifier() { nim.fn.validate.args "${@}" || return 1
    [[ ${1} =~ ^[a-z_][a-z0-9_]*$ ]] && return 0 || return 1; }
