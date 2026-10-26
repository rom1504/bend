# Phase144: compact owner computations and actual parallel boundaries

Read-only source investigation, 2026-10-26, repository `63dd41d`. No compiler,
benchmark, native target, installation or production mutation was performed.
This note proposes discriminating experiments; it reports no new speedup.

**The strongest bounded representation experiment is the complete local-verifier
computation, including conversion, schema construction, flow, branch joins and
destruction. The easiest independent parallel units occur after checked global
metadata is frozen. Neither observation establishes a route to 50 seconds yet.**

## Exact inspected inputs and evidence limits

- [Qualified Phase143 candidate](../../implementation/phase143/candidate.json):
  `selfhost/build/phase143/integrated-source03/compiler.bend`, 2,959,385 bytes,
  SHA256 `a51a4a6d0a32e118ca75eac96fb4e64bae0fcf951b09ee859c2632f65550bd4e`.
  All compiler line numbers below refer to this assembled source, not a newer
  overlay or an earlier report's differently numbered source.
- Its runtime source `selfhost/build/phase128/runtime-borrow01/runtime.c`,
  149,279 bytes, SHA256
  `6eb24c8d4a5d6358a9b8b4107a75af777a8dbdd06fe5fdce18d73b9f85f4824a`.
- The checked language library `bend2/base.bend`, 75,064 bytes, SHA256
  `99ac43f2b2bb3e3f39acdcedcecbbd3cb44749ce13969c827d6973fa66f7facf`.
- [Phase143 measured result](../../implementation/phase143/README.md): compiler
  296.541s, complete supervised build 315.310s, byte-identical generated QBE and
  machine object. One controlled pair, not a confidence interval.

The 12,017-sample [Phase143 profile](../phase143/cold-profile.md) is of Phase142
N1, **before** the selected 78s saving. Its `p111v_get` 4.08%, String append 4.59%
and physical drop/fade 27.48% are investigation leads, not current residual
percentages. Physical reclamation overlaps the owner categories. Old Phase136
stage clocks and Phase142 incremental-session interiors are different workloads.

## 1. A complete compact slice, rather than another lookup microbenchmark

The representation mismatch is concrete. `KTerm` uses textual tags and names,
eight general fields and recursive lists (41–44); `KDef` carries nine fields
(47–50). Low-level scalar IR nevertheless represents every local, symbol,
function and constructor reference as a String (`N111Value`, 38819–38824).
Statements include boxed values and argument/body lists (38829–38838).

The structural verifier then repurposes the full definition representation:

| Actual operation | Current source | Work that a compact unit could avoid |
|---|---|---|
| Query a local | `p111v_get`, 39615 | Hash String, traverse Patricia index, return generic KDef |
| Publish local facts | `p111v_put`, 39619 | Construct nine-field row containing only name, kind, width and capacity plus placeholders |
| Read an operand | `p111v_value`, 39693 | Project kind and width from that row; repeat name resolution |
| Mark assignment | `p111v_assign`, 39708 | Query immutable schema, reconstruct another generic live row |
| Check memory access | `p111v_memory`, 39724 | Capacity and type checks make separate local queries |
| Merge branches | `p111v_intersection`, 39731–39753 | Walk one tree, query the other, rebuild intersection rows |
| Verify complete segment | `p111v_segment`, 39940 | Schema traversal, flow traversal, all associated allocation/reclamation |

This is not a claim that every generic record projection currently executes an
owning take. Phase137 deliberately preserved borrowed scalar predicates; actual
emitted call paths still need inspection. The algorithm nevertheless repeatedly
uses String identity and an overly general fact representation.

### First discriminator

Use real compiler-derived `N111Segment` bodies with small, medium and large local
sets and nested branches. Compare the original **complete** `p111v_segment`
against a Bend implementation that resolves local names once into unit-local
IDs and stores scalar schema/live state separately. Keep the same global
function/constructor IDs and original source IR for independent verification
and emission. Include conversion and final release in the timed operation.

