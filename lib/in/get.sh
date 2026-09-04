#!/bin/bash

# another *righteous entropy synthesis* by ⎰𝙉𝙄𝙈⎰ ...
# ----------------------------------------------------------------------------
#   NIM Substation One | Planet Earth | https://github.com/metasyndicate
# ----------------------------------------------------------------------------
#   ... The NIM ***Metashell***: ***get***
#   argument extraction helpers. parsers for opt/flag/key=value forms.
#   designed for use inside other functions' argument-handling loops.
# ----------------------------------------------------------------------------

# === PUBLIC ===

##! @function nim.get.opt
##! @description extract a long-option value from an argv array
##! @param <name>           option name (without leading --)
##! @param <args>...        the caller's $@
##! @output value (or empty) on stdout
##! @return 0 if found, 1 otherwise
##! @example nim.get.opt tags --tags=foo,bar     # → foo,bar
##! @example nim.get.opt tags --tags foo,bar     # → foo,bar
function nim.get.opt() { nim.fn.validate.args "${@}" || return 1
    local name="${1}"; shift
    while (( ${#} > 0 )); do
        case "${1}" in
            "--${name}")     printf "%s" "${2}"; return 0 ;;
            "--${name}="*)   printf "%s" "${1#*=}"; return 0 ;;
        esac; shift
    done; return 1; }

##! @function nim.get.flag
##! @description test whether a flag (--name or -n) appears in an argv array
##! @param <name>           flag long name (without leading --)
##! @param [short=]         flag short name (single char, without leading -)
##! @param <args>...        the caller's $@
##! @return 0 if present, 1 otherwise
##! @example nim.get.flag verbose v "${@}" && do_thing
function nim.get.flag() { nim.fn.validate.args "${@}" || return 1
    local name="${1}"; local short="${2}"; shift
    [[ -n ${short} ]] && shift
    while (( ${#} > 0 )); do
        [[ ${1} == "--${name}" ]] && return 0
        [[ -n ${short} ]] && [[ ${1} == "-${short}" ]] && return 0
        shift
    done; return 1; }

##! @function nim.get.env
##! @description read a NIM_-prefixed env var with default fallback
##! @param <key>            variable name
##! @param [default=]       fallback if unset
##! @output value or default on stdout
function nim.get.env() { nim.fn.validate.args "${@}" || return 1
    local key="${1}"; local default="${2:-}"
    printf "%s" "${!key:-${default}}"
    return 0; }

##! @function nim.get.arg
##! @description return the Nth positional arg from an argv array (1-indexed)
##! @param <n>              positional index (1-based)
##! @param <args>...        the caller's $@
##! @output value on stdout (or empty if out of range)
function nim.get.arg() { nim.fn.validate.args "${@}" || return 1
    local n="${1}"; shift
    (( n < 1 )) && return 1
    (( n > ${#} )) && return 1
    printf "%s" "${!n}"
    return 0; }
