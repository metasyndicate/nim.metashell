#!/bin/bash

# another *righteous entropy synthesis* by ⎰𝙉𝙄𝙈⎰ ...
# ----------------------------------------------------------------------------
#   NIM Substation One | Planet Earth | https://github.com/metasyndicate
# ----------------------------------------------------------------------------
#   ... The NIM ***Metashell***: ***strings***
#   atomic string utilities. each function does one thing; consumers compose.
#   all output to stdout — these are pure transforms, never side-effecting.
# ----------------------------------------------------------------------------

# === PUBLIC ===

##! @function nim.str.trim
##! @description trim leading and trailing whitespace
##! @param <text>           input string
##! @output trimmed string on stdout
##! @example nim.str.trim "  hello  "
function nim.str.trim() {
    local text="${*}"
    text="${text#"${text%%[![:space:]]*}"}"
    text="${text%"${text##*[![:space:]]}"}"
    printf "%s" "${text}"
    return 0; }

##! @function nim.str.upper
##! @description uppercase a string
##! @param <text>
function nim.str.upper() { printf "%s" "${*^^}"; return 0; }

##! @function nim.str.lower
##! @description lowercase a string
##! @param <text>
function nim.str.lower() { printf "%s" "${*,,}"; return 0; }

##! @function nim.str.slug
##! @description normalize a string into a kebab-case slug
##! @description lowercase; collapse whitespace + punctuation to hyphens
##! @param <text>
##! @output slug on stdout
##! @example nim.str.slug "Hello, World!"   # hello-world
function nim.str.slug() {
    local text="${*,,}"
    text="$(printf "%s" "${text}" \
        | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//')"
    printf "%s" "${text}"
    return 0; }

##! @function nim.str.clean
##! @description strip ANSI escape sequences from input
##! @param <text>
##! @output unstyled text on stdout
function nim.str.clean() {
    printf "%s" "${*}" | sed -E $'s/\x1b\\[[0-9;]*[a-zA-Z]//g'
    return 0; }

##! @function nim.str.pad
##! @description right-pad a string to <width> with <char> (default space)
##! @param <text>           input string
##! @param <width>          target width
##! @param [char= ]         pad character (single)
##! @output padded string on stdout
function nim.str.pad() { nim.fn.validate.args "${@}" || return 1
    local text="${1}"; local width="${2}"; local char="${3:- }"
    local len=${#text}
    (( len >= width )) && { printf "%s" "${text}"; return 0; }
    local pad=""; local i
    for (( i = len; i < width; i++ )); do pad+="${char}"; done
    printf "%s%s" "${text}" "${pad}"
    return 0; }

##! @function nim.str.repeat
##! @description repeat a string <count> times
##! @param <text>
##! @param <count>
function nim.str.repeat() { nim.fn.validate.args "${@}" || return 1
    local text="${1}"; local count="${2}"; local out=""
    local i; for (( i = 0; i < count; i++ )); do out+="${text}"; done
    printf "%s" "${out}"
    return 0; }
