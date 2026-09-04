#!/usr/bin/env bash

# another *righteous entropy synthesis* by ⎰𝙉𝙄𝙈⎰ ...
# ----------------------------------------------------------------------------
#   NIM Substation One | Planet Earth | https://github.com/metasyndicate
# ----------------------------------------------------------------------------
#   ... The NIM ***Metashell***: ***setup***
#   install/setup/bootstrap helpers. provisions operator-scope directories,
#   emits shell-init snippets, validates environment health.
# ----------------------------------------------------------------------------

nim.source core fn log colors output fs

# === PUBLIC ===

##! @function nim.setup.operator
##! @description provision the operator-scope tree under ${NIM_OPS} and
##!              seed ~/.nim/nim.cfg from etc/nim.cfg if no operator cfg exists
##! @return 0 on success, 1 if any directory cannot be created or is unwritable
##! @example nim setup
function nim.setup.operator() { .nim.core.init.fn || return 1
    nim.out.info "provisioning operator scope at ${NIM_OPS}"

    nim.fs.mkdir "${NIM_OPS}"               0750 || return 1
    nim.fs.mkdir "${NIM_OPS}/log"           0750 || return 1
    nim.fs.mkdir "${NIM_OPS}/var"           0750 || return 1
    nim.fs.mkdir "${NIM_OPS}/codex"         0700 || return 1
    nim.fs.mkdir "${NIM_OPS}/codex/entries" 0700 || return 1

    local user_cfg="${HOME}/${NIM_STOR}/nim.cfg"
    [[ -e ${user_cfg} ]] && {
        nim.out.status "operator config exists: ${user_cfg}" skip
        nim.out.ok "operator scope ready"
        return 0; }

    nim.fs.mkdir "$(dirname "${user_cfg}")" 0750 || return 1
    [[ -r "${NIM_METASHELL_ETC}/nim.cfg" ]] || {
        nim.out.warn "no system cfg to seed from; ${user_cfg} not created"
        return 0; }

    cp "${NIM_METASHELL_ETC}/nim.cfg" "${user_cfg}" 2>/dev/null \
        && chmod 0640 "${user_cfg}" 2>/dev/null \
        && nim.out.status "wrote operator config: ${user_cfg}" ok \
        || { nim.out.fail "could not write ${user_cfg}"; return 1; }

    nim.out.ok "operator scope ready"
    return 0; }

##! @function nim.setup.init
##! @description emit a shell init line for sourcing metashell in caller shell
##!              intended use: source /path/to/etc/nim.init.sh in rc/profile
##! @output shell source line on stdout
##! @example source /path/to/nim.metashell/etc/nim.init.sh
function nim.setup.init() { .nim.core.init.fn || return 1
    local init_script="${NIM_METASHELL_ETC}/nim.init.sh"
    [[ -r ${init_script} ]] || {
        nim.out.fail "missing init script: ${init_script}"
        return 1; }

    # When stdout is a TTY, operator likely ran `nim init` directly.
    # Emit guidance to stderr; keep stdout machine-usable.
    if [[ -t 1 ]]; then
        printf "nim: activate metashell with:\n" >&2
        printf "     source %s\n\n" "${init_script}" >&2
    fi
    printf "source %q\n" "${init_script}"
    return 0; }

##! @function nim.setup.doctor
##! @description audit the runtime environment; print a status table
##! @return 0 if all checks pass, 1 if any check fails
##! @example nim doctor
function nim.setup.doctor() { .nim.core.init.fn || return 1
    local fail=0
    local v="${BASH_VERSINFO[0]}.${BASH_VERSINFO[1]}"

    .nim.setup.check.fn "bash 4+ (${v})" \
        "(( BASH_VERSINFO[0] >= 4 ))" || fail=1
    .nim.setup.check.fn "NIM_LIBPATH (${NIM_LIBPATH})" \
        '[[ -d ${NIM_LIBPATH} ]]' || fail=1
    .nim.setup.check.fn "NIM_METASHELL (${NIM_METASHELL})" \
        '[[ -d ${NIM_METASHELL} ]]' || fail=1
    .nim.setup.check.fn "NIM_OPS (${NIM_OPS})" \
        '[[ -d ${NIM_OPS} ]]' || fail=1
    .nim.setup.check.fn "system cfg (${NIM_METASHELL_ETC}/nim.cfg)" \
        "[[ -r '${NIM_METASHELL_ETC}/nim.cfg' ]]" || fail=1
    .nim.setup.check.fn "operator cfg (${HOME}/${NIM_STOR}/nim.cfg)" \
        "[[ -r '${HOME}/${NIM_STOR}/nim.cfg' ]]" skip-ok
    .nim.setup.check.fn "logger(1) available" \
        "command -v logger >/dev/null" warn-ok

    return ${fail}; }

##! @function nim.setup.summary
##! @description print a one-screen summary of the installed metashell
##! @output formatted summary on stdout/stderr
function nim.setup.summary() { .nim.core.init.fn || return 1
    nim.out.info "NIM Metashell — ${NIM_SUBTAG} @ ${NIM_LIBPATH}"
    printf "\n"
    printf "  paths:\n"
    printf "    NIM_LIBPATH       %s\n" "${NIM_LIBPATH}"
    printf "    NIM_METASHELL     %s\n" "${NIM_METASHELL}"
    printf "    NIM_HOME          %s\n" "${NIM_HOME}"
    printf "    NIM_OPS           %s\n" "${NIM_OPS}"
    printf "    NIM_METASHELL_ETC %s\n" "${NIM_METASHELL_ETC}"
    printf "    NIM_METASHELL_SYS %s\n" "${NIM_METASHELL_SYS}"
    printf "\n"
    local count
    count="$(nim.fn.list | wc -l | tr -d ' ')"
    printf "  loaded modules:        %s\n" "${#_NIM_LOADED[@]}"
    printf "  public functions:      %s\n" "${count}"
    printf "  registered subsystems: %s\n" "${#_NIM_SYS[@]}"
    printf "\n"
    return 0; }

# === PRIVATE ===

##! @function .nim.setup.check.fn
##! @description run a check expression and emit a status line
##! @param <label>          left-side label
##! @param <expression>     bash expression evaluated via eval; non-zero = fail
##! @param [policy=strict]  strict | skip-ok | warn-ok
##! @return 0 if check passes (or policy allows), 1 if it fails strictly
function .nim.setup.check.fn() {
    local label="${1}"
    local expr="${2}"
    local policy="${3:-strict}"
    eval "${expr}" 2>/dev/null && {
        nim.out.status "${label}" ok
        return 0; }
    case "${policy}" in
        skip-ok)  nim.out.status "${label}" skip; return 0 ;;
        warn-ok)  nim.out.status "${label}" warn; return 0 ;;
        *)        nim.out.status "${label}" fail; return 1 ;;
    esac; }
