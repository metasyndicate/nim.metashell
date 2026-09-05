#!/usr/bin/env bash

# chars.sh: handy character sets and utilities [07.15.25] B. Morgan 
#
#  activate: source /path/to/lib/chars.sh
#
#  ex. list available character sets:
#     bio.sh.charsets
#  ex. search available character sets: 
#     bio.sh.charsets "games|symbols|math|alphabet"
#  ex. get character from set by index: 
#     bio.sh.char "alphabet" 3


##### -------- @bio.sh.cli.var.global.collections -----------------

# @bio.sh.cli.char.games ---------------------------------------------------
coins=( '⛀' '⛁' )
suits=( '♠' '♥' '♣' '♦' )
cards=( 'A' '2' '3' '4' '5' '6' '7' '8' '9' 'J' '♚' '♕' )
chess=( '♚' '♛' '♜' '♝' '♞' '♟' '♔' '♕' '♖' '♗' '♘' '♙' )
bones=( '⚀' '⚁' '⚂' '⚃' '⚄' '⚅' )
# @bio.sh.cli.char.symbols ---------------------------------------------------
zodiac=( ♈ ♉ ♊ ♋ ♌ ♍ ♎ ♏ ♐ ♑ ♒ ♓ )
flowers=( 🌸 🌹 🌻 🌼 🌷 🌺 )
animals=( 🐶 🐱 🐭 🐹 🐰 🦊 🦁 🐻 🐼 🦄 )
faces=( 😀 😃 😄 😁 😆 😅 😂 🤣 )
weather=( 🌤 🌥 🌦 🌧 🌨 🌩 🌪 🌫 )
times=( ⏰ ⏱ ⏲ ⏳ ⌚ )
money=( 💵 💴 💶 💷 💸 💰 )
colors=( 🟥 🟧 🟨 🟩 🟦 🟪 🟫 ⬛ ⬜ )
hours=( 🕐 🕑 🕒 🕓 🕔 🕕 🕖 🕗 🕘 🕙 🕠 🕡 🕢 🕣 🕤 🕥 🕦 🕧 )
# @bio.sh.cli.char.numbers -----------------------------------------------------
numbers_roman="ⅠⅡⅢⅣⅤⅥⅦⅧⅨⅩ"
numbers_list="⒈⒉⒊⒋⒌⒍⒎⒏⒐⒑⒒⒓⒔⒕⒖⒗⒘⒚⒛"
#@bio.sh.cli.char.math--------------------------------------------------------
numbers_subscript="₀₁₂₃₄₅₆₇₈₉"
numbers_superscript="⁰¹²³⁴⁵⁶⁷⁸⁹"
numbers_math_variables="𝑎𝑏𝑐𝑑𝑒𝑓𝑔𝑖𝑗𝑘𝑙𝑚𝑛𝑜𝑝𝑞𝑟𝑠𝑡𝑢𝑣𝑤𝑥𝑦𝑧"
numbers_math_variables_bold="𝐚𝐛𝐜𝐝𝐞𝐟𝐠𝐡𝐢𝐣𝐤𝐥𝐦𝐧𝐨𝐩𝐪𝐫𝐬𝐭𝐮𝐯𝐰𝐱𝐲𝐳"
numbers_math_sets="⊂⊃⊄⊅⊆⊇⊈⊉⊊"
numbers_math_logic="∴∵∶∷"
numbers_roots="√∛∜"
numbers_equality="=≠≤≥"
numbers_algorithm="𝛺𝛻𝛼𝛽𝛾𝛿𝜀𝜁𝜂𝜃𝜄𝜅𝜆𝜇𝜈𝜉𝜊𝜋𝜌𝜍𝜎𝜏𝜐𝜑𝜒𝜓"
numbers_algorithm_bold="𝛀𝛁𝛂𝛃𝛄𝛅𝛆𝛇𝛈𝛉𝛊𝛋𝛌𝛍𝛎𝛏𝛐𝛑𝛒𝛓𝛔𝛕𝛖𝛗𝛘𝛙"
# @bio.sh.cli.char.alphabet ----------------------------------------------------
alphabet=( "a" "b" "c" "d" "e" "f" "g" "h" "i" "j" "k" "l" "m" "n" "o" "p" "q" "r" "s" "t" "u" "v" "w" "x" "y" "z" )
alphabet_emph=( "𝘢" "𝘣" "𝘤" "𝘥" "𝘦" "𝘧" "𝘨" "𝘩" "𝘪" "𝘫" "𝘬" "𝘭" "𝘮" "𝘯" "𝘰" "𝘱" "𝘲" "𝘳" "𝘴" "𝘵" "𝘶" "𝘷" "𝘸" "𝘹" "𝘺" "𝘻" )
alphabet_caps=( "𝖠" "𝖡" "𝖢" "𝖣" "𝖤" "𝖥" "𝖦" "𝖧" "𝖨" "𝖩" "𝖪" "𝖫" "𝖬" "𝖭" "𝖮" "𝖯" "𝖰" "𝖱" "𝖲" "𝖳" "𝖴" "𝖵" "𝖶" "𝖷" "𝖸" "𝖹" )
alphabet_caps_bold_italic=( "𝘼" "𝘽" "𝘾" "𝘿" "𝙀" "𝙁" "𝙂" "𝙃" "𝙄" "𝙅" "𝙆" "𝙇" "𝙈" "𝙉" "𝙊" "𝙋" "𝙌" "𝙍" "𝙎" "𝙏" "𝙐" "𝙑" "𝙒" "𝙓" "𝙔" "𝙕" )
alphabet_serif=( "𝐚" "𝐛" "𝐜" "𝐝" "𝐞" "𝐟" "𝐠" "𝐡" "𝐢" "𝐣" "𝐤" "𝐥" "𝐦" "𝐧" "𝐨" "𝐩" "𝐪" "𝐫" "𝐬" "𝐭" "𝐮" "𝐯" "𝐰" "𝐱" "𝐲" "𝐳" )
alphabet_caps_serif=( "𝐀" "𝐁" "𝐂" "𝐃" "𝐄" "𝐅" "𝐆" "𝐇" "𝐈" "𝐉" "𝐊" "𝐋" "𝐌" "𝐍" "𝐎" "𝐏" "𝐐" "𝐑" "𝐒" "𝐓" "𝐔" "𝐕" "𝐖" "𝐗" "𝐘" "𝐙" )
alphabet_caps_bold_serif=( "𝐀" "𝐁" "𝐂" "𝐃" "𝐄" "𝐅" "𝐆" "𝐇" "𝐈" "𝐉" "𝐊" "𝐋" "𝐌" "𝐍" "𝐎" "𝐏" "𝐐" "𝐑" "𝐒" "𝐓" "𝐔" "𝐕" "𝐖" "𝐗" "𝐘" "𝐙" )
alphabet_script=( "𝒶" "𝒷" "𝒸" "𝒹" "𝑒" "𝒻" "𝑔" "𝒽" "𝒾" "𝒿" "𝓀" "𝓁" "𝓂" "𝓃" "𝑜" "𝓅" "𝓆" "𝓇" "𝓈" "𝓉" "𝓊" "𝓋" "𝓌" "𝓍" "𝓎" "𝓏" )
alphabet_script_bold=( "𝓪" "𝓫" "𝓬" "𝓭" "𝓮" "𝓯" "𝓰" "𝓱" "𝓲" "𝓳" "𝓴" "𝓵" "𝓶" "𝓷" "𝓸" "𝓹" "𝓺" "𝓻" "𝓼" "𝓽" "𝓾" "𝓿" "𝔀" "𝔁" "𝔂" "𝔃" )
alphabet_script_caps=( "𝒜" "𝓑" "𝒞" "𝒟" "𝓔" "𝓕" "𝒢" "𝓗" "𝓘" "𝒥" "𝒦" "𝓛" "𝓜" "𝓝" "𝒪" "𝒫" "𝓠" "𝓡" "𝒮" "𝒯" "𝒰" "𝒱" "𝒲" "𝒳" "𝒴" "𝒵" )
alphabet_script_caps_bold=( "𝓐" "𝓑" "𝓒" "𝓓" "𝓔" "𝓕" "𝓖" "𝓗" "𝓘" "𝓙" "𝓚" "𝓛" "𝓜" "𝓝" "𝓞" "𝓟" "𝓠" "𝓡" "𝓢" "𝓣" "𝓤" "𝓥" "𝓦" "𝓧" "𝓨" "𝓩" )
alphabet_gothic=( "𝔞" "𝔟" "𝔠" "𝔡" "𝔢" "𝔣" "𝔤" "𝔥" "𝔦" "𝔧" "𝔨" "𝔩" "𝔪" "𝔫" "𝔬" "𝔭" "𝔮" "𝔯" "𝔰" "𝔱" "𝔲" "𝔳" "𝔴" "𝔵" "𝔶" "𝔷" )
alphabet_gothic_bold=( "𝖆" "𝖇" "𝖈" "𝖉" "𝖊" "𝖋" "𝖌" "𝖍" "𝖎" "𝖏" "𝖐" "𝖑" "𝖒" "𝖓" "𝖔" "𝖕" "𝖖" "𝖗" "𝖘" "𝖙" "𝖚" "𝖛" "𝖜" "𝖝" "𝖞" "𝖟" )
alphabet_gothic_caps=( "𝔄" "𝔅" "𝔖" "𝔇" "𝔈" "𝔉" "𝔊" "𝕳" "𝔍" "𝔎" "𝔏" "𝔐" "𝔑" "𝔒" "𝔓" "𝔔" "𝔖" "𝔗" "𝔘" "𝔙" "𝔚" "𝔛" "𝔜" "𝔝" )
alphabet_gothic_caps_bold=( "𝕬" "𝕭" "𝕮" "𝕯" "𝕰" "𝕱" "𝕲" "𝕳" "𝕴" "𝕵" "𝕶" "𝕷" "𝕸" "𝕹" "𝕺" "𝕻" "𝕼" "𝕽" "𝕾" "𝕿" "𝖀" "𝖁" "𝖂" "𝖃" "𝖄" "𝖅" )
alphabet_squares=( "🄰" "🄱" "🄲" "🄳" "🄴" "🄵" "🄶" "🄷" "🄸" "🄹" "🄺" "🄻" "🄼" "🄽" "🄾" "🄿︎" "🅀" "🅁" "🅂" "🅃" "🅄" "🅅" "🅆" "🅇" "🅈" "🅉" )
alphabet_squares_negative=( "🅰" "🅱" "🅲" "🅳" "🅴" "🅵" "🅶" "🅷" "🅸" "🅹" "🅺" "🅻" "🅼" "🅽" "🅾" "🅿︎" "🆀" "🆁" "🆂" "🆃" "🆄" "🆅" "🆆" "🆇" "🆈" "🆉" )
alphabet_circles=( "ⓐ" "ⓑ" "ⓒ" "ⓓ" "ⓔ" "ⓕ" "ⓖ" "ⓗ" "ⓘ" "ⓙ" "ⓚ" "ⓛ" "ⓜ" "ⓝ" "ⓞ" "ⓟ︎" "ⓠ" "ⓡ" "ⓢ" "ⓣ" "ⓤ" "ⓥ" "ⓦ" "ⓧ" "ⓨ" "ⓩ" )
alphabet_circles_caps=( "Ⓐ" "Ⓑ" "Ⓒ" "Ⓓ" "Ⓔ" "Ⓕ" "Ⓖ" "Ⓗ" "Ⓘ" "Ⓙ" "Ⓚ" "Ⓛ" "Ⓜ" "Ⓝ" "Ⓞ" "Ⓟ︎" "Ⓠ" "Ⓡ" "Ⓢ" "Ⓣ" "Ⓤ" "Ⓥ" "Ⓦ" "Ⓧ" "Ⓨ" "Ⓩ" )
alphabet_circles_caps_negative=( "🅐" "🅑" "🅒" "🅓" "🅔" "🅕" "🅖" "🅗" "🅘" "🅙" "🅚" "🅛" "🅜" "🅝" "🅞" "🅟︎" "🅠" "🅡" "🅢" "🅣" "🅤" "🅥" "🅦" "🅧" "🅨" "🅩" )
alphabet_wide=( "ａ" "ｂ" "ｃ" "ｄ" "ｅ" "ｆ" "ｇ" "ｈ" "ｉ" "ｊ" "ｋ" "ｌ" "ｍ" "ｎ" "ｏ" "ｐ" "ｑ" "ｒ" "ｓ" "ｔ" "ｕ" "ｖ" "ｗ" "ｘ" "ｙ" "ｚ" ) 
alphabet_wide_caps=( Ａ Ｂ Ｃ Ｄ Ｅ Ｆ Ｇ Ｈ Ｉ Ｊ Ｋ Ｌ Ｍ Ｎ Ｏ Ｐ Ｑ Ｒ Ｓ Ｔ Ｕ Ｖ Ｗ Ｘ Ｙ Ｚ )
alphabet_mono=( 𝚊 𝚋 𝚌 𝚍 𝚎 𝚏 𝚐 𝚑 𝚒 𝚓 𝚔 𝚕 𝚖 𝚗 𝚘 𝚙 𝚚 𝚛 𝚜 𝚝 𝚞 𝚟 𝚠 𝚡 𝚢 𝚣 )
alphabet_mono_caps=( 𝙰 𝙱 𝙲 𝙳 𝙴 𝙵 𝙶 𝙷 𝙸 𝙹 𝙺 𝙻 𝙼 𝙽 𝙾 𝙿 𝚀 𝚁 𝚂 𝚃 𝚄 𝚅 𝚆 𝚇 𝚈 𝚉 )

