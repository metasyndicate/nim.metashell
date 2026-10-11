#!/usr/bin/env bash

# another *righteous entropy synthesis* by ⎰𝙉𝙄𝙈⎰ ...
# ----------------------------------------------------------------------------
#   NIM Substation One | Planet Earth | https://github.com/metasyndicate
# ----------------------------------------------------------------------------
#   ... The NIM ***Metashell***: ***clip***
#   system clipboard bridge. resolves a copy/paste pair once per shell
#   (pbcopy, wl-copy, xclip, xsel), then reads and writes it. the history
#   capture path feeds nim.codex.add — see @example below.
#
#   stdout carries clipboard content only; all status goes to stderr.
# ----------------------------------------------------------------------------

nim.source core fn log output validate

# === GLOBALS ===

# Resolved clipboard commands, as argv arrays. Empty until the first
# .nim.clip.detect.fn call. Operators may preset NIM_CLIP_COPY and
# NIM_CLIP_PASTE (whitespace-delimited command lines) to override probing.
declare -ga _NIM_CLIP_COPY 2>/dev/null
declare -ga _NIM_CLIP_PASTE 2>/dev/null

# === PRIVATE ===

##! @function .nim.clip.detect.fn
##! @description resolve a copy/paste command pair for this platform, once
##! @description honors NIM_CLIP_COPY / NIM_CLIP_PASTE when set
##! @return 0 if a usable pair is resolved, 1 if no clipboard is available
function .nim.clip.detect.fn() {
    (( ${#_NIM_CLIP_COPY[@]} > 0 )) && return 0

    [[ -n ${NIM_CLIP_COPY} && -n ${NIM_CLIP_PASTE} ]] && {
        read -ra _NIM_CLIP_COPY  <<< "${NIM_CLIP_COPY}"
        read -ra _NIM_CLIP_PASTE <<< "${NIM_CLIP_PASTE}"
        return 0; }

    # Probe in descending specificity: macOS, Wayland, then X11. Each pair
    # is checked as a unit — a copy tool without its paste counterpart is
    # not a usable clipboard.
    if command -v pbcopy &>/dev/null && command -v pbpaste &>/dev/null; then
        _NIM_CLIP_COPY=( pbcopy )
        _NIM_CLIP_PASTE=( pbpaste )
    elif command -v wl-copy &>/dev/null && command -v wl-paste &>/dev/null; then
        _NIM_CLIP_COPY=( wl-copy )
        _NIM_CLIP_PASTE=( wl-paste --no-newline )
    elif command -v xclip &>/dev/null; then
        _NIM_CLIP_COPY=( xclip -selection clipboard )
        _NIM_CLIP_PASTE=( xclip -selection clipboard -o )
    elif command -v xsel &>/dev/null; then
        _NIM_CLIP_COPY=( xsel --clipboard --input )
        _NIM_CLIP_PASTE=( xsel --clipboard --output )
    else
        nim.log.error "clip: no clipboard utility (pbcopy, wl-copy, xclip, xsel)"
        return 1
    fi
    nim.log.trace "clip: using ${_NIM_CLIP_COPY[0]}/${_NIM_CLIP_PASTE[0]}"
    return 0; }

# === PUBLIC ===

##! @function nim.clip.copy
##! @description write text to the system clipboard, from args or a pipe
##! @param [text...]            text to copy; omit to read stdin
##! @return 0 on success, 1 if no clipboard, no input, or the write failed
##! @example nim.clip.copy "systemctl status sshd"
##! @example git log --oneline -5 | nim.clip.copy
function nim.clip.copy() { .nim.core.init.fn || return 1
    .nim.clip.detect.fn || return 1

    local data
    if (( ${#} > 0 )); then
        data="${*}"
    elif [[ ! -t 0 ]]; then
        data="$(cat)"
    else
        nim.log.error "clip.copy: no input (pass text or pipe stdin)"
        return 1
    fi

    [[ -z ${data} ]] && {
        nim.log.error "clip.copy: input is empty"
        return 1; }

    # The clipboard tool's own exit status is the only reliable signal —
    # it produces no stdout to inspect.
    printf "%s" "${data}" | "${_NIM_CLIP_COPY[@]}" || {
        nim.log.error "clip.copy: ${_NIM_CLIP_COPY[0]} failed"
        return 1; }

    nim.log.info "clip.copy: ${#data} bytes"
    return 0; }

##! @function nim.clip.paste
##! @description emit the system clipboard contents on stdout
##! @output clipboard contents
##! @return 0 on success, 1 if no clipboard or the read failed
##! @example nim.clip.paste | nim.codex.add --tags=net
function nim.clip.paste() { .nim.core.init.fn || return 1
    .nim.clip.detect.fn || return 1

    "${_NIM_CLIP_PASTE[@]}" || {
        nim.log.error "clip.paste: ${_NIM_CLIP_PASTE[0]} failed"
        return 1; }
    return 0; }

##! @function nim.clip.history
##! @description copy recent shell history to the clipboard, newest last
##! @param [count=1]            number of history entries to copy
##! @param [offset=0]           entries to skip back from the most recent
##! @return 0 on success, 1 if history is unavailable or the write failed
##! @example nim.clip.history 5
##! @example nim.clip.history 1 2
function nim.clip.history() { .nim.core.init.fn || return 1
    local count="${1:-1}"
    local offset="${2:-0}"

    nim.validate.number "${count}" || return 1
    nim.validate.number "${offset}" || return 1
    (( count > 0 )) || {
        nim.log.error "clip.history: count must be > 0"
        return 1; }

    # fc reads the live history list, which `history` cannot do from inside
    # a sourced function. Entry 1 is the most recent; the window therefore
    # runs from (offset + count) back to (offset + 1).
    local first=$(( offset + count ))
    local last=$(( offset + 1 ))

    local data
    data="$(fc -ln -"${first}" -"${last}" 2>/dev/null \
        | sed 's/^[[:space:]]*//')"
    [[ -z ${data} ]] && {
        nim.log.error "clip.history: no history in range (${first}..${last})"
        return 1; }

    nim.clip.copy "${data}" || return 1
    nim.out.ok "clip: ${count} $( (( count == 1 )) && printf command \
        || printf commands ) copied"
    return 0; }
