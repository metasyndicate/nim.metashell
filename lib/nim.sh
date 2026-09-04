#!/usr/bin/env bash

# another *righteous entropy synthesis* by ⎰ 𝙉 𝙄𝙈 ⎰ ⦟ 𝙉 𝙄𝙈/⚛ ⦢  ...
# ----------------------------------------------------------------------------
#   NIM Substation One | Planet Earth | https://github.com/metasyndicate
# ----------------------------------------------------------------------------
#   ... The NIM ***Metashell***: bootstrap loader. single canonical entry.
#   sets tier-0 substrings, derives tier-1 roots, sources core, resolves
#   scopes, validates. sourcing this file is idempotent.
# ----------------------------------------------------------------------------

# === TIER-0: SUBSTRINGS (rebrand here, nowhere else) ===

[[ -z ${NIM_TAG} ]]    && declare -gx NIM_TAG="nim"
[[ -z ${NIM_SUBTAG} ]] && declare -gx NIM_SUBTAG="metashell"
[[ -z ${NIM_STOR} ]]   && declare -gx NIM_STOR=".${NIM_TAG}"

# === TIER-1: ROOTS (derived from this file's location) ===

# NIM_LIBPATH    - directory containing this script (lib/). search root for
#                  nim.source; subsystems live in subdirs (core/, in/, …).
# NIM_METASHELL  - parent of NIM_LIBPATH (system root: etc/, bin/, sys/, …)
# NIM_HOME       - parent of NIM_METASHELL (install root or arbitrary in dev)
# NIM_OPS        - per-operator scope directory under $HOME

# Canonical roots come from THIS nim.sh location; do not trust inherited
# values from another NIM surface already loaded in the parent shell.
declare -gx NIM_LIBPATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
declare -gx NIM_METASHELL="$(dirname "${NIM_LIBPATH}")"
declare -gx NIM_HOME="$(dirname "${NIM_METASHELL}")"

P1=FAIL; P2=FAIL; P3=FAIL

[[ -e ${NIM_LIBPATH} ]] && P1=PASS
[[ -e ${NIM_METASHELL} ]] && P2=PASS
[[ -e ${NIM_HOME} ]] && P3=PASS

printf "NIM_LIBPATH (%s) ............ %s\n" ${NIM_LIBPATH} ${P1} 
printf "NIM_METASHELL (%s) .......... %s\n" ${NIM_METASHELL} ${P2}
printf "NIM_HOME (%s) ............... %s\n" ${NIM_HOME} ${P3}

[[ -z ${NIM_OPS} ]] && declare -gx NIM_OPS="${HOME}/${NIM_STOR}/${NIM_SUBTAG}"

# === LOAD CORE (order matters; dependency floor first) ===

source "${NIM_LIBPATH}/core/cfg.sh" || {
    printf "nim.sh: core/cfg.sh failed\n" >&2; return 1; }
source "${NIM_LIBPATH}/core/core.sh" || {
    printf "nim.sh: core/core.sh failed\n" >&2; return 1; }

# Register the directly-sourced modules so subsequent nim.source <name>
# requests are idempotent (downstream modules declare `nim.source core`).
_NIM_LOADED[cfg]="${NIM_LIBPATH}/core/cfg.sh"
_NIM_LOADED[core]="${NIM_LIBPATH}/core/core.sh"

nim.source log fn || {
    printf "nim.sh: log/fn failed\n" >&2; return 1; }

# Post-bootstrap onboarding: nim.source's scan hook only fires for modules
# loaded AFTER fn.sh was sourced. Retroactively scan the early modules now
# so their @param metadata is in the cache and nim.fn.validate.args works
# for cfg/core/log/fn calls as well as everything downstream.
nim.fn.scan "${NIM_LIBPATH}/core/cfg.sh"  2>/dev/null
nim.fn.scan "${NIM_LIBPATH}/core/core.sh" 2>/dev/null
nim.fn.scan "${NIM_LIBPATH}/core/log.sh"  2>/dev/null
nim.fn.scan "${NIM_LIBPATH}/core/fn.sh"   2>/dev/null

# === PREFLIGHT (after core is loaded; can use nim.log now) ===

function nim.boot.preflight() {
    (( BASH_VERSINFO[0] >= 4 )) || {
        nim.log.error "bash 4+ required (found ${BASH_VERSION})"
        return 1; }
    [[ -d ${NIM_LIBPATH} ]] || {
        nim.log.error "NIM_LIBPATH invalid: ${NIM_LIBPATH}"
        return 1; }
    [[ ! $_ != $0 ]] && {
        printf "usage: source %s\n" "${BASH_SOURCE[0]}" >&2
        exit 1; }
    return 0; }

nim.boot.preflight || return 1

# === RESOLVE SCOPE CONFIGS ===
# Order matters: highest-priority scope loads FIRST, so its values are
# already set when subsequent (lower-priority) scopes try to assign. Cfg
# files use conditional assignment (`: ${VAR:=value}`), so first-set wins.
# Env-set values are highest priority — present before any cfg file loads.

nim.cfg.load "${PWD}/.${NIM_TAG}/nim.cfg"   2>/dev/null    # project
nim.cfg.load "${HOME}/${NIM_STOR}/nim.cfg"  2>/dev/null    # user
nim.cfg.load "${NIM_METASHELL}/etc/nim.cfg" 2>/dev/null    # system

if (( ${NIM_LOGLEVEL:-4} >= 4 )); then
    printf "nim: %s ready (%s)\n" "${NIM_SUBTAG}" "${NIM_LIBPATH}" >&2
fi

# Explicit success — sourcing should not propagate a nonzero exit just
# because a final conditional was false (avoids the `cmd && action`
# gotcha at EOF).
return 0
