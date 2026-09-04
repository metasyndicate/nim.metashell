#!/bin/bash

# another *righteous entropy synthesis* by ⎰𝙉𝙄𝙈⎰ ...
# ----------------------------------------------------------------------------
#   NIM Substation One | Planet Earth | https://github.com/metasyndicate
# ----------------------------------------------------------------------------
#   ... The NIM ***Metashell***: ***input***
#   interactive prompts. guarded against non-tty stdin — returns defaults
#   silently when no terminal is attached so non-interactive callers still work.
# ----------------------------------------------------------------------------

nim.source colors

# === PUBLIC ===

##! @function nim.in.prompt
##! @description prompt for a value; return default on empty or non-tty
##! @param <label>          prompt text
##! @param [default=]       value returned on empty input or non-tty
##! @output user-provided value (or default) on stdout
##! @example name=$(nim.in.prompt "agent name" "anon")
function nim.in.prompt() { nim.fn.validate.args "${@}" || return 1
    local label="${1}"; local default="${2:-}"; local reply
    [[ ! -t 0 ]] && { printf "%s" "${default}"; return 0; }
    read -r -p "${SKY}${label}${OFF}${default:+ [${default}]}: " reply
    printf "%s" "${reply:-${default}}"
    return 0; }

##! @function nim.in.confirm
##! @description yes/no prompt. returns 0 for yes, 1 for no.
##! @param <question>       the question text (no trailing ?)
##! @param [default=n]      y or n
##! @example nim.in.confirm "delete file" || return 0
function nim.in.confirm() { nim.fn.validate.args "${@}" || return 1
    local question="${1}"; local default="${2:-n}"; local reply; local hint
    [[ ! -t 0 ]] && [[ ${default} == "y" ]] && return 0
    [[ ! -t 0 ]] && return 1
    [[ ${default} == "y" ]] && hint="Y/n" || hint="y/N"
    read -r -p "${SKY}${question}${OFF} [${hint}]? " reply
    reply="${reply:-${default}}"
    [[ ${reply,,} =~ ^(y|yes)$ ]] && return 0 || return 1; }

##! @function nim.in.select
##! @description present a numbered menu and return the chosen value
##! @param <prompt>         label
##! @param <option>...      one or more options
##! @output selected option on stdout
##! @example pick=$(nim.in.select "type" alpha beta gamma)
function nim.in.select() { nim.fn.validate.args "${@}" || return 1
    local prompt="${1}"; shift
    local options=( "${@}" )
    (( ${#options[@]} == 0 )) && return 1
    [[ ! -t 0 ]] && { printf "%s" "${options[0]}"; return 0; }
    local i; for i in "${!options[@]}"; do
        printf "  ${LGY}%d${OFF}) %s\n" "$((i+1))" "${options[$i]}" >&2
    done
    local reply; read -r -p "${SKY}${prompt}${OFF} [1-${#options[@]}]: " reply
    [[ ${reply} =~ ^[0-9]+$ ]] \
        && (( reply >= 1 && reply <= ${#options[@]} )) \
        && { printf "%s" "${options[$((reply-1))]}"; return 0; }
    return 1; }
