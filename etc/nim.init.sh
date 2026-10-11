#!/usr/bin/env bash

# Source this file from an interactive shell or your shell rc.
# Example: source /path/to/nim.metashell/etc/nim.init.sh

if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
    printf "nim: this file must be sourced, not executed\n" >&2
    printf "     use: source %s\n" "${BASH_SOURCE[0]}" >&2
    exit 1
fi

_nim_init_etc_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_nim_init_root="$(dirname "${_nim_init_etc_dir}")"
_nim_init_lib="${_nim_init_root}/lib"

# Replace any previously loaded nim.* function surface.
if declare -F nim.source >/dev/null 2>&1; then
    while IFS= read -r _nim_fn; do
        [[ -n ${_nim_fn} ]] && unset -f "${_nim_fn}" 2>/dev/null
    done < <(declare -F | awk '{print $3}' | grep '^nim\.')
fi

export NIM_LIBPATH="${_nim_init_lib}"
unset NIM_METASHELL NIM_HOME NIM_OPS NIM_METASHELL_ETC NIM_METASHELL_BIN
unset NIM_METASHELL_LIB NIM_METASHELL_DAT NIM_METASHELL_SYS NIM_METASHELL_LOG NIM_METASHELL_VAR

source "${_nim_init_lib}/nim.sh" || return 1
nim.source colors output strings input get validate dispatch \
           fs mod clip codex setup 2>/dev/null

# Interactive conveniences. Registered here rather than at module load time
# so that sourcing core/dispatch.sh has no side effect on the shell.
if declare -F nim.dispatch.complete >/dev/null 2>&1; then
    complete -F nim.dispatch.complete nim
    (( ${NIM_LOGLEVEL:-4} >= 6 )) \
        && printf "nim: completion registered for 'nim'\n" >&2
fi

unset _nim_fn _nim_init_etc_dir _nim_init_root _nim_init_lib
