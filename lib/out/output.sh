#!/bin/bash

# another *righteous entropy synthesis* by ⎰𝙉𝙄𝙈⎰ ...
# ----------------------------------------------------------------------------
#   NIM Substation One | Planet Earth | https://github.com/metasyndicate
# ----------------------------------------------------------------------------
#   ... The NIM ***Metashell***: ***output***
#   semantic output helpers. consistent OK/FAIL indicators and framed status
#   lines across metashell surfaces. all output goes to stderr (stdout is
#   reserved for function return values).
# ----------------------------------------------------------------------------

nim.source colors

# === PUBLIC ===

##! @function nim.out.ok
##! @description print an OK indicator with optional trailing message
##! @param [msg=]
##! @output ✓ + message to stderr
##! @example nim.out.ok "config loaded"
function nim.out.ok() { printf "${GRN}✓${OFF} %s\n" "${*}" >&2; return 0; }

##! @function nim.out.fail
##! @description print a FAIL indicator; returns 1 to chain into || handlers
##! @param [msg=]
##! @output ✗ + message to stderr
##! @example operation || nim.out.fail "operation failed"
function nim.out.fail() { printf "${RED}✗${OFF} %s\n" "${*}" >&2; return 1; }

##! @function nim.out.warn
##! @description print a WARN indicator with optional message
##! @param [msg=]
function nim.out.warn() { printf "${YEL}⚠${OFF} %s\n" "${*}" >&2; return 0; }

##! @function nim.out.info
##! @description print an INFO indicator with optional message
##! @param [msg=]
function nim.out.info() { printf "${SKY}ℹ${OFF} %s\n" "${*}" >&2; return 0; }

##! @function nim.out.status
##! @description print a label with a right-aligned status indicator
##! @param <label>          leading label (max 60 cols recommended)
##! @param <state>          ok|fail|warn|skip|<custom>
##! @example nim.out.status "loading config" ok
function nim.out.status() { nim.fn.validate.args "${@}" || return 1
    local label="${1}"; local state="${2}"; local indicator
    case "${state}" in
        ok)   indicator="${GRN}OK${OFF}" ;;
        fail) indicator="${RED}FAIL${OFF}" ;;
        warn) indicator="${YEL}WARN${OFF}" ;;
        skip) indicator="${DWT}SKIP${OFF}" ;;
        *)    indicator="${LGY}${state}${OFF}" ;;
    esac
    printf "%-60s [%s]\n" "${label}" "${indicator}" >&2
    return 0; }
