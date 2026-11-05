# Phase162 — separating bendc's runtime speed from compiler work

We now have a controlled frontend comparison on **the identical 3,085,157-byte
compiler source and 75,064-byte Base**, with no source adapter. Original current
bendc takes **63.111s** to load, check and report; our private bounded-search
runtime build takes **17.153s**, with the same **122,602-byte verdict**. That is a
**3.679× runtime-policy effect with unchanged frontend algorithms**. It is not
evidence that bendc's checker algorithm is four times better.

The advertised approximately100× self-compilation comparison still mixes
hardware, revisions, inputs, checking policy and output responsibilities.
The fast result is real: Phase158 reproduced historical checked self-emission
in8.810s on this host. It does not follow that our different compiler can perform
its complete request in that time. This investigation counts actual work to
make the remaining architectural question more specific.

[Design](../../design/phase162/README.md) ·
[Independent causal audit](../../experiments/phase162/causal-audit.md) ·
[Operation metrics](operation-metrics.json) · [Research cost](cost.json).

## Controlled observations

Starting HEAD `6c645c34e789b3c7de9229b86e809a7d84dab55e`, branch
`selfhost/bootstrap`. Pinned bendc56edcc65, identical seed C and Clang flags;
the private runtime changes the optional GC free-block search bound. These
are one fresh observation per role, not repeated medians. Filesystem caches
were not evicted. One CPU3 lane, GPU off, one worker.

| Whole fresh bendc process | Seconds | Peak RSS MiB | Result |
|---|---:|---:|---|
| Bounded runtime, parse-only |5.420|1159.3|Full parse corroborated by diagnostic EOF/declaration counters|
| Original runtime, check-only |63.111|1163.9|Successful body checking, unsafe verdict|
| Bounded runtime, check-only |17.153|1168.3|Exact same complete verdict|
| Bounded runtime, counted check-only |17.312|See raw receipt|Exact same complete verdict; diagnostic clocks only|

Both check-only processes return1 because the source depends on unsafe/foreign
code, **not because type checking failed**. The independent audit traces that
boundary. The counter run observes successful `Done` results from both parser
calls and the checker. A finite `@unsafe` function returning Bool where U32 is
required is rejected with the exact expected type error. This does not establish
independent BendTT proof acceptance or general cross-checker equivalence.

## What bendc actually does

The counted run parses8,761 declarations across Base and source, builds and
attempts8,761 checker jobs, replays23, and never enters the sequential fallback.
It checks7,668 definition bodies. Parser-cursor advances3,160,131 times over
3,160,221 input bytes; this counts cursor consumption, not a byte-equivalence
claim. Both parser invocations reach EOF.

| Pure synchronous region | Diagnostic CPU s | Logical allocation requests |
|---|---:|---:|
| Two checker-parser calls, including Base |5.219|153,369,145|
| Whole loaded-book checker |10.637|224,189,901|
| Unsafe/dependency report |1.165|16,338,709|

The complete process makes406,640,522 logical allocation requests and requests
1,647,905,681 words cumulatively. Those are not system allocator calls, retained
memory, or RSS. Checking executes54.85million weak-head-normalizer dispatches
and25.88million checked-map lookup visits. Native memo, String and Map operations
are included in the private hook census rather than treated as free foreign work.

This falsifies the simple story that bendc is fast because it barely allocates
or skips checking unsafe bodies. Cheap execution of substantial work is part
of the explanation. The unchanged-runtime-policy ablation is causal; the
entire46-second difference cannot be assigned exclusively to search-loop
instructions because allocation addresses/locality and collection cadence can
also change.

## Where our implementation does more work

We ran the **same original compiler algorithm** through the existing C02 route,
with counters, and compared every generated QBE byte to the independent oracle.
It makes **2.950 billion logical allocation requests** over the complete request.
Only818.0million occur inside the measured parse/check/report region; the
remaining2.132billion include Base preparation and the backend/output lifecycle.
Thus frontend optimization alone cannot explain or eliminate the whole gap.

| Region | Our diagnostic CPU s | Our allocations | bendc allocations | Our requested words / bendc |
|---|---:|---:|---:|---:|
| Parse/load |24.430|200.15million|153.37million|1.123billion /554.00million|
| Check/publication |31.543|613.60million|224.19million|4.320billion /998.16million|
| Proof/dependency report |0.677|4.27million|16.34million|27.37million /57.49million|

These are **descriptive work censuses**, not identical stage contracts or
controlled time ratios. In particular Base is included on bendc's side, our
parse/load region includes preparation outside parsing, and generated object
representations differ. Our report is actually cheaper on these observations;
there is no evidence for “everything is uniformly slower.”

Within our checking region, actual loop counters record:

- 370 calls to declaration-book canonicalization;
- 3,005,961 rows in each of name validation and final selection;
- 6,011,431 rows in its two recorded reversal passes;
- 6,533,273 nonempty rows visited by index removal;
- 2,010,252 constructor-existence scan rows.

The four book pass counters alone sum to12.02million row visits, excluding an
additional generic reversal. `book_final_step` duplicates the final-selection
counter and is deliberately not added. These are concrete repeated traversals,
not allocations or sampled percentages. In contrast bendc checking performs
17,421 Book-set operations and26,945 Map sets, with native/trie traversal counted
separately. These are different algorithms, not directly exchangeable operations.

The relevant source chain is
[`p143cp_put_log` → `p143cp_canon`](../../selfhost/src/check/compact-schedule.bend),
then [`book_final_fast`](../../selfhost/src/core/index.bend), which validates
names, reverses, selects the final definition and reverses again. A constructor
publication crosses a conservative fallback boundary and materializes this view.
This is a specific way a relatively short source algorithm creates much more
runtime work. It is a better optimization target than deleting source lines.