An initial typed-row version is useful as an ablation, not the full compact
claim. The larger version can encode a private verification tape in scalar
columns: statement tag, destination ID, operand tags/payloads, operation code,
extra-operand span and branch spans. Retain an ID-to-original-name table for
diagnostics. Both halves of 64-bit constants remain explicit U32 values.
String interning must resolve collisions by full equality and preserve absence;
it cannot use a hash as identity. Unknown imports and malformed local names
still produce the same original error at the same original priority.

Schema collection precedes flow checking in the original. In particular, a
later schema error may win over an earlier flow error. Its local-count gate
allows a step while count <=65535 (39685–39690); preserve the actual boundary
instead of assuming a simpler maximum. Branches can be terminal, and dynamic
pointer capacities can differ; a live bitset alone does not represent the
current verifier. `p111v_offset` (39861) and intersection must retain capacities.

Array copies on every branch could erase the benefit of compact storage. Measure
that straightforward baseline before choosing an undo log or branch delta.
Do not promise constant-time snapshots. The independent final verifier remains;
this prototype first establishes representation cost and full-result equality,
not authority to remove checks.

Transfer to the direct verifier is real: `p113e_seed`/`p113e_schema` (44409/44423)
reuse the same scalar schema machinery and `p113e_function` (44544) drives a
related flow. A successful segment-only result should then transfer there before
another whole-image acquisition. The separately assigned Phase144 verifier
experiment owns implementation; this note does not add a competing pass.

### Bend-native storage that actually exists

`Array<U32>` is already an admitted source-level building block. Although Base
defines arrays as a binary tree (77–79), recognized `Array.new/get/set/swap/size`
lower to contiguous native blocks. The runtime explicitly says those primitives
do not open/copy halves (1077–1087). Avoid implementing indexed access through
source `ANode` matching: native split/merge copies blocks.

**Storage width is conditional.** Runtime `NATIVE_SCALAR_ARRAYS` is a program
capability, and `native_array_get/set` (1252–1270) choose 32-bit packed buffers or
uniform 64-bit Term slots. The source certificate checks reachable definitions
(`p113a_certificate`, 46999), not merely the spelling of one new Array<U32>.
A new array inside a mixed compiler cannot automatically be described as four
bytes per cell. Uniform scalar arrays still eliminate per-record boxes and
pointer fields, but their final release scans the array's Terms (929–1011).
Packed TAG_BUF release is shallow (948–950).

The existing `p113_rt_array_pair` (runtime 4514) can return array/value pairs
without allocating a Tuple. Whether a proposed loop actually selects that path
must be confirmed in generated code; source tuple notation is not proof either
way. Source `+` permits repeated use and is not a guaranteed borrowed ABI.

A phase-owned scalar arena can initially mean a few linearly threaded arrays of
indices and numbers, released at a unit boundary. There is no demonstrated
general region primitive in the inspected public QBE runtime that may reclaim
arbitrary aliased KTerm graphs wholesale. An arena containing Term pointers would
still owe their ownership credits. Read-only strings can remain separately owned
until all IDs/diagnostics using them die. `Array.fork` is explicitly unsafe shared
mutable storage in Base (2381–2392); do not silently use it as an immutable
snapshot or permit racing ordinary writes.

## 2. Which units are independent now?

The runtime currently refuses `--threads` other than 1 and GPU mode other than
off (4494). The ordinary compiler's foreign-provider list (39585) omits
IO.spawn/Chan. The file contains a broader runtime worker pool, but that is not
a qualified parallel direct-QBE compiler API. Raising a flag is not sufficient.
The one-program descriptor is immutable after binding; that alone does not prove
that all heap, stack, IO and task publication paths support multiple compiler
workers safely.

