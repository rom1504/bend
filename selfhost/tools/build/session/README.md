# Experimental sessions and exact object reuse

This is one experimental interface to the maintained Bend compiler. The shared
compiler owns parsing, checking, change invalidation, backend planning, QBE
rendering and reuse decisions. These host files transport bytes, authenticate
inputs and invoke pinned machine tools. They do not implement a second frontend
or interpret QBE instructions.

The compiler's existing incremental path is preserved. The only additive Bend
module is `selfhost/src/session/object-frames.bend`: three declarations exposing
complete machine-unit boundaries from the existing `P134Cursor`. It changes no
declaration or compiler decision. A function bundle can contain several QBE
functions; an object is not necessarily one source definition.

## Explicit modes and boundaries

| Path | Input/contract | Established by its controls |
|---|---|---|
| Hosted session | Checked Bend API, fixed prepared Base, ordered source snapshots, logical filename, owner and edit hint | Cold/no-op/real edit/revert; same-mode cold comparison; parse/type error recovery |
| Native byte session | Native image explicitly bound to `P140/2`; successful batch only | Counted byte framing and identity-bound prior pieces; no native recovery claim |
| Object reuse | Bend-framed `P135/1` units, pinned QBE/as/objcopy/linker/runtime | Exact byte keys, closed-image symbol globalization, stale/corrupt object refusal |

These are experimental capabilities. They do not select a default compiler or
claim a self-hosting fixed point, complete incremental invalidation theorem,
native error recovery, general separate compilation, or broad performance gains.
An ordinary cold compile is a different mode from a cold incremental session;
the controls compare identical modes. This migration does not reinstate an older
compiler implementation.

`session.py` requires a checked `session-api-v1` image binding for JavaScript.
Native use requires `sessionProtocols: ["P140/2"]` in an explicitly qualified
image binding. A native ordinary-request capability alone is insufficient, even
when matching source contains a batch dispatch declaration. Native mode does
not claim the object-unit adapter is reachable from its CLI. Unit production in
this slice uses the checked hosted Bend API.

## Acquire the shared checked API

Run these commands from the repository root. `ROOT_SOURCE` below is a fresh
source assembled by `selfhost/tools/build/source.py` from the maintained modules;
there is no implicit historical source lookup. The adapter preparation performs
only byte assembly and duplicate-declaration checks. Acquisition performs the
actual Bend check. Use fresh output directories.

```sh
python3 -B selfhost/tools/build/session/prepare.py \
  --source "$ROOT_SOURCE" --out selfhost/build/session-source

selfhost/.assets/bin/bun selfhost/tools/build/hosted.mjs acquire \
  --source selfhost/build/session-source/session.bend \
  --exports selfhost/tools/build/session/exports.json \
  --out selfhost/build/session-api \
  --upstream selfhost/.bootstrap/upstream-phase66 \
  --engine selfhost/.assets/bin/bun
```

The example upstream is the explicitly pinned checker checkout, not a compiler
source fallback. Its revision and acquisition methods are recorded. In another
workspace supply the qualified checkout explicitly. Run acquisition and every
compiler, QBE or generated-program execution under the repository's
`selfhost/tools/build-retention/guard.py`; declare all fresh artifact roots,
finite time/RSS limits, an honest disk budget, and the required reserve.
The commands shown here are the commands *inside* that outer guard.

`selfhost/manifests/assets-session.json` is a separate operational manifest. It
adds the `objcopy` identity needed for the closed-image policy without mutating a
manifest already consumed by another build. Verify/acquire its named assets
with the ordinary `build/assets.py` interface. It does not silently add a native
session qualification to an ordinary native image.

## Run the bounded semantic controls