## Causal ablation: repeated publication is expensive

The same diagnostic executable already contains the independently investigated
Phase156 publication policy. Selecting only that policy, with identical input and
complete output oracle, produces the following actual work changes:

| Checking/publication | Original | Existing publication policy |
|---|---:|---:|
| Canonicalizations |370|76|
| Final-selection rows |3,005,961|636,469|
| Allocation requests |613,603,513|254,704,544|
| Requested words |4,320,218,635|1,707,725,637|
| Execution-thread collections |127|50|
| Diagnostic process CPU seconds |31.543|12.344|

**58.49% fewer checking allocations and60.47% fewer requested words** are concrete
work elimination. Index-remove and constructor-existence visits remain identical.
Parse allocation/word counts and report allocation/word counts are also exact,
providing useful internal controls. The complete output remains byte-identical.

Complete diagnostic wall time is178.990→148.379s (17.10% less); peak process RSS
and detailed costs are in the receipts. These are single instrumented, streamed
requests through C, **not a new clean QBE performance claim**. Phase156's earlier
clean native whole-request result was4.62%; runtime/GC interaction makes effects
nonportable. No new source optimization was implemented or promoted here.
After the ablation, our checking allocation count is only1.14× bendc's observed
count, though requested words remain1.71×. This strongly narrows the explanation:
a major part of the original extra checker work was publication bookkeeping,
not inherently expensive type theory or simply having more source lines.

## A wider architectural opportunity: semantic data representation

The [representation trace](../../experiments/phase162/representation-note.md)
follows actual source through generated constructors. Our application is a generic
eight-field `KTerm` plus two child-list cells: **three objects,15 requested words**.
bendc's typed `TApp{f,x,span}` needs **one object,four words**, given existing
children/span. Cached tag Strings are not charged as fresh allocations. Source
span construction and other variants remain separate costs.

This is a3.75× local word difference, **not a measured speedup**. Generic `KDef`
records also serve as membership markers and caches, carrying fields those
operations do not need. bendc has wide records too, and its active flat-result
paths differ from our compatibility-required unboxing-off C image. The trace
states those limits rather than claiming every object is four times smaller.

The strongest next structural hypothesis is to retain typed semantic variants
and direct children through a complete hot parser/checker computation, avoiding
repeated conversion back to generic records. Count constructor widths/producers
first, then test a bounded representation change with exact normalized terms,
locations, errors, ownership and checked outcomes. Do not begin a whole compiler
rewrite or assume the local allocation saving transfers unchanged.

For whole self-compilation, continue the separate backend work audit: the current
request still allocates2.132billion objects outside the measured frontend region,
including Base and output lifecycle. Generic/private body production, repeated
analysis, registry construction and reclamation remain targets. Shared compacted
body preparation already exists; another such cache would not address this.

## What we now understand, and what remains unknown

The evidence supports **three interacting costs**: execution/runtime policy,
repeated semantic bookkeeping, and bulky intermediate representation. We have
isolated the first two with actual ablations and demonstrated a concrete local
representation tax. Source line count is a weak proxy for all three.

We still have no valid factorization of the headline100× into independent
multipliers, nor a same-output backend comparison assigning every second of the
remaining gap. The comparison of two compilers compiling themselves necessarily
changes their algorithm, input and output. The highest-value next investigation
is a constructor/producer census of the remaining frontend plus one bounded
compact-term experiment, while qualifying the existing publication result
separately if it is selected for production integration.

## Measurement and preservation

Counters are added to private copies of frozen generated C and its runtime;
no compiler algorithm or production source changes. Hooks bind exact function
hashes and unique insertion sites, including tail-loop iterations. Counters are
thread-local and dumped by the actual Bend execution worker. CPU clocks cover
the process; counts cover that worker. Pure wrappers preserve all returned
values. Instrumentation can change machine layout, stack roots and GC cadence,
so its clocks are diagnostic.

Our algorithm is observed through the already-admitted Phase160 C02 image,
using the same bounded-search runtime. It uses `BEND_UNBOX=0`, whereas bendc's
own seed retains its parent representation. Allocation-count differences thus
include representation as well as algorithm differences. Our frontend markers
begin after Base preparation; bendc's timers include Base and have different
parser/loader boundaries. They are not interchangeable stage-speed benchmarks.

The complete our-compiler request continues through checking, lowering,
optimization, independent verification and emission. Its output is streamed
through a job-owned FIFO and compared byte by byte against the independent
118,227,421-byte qualified oracle, avoiding another118MB disk allocation.
This is an operation-count observation, not a clean regular-file wall-time
comparison. The FIFO is removed after completion; no ordinary evidence is deleted.

Negative instrumentation findings are preserved: the first observer dumped TLS
from the process thread rather than the Bend execution thread. Independent review
caught this before measurement; its acquired image is rejected. Version2 dumps
before the worker's normal return. The first type-error runner incorrectly
rejected the shared `SOME PROOFS FAIL` prefix; its failed receipt remains intact,
with a separate exact-diagnostic [admission](control-admission.json).

Qualified Phase152 and installed selections remain unchanged. This phase neither
promotes bendc nor changes checking/proof/ownership gates. No PR comment posted.

Twelve guarded jobs consumed723.75 seconds (12.06 minutes) of the single target
lane, including the rejected observer build and failed classifier. The two good
C diagnostic acquisitions plus the rejected first acquisition consumed about
4.8 minutes. Two bounded agents performed source/observer audits; the leader
owned every target execution. Agent analysis, documentation and archiving are
outside that lane total; token/quota telemetry is unavailable. Largest observed
process-tree RSS was4.01GiB under an explicit6GiB limit. All12 jobs are classified
and the exact evidence capsule is reopened/hash-verified. No full self-hosting
or broad conformance campaign was run for this investigation.
