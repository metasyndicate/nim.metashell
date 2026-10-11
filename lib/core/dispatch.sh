#!/usr/bin/env bash

# another *righteous entropy synthesis* by ⎰𝙉𝙄𝙈⎰ ...
# ----------------------------------------------------------------------------
#   NIM Substation One | Planet Earth | https://github.com/metasyndicate
# ----------------------------------------------------------------------------
#   ... The NIM ***Metashell***: ***dispatch***
#   multi-token routing. turns `nim core path absolute /tmp` into a call to
#   nim.core.path.absolute, and an incomplete path into a browsable listing
#   of that namespace level.
#
#   this module routes only. metadata, usage rendering and arity checking
#   belong to core/fn.sh and are delegated, never reimplemented — the
#   target function self-validates via nim.fn.validate.args when invoked.
# ----------------------------------------------------------------------------

nim.source core fn log output colors

# === PUBLIC ===

##! @function nim.dispatch.resolve
##! @description resolve space-separated tokens to the longest matching nim.* function
##! @param <token...>          namespace tokens, outermost first
##! @output "<function> <depth>" — depth is the token count consumed
##! @return 0 if a function matched, 1 if none did (emits "nim 0")
##! @example nim.dispatch.resolve core path absolute
function nim.dispatch.resolve() { .nim.core.init.fn || return 1
    nim.fn.validate.args "${@}" || return 1
    local -a tokens=( "${@}" )
    local candidate depth i

    # Greedy: the longest dotted name wins, so a leaf function is preferred
    # over a shorter namespace that happens to also exist as a function.
    for (( depth = ${#tokens[@]}; depth > 0; depth-- )); do
        candidate="nim"
        for (( i = 0; i < depth; i++ )); do
            candidate="${candidate}.${tokens[i]}"
        done
        nim.fn.exists "${candidate}" && {
            printf "%s %d\n" "${candidate}" "${depth}"
            return 0; }
    done

    printf "nim 0\n"
    return 1; }

##! @function nim.dispatch.list
##! @description list the immediate child tokens of a namespace prefix
##! @param [prefix=nim]        dotted namespace prefix
##! @output one child token per line, sorted
##! @return 0 if the namespace has children, 1 if it is empty or a leaf
##! @example nim.dispatch.list nim.codex
function nim.dispatch.list() { .nim.core.init.fn || return 1
    local prefix="${1:-nim}"
    local -a seen=()
    local fn suffix next

    while IFS= read -r fn; do
        [[ ${fn} == "${prefix}."* ]] || continue
        suffix="${fn#"${prefix}".}"
        next="${suffix%%.*}"
        [[ " ${seen[*]} " == *" ${next} "* ]] || seen+=( "${next}" )
    done < <(nim.fn.list)

    (( ${#seen[@]} == 0 )) && return 1
    printf "%s\n" "${seen[@]}" | sort
    return 0; }

##! @function nim.dispatch.browse
##! @description render one namespace level — leaves with their description,
##! @description branches marked as having children of their own
##! @param [prefix=nim]        dotted namespace prefix
##! @output formatted listing on stdout
##! @return 0 if something was rendered, 1 if the namespace is empty
##! @example nim.dispatch.browse nim.fs
function nim.dispatch.browse() { .nim.core.init.fn || return 1
    local prefix="${1:-nim}"
    local -a subs=()
    local sub desc

    while IFS= read -r sub; do
        [[ -n ${sub} ]] && subs+=( "${sub}" )
    done < <(nim.dispatch.list "${prefix}")

    (( ${#subs[@]} == 0 )) && return 1

    printf "\n  ${BLD}%s${OFF}\n\n" "${prefix}"
    for sub in "${subs[@]}"; do
        if nim.fn.exists "${prefix}.${sub}"; then
            desc="$(nim.fn.metadata "${prefix}.${sub}" description \
                2>/dev/null | head -1)"
            printf "    ${GRN}%-20s${OFF} ${LGY}%s${OFF}\n" "${sub}" "${desc}"
        else
            printf "    ${SKY}%-20s${OFF} ${LGY}…${OFF}\n" "${sub}"
        fi
    done
    printf "\n"
    return 0; }

##! @function nim.dispatch
##! @description route tokens to a nim.* function; browse when the path is
##! @description incomplete, render usage when -h/--help is present
##! @param [token...]          namespace tokens, then the function's own args
##! @return the target function's status, or 1 if nothing resolved
##! @example nim.dispatch codex add --tags=net
##! @example nim.dispatch fs mkdir --help
function nim.dispatch() { .nim.core.init.fn || return 1
    local -a tokens=()
    local help=0 arg

    # Exact-match extraction. Substring replacement (`${args[@]/-h/}`) looks
    # equivalent and is not: it silently rewrites any argument that merely
    # CONTAINS the flag, so /path-here becomes /pathere and --host becomes
    # -ost. Only whole elements may be removed.
    for arg in "${@}"; do
        case "${arg}" in
            -h|--help) help=1 ;;
            *)         tokens+=( "${arg}" ) ;;
        esac
    done

    (( ${#tokens[@]} == 0 )) && { nim.dispatch.browse nim; return 0; }

    local name depth
    read -r name depth < <(nim.dispatch.resolve "${tokens[@]}")

    (( depth == 0 )) && {
        # Nothing resolved. Walk up from the fully-qualified guess to the
        # deepest namespace that does exist, and show the operator what is
        # actually there rather than a bare error.
        local partial="nim" token
        for token in "${tokens[@]}"; do
            partial="${partial}.${token}"
        done
        while : ; do
            nim.dispatch.browse "${partial}" && return 0
            [[ ${partial} == *.* ]] || break
            partial="${partial%.*}"
        done
        nim.out.fail "no such function or namespace: nim.${tokens[0]}"
        return 1; }

    (( help )) && { nim.fn.help "${name}"; return 0; }

    "${name}" "${tokens[@]:${depth}}"; }

##! @function nim.dispatch.complete
##! @description bash completion for the `nim` command; register explicitly
##! @description with: complete -F nim.dispatch.complete nim
##! @output sets COMPREPLY
##! @return 0
function nim.dispatch.complete() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local -a words=( "${COMP_WORDS[@]:1:COMP_CWORD-1}" )
    local prefix="nim" word candidate

    for word in "${words[@]}"; do
        [[ -n ${word} ]] && prefix="${prefix}.${word}"
    done

    COMPREPLY=()
    while IFS= read -r candidate; do
        [[ -n ${candidate} && ${candidate} == "${cur}"* ]] \
            && COMPREPLY+=( "${candidate}" )
    done < <(nim.dispatch.list "${prefix}" 2>/dev/null)

    # At a leaf the operator is typing the function's own arguments; the only
    # thing this module knows to offer there is help.
    (( ${#COMPREPLY[@]} == 0 )) && [[ ${cur} == -* ]] \
        && COMPREPLY=( "--help" )
    return 0; }