| Computation | Existing independent input | Remaining ordering/contract |
|---|---|---|
| Raw segment body verification, `p111v_segment` | Segment + immutable IDs | Build/validate global headers first; reduce body errors by original ordinal |
| Direct function verification, `p113e_function` | Function + IDs + exact ready-prefix | Prefix signatures are header-only, but later functions must not see later signatures; preserve duplicate/name/error priority |
| Range pass, `p113k_function` (47696) | One function; starts fresh local facts | Preserve outer output order and final admission |
| Private candidate construction, `p113pl_candidates` (45483) | Owner + fixed prepared book, bangs and signature view | Prepare per owner in parallel; concatenate in source order; keep subsequent admission passes unchanged |
| Private/legacy/public rendering, `p134e_private/legacy/public` (57405/57412/57419) | One unit + frozen P134Context | Ordered output and I/O errors; bounded completed pieces waiting behind a slow early unit |

The direct verifier's prefix restriction is important: `p113e_functions`
(44556) validates a function, then publishes its signature for subsequent
functions. Supplying the complete final signature table would change admission.
Persistent prebuilt prefix snapshots could permit independent body checks, with
the first failing ordinal controlling publication. The memory and prefix-building
cost must be charged. Malformed/expensive work after an earlier error must not
change the reported error or cause uncontrolled resource use.

### Real barriers, not just inconvenient loops

- Generic lowering threads global `fresh` through `p111_compile_defs` and
  `p111_compile_step` (39524–39538). `p111_entry` uses it for parameter and
  continuation identity. Starting each owner at zero is not byte-equivalent.
- Static preparation interns literal graphs in encounter order (`p112s_intern`,
  41655; `p112s_defs`, 41732), producing physical offsets. Independent local
  interners need explicit symbolic relocation and a deterministic global merge.
- Inlining publishes the **transformed earlier function** into the table
  (`p113i_functions_step`, 46453). It cannot blindly parallel-map all functions
  against the original global table while preserving the existing policy.
- Candidate readiness (`p113d_passes`, 44125–44167) has ordered publication,
  duplicate suppression, waiting lists and a32-pass fuel bound. A graph/SCC
  scheduler is a semantic change unless it reproduces these choices; an SCC does
  not automatically make mutual worker admission legal.
- FIDs/CIDs use final ordered lists (`p111q_ids`, 40217–40240). A changed code
  order changes ABI tables even when every individual function is correct.
- Parser/checker state, dependent normalization, templates and ordered diagnostic
  publication remain earlier serial barriers. An independent backend cannot
  make that frontend cost vanish.

The existing named N111FuncId/N111CtorId references are an advantage: they delay
some binding. Owner-local symbolic continuation IDs plus a late deterministic
bind are a credible eventual extension, but not a cheap parallel-loop patch.

## 3. The cheapest meaningful parallel discriminator

First obtain costs for the **actual candidate Phase143 units**, not aggregate
function counts or QBE bytes. Reuse exact stage markers, then sample or instrument
only the strongest independent phase. Record total unit time W, maximum unit
time, serial context preparation, retained bytes and an approximate size histogram.
The optimistic work-only floor on p workers is at least max(W/p, max-unit-time),
before scheduling, context sharing, output ordering and memory traffic. This can
reject a parallel rewrite without constructing one.

For a native experiment before changing the threading ABI, use a few isolated
process workers executing **Bend-owned unit computations** over explicitly frozen
inputs. Host code may schedule, transport bytes, time and compare results; it must
not reimplement checking, lowering or code generation. Each worker doing the
entire frontend again would not test useful backend parallelism. Charge snapshot
encoding/decoding, process setup, duplicated immutable context and joining.
Copying a full checked book to every process can overwhelm the saved work.

The first pair should be one-core versus two-core execution of the same unit
algorithm and exact inputs. Only after positive total latency and RSS evidence
should it grow to4–8 workers or a qualified shared-memory task primitive. Schedule
large measured units early, retain deterministic output ordinals, and enforce a
byte budget for all in-flight contexts/results. More workers do not multiply the
available RAM.

