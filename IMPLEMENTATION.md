# NIM Metashell — Core Implementation Plan

> A lightweight, composable field interface for systems administrators, biomimetic agents, and advanced data infrastructure operators.

This document proposes a build-out for the core of `nim.metashell`. It synthesizes the existing skeleton (`nim.metashell/{nim.cfg.sh,crypt.sh,datacenter.sh}`), the working installed library (`/usr/local/nim/lib/sh/{core,in,out,sys}/**`), and the reference prototypes (`nim.root/.nim/.ref/**`, `nim.root/meta/sh/**`) into a single, atomic build sequence.

Goal: a small set of *solid, atomic, well-named primitives* that compose every higher-level capability — nothing in the metashell does not eventually reduce to these.

---

## 0.2 Knowns

- TODO: define referential `./.nim/**` substructure(s). the relative `.nim` substrucures are omnipresent throughout, with known subfolders, config files, scripts, etc. that should be defined, designated, established, and persisted as specific filesystem locations that hold various data implements, with various include/exclude (localized vs. distributed/default) requirements, etc.
- TODL include any core doc/instruction/context references for general/high level perspective/context/detail/data/metadata/etc.


---

## 0.2 Primacy

- always maintain full context
- refresh, analyze, model, and plan first
- scope high->low
- persist the doctrine
- think before acting
- know your principles
- schematize everything
- establish and assert
- standardize
- normalize
- reflect excellence
- follow the architecture


---

## 1. Goals & Non-Goals

### Goals

- **Atomic primitives.** Every function does one thing. Composition lives at the call site, not inside primitives.
- **Single source of truth for paths.** All filesystem locations derive from a small set of root variables. No path string appears twice.
- **Deterministic bootstrap.** Sourcing the metashell is idempotent; failures are loud and early.
- **Self-documenting functions.** Every function carries parseable metadata (`##!`) usable for validation, help, and introspection.
- **Operator/dev separation.** Public (`nim.*`) and private (`.nim.*`) namespaces enforce visibility without depending on access control.
- **Composable extension.** Subsystems and metakits attach via a single registration protocol (`nim.source`).
- **Cross-platform within reason.** Bash 4+ on macOS, Linux, BSD. Windows via WSL. No platform-specific dependencies in core.

### Non-Goals

- Replacing the shell. The metashell augments bash; it does not aim to be a new shell.
- Heavy frameworks. No event loops, no plugin systems, no DSL parsers in core.
- Hidden magic. If a function modifies environment, it announces that.

---

## 2. Naming & Namespacing

### Function Namespace

```
nim.<module>.<verb>                  # public, leaf
nim.<module>.<noun>.<verb>           # public, namespaced
nim.<module>.<noun>.<adj>.<verb>     # public, deeply-namespaced
.nim.<module>.<verb>.fn              # private/internal (leading dot)
.nim.<module>.init.fn                # private: per-module bootstrap prologue
```

Rules:

- **Public** functions begin with `nim.` and are intended for operator and agent use. They appear in `nim.fn.list` output.
- **Private** functions begin with `.nim.` and end with `.fn`. They are filtered from operator-facing listings. They may be invoked by other functions but not advertised.
- **Module** is the second segment (`crypt`, `core`, `log`, `fs`). It maps 1:1 to a script file.
- **Verb-final** is the convention for action functions (`nim.path.absolute`, `nim.fn.exists`).
- **Noun-final** is the convention for value/getter functions (`nim.cfg.path`, `nim.log.level`).

### Variable Namespace

Four tiers, in order of derivation:

| Tier | Pattern | Examples |
|------|---------|----------|
| **Substring** | `NIM_<TAG>` | `NIM_TAG="nim"`, `NIM_SUBTAG="metashell"`, `NIM_STOR=".nim"` |
| **Root** | `NIM_<SCOPE>` | `NIM_HOME`, `NIM_OPS`, `NIM_<SUB>` |
| **Trunk** | `NIM_<SUB>_<DIR>` | `NIM_METASHELL_ETC`, `NIM_METASHELL_BIN`, `NIM_METASHELL_LIB` |
| **Config** | `NIM_<SUB>_<SCOPE>_CFG` | `NIM_METASHELL_SYS_CFG`, `NIM_METASHELL_OPS_CFG` |

