# The Auburn HPC Admins
# AUIVS-HPC Shell Development Library
# -----------------------------------------------------------------------------
#  easme.api.cli.sh | colors.sh | 04.12.2022
#  color codes, text emphasis, assorted finery for terminal output
# -----------------------------------------------------------------------------
# @easme.api.cli.sh@metadata:set:colors:id=colors
# @easme.api.cli.sh@metadata:set:colors:description=variables holding ascii color escape codes
# @easme.api.cli.sh@metadata:set:colors:ref=https://misc.flogisoft.com/bash/tip_colors_and_formatting
# @easme.api.cli.sh@metadata:set:colors:author=EASME Core Development Team
# @easme.api.cli.sh@metadata:set:colors:date=04.12.2022
# ----------------------------------------------------------------------------

# --------------- [PRE]@easme.api.cli.sh.colors: dependencies ----------------------


# --------------- [BEGIN]@easme.api.cli.sh.colors: variables ------------------

# platform compatibility
esc_short='\e'                   # common shorthand
esc_octal='\033'                 # POSIX standard
esc_hex='\x1B'                   # ANSI/VT100 standard
esc="${esc_short}"               # default to short form

# style variables
export BOLD="${esc}[1m"
export BOFF="${esc}[0m"
export EMPH="${esc}[3m"
export EOFF="${esc}[0m"
export OFF="${esc}[0m"
# cursor control codes
export ERSE="${esc}[0K"
export DELC="${esc}[9D"
export DELB="${esc}[0m"
export DELP="${esc}[3D"
# normal codes
export CLEAR="${esc}[0m" # No Color
export WHITE="${esc}[1;37m"
export BLACK="${esc}[0;30m"
export GRAY="${esc}[1;30m"
export BOLDGRAY="${esc}[0;37m"
export DARKGRAY="${esc}[1;30m"
export BLACKGRAY="${esc}[1;30m"
export RED="${esc}[38;5;9m"
export BOLDRED="${esc}[1;31m"
export LIGHTRED="${esc}[38;5;88m"
export DARKRED="${esc}[0;31m"
export GREEN="${esc}[0;32m"
export BOLDGREEN="${esc}[1;32m"
export DARKGREEN="${esc}[0;32m"
export BROWN="${esc}[0;33m"
export BOLDBROWN="${esc}[0;33m"
export DARKBROWN="${esc}[0;33m"
export ORANGE="${esc}[38;5;214m"
export BOLDORANGE="${esc}[1;33m"
export YELLOW="${esc}[1;33m"
export BOLDYELLOW="${esc}[1;33m"
export DARKYELLOW="${esc}[0;33m"
export BLUE="${esc}[0;34m"
export BOLDBLUE="${esc}[1;34m"
export DARKBLUE="${esc}[0;34m"
export PURPLE="${esc}[0;35m"
export BOLDPURPLE="${esc}[1;35m"
export DARKPURPLE="${esc}[0;35m"
export CYAN="${esc}[0;36m"
export BOLDCYAN="${esc}[1;36m"
export DARKCYAN="${esc}[0;36m"
# export theme colors
export CHARCOAL="${esc}[38;5;0m"
export MAROON="${esc}[38;5;1m"
export OLIVE="${esc}[38;5;3m"
export NAVY="${esc}[38;5;4m"
export TEAL="${esc}[38;5;6m"
export SILVER="${esc}[38;5;7m"
export LIME="${esc}[38;5;10m"
# short codes
export GRN="${esc}[38;5;2m"
export YEL="${esc}[38;5;3m"
export BLU="${esc}[38;5;4m"
export PUR="${esc}[38;5;5m"
export CYN="${esc}[38;5;6m"
export WHT="${esc}[38;5;7m"
export GRY="${esc}[38;5;8m"
export MAG="${esc}[38;5;128m"
export LMG="${esc}[31;6;95m"
export BRD="${esc}[38;5;9m"
export BRN="${esc}[38;5;179m"
export BNZ="${esc}[38;5;58m"
export BGN="${esc}[38;5;10m"
export BYL="${esc}[38;5;11m"
export BBL="${esc}[38;5;12m"
export BPP="${esc}[38;5;13m"
export BCY="${esc}[38;5;14m"
export BWT="${esc}[38;5;15m"
export BLK="${esc}[38;5;16m"
export SKY="${esc}[38;5;33m"
export GRY="${esc}[38;5;8m"
export LGY="${esc}[38;5;249m"
export DWT="${esc}[38;5;247m"
export BLK="${esc}[38;5;0m"
export YEL="${esc}[38;5;3m"
export GRN="${esc}[38;5;2m"
export WHT="${esc}[38;5;7m"
# log \ status codes
export INFO="${esc}[38;5;33m"
export WARN="${esc}[38;5;214m"
# special char formats
export DOT="${DWT}*${OFF}"

