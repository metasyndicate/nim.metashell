#!/bin/bash

# another *righteous entropy synthesis* by ⎰𝙉𝙄𝙈⎰ ...
# ----------------------------------------------------------------------------
#   NIM Substation One | Planet Earth | https://github.com/metasyndicate
# ----------------------------------------------------------------------------
#   ... The NIM ***Metashell***: ***colors***
#   ANSI/256-color escape variables. no functions — referenced directly by
#   other out/* modules. disabled when stderr is not a tty or NIM_COLOR=0.
# ----------------------------------------------------------------------------

# === 8-COLOR ===

declare -gx RED=$'\e[31m'  GRN=$'\e[32m'  YEL=$'\e[33m'
declare -gx BLU=$'\e[34m'  MAG=$'\e[35m'  CYN=$'\e[36m'
declare -gx WHT=$'\e[37m'  OFF=$'\e[0m'

# === 256-COLOR (NIM PALETTE) ===

declare -gx ORANGE=$'\e[38;5;214m'
declare -gx SKY=$'\e[38;5;39m'
declare -gx LGY=$'\e[38;5;248m'    # light grey
declare -gx DWT=$'\e[38;5;250m'    # dim white
declare -gx PUR=$'\e[38;5;141m'

# === ATTRS ===

declare -gx BLD=$'\e[1m'  DIM=$'\e[2m'  ITL=$'\e[3m'  UND=$'\e[4m'

# === DISABLE WHEN NOT A TTY OR NIM_COLOR=0 ===

[[ -t 2 ]] && [[ "${NIM_COLOR:-1}" != "0" ]] || {
    for _v in RED GRN YEL BLU MAG CYN WHT OFF \
              ORANGE SKY LGY DWT PUR \
              BLD DIM ITL UND; do
        declare -gx "${_v}"=""
    done
    unset _v; }