Rules:

- A tier-N variable is *only* defined in terms of tier-(N-1) variables. Roots derive from substrings. Trunks derive from roots. Configs derive from trunks. Never the reverse.
- Tier-0 (substrings) values are the only place rebranding is permitted. Changing `NIM_TAG` rebrands the whole subsystem deterministically.
- All variables exported by metashell scripts begin with `NIM_`. No exceptions.

### File Naming

```
core/<module>.sh           # one module per file, lowercase, single noun
<module>/<submodule>.sh    # nested submodules where structure demands it
*.cfg.sh                   # config file, sourceable
*.template.sh              # function set template, copied for new modules
```

---

## 3. Bootstrap & Initialization

A NIM session starts by sourcing exactly **one entry point**. Everything else cascades from there.

```bash
source ${NIM_METASHELL}/lib/nim.sh
```

`nim.sh` is the single canonical loader. It:

1. Sets tier-0 substrings (`NIM_TAG`, `NIM_SUBTAG`, `NIM_STOR`) if unset.
2. Derives tier-1 roots (`NIM_HOME`, `NIM_OPS`, `NIM_<SUB>`) by inspection (resolving `${BASH_SOURCE[0]}`).
3. Sources `core/cfg.sh` to load the resolution machinery.
4. Resolves and sources system, user, and project configs in scope order.
5. Sources `core/core.sh` (which exposes `nim.source`).
6. Loads required core modules: `core/log.sh`, `core/fn.sh`.
7. Validates the environment (`nim.env.validate`).
8. Reports ready status to stderr at `NIM_LOGLEVEL >= 4`, silent otherwise.

```
nim.sh
  └── core/cfg.sh        (must be self-contained — only bash builtins)
  └── core/core.sh       (depends on cfg)
  └── core/log.sh        (depends on core)
  └── core/fn.sh         (depends on core, log)
  └── [user modules]     (depend on the above via nim.source)
```

The bootstrap rule: **a module deeper in the chain may depend on shallower modules; the reverse is forbidden.** Cyclic dependencies cause sourcing to fail loudly.

---

## 4. Path & Config Schema

### Resolution Order

```
1. Explicit absolute path argument
2. NIM_<KEY> environment variable
3. Project scope:  ${PROJECT_ROOT}/.nim/nim.cfg
4. User scope:     ${HOME}/.nim/nim.cfg          (or  ~/.nimrc)
5. System scope:   /usr/local/nim/etc/nim.cfg
6. Compiled-in defaults
```

Lower scopes override higher scopes per-key. `nim.cfg.resolve <key>` walks the chain and returns the first match.

### Single Source of Truth

Path derivation lives in **one file**: `core/cfg.sh`. Every other module asks `nim.cfg.path <key>` rather than constructing its own. Hard-coded path strings outside `core/cfg.sh` are a code smell and should fail review.

### Config File Format

`*.cfg.sh` files are bash-sourceable, with one-pair-per-line key/value:

```bash
NIM_LOGLEVEL=4
NIM_LOGFILE="${NIM_OPS}/log/nim.log"
NIM_DEFAULT_EDITOR="${EDITOR:-vim}"
```

No logic, no functions, no conditionals. If logic is needed, the resolution machinery in `core/cfg.sh` handles it.

---

## 5. Module Architecture

