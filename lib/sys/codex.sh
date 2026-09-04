#!/usr/bin/env bash

# another *righteous entropy synthesis* by ⎰𝙉𝙄𝙈⎰ ...
# ----------------------------------------------------------------------------
#   NIM Substation One | Planet Earth | https://github.com/metasyndicate
# ----------------------------------------------------------------------------
#   ... The NIM ***Metashell***: ***codex***
#   command catalog. add, tag, group, index, export shell commands from
#   operator workflows. supports pipe intake, history pull, and session-
#   scoped default tags/groups via nim.codex.set.
# ----------------------------------------------------------------------------

nim.source core fn log output input

# === GLOBALS (per-PID session state) ===

[[ -z ${NIM_CODEX_STORE} ]] && \
    declare -gx NIM_CODEX_STORE="${NIM_OPS}/codex"
[[ -z ${NIM_CODEX_SESSION} ]] && \
    declare -gx NIM_CODEX_SESSION="${NIM_CODEX_STORE}/.session.${$}"

# session-cleanup trap (best-effort)
trap '[[ -f "${NIM_CODEX_SESSION}" ]] && rm -f "${NIM_CODEX_SESSION}"' EXIT

# === PUBLIC ===

##! @function nim.codex.set
##! @description set session-sticky tags/groups for subsequent add calls
##! @param [-t|--tags <csv>]    default tags
##! @param [-g|--group <csv>]   default groups
##! @example nim.codex.set --tags=debug,net --group=prod
function nim.codex.set() { .nim.core.init.fn || return 1
    local tags=""
    local groups=""
    while (( ${#} > 0 )); do
        case "${1}" in
            -t|--tags)   tags="${2}"; shift 2 ;;
            --tags=*)    tags="${1#*=}"; shift ;;
            -g|--group)  groups="${2}"; shift 2 ;;
            --group=*)   groups="${1#*=}"; shift ;;
            *) nim.log.warn "codex.set: unknown arg: ${1}"; shift ;;
        esac
    done

    mkdir -p "$(dirname "${NIM_CODEX_SESSION}")"
    {
        [[ -n ${tags} ]]   && printf "NIM_CODEX_TAGS=%q\n"   "${tags}"
        [[ -n ${groups} ]] && printf "NIM_CODEX_GROUPS=%q\n" "${groups}"
    } > "${NIM_CODEX_SESSION}"
    nim.out.ok "codex session: tags=${tags} groups=${groups}"
    return 0; }

##! @function nim.codex.add
##! @description store a command in the catalog (arg, pipe, or history)
##! @param [-n|--last <N>]      pull from bash history index N
##! @param [-t|--tags <csv>]    per-call tags (merged with session tags)
##! @param [--title <text>]     short title
##! @example some --command | nim.codex.add --tags=debug,net
function nim.codex.add() { .nim.core.init.fn || return 1
    [[ -r ${NIM_CODEX_SESSION} ]] && source "${NIM_CODEX_SESSION}"

    local cmd=""
    local title=""
    local tags="${NIM_CODEX_TAGS:-}"
    local hist=""
    while (( ${#} > 0 )); do
        case "${1}" in
            -n|--last)  hist="${2}"; shift 2 ;;
            --last=*)   hist="${1#*=}"; shift ;;
            -t|--tags)  tags="${tags:+${tags},}${2}"; shift 2 ;;
            --tags=*)   tags="${tags:+${tags},}${1#*=}"; shift ;;
            --title)    title="${2}"; shift 2 ;;
            --title=*)  title="${1#*=}"; shift ;;
            *) cmd="${cmd:+${cmd} }${1}"; shift ;;
        esac
    done

    # intake priority: explicit cmd > history > stdin pipe
    [[ -z ${cmd} && -n ${hist} ]] && \
        cmd="$(fc -ln -"${hist}" -"${hist}" 2>/dev/null)"
    [[ -z ${cmd} && ! -t 0 ]] && cmd="$(cat)"
    [[ -z ${cmd} ]] && {
        nim.log.error "codex.add: no command provided"
        return 1; }

    local id stamp
    id="$(printf "%s" "${cmd}" | shasum | cut -c1-12)"
    stamp="$(date -u +'%Y-%m-%dT%H:%M:%SZ')"

    # JSON-escape: backslash → \\, double-quote → \", newline → \n.
    # Sufficient for shell-derived strings; for arbitrary binary, swap in
    # jq later (TODO).
    local groups="${NIM_CODEX_GROUPS:-}"
    local cmd_j title_j tags_j groups_j
    cmd_j="${cmd//\\/\\\\}"
    cmd_j="${cmd_j//\"/\\\"}"
    cmd_j="${cmd_j//$'\n'/\\n}"
    title_j="${title//\\/\\\\}";   title_j="${title_j//\"/\\\"}"
    tags_j="${tags//\\/\\\\}";     tags_j="${tags_j//\"/\\\"}"
    groups_j="${groups//\\/\\\\}"; groups_j="${groups_j//\"/\\\"}"

    local fmt='{"id":"%s","stamp":"%s","cmd":"%s","title":"%s",'
    fmt+='"tags":"%s","groups":"%s"}'
    local record
    record="$(printf "${fmt}" \
        "${id}" "${stamp}" "${cmd_j}" "${title_j}" "${tags_j}" "${groups_j}")"

    mkdir -p "${NIM_CODEX_STORE}/entries"
    printf "%s\n" "${record}" > "${NIM_CODEX_STORE}/entries/${id}.json"
    nim.out.ok "codex: ${id} (${title:-${cmd:0:40}})"
    return 0; }

##! @function nim.codex.list
##! @description list catalog entries, optionally filtered by tag or group
##! @param [-t|--tag <name>]    filter by tag
##! @param [-g|--group <name>]  filter by group
##! @output one line per entry: id, stamp, title or command
function nim.codex.list() { .nim.core.init.fn || return 1
    local tag=""
    local group=""
    while (( ${#} > 0 )); do
        case "${1}" in
            -t|--tag)   tag="${2}"; shift 2 ;;
            --tag=*)    tag="${1#*=}"; shift ;;
            -g|--group) group="${2}"; shift 2 ;;
            --group=*)  group="${1#*=}"; shift ;;
            *) shift ;;
        esac
    done

    [[ -d ${NIM_CODEX_STORE}/entries ]] || {
        nim.out.info "codex: empty"
        return 0; }

    local f
    for f in "${NIM_CODEX_STORE}/entries/"*.json; do
        [[ -r ${f} ]] || continue
        [[ -n ${tag} ]] \
            && ! grep -q "\"tags\":\"[^\"]*${tag}" "${f}" && continue
        [[ -n ${group} ]] \
            && ! grep -q "\"groups\":\"[^\"]*${group}" "${f}" && continue
        # TODO: replace shell parsing with jq when a json subsystem lands
        local id stamp title cmd
        id="$(sed -nE 's/.*"id":"([^"]+)".*/\1/p' "${f}")"
        stamp="$(sed -nE 's/.*"stamp":"([^"]+)".*/\1/p' "${f}")"
        title="$(sed -nE 's/.*"title":"([^"]+)".*/\1/p' "${f}")"
        cmd="$(sed -nE 's/.*"cmd":"([^"]+)".*/\1/p' "${f}")"
        printf "%-12s  %-20s  %s\n" \
            "${id}" "${stamp}" "${title:-${cmd:0:60}}"
    done
    return 0; }

# TODO: nim.codex.export — render a tag/group subset as a markdown doc
# TODO: nim.codex.find    — full-text search over cmd/title/tags
# TODO: subshell mode     — bare `nim.codex` opens an interactive prompt