Machine-unit parallelization is a separate comparison. Phase135's66-group cold
replay cost39.034s versus14.699s monolithic; even its cached replay16.064s was
slower than monolithic. Reusing that partition infrastructure does not establish
a win. QBE process concurrency, linking and loaded-image equivalence need their
own controlled test; do not assume QBE itself is multithreaded.

## 4. What the existing Zig and Go research actually supports

The [pinned Zig0.17 source audit](../phase133/zig-ir.md) supports dense instruction
IDs, separated scalar columns/extra payloads, a separate string pool, transient
per-function AIR and a memory-bounded code-generation queue. It explicitly warns
that MIR can greatly exceed AIR and that the queue budget is not an RSS bound.
This is the relevant architectural transfer; one small IR dump is not a forecast
for total Bend memory or speed. Primary pinned definitions are
[Air.zig](https://codeberg.org/ziglang/zig/src/tag/0.17.0/src/Air.zig),
[InternPool.zig](https://codeberg.org/ziglang/zig/src/tag/0.17.0/src/InternPool.zig)
and [Zcu.zig](https://codeberg.org/ziglang/zig/src/tag/0.17.0/src/Zcu.zig).

The [pinned Go1.25 study](../compilers_architecture_and_techniques/go.md)
describes serialized preparation followed by size-ordered bounded function
backend workers. Its export information includes bodies and summaries, not just
declared types. See the inspected
[compile.go](https://github.com/golang/go/blob/6e676ab2b809d46623acb5988248d95d1eb7939c/src/cmd/compile/internal/gc/compile.go).
This supports explicit parallel boundaries after semantic work; it does not
prove our current dependent frontend or ordered optimizer is independent.
These are reused pinned studies, not new claims about latest development heads.

## Ranked architectural discriminators and stop conditions

1. **Complete compact verifier slice.** Most economical test of numeric identity,
   scalar storage and phase lifetime. Transfer to direct verification before
   broad integration. Reject if encoding/branch restoration/destruction erases
   the consumer win, or if only a synthetic lookup gets faster.
2. **Packed prepared-owner representation through more than one consumer.** If1
   succeeds, carry those IDs into a range/admission or rendering consumer, retaining
   original names only at diagnostics/output. This has larger cold-build scope;
   a new representation converted back after every pass does not.
3. **Bounded parallel verification/rendering/private preparation.** Measure actual
   independent work and serialization cost before a runtime ABI project. Reject
   if the serial floor or transport already dominates the target.
4. **Owner-local naming/static references and dependency-scheduled optimization.**
   The largest enabler for coherent parallel and incremental compilation, but
   global freshness, static layout and ordered helper readiness make it materially
   more expensive. Prototype one owner family with unchanged complete products;
   do not launch a universal IR rewrite from static inventories.

On the current315s single-core denominator, even perfect elimination of a4%
owner is small. A50s single-core build with the approximately15s machine tail
needs roughly9× faster compiler execution. Compact storage must therefore remove
work across many stages, not just make the verifier faster. A hypothetical
multicore budget—297→108 CPU-seconds through structural reductions,12s serial,
96s at4× effective parallel throughput,12s machine work and2s supervision—totals
50s. Every component is an unmeasured requirement, not a combined gain forecast.
Do not multiply overlapping interning, ownership, arena and parallel estimates.


## 2026-10-26 consolidation update

The315s/297s denominator and50s budget above are historical illustrations, not
the latest measurement. Fresh source01 compiler requests are304.534s for the
parent,266.862s for the integrated image and249.679s for its separate serial
runtime, all on unchanged Phase142 input. The actual integrated diagnostic
partitions are now94.833s frontend,44.819s raw/static/admission,64.431s initial
optimization/verification,25.150s observer work and65.231s registry/output.
They do not profile the serial runtime or final03. The compact sum-record slice
measured11.06% less native time; whole-compiler integration remains unmeasured.
Use [current conditional budgets](remaining-opportunities.md), not the old
denominator, when selecting the next experiment.
