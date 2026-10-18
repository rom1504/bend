# Phase111: full direct QBE self-hosting

The compiler written in Bend now compiles its complete source directly through
structured native IR and QBE, and the resulting native executable reproduces
that compilation. Ordinary requests generate no C and invoke no cproc or Clang.
A separately compiled, cached C runtime remains part of the executable.

[Design](../../design/phase111/direct-qbe-selfhost.md) ·
[Experiment](../../experiments/phase111/P111-001-direct-qbe-selfhost.md) ·
[Usage](../../docs/self_hosted/direct-qbe.md).

**The direct route works, but is not a performance replacement yet.** Native
self-emission takes **944.82 seconds (15m45s)**; building its QBE output takes
**10.26 seconds**. The installed compiler, JavaScript release and existing
C/cproc/QBE route remain unchanged. Successor focused qualification passes;
the final 45-program corpus gate is running.

## What is established

The trusted checked development API acquires N1 from full-source05. N1 checks
and compiles that exact source with the same authenticated Base/cache inputs:

```text
Bend source → existing checked frontend/erasure → structured segments
  → structural verifier → QBE/data → QBE → assembler → link cached runtime
                                                       ↓
                                                      N1
                                                       ↓ same source
                                                identical QBE/object
                                                       ↓
                                                      N2
```

N1 emits all **50,664,292 QBE bytes** identically to the development API.
The generated assembly and complete object file also match exactly. N2 builds
successfully and passes all 19 focused source cases: 16 positive executions
and three expected refusals. The first six representative corpus cases pass;
39 further cases remain in progress.

Raw executable files are **not** byte-identical. GNU ld records the different
input object path in a local file symbol, changing `.strtab`, `.symtab` and its
build ID. The image audit confirms identical ELF/program headers, entry point,
all four loadable segments and all 25 allocated sections after masking only the
parsed 20-byte GNU build-ID descriptor. BSS sizes also match. This distinction
is preserved in the raw-image check and separate
[image audit](image-comparison.md); no metadata normalization is described as
literal file equality. N2 self-emission is not redundantly rerun: the actual
N1 self-emission and independently checked successor loaded-image agreement
supply the bootstrap evidence, with N2 semantic checks recorded separately.

Route-local **N1/N2** labels do not replace the established production **B1/B2**
metrics. This is a real complete compiler source, not a scalar kernel, a hidden
fallback through the old backend, or only hosted emission of a compiler.

## Architecture

The new compiler code is Bend: model, lowering, verifier, QBE formatter and
entry total **1,688 lines**. The [module list](../../selfhost/tools/performance/phase111/modules.txt)
and [lowering audit](segment-lowering-audit.md) identify the components.
Preparation tools authenticate the selected mature source and compose exact
modules; host scripts transport inputs, acquire checked APIs, supervise tools
and preserve evidence. They do not implement semantic lowering.

Checked erasure, constructor identities, liveness, closure captures and
continuation decisions are reused before C expressions are formatted.
Structured values distinguish U32, opaque 64-bit Terms and pointers. Calls,
loads, stores, offsets, constants and branches remain structured. QBE builds
SSA from mutable temporaries, avoiding a separate SSA implementation.
Function/constructor references use indexed identities rather than repeated
whole-program linear scans. Data emission preserves exact 64-bit values,
UTF-8 bytes and relocations.

The portable continuation trampoline and reference-counted allocator remain.
A versioned 192-byte descriptor supplies program tables, effects and readback
metadata. The state is 2,088 bytes with 256 physical register slots. Runtime
C/providers are compiled once with GCC and reused as an object; the GCC command
on ordinary builds is a linker invocation. No per-program C translation unit
or cproc stage remains in this route.

The admitted configuration is Linux x86-64/System V, **one CPU worker and GPU
off**, with the fixed authenticated effect-provider catalogue. Parallel scaling,
CUDA/Metal, arbitrary foreign providers and a general untrusted cache interface
are outside this qualification. The generic route deliberately bypasses mature
optimized workers and static-image planning; Phase110 ownership optimizations
have not all been composed into it.