# @bio.sh.cli.char.arrows ------------------------------------------------------
arrows=( ↑ ↓ ← → )
arrows_square=( ↰ ↱ ↲ ↳ ↴ ↵ )
arrows_round=( ↶ ↷ ↩ ↪ ↺ ↻ ⤴ ⤵ )
arrows_block=( ⏩ ⏪ ⏫ ⏬ )
# @bio.sh.cli.char.shapes ------------------------------------------------------
triangles=( ▲ ▼ ◀ ► )
squares=( ■ □ ▢ ▪ ▫ ▣ ▤ ▥ ▦ ▧ ▨ ▩ )
rectangles=( ▬ ▭ ▮ ▯ ▰ ▱ )
circles=( ● ○ ◌ ◍ ◎ ● ◐ ◑ ◒ ◓ ◔ ◕ )
# @bio.sh.cli.char.celestial ---------------------------------------------------
stars=( ★ ☆ ✮ ✯ ✰ ✱ ✲ ✳ ✴ ✵ ✶ ✷ ✸ ✹ ✺ ✻ ⁕ )
moon=( 🌑 🌒 🌓 🌔 🌕 🌖 🌗 🌘 )
space=( 🌎 ⭐️ 🌟 ✨ 𖣔 𖤓 ꥟ ✦ ⌑ ꩜ ☄ 🪐 🔆 )
hazards=( ☣️ ☣︎ ⚠️ ⚙️ ⚡️ ⚛️ )
lab=( 🌡 🎓 🏛 📚 📋 🔍 🧬 ⚙️ 📈 📉 📊 🧪 🧫 🥼 🔬 🔭 )
awards=( 🎓 🎖 🎗 📦 ⭐️ 🌟 🎈 💰 💥 🥇 🥈 🥉 🪙 💎 🍪 🍭 🍬 🎁 🎆 🎯 🏆 🏅 👑 )

