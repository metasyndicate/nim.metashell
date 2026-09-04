#!/usr/bin/env bash

# another *righteous entropy synthesis* by ⎰𝙉𝙄𝙈⎰ ...
# ----------------------------------------------------------------------------
#   NIM Substation One | Planet Earth | https://github.com/metasyndicate
# ----------------------------------------------------------------------------
#   ... The NIM ***Metashell***: ***fn***
#   function authoring, introspection, validation. dev-augmentation layer.
#
#   the SOURCE OF TRUTH for argument shape is the function's own ##! @param
#   metadata. nim.fn.validate.args reads the caller's metadata from cache
#   and validates received argv against the declared minimum. call sites do
#   not repeat the schema — the schema is the metadata.
# ----------------------------------------------------------------------------

# === GLOBALS ===

# Function-metadata cache. Populated lazily by .nim.fn.parse.fn (called from
# nim.fn.metadata, nim.fn.validate.args, or nim.fn.scan). Eager-populated by
# nim.source's post-source hook for every successfully-loaded module.
declare -gA _NIM_FN_META 2>/dev/null         # name -> raw ##! block
declare -gA _NIM_FN_REQUIRED 2>/dev/null     # name -> required-positional count

# === PRIVATE ===

##! @function .nim.fn.parse.fn
##! @description parse ##! metadata for <name> from <script>; populate caches
##! @description floor-level: does NOT call nim.fn.validate.args (recursion)
##! @param <name>           function name
##! @param <script>         absolute path to source file
##! @return 0 on success, 1 if unreadable or no metadata block
function .nim.fn.parse.fn() {
    local name="${1}"
    local script="${2}"
    [[ -z ${name} || -z ${script} ]] && return 1
    [[ -r ${script} ]] || return 1

    # escape dots so sed doesn't treat them as wildcards; anchor end pattern
    # to literal "()" so nim.foo's range doesn't bleed into nim.foo.bar.
    local esc="${name//./\\.}"
    local block
    block="$(sed -nE \
        "/^##! @function ${esc}\$/,/^function ${esc}\(\)/p" \
        "${script}" 2>/dev/null)"
    [[ -z ${block} ]] && return 1

    _NIM_FN_META[${name}]="${block}"

    # Required-positional count: every `@param <name>` line (angle-bracket-
    # led) is one required positional. Variadic `<args>...` counts as 1
    # (must have at least one element). Square-bracket entries — `[opt=]`,
    # `[-f|--flag]`, `[--key <val>]` — are optional and skipped.
    local required=0
    local line
    while IFS= read -r line; do
        [[ ${line} =~ ^##!\ @param[[:space:]]+\<[a-zA-Z_] ]] \
            && (( required++ ))
    done < <(printf '%s\n' "${block}")

    _NIM_FN_REQUIRED[${name}]="${required}"
    return 0; }

# === PUBLIC ===

##! @function nim.fn.exists
##! @description test whether a shell function is currently defined
##! @param <name>           function name
##! @return 0 if defined, 1 otherwise
##! @example nim.fn.exists nim.source && echo yes
function nim.fn.exists() {
    local name="${1}"
    [[ -z ${name} ]] && return 1
    declare -F -- "${name}" >/dev/null 2>&1
    return ${?}; }

##! @function nim.fn.source
##! @description resolve the source file that defined a function
##! @param <name>           function name
##! @output absolute path of defining script on stdout
##! @return 0 on success, 1 if undefined
##! @example nim.fn.source nim.source
function nim.fn.source() {
    local name="${1}"
    [[ -z ${name} ]] && return 1
    local info
    info="$(shopt -s extdebug; declare -F -- "${name}" 2>/dev/null)"
    [[ -z ${info} ]] && return 1
    printf "%s" "${info#* * }"
    return 0; }

##! @function nim.fn.validate.args
##! @description validate caller's argv against its ##! @param schema
##! @description reads required-positional count from cache; rejects calls
##!              with fewer args; renders usage from metadata on shortfall.
##!              the ONLY argument is "$@" — schema lives in metadata.
##! @param <args>...        the caller's $@
##! @return 0 if call meets the declared minimum, 1 otherwise (usage->stderr)
##! @example function foo() { nim.fn.validate.args "${@}" || return 1; }
function nim.fn.validate.args() {
    local caller="${FUNCNAME[1]:-}"
    [[ -z ${caller} ]] && return 0    # not called from a function — skip

    # ensure caller's metadata is cached (lazy populate on first call)
    local required="${_NIM_FN_REQUIRED[${caller}]-}"
    [[ -z ${required} ]] && {
        local script
        script="$(nim.fn.source "${caller}")" || return 0
        .nim.fn.parse.fn "${caller}" "${script}" || return 0
        required="${_NIM_FN_REQUIRED[${caller}]:-0}"; }

    (( ${#} >= required )) && return 0

    # render usage from cache. read directly — do NOT call nim.fn.metadata
    # here (it would call back into validate.args and recurse).
    local block="${_NIM_FN_META[${caller}]}"
    {
        printf "usage: %s\n" "${caller}"
        [[ -n ${block} ]] && {
            local desc params
            desc="$(printf '%s\n' "${block}" \
                | grep '^##! @description ' \
                | head -1 \
                | sed 's|^##! @description ||')"
            [[ -n ${desc} ]] && printf "  %s\n" "${desc}"
            params="$(printf '%s\n' "${block}" \
                | grep '^##! @param ' \
                | sed 's|^##! @param |    |')"
            [[ -n ${params} ]] && {
                printf "  params:\n"
                printf '%s\n' "${params}"; }
        }
    } >&2
    return 1; }

##! @function nim.fn.metadata
##! @description return ##! metadata for a function (cached after parse)
##! @param <name>           function name
##! @param [field=all]      single field (description|param|return|...)
##! @output metadata block or single-field values on stdout
##! @example nim.fn.metadata nim.source description
function nim.fn.metadata() {
    nim.fn.validate.args "${@}" || return 1
    local name="${1}"
    local field="${2:-all}"

    local block="${_NIM_FN_META[${name}]-}"
    [[ -z ${block} ]] && {
        local script
        script="$(nim.fn.source "${name}")" || return 1
        .nim.fn.parse.fn "${name}" "${script}" || return 1
        block="${_NIM_FN_META[${name}]}"; }
    [[ -z ${block} ]] && return 1

    [[ ${field} == "all" ]] && { printf "%s" "${block}"; return 0; }
    printf "%s" "${block}" | sed -nE "s|^##! @${field}[[:space:]]+||p"
    return 0; }

##! @function nim.fn.scan
##! @description extract ##! metadata for every @function in <script>
##! @description invoked by nim.source's post-source hook for every loaded
##!              module — this is "function/module onboarding".
##! @param <script>         absolute path to source file
##! @return 0 on success, 1 if file is unreadable
##! @example nim.fn.scan lib/core/log.sh
function nim.fn.scan() {
    nim.fn.validate.args "${@}" || return 1
    local script="${1}"
    [[ -r ${script} ]] || return 1

    local names
    names="$(sed -nE 's|^##! @function ([[:graph:]]+).*|\1|p' \
        "${script}" 2>/dev/null)"
    local name
    while IFS= read -r name; do
        [[ -z ${name} ]] && continue
        .nim.fn.parse.fn "${name}" "${script}"
    done < <(printf '%s\n' "${names}")
    return 0; }

##! @function nim.fn.list
##! @description list defined nim.* functions, optionally filtered
##! @param [filter=]        grep pattern; default lists all public nim.*
##! @output one function name per line on stdout
##! @example nim.fn.list cfg
function nim.fn.list() {
    local filter="${1:-}"
    local names
    names="$(declare -F | awk '{print $3}' | grep '^nim\.')"
    [[ -n ${filter} ]] \
        && names="$(printf "%s\n" "${names}" | grep -- "${filter}")"
    printf "%s\n" "${names}" | sort
    return 0; }

##! @function nim.fn.help
##! @description render a usage block for a function from cached metadata
##! @param <name>           function name
##! @output formatted usage on stdout
##! @example nim.fn.help nim.codex.add
function nim.fn.help() {
    nim.fn.validate.args "${@}" || return 1
    local name="${1}"
    local desc params example
    desc="$(nim.fn.metadata    "${name}" description)"
    params="$(nim.fn.metadata  "${name}" param)"
    example="$(nim.fn.metadata "${name}" example)"
    printf "\n  %s\n" "${name}"
    [[ -n ${desc} ]] && printf "%s\n" "${desc}" | sed 's|^|    |'
    [[ -n ${params} ]] && {
        printf "\n    params:\n"
        printf "%s\n" "${params}" | sed 's|^|      |'; }
    [[ -n ${example} ]] && {
        printf "\n    e.g.\n"
        printf "%s\n" "${example}" | sed 's|^|      |'; }
    printf "\n"
    return 0; }

# TODO: nim.fn.new, nim.fn.set.new, nim.fn.set.header — Phase-3 scaffolds.
# TODO: persistent metadata store at ${NIM_METASHELL_DAT}/fn.metadata.json
#       for cross-process introspection. currently in-memory only.