Details: [runtime](runtime-notes.md), [emitter](emitter-notes.md),
[show descriptors](show-audit.md), [verifier](verify-audit.md),
[coverage](coverage-notes.md).

## Measurements and independent gates

| Observation | Result | Scope |
| --- | ---: | --- |
| Checked API full-source emission | 345.42 s | Hosted Bend compiler, not upstream compiler timing |
| Full QBE → assembly → link | 10.26 s | 7.68 s QBE, 2.37 s assembler, 0.22 s linker |
| Native complete self-emission | 944.82 s | Includes approximately 4.18 s of diagnostic pauses |
| Native emission plus successor construction | 956.58 s guard wall | 1,999,306,752 bytes peak process-tree RSS |
| Cached runtime acquisition | 1.28 s | Separate from ordinary builds |
| Runtime-only compiler relink | 0.215 s | Reuses the authenticated full QBE object |
| Successor focused suite | 19/19, 74.68 s | 16 semantic executions, three expected refusals |
| Successor initial representatives | 6/6, 35.38 s | Frozen prior corpus outputs |
| Runtime representation/primitive boundaries | 10/10 | Includes exact outputs and expected fail-stops |
| Register-bank boundaries | 13/13 | Seven positive, six malformed-input cases |
| Structural verifier controls | 53/53 | 11 positive, 42 negative; not ownership proofs |

Data-format checks also cover 272 independent U64 decimal cases, two text
controls and actual native word/byte/relocation readback. Do not add these counts
together into a claimed number of independent language features.

The hosted full-source stage breakdown is preparation 1.37 s, frontend 138.78 s,
lowering 148.25 s, verification 47.99 s, QBE emission 7.26 s and writing 0.73 s.
Its peak process-tree RSS is 3,733,917,696 bytes. These are hosted stage clocks;
no corresponding native per-stage timing is inferred from samples.

The generated compiler contains 37,018 segments, maximum arity 26,
incoming/output width one, 442 constructors and six required effects. Its QBE
is 50,664,292 bytes, assembly 68,809,177 bytes and executable 15,731,104 bytes.

## Findings that changed the implementation

**Actual widths must remain distinct from capacities.** The first runtime
cleared/copied all 256 register slots on transitions, although this compiler
needs 26. Runtime04 binds `max(register_width,result_width,2)` and narrows
scalar clearing and builtin INIT/READ/WRITE/SAVE/TAKE coherently. Physical
arrays, state layout and heap/static offsets remain unchanged. High slots are
transport storage, never scanned ownership roots. The
[bank audit](../../selfhost/tools/performance/phase111/runtime/bank-audit.md)
records the read paths and initializedness argument.

The five-case runtime-only screen preserves every QBE byte and takes about
15–18% less compiler-request time than earlier single observations. These are
non-alternating finite comparisons, not a statistically established broad
speed ratio. The 13 bank controls cover widths 2, 17, 255 and 256, captures,
multiple results, unused high slots and malformed widths/closures. EXIT/SAVE
and root readback are exercised; task-continuation EXIT/TAKE safety is source
reviewed rather than claimed as executed coverage.

**The native dispatcher hid the active compiler stage.** Ordinary native stack
samples mostly saw transfer helpers. The image-specific continuation sampler
recovered Bend frame identities without changing program code or data. Early
samples show use-set traversal beneath the structured lowerer; later samples
show IR verification. Pauses and transient frames are explicit, and these are
qualitative clues, not unbiased CPU percentages. See
[sampling interpretation](sampling-interpretation.md).

**The new lowerer duplicates analysis that the mature one reuses.**
`p111_bind_value` and `p111_let_cut` calculate a body use set and then call a
helper that calculates it again. Empty environments also trigger needless
analysis. The mature lowerer already supplies the reuse pattern. The
[remaining-cost audit](remaining-costs.md) gives exact sites, a semantic
argument and a small byte-equivalence/timing experiment. It remains a proposed
optimization, not a gain counted in this report. Reuse reduces a coefficient;
it does not by itself remove nested suffix scans' quadratic worst case.