```sh
python3 -B selfhost/tools/build/session/controls.py prepare \
  --out selfhost/build/session-fixtures

python3 -B selfhost/tools/build/session/session.py \
  --assets selfhost/manifests/assets-session.json \
  --host js --stage B1 \
  --image selfhost/build/session-api/api.mjs \
  --image-receipt selfhost/build/session-api/report.json \
  --jobs selfhost/build/session-fixtures/jobs.json \
  --check-cold --units --seconds 120 \
  --out selfhost/build/session-semantic

python3 -B selfhost/tools/build/session/controls.py inspect \
  --report selfhost/build/session-semantic/hosted.json \
  --out selfhost/build/session-semantic-controls
```

`--plan` authenticates the request and prints it without executing the compiler.
Every job specifies `name`, immutable `source`, source-relative UTF-16 `hint`,
`owner`, `mode` (`cold` or `warm`) and `expectError`. All jobs share one absolute
logical source path and one prepared Base. An optional `expected` pins a frozen
complete QBE product. The eight-job control includes both parse/type refusal and
successful recovery, verifies the error leaves the prior compiler cache exact,
and checks every request against a separate empty session in the same mode.
The positive A/B programs independently evaluate to `3` and `5`.

For a separately qualified native session image, select `--host native`, its
actual stage and image binding, use `native-jobs.json`, and omit `--check-cold`
and `--units`. Native batch failure aborts publication. The supervisor joins
successful producer exit before decoding transport; a transport receipt alone
deliberately does not attest producer success.

## Object controls and reuse

```sh
python3 -B selfhost/tools/build/session/object-controls.py \
  --assets selfhost/manifests/assets-session.json \
  --session selfhost/build/session-semantic/hosted.json \
  --out selfhost/build/session-objects --seconds 60
```

This performs cold, unchanged and real-edit object builds, executes their three
scalar outputs, and verifies both reuse and rebuilding on the real edit. It
checks producer/runtime/tool/flags/method/policy/payload key separation and
deliberately corrupts one private test-cache object to establish rejection,
restoring the bytes afterwards. It is a qualification control, not a benchmark.

For individual requests, `objects.py` accepts `--stream` (a completed `.units`
file), `--producer` (the exact generating API/image), `--source`, `--assets`,
`--cache` and a fresh `--out`; `--expected` binds the full concatenated QBE.
Source identity is recorded per request but intentionally excluded from each
object key: unchanged exact units can survive a source edit. Producer, target
runtime, tools, flags, adapter methods, policy and complete unit bytes are in the
key. The runtime linked into the compiler image is a distinct identity from the
runtime subsequently linked into generated programs.

The closed non-PIE x86-64 policy globalizes only the known generated symbols.
`elf.py` verifies allocated bytes, relocations and all other symbol information
are unchanged. Unknown generated symbols, duplicate definitions, wrong object
architecture, incomplete receipts and corrupted cache objects are rejected.
This is not an arbitrary ELF rewriter or public cross-module ABI. The assembly
alignment policy matches the ordinary native build. A failed or partial cache
entry remains fail-closed; use a fresh cache to retry.

P140/2 is length-counted and accepts arbitrary opaque payload bytes. P135/1 is
a line-framed boundary view of compiler-generated QBE only; it does not claim
arbitrary opaque transport. The independent host-only protocol controls are:

```sh
python3 -B selfhost/tools/build/session/transport-controls.py \
  --out selfhost/build/session-transport-controls
python3 -B selfhost/tools/build/session/protocol-controls.py \
  --out selfhost/build/session-protocol-controls
```

## Migration provenance

The source audit found all 609 accepted incremental declaration names in the
maintained shared source. Nine later body refinements were retained, rather
than replacing them with earlier experimental bodies. Native batch/session
dispatch is already in that shared source. Only the three-declaration object
boundary view was absent. The prepared migration audit records exact source and
extension hashes; no maintained method reads an experiment directory.

`transport.py`, `protocol.py` and `elf.py` retain their previously accepted byte
protocol and ELF audit implementations. Their versioned wire names are stable
protocol identities, not runtime imports of an old experiment. The maintained
machine stage reuses the ordinary build identity and child-process helpers.
Qualification receipts must remain separate from these architectural facts:
source presence and host parsing alone do not establish semantic conformance.
