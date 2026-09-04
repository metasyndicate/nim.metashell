#!/usr/bin/env bash

# another *righteous entropy synthesis* by ⎰𝙉𝙄𝙈⎰ ...
# ----------------------------------------------------------------------------
#   NIM Substation One | Planet Earth | https://github.com/metasyndicate
# ----------------------------------------------------------------------------
#  [NIM.METASHELL.SUBSYSTEM]: ***crypt***
#    integrated key/secret management. standardizes encoding, access,
#    storage, retrieval, signing, and key generation/distribution over
#    a flat ${NIM_OPS}/crypt store with armored-gpg payloads.
# ----------------------------------------------------------------------------

nim.source core fn log output input validate

# === GLOBALS ===

[[ -z ${NIM_CRYPT_STORE} ]] && declare -gx NIM_CRYPT_STORE="${NIM_OPS}/crypt"
[[ -z ${NIM_CRYPT_GPG} ]]   && declare -gx NIM_CRYPT_GPG="${GPG:-gpg}"

# === PRIVATE ===

##! @function .nim.crypt.init.fn
##! @description ensure crypt store exists and gpg is available
##! @return 0 on success, 1 on missing dependency or permission failure
function .nim.crypt.init.fn() { .nim.core.init.fn || return 1
    command -v "${NIM_CRYPT_GPG}" >/dev/null 2>&1 || {
        nim.log.error "crypt: ${NIM_CRYPT_GPG} not found in PATH"
        return 1; }
    [[ -d ${NIM_CRYPT_STORE} ]] || {
        mkdir -p "${NIM_CRYPT_STORE}" 2>/dev/null
        chmod 0700 "${NIM_CRYPT_STORE}" 2>/dev/null; }
    [[ -w ${NIM_CRYPT_STORE} ]] || {
        nim.log.error "crypt: store not writable: ${NIM_CRYPT_STORE}"
        return 1; }
    return 0; }

# === PUBLIC ===

##! @function nim.crypt.list
##! @description list secrets currently stored in NIM_CRYPT_STORE
##! @output one tag per line on stdout
function nim.crypt.list() { .nim.crypt.init.fn || return 1
    local f
    for f in "${NIM_CRYPT_STORE}/"*.gpg; do
        [[ -r ${f} ]] || continue
        printf "%s\n" "$(basename "${f}" .gpg)"
    done
    return 0; }

##! @function nim.crypt.put
##! @description encrypt a value and store it under <tag>
##! @param <tag>           identifier (lowercase; nim.validate.identifier)
##! @param [recipient=]    gpg recipient (defaults to symmetric)
##! @example echo 'secret' | nim.crypt.put my_token bradley@example.com
function nim.crypt.put() { .nim.crypt.init.fn || return 1
    nim.fn.validate.args "${@}" || return 1
    local tag="${1}"
    local recipient="${2:-}"
    nim.validate.identifier "${tag}" || {
        nim.out.fail "crypt.put: invalid tag (lowercase identifier): ${tag}"
        return 1; }
    local target="${NIM_CRYPT_STORE}/${tag}.gpg"
    local args=( --quiet --yes --batch --output "${target}" --armor )
    [[ -n ${recipient} ]] \
        && args+=( --encrypt --recipient "${recipient}" ) \
        || args+=( --symmetric )
    "${NIM_CRYPT_GPG}" "${args[@]}" 2>/dev/null || {
        nim.out.fail "crypt.put: gpg failed for ${tag}"
        return 1; }
    chmod 0600 "${target}" 2>/dev/null
    nim.out.ok "crypt.put: ${tag}"
    return 0; }

##! @function nim.crypt.get
##! @description decrypt a stored secret to stdout
##! @param <tag>
##! @output decrypted value on stdout
function nim.crypt.get() { .nim.crypt.init.fn || return 1
    nim.fn.validate.args "${@}" || return 1
    local tag="${1}"
    local source="${NIM_CRYPT_STORE}/${tag}.gpg"
    [[ -r ${source} ]] || {
        nim.log.error "crypt.get: not found: ${tag}"
        return 1; }
    "${NIM_CRYPT_GPG}" --quiet --decrypt "${source}" 2>/dev/null || {
        nim.log.error "crypt.get: decrypt failed: ${tag}"
        return 1; }
    return 0; }

##! @function nim.crypt.rm
##! @description remove a stored secret
##! @param <tag>
function nim.crypt.rm() { .nim.crypt.init.fn || return 1
    nim.fn.validate.args "${@}" || return 1
    local tag="${1}"
    local target="${NIM_CRYPT_STORE}/${tag}.gpg"
    [[ -e ${target} ]] || {
        nim.log.warn "crypt.rm: not found: ${tag}"
        return 0; }
    nim.in.confirm "remove encrypted secret ${tag}" || return 0
    rm -f "${target}" \
        && nim.out.ok "crypt.rm: ${tag}" \
        || { nim.out.fail "crypt.rm: ${tag}"; return 1; }
    return 0; }