# bonsai special 

GLEAF="\033[0;32m"
YLEAF="\033[1;33m"
LLEAF="\033[1;32m"
BROWN="\033[0;33m"

# text functions
function easme.colors.list() { printf "${DWT}-%b${OFF} " "${1#*[}"; }
function easme.colors.bold() { printf "${BOLD}%b%b${BOFF}" "${1#*[}"; }
function easme.colors.ol() { printf "${DWT}${1}${GRY}.${OFF} "; }
function easme.colors.hue() { printf "\033[38;5;%sm" "${1}"; }
function easme.colors.shade() { printf "\033[48;5;%sm" "${1}"; }

function easme.colors.hue() { 
    local code="${1:-WHITE}"
    local msg="${2:-${code}}"
    local pair="$(grep -E -m1 -o "[ ]+${code^^}=[^ ]*" "${BASH_SOURCE[0]}" | grep -v export | tr -d ' ')"
    # extract key and value
    local key=${pair%=*}
    local value=${pair#*=}
    (( ${#key} < 1 )) || [[ -z ${value} ]] && return 1
    printf "%b%s%b\n" "${!key}" "${msg}" "${OFF}";
    return 0; }

function easme.colors.shade() { 
    local shade="${1}"
    local tag="${2:-WHITE}"
    local name="${shade^^}${tag^^}"

    local pairs=($(grep -E -o "${name}=[^ ]*" "${BASH_SOURCE[0]}" | grep -v export))
    for pair in "${pairs[@]}"; do local kvpair=$(echo ${pair} | tr -d ' ')
        local key=${kvpair%=*}; local value=${kvpair#*=}
        printf "%b%s%b\n" "${!key}" "${key}" "${OFF}"; done; return 0; }

function easme.colors.test() {
    for code in {0..255}; do printf "\033[38;5;%sm %3d " "${code}" "${code}"
        (( (code + 1) % 16 == 0 )) && printf "\n"; done; printf "${OFF}\n"; return 0; }

function easme.colors.prefix() { [[ "${1}" == "l" ]] && echo "LIGHT" || { [[ "${1}" == "d" ]] && echo "DARK" || { 
        [[ "${1}" == "b" ]] && echo "BOLD" || echo ""; } }; echo "${prefix}"; return 0; }


# --- aliases ---

hue() { easme.colors.hue ${@}; }
shade() { easme.colors.shade ${@}; }
list() { easme.colors.list ${@}; }
bold() { easme.colors.bold ${@}; }
ol() { easme.colors.ol ${@}; }


red() { local shade="${1}"; local prefix=$(prefix "${shade}"); easme.colors.hue "${prefix}RED"; }
blu() { local shade="${1}"; local prefix=$(prefix "${shade}"); easme.colors.hue "${prefix}BLUE"; }
gre() { local shade="${1}"; local prefix=$(prefix "${shade}"); easme.colors.hue "${prefix}GREEN"; }
yel() { local shade="${1}"; local prefix=$(prefix "${shade}"); easme.colors.hue "${prefix}YELLOW"; }
ora() { local shade="${1}"; local prefix=$(prefix "${shade}"); easme.colors.hue "${prefix}ORANGE"; }
pur() { local shade="${1}"; local prefix=$(prefix "${shade}"); easme.colors.hue "${prefix}PURPLE"; }
cya() { local shade="${1}"; local prefix=$(prefix "${shade}"); easme.colors.hue "${prefix}CYAN"; }
gra() { local shade="${1}"; local prefix=$(prefix "${shade}"); easme.colors.hue "${prefix}GRAY"; }

# -------------- [END]@easme.api.cli.sh.colors: variables ----------------------