##### ---------------- @bio.sh.chars: FUNCTIONS ----------------------------

function bio.sh.char() {
  
  local set="${1:-"alphabet"}"
  local idx="${2:-0}"
  local charset="${set}[@]"
  local chars=( "${!charset}" )

  [[ -z ${chars} ]] && { echo "error: character set '${set}' not found." >&2; return 1; }
  (( idx < 0 || idx >= ${#chars[@]} )) && { 
        echo "error: index ${idx} out of range for set '${set}' (0 to $((${#chars[@]} - 1)))." >&2; return 1; }
  
  echo "${chars[$idx]}"; return 0; }

# bio.sh.chars: list all character sets

function bio.sh.chars() {
  local sets=( $(grep -oE "^[a-z_]*[=]" ${BASH_SOURCE[0]:-${0}}) )
  for set in ${sets[@]}; do 
    name="${set//=*/}[@]"
    printf "%-32s: " "${set//=*/}";
    printf "%s " ${!name}; printf "\n"; done
    #chars="$(echo "${!name}" | grep -oE "\(.+\)" | tr -d '()')"
    #printf "%d\t%s" ${idx} ${chars} | tr -d '\n'; ((idx++)); done;
  return 0; }

# bio.sh.cli.charsets: list all character sets matching a filter

function bio.sh.charsets() {
  
    [[ ${1} =~ -(H|h|help) ]] && {
        echo "usage: bio.sh.charsets [filter]" >&2; return 1; }
        
    local filter="${1:-"alphabet"}"
    local source="$(readlink -f "${BASH_SOURCE[0]:-${0}}" 2>/dev/null || 
        $(stat ${BASH_SOURCE[0]:-${0}}) 2>/dev/null | awk '{print $NF}' 2>/dev/null)"
    local sets=$(grep -o -E "^[a-z_\.\-]*[^=]" "${source}" | \
        grep -E -v "(^[ #]|^function*)" | grep -i ${filter})

  [[ -z ${sets} ]] && { echo -e "no sets found matching filter: ${filter}"; return 1; }
  
  printf "\n====== ${#sets[@]} CHARACTER SET(S) MATCHING (filter=${filter}) ======\n\n"

  for set in ${sets[@]}; do
    charset="${set}[@]"; chars=( "${!charset}" )
    printf "%-32s: " "${set}"; printf "%b " "${chars[@]}"
    printf "\n"; done; printf "\n"; return 0; }

# bio.sh.utf.chars: list all Unicode characters in a range

function bio.sh.utf.chars() {
  
  local start=${1:-0}; local end=${2:-1000}
  local min=0;local max=1114111

  [[ ${1} =~ -(H|h|help) ]] && {
    echo "usage: bio.sh.utf.chars [start] [end]" >&2; return 1; }
    
  (( start < min || start > max || end < min || end > max || start >= end )) && {
    echo "error: range must be within 0x00000 and 0x10FFFF" >&2; return 1; }
  
  for ((i=start; i<end; i++)); do
    local code="$(printf "%06x" "$i")"
    local char=$(printf "\U${code}")
    
    [[ "$char" =~ ^$ ]] || [[ "$char" == $'\0' ]] || [[ "${char}" =~ 𝒺 ]] && continue
    [[ ! LC_CTYPE=C  ]] || grep -q "^[[:print:]]$" <<< "$char" 2>/dev/null || continue

    printf " %b" "${char// /}"; done; printf "\n"; return 0; }

# nim.alpha.to.index: get index of character in 'alphabet' set

function nim.alpha.to.index() {
  local char="${1:-a}"
  local chars=( ${alphabet[@]} )
  for idx in "${!chars[@]}"; do
    if [[ "${chars[$idx]}" == "${char}" ]]; then
      echo "$idx"; return 0; fi; done
  echo "error: character '${char}' not found in set 'alphabet'." >&2; return 1; }

function nim.alpha.to.char() {
  local idx="${1:-0}"
  local chars=( ${alphabet[@]} )
  if (( idx < 0 || idx >= ${#chars[@]} )); then
    echo "error: index ${idx} out of range for set 'alphabet' (0 to $((${#chars[@]} - 1)))." >&2; return 1; fi
  echo "${chars[$idx]}"; return 0; }

function nim.charset.by.name() {
local filter="${1:-alphabet_caps_bold_italic}"
local sets=( $(grep "${filter}" "${BASH_SOURCE[0]}" | cut -d'=' -f1) )
local chars="${sets[0]}[@]"
local charset=(${!chars})
[[ -z ${charset} ]] && return 1;
printf "%b" "${charset[@]}\n"
}

function nim.string.to.chars() {
  local str="${1,,}"; 
  local tag="${2:-alphabet_caps_bold_italic}[@]"
  local charset=( ${!tag} ) 
  local chars=()
  for ((i=0; i<${#str}; i++)); do
    local c="${str:i:1}"
    [[ ! "${c}" =~ (a-z) ]] && chars+=( "${c}" ) 
    # printf "%b\n" ${c}
    local idx=$(nim.alpha.to.index "${c}" 2>/dev/null) || continue
    (( idx >= 0 )) && chars+=( "${charset[${idx}]}" ); done
echo "CHARS: ${chars[@]}" >&2
  local out=$(printf "%b" "${chars[@]}" | tr -d ' [](){}\t\n')
  printf "%q" ${out// /}; printf "\n"; return 0; }
    