## Failed attempts and limits retained

- The first full hosted emission hit its 300-second guard during lowering.
  The same frozen request completed with a 900-second deadline and unchanged
  4 GiB memory cap. The failed receipt remains.
- The first full QBE build hit the old 64 MiB per-file limit while writing
  assembly. The local guard now records a bounded 128 MiB limit and increased
  disk admission floor; process-tree memory/deadline supervision is unchanged.
- The first native self-request timed out after 1,100 seconds, with no output
  or compiler diagnostic and 646,033,408-byte peak tree RSS. Runtime04 then
  completed the unchanged source. No successful baseline time is invented.
- Focused development found unavailable foreign providers admitted too late
  and F32 primitives misclassified as foreign effects. Source05 fixes admission
  and primitive-first classification; final native focused qualification passes.
- Closure arity checks prevent underflow before capture copying. Continuation
  incoming width remains separate from its output width.
- Early module/slicing checks caught missing signatures, ordering and delimiter
  faults. Failed checks are preserved separately from semantic observations.

The structural verifier is not a proof of ownership, runtime correctness or
whole-compiler semantics. Frozen corpus outputs are regression evidence, not
fresh held-outs or exhaustive conformance. No new upstream compiled-program
speed ratio or B1/B2 comparison is established, and no default is promoted.

## Simplicity, unused experiments and next step

A dependency slice reduces composed source from 1,879,953 to 650,720 bytes
(65.4% less), keeping retained declaration bodies. It passes checked API
acquisition but is not the source of this native bootstrap. Declaration order
changes, so it needs separate native qualification. See
[source slicing](source-slice-audit.md).

An inactive 81-line streaming consumer is prepared to avoid retaining all QBE
strings simultaneously. It is absent from module selection and remains
unvalidated. Memory did not block the successful bootstrap, so no extra image
acquisition was spent on that contingency.

The highest-value next experiment is the small use-set reuse correction,
measured on a captured checked request before another full image. Then integrate
existing owning operations and specialized workers into this structured route.
Changing machine backends again is not supported by the observed bottleneck.

## Evidence and reproduction

Build artifacts live under `selfhost/build/phase111/`. Important directories:
`full-source05`, `full-api05`, `full-emission02`, `runtime-source04`,
`full-native03`, `native-self02`, `successor-focused01`,
`successor-representatives01`, `successor-remaining39`, `runtime-boundaries04`
and `runtime-banks04`. Each receipt pins sources, tools and commands. The native
self request's `image-comparison` directory records literal and loaded-image
comparisons separately. Its earlier `fixed-point.json` is explicitly the failed
additional raw-file equality check, not a failed QBE self-reproduction claim.

The [usage guide](../../docs/self_hosted/direct-qbe.md) contains native commands,
fast/focused/full45 gates, trusted-asset boundaries and full-build resource caps.
The bounded evidence capsule is sealed after final qualification. It retains
source/method snapshots, logs and failures; large machine products stay local
with hashes. [Evidence format](evidence-sealing.md).

Disk began below the guard floor. [Cleanup01](evidence/cleanup01.json) reclaims
about 70 MiB of authenticated archived generated artifacts.
[Cleanup02](evidence/cleanup02.json) losslessly compresses historical generated
outputs and diagnostics, verifies decompressed hashes and records restore paths,
reclaiming about 1.09 GiB. Sources and selected executables are preserved.

Root owns the serial CPU3 target lane. Agents prepared/reviewed disjoint source,
runtime, emitter, verifier, coverage and evidence tools without competing target
runs. Reusing the full object isolated the runtime change without repeating the
345-second acquisition. The failed 18-minute native attempt is the main avoidable
cost: future large runs should expose stage progress or sample early, then use
small analysis-heavy requests before committing to a long bootstrap.