Five layers, each depends only on lower layers. The metashell follows the NIM-wide [structural hierarchy](../nim.root/.nim/DOCTRINE.md#structural-hierarchy) (metasystem → system → subsystem → module → function); subsystems are the L1–L4 groupings below.

```
┌──────────────────────────────────────────────────────────────────┐
│  L4  external subsystems   metashell/sys/<subsystem>/<module>.sh │
│      crypt, datacenter, taxonomy, ...                            │
├──────────────────────────────────────────────────────────────────┤
│  L3  built-in sys           lib/sys/{fs,mod,db,codex,setup,…}    │
├──────────────────────────────────────────────────────────────────┤
│  L2  built-in io            lib/in/{input,get,validate}          │
│                              lib/out/{colors,output,strings,…}   │
├──────────────────────────────────────────────────────────────────┤
│  L1  built-in core          lib/core/{cfg,core,log,fn}           │
├──────────────────────────────────────────────────────────────────┤
│  L0  bootstrap              lib/nim.sh                           │
└──────────────────────────────────────────────────────────────────┘
```

### Filesystem Layout

```
nim.metashell/
├── bin/nim                      operator entry point (executable)
├── etc/nim.cfg                  system-scope cfg defaults
├── lib/                         BUILT-IN subsystems
│   ├── nim.sh                   L0 bootstrap loader
│   ├── core/{cfg,core,log,fn}.sh
│   ├── in/{input,get,validate}.sh
│   ├── out/{colors,output,strings}.sh
│   └── sys/{fs,mod,codex,setup}.sh
└── sys/                         EXTERNAL subsystems (extension scope)
    └── <subsystem>/
        ├── <subsystem>.sh       module(s) directly under subsystem dir
        └── .nim/nim.sys.cfg.sh  manifest (NIM_SYS_NAME, _DEPS, _MODS, …)
```

A module at layer N may call any function at layer < N. Calls into the same layer are permitted but documented. Calls into a higher layer are forbidden — any attempt is a layering violation.

External subsystems (`sys/<name>/`) register with `nim.mod.register`, which loads the manifest, resolves declared deps, extends `_NIM_LIBPATHS` with the subsystem dir, and sources the modules listed in `NIM_SYS_MODS`.

---

## 6. Core Modules (L0 + L1)

This is the minimum set. Everything else is built on top of these.

### 6.1 `lib/nim.sh` — the loader

| Function | Purpose |
|----------|---------|
| `nim.boot` | Idempotent entry. Sets substrings, derives roots, sources `core/cfg.sh` and `core/core.sh`, validates. |
| `nim.boot.preflight` | Bash version, required commands, writeable paths. |
| `nim.boot.report` | Print bootstrap summary if `NIM_LOGLEVEL >= 4`. |

`nim.sh` itself is the only file that may be sourced before `nim.boot` runs — everything else assumes the environment is initialized.

### 6.2 `core/cfg.sh` — paths & configuration

Self-contained. **Only bash builtins** — does not source anything else. This is the floor of the dependency tree.

| Function | Purpose |
|----------|---------|
| `nim.cfg.path <key>` | Resolve a path key against scope chain. |
| `nim.cfg.get <key>` | Resolve a config value against scope chain. |
| `nim.cfg.set <key> <value>` | Set a value in the operator scope file. |
| `nim.cfg.load <file>` | Source a `*.cfg.sh` with validation. |
| `nim.cfg.scopes` | List known scope files in order. |
| `nim.cfg.resolve <key>` | Internal: scope walk; returns first match. |
| `nim.cfg.list [prefix]` | List all NIM_-prefixed vars matching prefix. |
| `nim.cfg.validate` | Verify required keys are set and paths exist. |

### 6.3 `core/core.sh` — primitives

The primitive layer. Every higher function in the metashell starts with `.nim.core.init.fn ${@}` (validation+prologue) and depends on these.

| Function | Purpose |
|----------|---------|
| `nim.source <name>...` | Resolve and source a module by name; idempotent. |
| `nim.source.list` | List sourceable modules in `${NIM_LIBPATH}`. |
| `nim.source.loaded` | List currently-loaded modules. |
| `nim.path.absolute <path>` | Cross-platform absolute path resolution. |
| `nim.path.init <path>` | Create + validate a directory path. |
| `nim.path.script` | Absolute path of currently-sourced script. |
| `nim.env.validate` | Confirm `NIM_LIBPATH`, bash version, sourcing mode. |
| `nim.env.set <key> <value>` | Set + persist an environment var. |
| `nim.env.list [prefix]` | List NIM_-prefixed environment vars. |
| `.nim.core.init.fn <args>` | Internal: standard function prologue. |

### 6.4 `core/log.sh` — structured logging

| Function | Purpose |
|----------|---------|
| `nim.log <level> <msg>` | Generic log dispatcher. |
| `nim.log.debug <msg>` | DEBUG-level message. |
| `nim.log.info <msg>` | INFO-level message. |
| `nim.log.warn <msg>` | WARNING-level message. |
| `nim.log.error <msg>` | ERROR-level message. |
| `nim.log.trace <msg>` | TRACE-level message. |
| `nim.log.init [tag] [level]` | Create logfile, set tag/level. |
| `nim.log.stamp.begin` | Mark session start in logfile. |
| `nim.log.stamp.end` | Mark session end in logfile. |
| `nim.log.level <0-7>` | Get/set runtime log level. |

Routes through `logger(1)` where available; falls back to direct file append.

### 6.5 `core/fn.sh` — function authoring & introspection

The dev-augmentation layer (the `nim.fn.*` namespace). Houses the metadata cache (`_NIM_FN_META`, `_NIM_FN_REQUIRED`) — the single source of truth for argument shape, populated lazily and eagerly by the `nim.source` post-load hook (function/module onboarding).

| Function | Purpose |
|----------|---------|
| `nim.fn.exists <name>` | Test whether a function is defined. |
| `nim.fn.list [filter]` | Public function names, optionally filtered. |
| `nim.fn.validate.args "$@"` | **Schema-driven** arg validation. Reads caller's `##! @param` from cache; rejects if fewer args than the declared minimum required-positionals. **No inline labels or count** — the schema lives in the caller's metadata. |
| `nim.fn.metadata <name> [field]` | Cached metadata block (or single field). |
| `nim.fn.help <name>` | Render usage block from cached metadata. |
| `nim.fn.source <name>` | Path of script defining the function. |
| `nim.fn.scan <script>` | Onboarding: extract metadata for every `@function` in `<script>`; populate caches. Called by `nim.source` post-load hook. |
| `.nim.fn.parse.fn <name> <script>` | **Private.** Parse one function's `##!` block; populate `_NIM_FN_META[name]` and `_NIM_FN_REQUIRED[name]`. The metadata-cache floor — does not call `validate.args` itself (would recurse). |
| `nim.fn.new <set> <name>` | *(Phase 3)* Scaffold a new function in a set. |
| `nim.fn.set.new <name>` | *(Phase 3)* Create a new function set with header. |
| `nim.fn.set.header <name>` | *(Phase 3)* Generate the canonical set header. |

These compose the development surface: the framework uses `nim.fn.validate.args` to enforce contracts (driven by the metadata schema); `nim.fn.help` and `nim.fn.metadata` render and query docs; `nim.fn.scan` runs at module-load time so cached metadata is ready before any caller asks.

**Why the cache.** Every `nim.*` function call invokes `nim.fn.validate.args`, which needs to know the caller's required-positional count. Re-parsing the source file on every call would re-`sed` the file each time. Instead, `nim.source`'s post-load hook calls `nim.fn.scan` once per module, populating `_NIM_FN_META` and `_NIM_FN_REQUIRED` in bulk. Subsequent validation is an `${associative_array[key]}` lookup — O(1).

---

## 7. IO Modules (L2)

### 7.1 `out/` — output

| File | Purpose |
|------|---------|
| `out/colors.sh` | ANSI/256-color variables (`RED`, `GRN`, `BLU`, `OFF`, …). No functions, just exports. |
| `out/output.sh` | `nim.out.{ok,fail,warn,info}`, formatted lines, status indicators. |
| `out/present.sh` | `nim.present.{table,kv,tree,box}` — structured presentation. |
| `out/script.sh` | `nim.script.{header,banner,section}` — script chrome. |
| `out/spinners.sh` | `nim.spin.{start,stop,deluxe}` — async progress indicators. |
| `out/strings.sh` | `nim.str.{trim,clean,pad,wrap,upper,lower,slug}` — string utilities. |

### 7.2 `in/` — input

| File | Purpose |
|------|---------|
| `in/input.sh` | `nim.in.{prompt,confirm,select,multi,password}` — interactive input. |
| `in/get.sh` | `nim.get.{arg,opt,flag,env}` — argument parsing. |
| `in/validate.sh` | `nim.validate.{path,url,email,number,enum}` — input validators. |

---

## 8. System Modules (L3)

| File | Purpose |
|------|---------|
| `sys/fs.sh` | `nim.fs.{find,touch,mkdir,backup,rotate,perms}` — filesystem helpers with logging. |
| `sys/mod.sh` | `nim.mod.{register,list,info,reload}` — metakit registration. |
| `sys/db.sh` | `nim.db.{query,store,seed}` — local schematic datastore (JSON). |
| `sys/codex.sh` | `nim.codex.{add,set,list,export,find}` — the command catalog (per CLAUDE.md). |
| `sys/ldap.sh` | `nim.ldap.{search,bind,user}` — directory queries. |

`sys/codex.sh` is the implementation target named in the project CLAUDE.md — it lives at L3 and uses `core/cfg.sh` (paths), `core/log.sh` (audit), `in/` (operator prompts), and `out/` (export rendering).

---

## 9. Function Authoring Standard

Every function in the metashell follows the same shape.

### 9.1 Header Metadata — the Schema

```bash
##! @function nim.module.verb
##! @description one-line summary (this is the help text)
##! @param <required>             required positional (angle brackets)
##! @param [optional=default]     optional positional (square brackets)
##! @param [-f|--flag]            optional boolean flag
##! @param [-o|--opt <value>]     optional option-with-value
##! @output what gets printed (stdout/stderr distinction explicit)
##! @return 0 on success, 1 on failure
##! @example nim.module.verb foo bar
##! @see nim.module.related
```

**`##!` metadata IS the schema.** It is the single source of truth for argument shape, description, return semantics, and examples. Every consumer reads from it:

- `nim.fn.validate.args` reads required-positional count.
- `nim.fn.help` renders usage from it.
- `nim.fn.metadata <name> <field>` returns any individual field.
- The `nim.source` post-load hook runs `nim.fn.scan` to cache it at module-onboarding time.

Required-positional count is determined by counting `@param` lines whose first token starts with `<` (angle brackets). Square-bracket entries — `[opt=default]`, `[-f|--flag]`, `[--key <val>]` — are optional and don't count toward the minimum.

`##!` is the discriminator; the format is grep-friendly so tools render help without parsing bash AST.

### 9.2 Function Body

```bash
function nim.module.verb() { .nim.core.init.fn || return 1
    nim.fn.validate.args "${@}" || return 1

    local key="${1}"
    local value="${2:-default}"

    # ... atomic operation ...

    return 0; }
```

Conventions:

- **Prologue.** Every public function opens with `.nim.core.init.fn || return 1`. This validates the runtime environment and is the universal hook for instrumentation. (`.nim.core.init.fn` takes no arguments.)
- **Argument validation.** Immediately after the prologue, call `nim.fn.validate.args "${@}"` — pass argv, nothing else. The validator reads the caller's `##! @param` declarations from cache and rejects calls with fewer positional args than the schema requires. **Do not duplicate the schema at the call site** (no inline labels, no count). If the caller's metadata says two required positionals exist, validate.args knows.
- **No redundant emptiness checks.** Don't follow `validate.args` with `[[ -z ${1} ]] && return 1` — the validator already enforced `${#} >= required`. Domain checks ("is this slug a valid identifier?", "did the manifest declare a name?", "is this path a directory?") are different and stay in the body.
- **Local scoping.** Every variable declared `local`. No exceptions.
- **Conditional operators.** `[[ ]] && cmd && cmd` preferred over `if/then/fi` for short tests.
- **Inline coupling.** When a line and its consequent fit in <80 columns, couple them on one line.
- **Explicit returns.** `return 0` on success path, `return 1` on failure. Closing brace on the return statement: `return 0; }`.
- **Stderr for diagnostics.** Function output that is not the primary return value goes to `>&2`.
- **No echo for return values.** Functions that "return" a value do so via stdout; consumers capture with `$(…)`.

### 9.3 Error Handling

- Errors are logged via `nim.log.error` (or `nim.log.warn` for non-fatal).
- A function that fails returns 1 immediately — no partial state, no fallbacks.
- The caller decides whether to retry, fall back, or propagate.

---

## 10. Extension Protocol

### 10.1 Sourcing a Module

```bash
nim.source <name> [<name>...]
```

Names are **bare** (no path qualifier). The library search walks every entry in `_NIM_LIBPATHS` and matches `<name>.sh` anywhere underneath.

`nim.source`:

1. For each name, search `_NIM_LIBPATHS` (in order) for `<name>.sh`.
2. Resolve to absolute path; reject if not found.
3. If `_NIM_LOADED[<name>]` is set, skip (idempotent).
4. Source the file.
5. Record the load in `_NIM_LOADED`.
6. Run the `nim.fn.scan` post-load hook to onboard `##!` metadata.
7. Report OK/FAIL at `NIM_LOGLEVEL >= 4`.

### 10.2 Registering a Subsystem

An external subsystem is a directory under `<system>/sys/<subsystem>/` containing one or more `.sh` modules and a manifest at `.nim/nim.sys.cfg.sh`. Its directory token equals its subsystem name.

```
sys/<subsystem>/
├── <subsystem>.sh             primary module
├── <other-module>.sh           additional modules (optional)
└── .nim/
    └── nim.sys.cfg.sh          subsystem manifest
```

Registration:

```bash
nim.mod.register ${NIM_METASHELL_SYS}/<subsystem>
```

This:

1. Sources the manifest at `<path>/.nim/nim.sys.cfg.sh` in a controlled scope.
2. Validates `NIM_SYS_NAME` is set; rejects duplicate registration.
3. Resolves declared deps via `nim.source`.
4. Appends `NIM_SYS_PATH` to `_NIM_LIBPATHS`.
5. Sources every module in `NIM_SYS_MODS` (defaults to `[NIM_SYS_NAME]`).
6. Records the subsystem in `_NIM_SYS`.

After registration, the subsystem's modules are sourceable by bare name via `nim.source`, and its functions are introspectable via `nim.fn.help`/`nim.fn.metadata`.

### 10.3 Manifest Format

```bash
#!/usr/bin/env bash
# ⎰𝙉𝙄𝙈⎰  METASHELL SUBSYSTEM MANIFEST — declarations only.

NIM_SYS_NAME="crypt"                      # canonical subsystem name
NIM_SYS_VERSION="0.1.0"                   # semver
NIM_SYS_DEPS=( core fn log output input ) # bare-name deps
NIM_SYS_MODS=( crypt )                    # modules to source on register
NIM_SYS_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
```

The manifest carries no logic. It declares identity, version, dependencies, and module list — `nim.mod.register` interprets these and orchestrates the load.

---

## 11. Code Style

Inherits the NIM-wide shell style from [`.nim/DOCTRINE.md` — Code Style](../nim.root/.nim/DOCTRINE.md). The metashell adds:

- **PD-1: No heredocs.** Absolutely prohibited (`<<EOF`, `<<-`, `<<<`, multi-line string literals for file/command/data construction). Use the Write tool for files, arrays for commands, templates or `printf` for configs, `printf` / `jq` for JSON.
- **80-column hard limit.** No exceptions for "just barely over." Wrap, refactor, or rephrase. Banner separator lines also fit. Keep lines visually balanced — don't trail off the right edge.
- **Prefer short-circuit conditionals.** `[[ test ]] && { ... } || { ... }` is the canonical form. Use `if/then/else/fi` only when the success branch may legitimately return non-zero (`cmd && BLOCK1 || BLOCK2` runs `BLOCK2` when `BLOCK1` returns non-zero — real footgun). When in doubt: explicit `if/fi` is clearer than `&& { ...; true; }` workarounds.
- **Bash 4+ required.** Use associative arrays, `${var,,}`, `[[ ]]`. No `/bin/sh` portability.
- **Indentation.** 4 spaces. Tabs only where a tool absolutely requires them (e.g. Makefile recipes); never inside library code.
- **Quoting.** `"${var}"` always. Bare `${var}` only inside `[[ ]]` and arithmetic contexts where word-splitting can't bite.
- **Local scoping always.** Every variable inside a function is `local`. Globals are explicit `declare -gx` and live in clearly-marked global blocks.
- **Comments.** `# @nim:` for metashell directives; `# @<author>:` for personal notes; `##!` for parseable function metadata.
- **Banner header.** Every module file opens with the standard NIM banner block (Substation, transmission stamp, module description, separator lines). Separators are dashes that fit within 80 columns.
- **Structural comments.** `# === SECTION ===`, `# -- SUBSECTION --` separate function groups.

---

## 12. Module Banner Template

Every module file opens with this. `nim.fn.set.header` generates it.

```bash
#!/bin/bash

# another *righteous entropy synthesis* by ⎰𝙉𝙄𝙈⎰ ⦟𝙉𝙄𝙈⚛⦢  ...
#    🆃🅷🅴 🅽🅴🆆 🅸🅽🅵🆁🅰🆂🆃🆁🆄🅲🆃🆄🆁🅴 🅼🅴🆃🅰🆂🆈🅽🅳🅸🅲🅰🆃🅴
#  -------------------------------------------------------------------------------
#   NIM Substation One | Planet Earth | https://github.com/metasyndicate
#   Transmission: <T> | [<DATE>]@<author>
#  -------------------------------------------------------------------------------
#   ... The NIM ***Metashell***: <module description>
#  -------------------------------------------------------------------------------
#   ***<module>***: <one-line module purpose>
#  -------------------------------------------------------------------------------

# === GLOBALS ===

# === METHODS/FUNCTIONS ===

# -- PRIVATE --

# -- PUBLIC --

# -- INITIALIZATION --
```

---

## 13. Build Plan

Phased to keep each phase shippable. No phase introduces a dependency on a future phase.

### Phase 1 — Foundation (week 1)

Deliverables:

- [ ] `lib/nim.sh` — bootstrap loader
- [ ] `core/cfg.sh` — path/config resolution (no other deps)
- [ ] `core/core.sh` — `nim.source`, `nim.path.*`, `nim.env.*`, `.nim.core.init.fn`
- [ ] `core/log.sh` — `nim.log.*`
- [ ] `core/fn.sh` — `nim.fn.exists`, `nim.fn.list`, `nim.fn.validate.args`, `nim.fn.metadata`
- [ ] Test: source `nim.sh` from a clean shell; verify all of the above are callable.

Exit criteria: a fresh bash session can `source nim.sh` and run `nim.fn.list` without error.

### Phase 2 — IO (week 2)

Deliverables:

- [ ] `out/colors.sh` (port from `nim.root/.nim/.ref/colors/`)
- [ ] `out/output.sh`, `out/strings.sh`, `out/present.sh`
- [ ] `in/input.sh`, `in/get.sh`, `in/validate.sh`
- [ ] Test: write an interactive function set that uses input/output/colors end-to-end.

### Phase 3 — Function Authoring (week 2-3)

Deliverables:

- [ ] `nim.fn.new`, `nim.fn.set.new`, `nim.fn.set.header` (scaffolding)
- [ ] `nim.fn.help`, `nim.fn.example`, `nim.fn.test` (introspection)
- [ ] Module banner template generator
- [ ] Test: `nim.fn.set.new mykit && nim.fn.new mykit doit` produces a working scaffold.

### Phase 4 — System (week 3)

Deliverables:

- [ ] `sys/fs.sh`, `sys/mod.sh`
- [ ] `nim.mod.register` for metakit loading
- [ ] Convert existing `crypt.sh` and `datacenter.sh` into proper metakits.

### Phase 5 — Codex (week 4)

Deliverables:

- [ ] `sys/codex.sh` per the CODEX spec in the project CLAUDE.md
- [ ] `nim.codex.add`, `nim.codex.set`, `nim.codex.list`, `nim.codex.export`
- [ ] Pipe support: `<command> | nim.codex --tags=foo`
- [ ] Subshell mode: `nim.codex` with no args opens interactive prompt.

### Phase 6 — Polish

- [ ] `out/spinners.sh`, `out/script.sh`
- [ ] `sys/db.sh` (JSON datastore for codex backing)
- [ ] `sys/taxonomy.sh` (port from EASME for agent name generation)
- [ ] Documentation pass; `nim.fn.help` for every public function.

---

## 14. Open Questions / Decisions

Items requiring confirmation before implementation begins.

1. **Bash baseline.** Bash 4+ requires explicit install on macOS (default is 3.2). Confirm we require operators to install via Homebrew (existing notes suggest yes).
2. **Logger fallback.** `core/log.sh` uses `logger(1)`. On systems without it, fall back to direct file append? Or fail loudly? *Proposal: fall back, emit a one-time warning at init.*
3. **Codex datastore.** SQLite, JSON-only, or both? The project CLAUDE.md suggests JSON for portability, but a relational store might serve query/tag operations better. *Proposal: JSON primary, SQLite as optional accelerator via `sys/db.sh`.*
4. **Scope file format.** Bash-sourceable `*.cfg.sh` (per existing pattern) or YAML/TOML (more portable)? *Proposal: stick with `*.cfg.sh` for L0–L2, allow YAML/TOML for L4 metakits via opt-in parser.*
5. **Module reload.** Should `nim.source` re-source if already loaded, or require explicit `nim.source.reload`? *Proposal: explicit reload only; idempotent default.*
6. **Versioning.** How does a metakit declare bash/metashell version requirements? *Proposal: `NIM_KIT_REQUIRES` array in manifest, checked at registration.*
7. **Session-scoped state.** Codex `set` mentions session/environment vars for sticky tag/group context. Per-shell, per-tty, or per-PID? *Proposal: per-PID via `${NIM_SESSION_FILE}`; cleanup on shell exit via trap.*

---

## 15. References

- Existing skeleton: `nim.metashell/{nim.cfg.sh,crypt.sh,datacenter.sh}`
- Working installed library: `/usr/local/nim/lib/sh/{core,in,out,sys}/**`
- Reference patterns: `nim.root/.nim/.ref/{core,function,log,colors,crypto}/**`
- In-progress prototypes: `nim.root/meta/sh/{core,data,ops,out,sys}/**`
- Code style notes: `nim.root/.nim/.ref/nims.sh.notes.sh`
- Sibling library (idiomatic source): `nim.agency/arc/**` (function sets, validation patterns)
- Project doctrine: `nim.root/.nim/DOCTRINE.md`, `nim.root/.nim/PATHS.md`
- CODEX spec: `nim.root/CLAUDE.md` ("ENVIRONMENT MODULES CODEX" section)

---

## 16. Reference Implementations

Sourceable first-draft pseudocode for the modules described above lives in [proposals/](./proposals/). Each file is a working illustration of the conventions — not a finished implementation.

| Module | File | Functions Demonstrated |
|--------|------|------------------------|
| L0 bootstrap | [proposals/lib/nim.sh](./proposals/lib/nim.sh) | tier-0/1 derivation, core cascade, `nim.boot.preflight`, scope resolution |
| L1 cfg | [proposals/core/cfg.sh](./proposals/core/cfg.sh) | `nim.cfg.{load,get,path,scopes,list}` — builtins-only |
| L1 core | [proposals/core/core.sh](./proposals/core/core.sh) | `.nim.core.init.fn`, `nim.path.{absolute,init}`, `nim.source`, `nim.env.*` |
| L1 log | [proposals/core/log.sh](./proposals/core/log.sh) | `.nim.log.write.fn`, `nim.log.{error,warn,info,debug,trace}`, `nim.log` dispatcher |
| L1 fn | [proposals/core/fn.sh](./proposals/core/fn.sh) | `nim.fn.{exists,validate.args,source,metadata,list,help}` |
| L2 out | [proposals/out/colors.sh](./proposals/out/colors.sh) | ANSI/256-color exports + tty guard |
| L2 out | [proposals/out/output.sh](./proposals/out/output.sh) | `nim.out.{ok,fail,warn,info,status}` |
| L2 in | [proposals/in/input.sh](./proposals/in/input.sh) | `nim.in.{prompt,confirm,select}` — non-tty guarded |
| L3 sys | [proposals/sys/mod.sh](./proposals/sys/mod.sh) | `nim.mod.{register,list,info}` — extension protocol |
| L3 sys | [proposals/sys/codex.sh](./proposals/sys/codex.sh) | `nim.codex.{set,add,list}` — the project target |

Smoke test (after Phase 1 paths are wired up):

```bash
source proposals/lib/nim.sh
nim.fn.list
nim.fn.help nim.source
echo "ls -la /tmp" | nim.codex.add --tags=fs,debug
nim.codex.list --tag=fs
```

The remaining `out/*` modules (`present`, `script`, `spinners`, `strings`), `in/get.sh`, `in/validate.sh`, and `sys/{fs,db,ldap}.sh` follow the same patterns — they're omitted from the proposal set to keep review scope tight, not because they're skipped in the build plan.
