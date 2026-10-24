# Go build reuse: practical lessons for incremental native Bend

Research date: 2026-10-24. Bend checkout inspected: `2227ce2`,
`selfhost/bootstrap`. Scope: source research and one tiny isolated Go experiment;
no Bend compiler, runtime, production selection or qualified artifact changed.
This follows [the Phase132 proposal](../../design/phase132/incremental-native-development.md),
the [Phase131 frontier](../../experiments/STEERING.md) and our
[previous Go survey](../compilers_architecture_and_techniques/go.md).

**Recommendation:** establish stable compilation units and distinguish the
facts consumed by a caller from the machine object consumed by the linker.
First demonstrate a correctly invalidated small edit under one fixed qualified
producer. Go's fast warm builds do not imply function-level incremental
compilation, or that a changed compiler can safely reuse its predecessor's work.

## Versions and primary sources

The local executable reports **Go 1.22.2 linux/amd64** and was used only for the
small experiment. No installation or download was performed. Current released
source was independently pinned to **Go 1.27.3**,
`2aae1000ea1d4b28923b96db28acf4e3b99d6aff` (release commit 2026-10-20). Current
development source was pinned to
`c4bf0b94ba5bff279eb7b8864ac77971a874efe0` (commit 2026-10-23).
The [retained primary-source receipts](../../implementation/phase132/evidence/go/primary-sources.json)
include exact source excerpts, file blob identities and resolved commit metadata.
The [official downloads feed](https://go.dev/dl/?mode=json) reported 1.27.3;
[release commit](https://github.com/golang/go/commit/2aae1000ea1d4b28923b96db28acf4e3b99d6aff)
and [development commit](https://github.com/golang/go/commit/c4bf0b94ba5bff279eb7b8864ac77971a874efe0)
resolve the exact inspected revisions. Development behavior below is not claimed
for either the installed executable or the released tag.

| Source inspected | Relevant mechanism |
|---|---|
| [Released `work/buildid.go`](https://github.com/golang/go/blob/2aae1000ea1d4b28923b96db28acf4e3b99d6aff/src/cmd/go/internal/work/buildid.go) | Action versus output identity, bootstrap convergence, actual compiler-tool identity, installed executable reuse. |
| [Released `work/exec.go`](https://github.com/golang/go/blob/2aae1000ea1d4b28923b96db28acf4e3b99d6aff/src/cmd/go/internal/work/exec.go) | `buildActionID`, dependency/content hashes, DAG execution, distinct linking action. |
| [Released compiler README](https://github.com/golang/go/blob/2aae1000ea1d4b28923b96db28acf4e3b99d6aff/src/cmd/compile/README.md#7a-export) | Exported types, inlineable/generic bodies and escape summaries. |
| [Released `noder/unified.go`](https://github.com/golang/go/blob/2aae1000ea1d4b28923b96db28acf4e3b99d6aff/src/cmd/compile/internal/noder/unified.go#L151) | Self-contained export representation, summary updates, transitive re-export and pruning of unneeded bodies. |
| [Released `cache/cache.go`](https://github.com/golang/go/blob/2aae1000ea1d4b28923b96db28acf4e3b99d6aff/src/cmd/go/internal/cache/cache.go#L28) | Separate action/output keys. |
| [Development `work/action.go`](https://github.com/golang/go/blob/c4bf0b94ba5bff279eb7b8864ac77971a874efe0/src/cmd/go/internal/work/action.go#L589) | Early export availability versus completed machine archive. |
| [Development `work/buildid.go`](https://github.com/golang/go/blob/c4bf0b94ba5bff279eb7b8864ac77971a874efe0/src/cmd/go/internal/work/buildid.go#L26) | Separate export and object content identities. |
| [Development `work/exec.go`](https://github.com/golang/go/blob/c4bf0b94ba5bff279eb7b8864ac77971a874efe0/src/cmd/go/internal/work/exec.go#L373) | Compilation consumes export identities; linking consumes object identities. |

## What Go actually avoids

The reusable build unit is a **package**, not an individual function. A package's
action key incorporates selected files and relevant toolchain, target and build
configuration, plus dependency identities. A hit skips its compilation. A miss
builds it; downstream decisions depend on the resulting content, allowing an
invalidation wave to stop even when an input changed. This is different from
rerendering everything and finding identical object files afterward.
[Released action-key implementation](https://github.com/golang/go/blob/2aae1000ea1d4b28923b96db28acf4e3b99d6aff/src/cmd/go/internal/work/exec.go#L262).

There are three separate identities worth preserving in Bend:

1. A stable semantic name identifies which unit an edit refers to.
2. An action identity fingerprints all inputs and assumptions needed to produce
   a result, including the actual compiler and policy.
3. Content identities describe reusable outputs. Different actions may produce
   equal outputs, which should stop unnecessary downstream work.

Go explicitly separates actions from content to allow reproducible compiler
bootstrapping: including a predecessor's action identity recursively in successor
identity would prevent convergence. Its tool identity mechanism also accounts for
compiler wrappers and changed compilers. Release tools use a version-based
equivalence assumption; Bend experiments should retain exact producer identities
rather than silently adopting that assumption.
[Build-ID rationale and tool IDs](https://github.com/golang/go/blob/2aae1000ea1d4b28923b96db28acf4e3b99d6aff/src/cmd/go/internal/work/buildid.go#L26).

### An interface is larger than a type signature

Go exports the type and optimization information needed to compile callers:
inlineable bodies, generic bodies and escape summaries, in addition to public
declarations. The export writer incorporates analysis results and transitive
dependencies, then prunes unnecessary bodies. A body edit can therefore change
the compilation interface while preserving every source-level function type.
[Export contract](https://github.com/golang/go/blob/2aae1000ea1d4b28923b96db28acf4e3b99d6aff/src/cmd/compile/README.md#7a-export),
[export preparation](https://github.com/golang/go/blob/2aae1000ea1d4b28923b96db28acf4e3b99d6aff/src/cmd/compile/internal/noder/unified.go#L151).

Bend needs the analogous *consumed semantic interface*: constructor layouts,
ownership/borrowing summaries, admitted private calls, specialization inputs,
effect/escape facts and any source bodies actually inspected by its optimizer.
Dependent checking may also consume reducible definition bodies. Erasing a proof
at runtime does not erase the dependency that checked it. A type-signature-only
cache would therefore be incorrect even before considering machine-code quality.
This is a design inference from Bend's existing passes, not an implemented cache.

### A useful distinction in current development Go

The inspected release still hashes the imported package archive's content into a
dependent build action. Current development source separates export and object
content IDs: compile dependencies use `buildExportID`, while link dependencies
use `buildObjectID`. Its action graph can make export data available before the
full archive is complete. This separates invalidation and critical-path concerns:
earlier availability can improve scheduling without reducing total work.
[Separate IDs](https://github.com/golang/go/blob/c4bf0b94ba5bff279eb7b8864ac77971a874efe0/src/cmd/go/internal/work/buildid.go#L26),
[consumer hashes](https://github.com/golang/go/blob/c4bf0b94ba5bff279eb7b8864ac77971a874efe0/src/cmd/go/internal/work/exec.go#L373),
[action boundary](https://github.com/golang/go/blob/c4bf0b94ba5bff279eb7b8864ac77971a874efe0/src/cmd/go/internal/work/action.go#L589).

This is a stronger Bend template than caching one giant QBE string: a checked
semantic artifact can serve callers independently of final text/object emission.
It does not require adopting Go's IR or building a universal optimizer IR first.

## Isolated experiment: which edits really propagate?

We built four tiny packages with the installed Go 1.22.2:

```text
main → mid → leaf
   └→ side
```

`leaf` contains a private non-inlineable function, an inlineable function, an
exported constant and a small record. `mid` consumes them; `side` is unrelated.
The same output path is retained so a true no-op can skip linking. Each revision's
source, executable, command logs and package/archive identity are preserved.
Execution checks a separately fixed integer result after every build.

| Edit/build | Package compilations observed in `go build -x` | Link | Build wall time |
|---|---|---:|---:|
| Cold isolated cache | All four plus required runtime packages | Yes |4.683s |
| No edit | None | No |0.039s |
| Trailing comment | `leaf` | No |0.047s |
| Private non-inlineable body | `leaf`, `mid` | Yes |0.125s |
| Revert to original | None | Yes |0.122s |
| Inlineable body | `leaf`, `mid`, `main` | Yes |0.172s |
| Exported constant | `leaf`, `mid`, `main` | Yes |0.172s |

Each source variant was synthesized from the original source. The final row
also restores the preceding inline-body change, so it is not an isolated
constant-only transition. These are one-run diagnostic timings, **not**
statistical Go speed benchmarks or Bend latency forecasts. The interesting evidence is the compiler/link invocation
set and content identities:

- The comment changed `leaf`'s action ID but not its content ID, stopping the
  dependency wave immediately.
- The private body changed `leaf`'s content. Its export payload remained equal
  after excluding only the textual build-ID header. The older whole-archive
  dependency still rebuilt `mid`, whose action changed but output content did
  not; `main` was reused. This makes the benefit of separate interface/object
  fingerprints concrete without pretending we ran the new Go version.
- The inlineable-body and constant-bearing variants changed export payloads and propagated
  into callers. The unrelated package was reused throughout.
- Reverting source recovered package artifacts, but the currently installed
  executable represented another revision, so linking still ran. No-op and edit
  latency are different cases.

Raw `__.PKGDEF` bytes include a build-ID header; comparing raw hashes would
misclassify the comment/private-body exports. `analyze.py` removes exactly that
known header for this diagnostic. It is not a general semantic hash or a
replacement for Go's own content-ID calculation.

The successful campaign took 6.35 guarded seconds, peaked at 254.1MiB process-tree
RSS and retained 13,955,727 cache bytes. It used CPU5, `-p=1`, `GOMAXPROCS=1`, a
fresh isolated cache, `GOTOOLCHAIN=local`, disabled network module lookup and
`CGO_ENABLED=0`. A first attempt stopped after cold compilation because the
harness copied its executable without its executable permission; that harness
failure is retained as `go-cache01`. V02 preserves file mode and all seven
ordinary executions pass. No global cache or source was changed.

Tools: [cache-experiment-v02.py](../../selfhost/tools/performance/phase132/go/cache-experiment-v02.py)
and [analyze.py](../../selfhost/tools/performance/phase132/go/analyze.py).
Tracked receipts: [successful experiment](../../implementation/phase132/evidence/go/go-cache02/report.json),
[resource guard](../../implementation/phase132/evidence/go/go-cache02-guard/process.json)
and [artifact comparison](../../implementation/phase132/evidence/go/analysis/report.json).
The [text-only evidence archive](../../implementation/phase132/evidence/go/README.md)
also preserves source revisions, command/output logs, the failed first attempt
and a hash-indexed map from original paths. Executables and cache trees remain
outside the repository archive.
The receipts pin local method, Go executable/version, local cache implementation,
source snapshots, outputs and captured artifacts. Latest-Go source research is
separate from these old-toolchain measurements.

## What this means for 107MB→1MB and350s→10s

Those targets describe different quantities. Avoiding 99% of regenerated text is
plausible for a sufficiently local edit; it is not a promise that a complete
compiler representation becomes 1MB. Reusing existing units removes repeated work
without necessarily shrinking the full executable or its total IR.

With a 350s reference build, 10s requires eliminating 97.14% of its time. Let `f` be
the fraction of actual compilation work invalidated and `G` the unavoidable
lookup, global work, link and selected validation cost:

```text
T_edit = G + f × T_reusable
```

If 107MB→1MB also corresponded to work fraction 1/107, 335s of reusable work would
leave about 3.13s plus `G`; ten seconds then requires `G` below 6.87s. Neither the
byte/work equivalence nor that fixed cost is measured. A global check, global
identity renumbering, ownership/admission cascade or full qualification on each
edit can alone defeat the target. Object-only reuse cannot remove the several
minutes already spent checking, preparing and lowering Bend.

There is also an important self-hosting constraint: **keep the producer fixed in
the first incremental experiment**. Editing candidate source under one qualified
N2 is ordinary incremental building. Adopting a new compiler executable changes
a key input, conservatively invalidating its compiled-unit cache. Reusing old
producer outputs after adoption requires additional equivalence evidence or
explicitly scoped compatibility; unchanged input source is insufficient.
Self-reproduction/qualification is a separate epoch and should remain visible in
the amortized research cost. A 350s integration gate every 20 experiments adds 17.5s
per experiment before the fast work itself.

## Ranked next experiments for Bend

1. **Fixed-producer artifact stability:** choose a real small body edit, emit
   before/after completely once, and measure unchanged unit bodies, names,
   referenced identities, dispatch/layout data and allocated code. This is a
   cheap falsifier for the proposed reuse granularity, not yet a fast frontend.
   If a tiny edit renumbers most references, solve that specific identity boundary
   before implementing a cache.
2. **Reuse one checked unit before lowering:** bind stable identity, source,
   consumed semantic interface, producer/policy/runtime ABI and verification
   receipt. Skip actual unchanged preparation/lowering, not just QBE output.
   Compare the incremental result to a fresh full rebuild. Deliberately change
   an inline body, ownership/layout fact and policy to prove invalidation; retain
   an unknown-dependency fallback that recompiles.
3. **Split interface and object fingerprints:** stop caller invalidation when a
   rebuilt unit exports unchanged facts, while still relinking its changed
   machine code. Start with conservative package/SCC-sized groups. Arbitrary
   per-function memoization and a global dependency-query framework can wait
   until measured edits show package-level reuse is insufficient.
4. **Only then optimize the scheduling:** once immutable unit boundaries exist,
   publish verified semantic summaries before all QBE/object work completes,
   and run independent units under a bounded resource budget. This can shorten
   critical paths; report it separately from avoided work.

Retain an explicit artifact-cache verification mode and print the inputs
responsible for misses. Go exposes `gocachehash` and `gocacheverify` for these
diagnostics. Its documented cgo caveat also warns that changed external C
libraries are not automatically captured by the ordinary cache: Bend should
authenticate the runtime object, headers/ABI, assembler/linker configuration and
foreign dependencies explicitly rather than treating its cached runtime as
ambient system state.
[Official cache documentation](https://go.dev/src/cmd/go/internal/help/helpdoc.go#L884).

The next decisive result is therefore a small **validated delta build that avoids
real compiler work**. Do not substitute a no-op cache hit, an object-cache hit
after full emission, or a shorter symbol table for that result. Large optimizer
or ABI edits may appropriately remain full rebuilds. The Go evidence supports
ambitious warm-edit speedups while making their scope and invalidation cost
testable.
