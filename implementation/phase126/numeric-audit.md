# Phase126 numeric representation audit

This is a source and retained-machine-code audit at `3c94d98`, plus an isolated
analysis-only prototype. No compiler, API, target, benchmark or full image was
executed by this audit. Root owns candidate checking and performance measurement.

## Authenticated starting point

The selected source is
`selfhost/build/phase125/verified-source06/compiler.bend`, SHA256
`d1399234ad28a3d03ee06fdad436a1585278bcbaea127425a226b5ceb79029b2`.
[Static evidence](../../selfhost/tools/performance/phase126/machine/current-ray.json)
pins the source, current active-ray QBE and current binary and contains the
extraction method. The candidate identity is also recorded in
[Phase125's selection](../phase125/candidate.json).

The retained Phase125 active-ray machine code still contains:

| Private worker | Instructions including alignment padding | GPR/XMM moves | Frame-address references |
| --- | ---: | ---: | ---: |
| `isect5` | 202 | 49 | 47 |
| product `nearest` | 427 | 4 | 113 |
| `nearest.t` | 372 | 4 | 93 |

These are static occurrences, not dynamic shares or cycle attribution. The
[intersection excerpt](../../selfhost/tools/performance/phase126/machine/direct-isect5.asm)
shows repeated scratch stores, `movq` into XMM, one scalar arithmetic operation,
`movq` back to a general register and a low-word move. Its frame allocation is
`0x818` bytes before saved registers. It still calls generic `p111_rt_op` for
square root. The nearest workers call four separate finite selectors and
intersection, retain substantial stack transport, and already use the existing
flat Hit result interface. Product boxing is therefore not the primary missing
transformation in this particular region.

## What the architecture loses

`NC_Binding.kind` does not supply an F32 signature: `N_W32` merges U32, F32,
Bool and Char. Flattened product fields can be `N_W64`. Treating either as F32
would infer a representation fact that the checked interface does not establish.

The structured native IR has U32/U64/Ptr but no persistent F32 value. In the
selected source, `p113e_formals:45133`, `p113e_arguments:45140`, backedge
snapshots/moves and results all transport machine words. `p112fp_binary_text`
recreates F32 operands around each arithmetic operation. QBE already supports
scalar floating arithmetic, so this lost information is in our lowering and
private interface, not an inability of QBE to compute F32.

The reusable Phase114 explicit-operand and float-lane modules already provide
most local rendering machinery. Their whole-buffer proof is essential: dropping
scratch stores is legal only when there are no other observations of that
buffer. One missing recognized operation can refuse the entire buffer. In
intersection, op36 square root is that blocker: existing group admission covers
23 and 26–35, while the source uses 36. Root's proposed extension must preserve
exactly the original promoted-double `sqrt` followed by F32 truncation; replacing
it with `sqrtf` or introducing fast math is a separate semantic change.

The actual selected private emission hook is `p113ah_private_chunks`, which
retains the Phase117 array-memory proof/templates. Changing only
`p113e_private_chunks` would miss the active path. A numeric adapter must keep
`p113ah_function` as the unchanged fallback and refuse typed conversion for
functions containing array fast-path sites.

## Small general representation certificate

[analysis.bend](../../selfhost/tools/performance/phase126/typed/analysis.bend)
adds no IR node, runtime helper or production hook. Its interface is:

```text
P126TPlan { function: P113DFunction, floats: List<String> }
p126t_plans(functions) -> List<P126TPlan>
p126t_find(plans, name) -> Maybe<P126TPlan>
p126t_analyze(function, priorPlans) -> List<String>
```

`floats` contains formal word names only. The certificate proves that discarding
that formal's high 32 bits cannot affect any observation of the original
verified function. It deliberately does not claim source-level F32 typing.

It constructs a conservative may-depend graph of local names. Exact U64 copies
add source→destination edges. Every parallel Again argument adds
actual→formal edges. Both branch arms and every assignment contribute to the
same graph; facts are never killed. Consequently mutable names, overwrites and
joins can add false refusals but cannot erase an earlier dependency. Conditions,
results, memory operations and unknown calls are full-word observations.
Whole-buffer-certified float groups are low-word observations. An earlier
verified callee's admitted float parameter is also a low-word observation.

A formal is accepted only if its reachable graph has at least one low-word use
and no full-word observation. The scan refuses array functions, more than 32
formals or body size above 4096; a per-formal traversal refuses after 256 distinct
names. Those are analysis budgets, not a claim of an independent host-stack
bound for existing body-size helpers. The original direct verifier establishes
callee-before-caller order; Again edges account for the admitted recursion.
No assumption about arbitrary indirect calls or a recursive callable fixed point
is introduced.

The proposed emitter keeps the existing `l` callable as an adapter and adds a
private companion with certified `s` parameters. Its loop entry reconstructs the
original low-word value and seeds the float fact. Original verified word
operations remain the semantic fallback. Backedges must snapshot all old values
before assigning any formal. Results remain word-valued in the first experiment;
therefore a formal returned directly (for example nearest's candidate result
fields) is correctly refused. The initial certificate should be judged on actual
admission rather than assuming all eight apparent float formals qualify.

[Pure controls](../../selfhost/tools/performance/phase126/typed/analysis-controls-v02.bend)
cover float use, copy closure, raw return, unknown call, one bad branch,
conservative overwrite, self/cross backedges, an external scratch observation,
and a prior callee contract. These analyze invented IR only; they never execute
it as native code. Root must still check the API, verify the complete generated
programs and run ordinary independently expected semantic controls.

## Decisive comparisons and remaining headroom

Separate explicit operands/sqrt recognition, local persistent lanes, and typed
call/backedge transport. Otherwise a combined win cannot establish which new
mechanism helped. Inspect the surviving scratch stores, GPR/XMM transfers,
call-boundary adapters and spill/frame references in each case. Require an
unrelated numeric recurrence and whole compiler cost in addition to ray.

A ten-float intersection currently consumes ten integer argument positions plus
state. A typed companion uses the separate float bank; ten float arguments still
exceed eight XMM argument registers. Nearest's exact admitted subset determines
its real benefit. XMM registers are caller-saved on this ABI, so keeping ray
constants live across intersection can still create spills. Typed ABI alone is
not a proof that a large numeric region will become fast.

The old upstream evidence in [Phase122](../phase122/numeric-audit.md) remains
relevant but is not a new timing result: Clang sees a larger scalar region and
emits packed arithmetic; mature selfhost C already inlines intersection yet
historically remains materially slower than upstream. Once typed scalar code is
compact, the next separate questions are immutable finite selector specialization,
loop-invariant numeric data, and exact-operation-order vector packing. None has a
measured Phase126 gain yet. The four selector calls and nine sphere cases alone
do not establish dynamic cost.

Finally, certificate construction must not make most compiler workloads slower.
The first prototype intentionally favors transparent proof over tuning. If cost
is material, a staged necessary prefilter for float groups or calls to already
admitted callees can avoid buffer/graph construction in irrelevant functions.
Do not add a general cache or abandon the original verifier to reduce this cost.

## First emitted admission observation

Root's checked typed-source04 produced active-ray QBE. Read-only inspection is
preserved in [typed04-ray.json](../../selfhost/tools/performance/phase126/machine/typed04-ray.json).
The concrete admission matches the intended conservative boundary: all ten
intersection formals are `s`; product nearest, nearest.t and direct nearest each
admit six ray formals. Ten typed companions occur in this program. Nearest calls
the typed intersection directly, and its ordinary loop arm forwards the six
existing float lanes. The word ABI adapters remain present.

Intersection now calls double `sqrt` explicitly. Product nearest still contains
op25 (U32_FROM_NAT, low-word zero-extension), which prevents whole-buffer admission for its shared scratch
local. This is an observed remaining projection boundary, not evidence that the
operation's runtime cost dominates. One nearest arm forwards existing lanes;
another still rematerializes more operands after scalar/control barriers.
Complete native output, runtime and machine counts are root's separate gates.

Root's staged `prefilter.bend` preserves analysis admission: an accepted formal
must reach a recognized outer float group or a call to a previously admitted
plan. The original analysis does not admit float groups hidden inside scalar
N111If snippets, so the prefilter does not miss an existing proof there. It
changes no alias edges or full-word observation. Eager conjunction still scans
body size after a negative seen result; that is a possible later cost refinement,
not a semantic concern.

## First typed machine comparison and primitive correction

The [typed04 comparison](../../selfhost/tools/performance/phase126/machine/typed04/comparison.json)
pins both actual binaries and preserves per-symbol assembly. It counts alignment
padding consistently with the original table. New word adapters are counted
separately; they must not be silently ignored when the caller uses the old ABI.

| Worker | Parent → typed companion instructions | GPR/XMM moves | Frame references | Initial frame subtraction |
| --- | ---: | ---: | ---: | --- |
| intersection | 202 → 133 | 49 → 19 | 47 → 4 | 0x818 → 0x18 |
| product nearest | 427 → 419 | 4 → 28 | 113 → 67 | 0x8e8 → 0x878 |
| nearest.t | 372 → 384 | 4 → 28 | 93 → 49 | 0x8b8 → 0x68 |

This supports removal of scratch traffic and much of intersection's word/float
conversion. It does not show uniform code-size reduction: the float ABI also
introduces parameter-register permutations, caller/return conversions and
adapters. The nearest workers retain their branches and calls. Intersection
contains a promoted-double sqrt call, and its result is truncated back to F32.
Product nearest retains its 2KiB scratch allocation while nearest.t loses it.
Root reports the runtime comparison separately; these static counts do not
assign the observed runtime change to any one category.

**Correction:** the first version of this audit mislabeled op25 as F32→U32.
Pinned `primitives.h:30` names it U32_FROM_NAT; `runtime.c:4112` returns
`((u64)(u32)(args[0]))` after the unary arity check. F32_TO_U32 is op58 at
`primitives.h:63` / `runtime.c:4244`. The earlier wording above is corrected.
An exact op25 projection would be low-word copy plus zero-extension, with no
float-result fact. Together with the existing whole-buffer proof it could make
product nearest's scratch stores unnecessary. This is a proposed experiment,
not a measured improvement.

A second concrete source limit is `p114fl_bind`: it retains only 16 total facts.
Intersection begins with ten typed formal facts, then adds aliases and arithmetic
results; older still-needed lanes can therefore be evicted before any branch.
The typed machine code still contains 19 word/float moves. A bounded 32/64 fact
capacity comparison is a cheap discriminating test, alongside the separately
planned branch-write invalidation repair. More retained facts can raise compiler
cost, and fewer casts can change register pressure, so neither is a free win.
