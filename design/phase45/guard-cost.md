# Guard cost and a credible path for small programs

This is a read-only proposal following worker11. It changes no selected compiler
or runtime. Its scope is the complete public mutation contract, including the
hostile-import concern that stopped [P45-007](../../experiments/phase45/P45-007-guard-temporaries.md).
No speed estimate below is a measured result.

## What the current entry actually pays

The contextual wrapper in `jpure.bend:j_instance_root_guarded_mode` performs,
in order: exact-entry permission, no inherited proof, `regionHostGuard`, full
`stringHostGuard`, scalar inputs, then `localGuard($guards)`. `localGuard` checks
Array prototype/markers and calls `scalarGuard`. The latter can call
`stringHostGuard` again, checks the Object/Function/primitive prototypes and
Function.call, then checks every public dependency's G descriptor, function/code
prototypes, metadata descriptors, empty bound vector and marker properties.
The per-dependency `[a,c,e,b].every(...)` creates a temporary receiver as well.

Three compiler lists are simply concatenated: original source names for every
instance row, the primitive fence, and residual native/global dependencies from
the successful JPure proof. Multiple contextual rows can repeat one original
source. There is no compile-time union across these lists.

Read-only counts from preserved emitted modules:

| Snapshot / root | Guard entries | Unique names | Duplicate names |
| --- | ---: | ---: | --- |
| worker09 Map / bench | 112 | 112 | none |
| worker09 records / bench | 112 | 110 | Map.lo, Map.hi twice |
| rejected worker07 RLE / main.out | 67 | 67 | none |
| rejected worker07 Map/Set / chk_get | 110 | 106 | Map.lo, Map.hi three times |
| rejected worker07 Map/Set / chk_union | 105 | 103 | Map.lo, Map.hi twice |

Raw modules are under `selfhost/build/phase45/preparation-worker09/modules/` and
`preparation-worker07/modules/`. These are structural counts, not timed guard
shares. RLE's 67 names consist of 13 source names plus the 54-name primitive fence;
P45-012 therefore targets a much larger source of excess work than deduplication,
but is an experiment: the hostile-import issue below also applies to its pruning.
Morning/evening had no contextual worker in worker07, so reducing this guard alone
cannot improve them. Rejected nullary admission remains rejected until measured
with a materially cheaper entry.

## What can safely be reused, and what cannot

For an ordinary initialized host, the full host guard establishes canonical
reflection before the dependency guard. All original G/function/code/bound objects
were privately captured at creation. A successful descriptor check neither calls
a getter nor invokes user code on those objects. Within that *same entry*, a
successful String check and repeated checks of an identical dependency are
therefore logically dominated. Array prototype checks also overlap the host guard.
Function.call and primitive-prototype marker checks are not all subsumed.

That argument has an important boundary: identity with an imported snapshot does
not establish that a hook is native and inert. P45-007 stopped because a custom
Array.every installed before import can be captured and can mutate state on each
invocation. The same concern applies to repeated reflection/protocol checks.
Do not silently revive that experiment by calling a full host check a universal
native-host certificate. Any elimination must preserve the original behavior in
that domain, or establish a stronger supported provenance fact. A finite behavioral
probe or Function.toString test is not such a proof.

Exact-entry permission alone cannot replace dependency/host validation. After
invokeExact checks Function.call, reading env or argument getters may reenter and
mutate the world before the worker body starts. The token is consumed before
argument reads for precisely this reason. Error construction also reenters; `bad`
suspends the private proof and the next public entry must check afresh.

## Recommended sequence

1. **Measure fixed cost on the selected compiler and any qualified P45-012 experiment.** Use the same ordinary
   tiny/medium/large sources with inputs 0/1 and their existing larger points.
   Count entries into invokeExact, regionHostGuard, stringHostGuard and
   localGuard/scalarGuard in an untimed derivative, then profile clean modules.
   Record whether an optimized root actually activates. Never subtract unrelated
   process startup from an independently measured module time. A 20–60 second
   screen should decide whether the next intervention belongs to guards or work.

2. **Make entry requirements an explicit reusable IR fact.** Alongside exact
   dependency identities, carry needed host families and whether the root can
   reach String/Char, F32/DataView, native adapters, or public residual calls.
   Derive this from original typed proof plus lowered operations; printing text or
   snapshot.stringFamily is insufficient. For example, j_instance_capture can
   recapture a source using the default false flag, so that flag is not complete
   String provenance. Preserve original erased-call provenance as P45-012 does.
   Unknown facts choose the existing complete guard.

3. **One guard implementation consumes that fact.** Factor the existing checks
   into host/protocol, input and dependency parts. Initially preserve their order,
   callback count and fallback behavior exactly. Once the fact's premise is
   qualified, it can avoid a second String scan, unnecessary String/F32 domains,
   and repeated source identities within one entry. Keep freshness per entry,
   rather than introducing a global guard cache. The hostile-import case above
   is an explicit qualification gate, not a documentation footnote.

4. **Amortize over semantic computation, not a benchmark batch.** The existing
   complete graph worker already checks once for many private calls. Extend that
   general mechanism to positive-arity monomorphic source graphs and currently
   unsupported ordinary data/loop shapes. This is the promising way to improve
   the rest of the corpus while retaining public mutation behavior. Suppress
   independent private wrappers at trivial leaves when they add a guard but no
   useful work. Nullary roots need a fresh profitability screen after the entry
   improves; do not turn their failed candidate back on indiscriminately.

5. **Only if profiles justify it, consider lazy component capabilities.** A
   per-invocation plan could validate a dependency/component on first demand,
   keeping a private checked set until the proved computation exits. This avoids
   guarding an unvisited branch's entire graph. It requires a complete effect/
   reentry argument, careful guard-failure continuation at the original demand
   point, and errors that suspend capabilities. It is substantially harder than
   exact sets and must not become cross-call caching. It is a later architecture
   experiment, not the next quick patch.

## Likely payoff and effort

| Direction | Conditional gain estimate | Engineering / validation |
| --- | --- | --- |
| Deduplicate source/native names | 0–4% fewer dependency iterations in the inspected examples; usually less wall-time gain | Small implementation; host-import semantic gate remains |
| Reuse String/host facts within one entry | 1.1–1.5× guard time if duplicate scans are active; total gain depends on measured guard share | Medium refactor; ordinary + pre/post-import hook controls, one short screen |
| Exact host-family requirements | 1.3–3× guard time on small non-String/non-F32 graphs is plausible, unmeasured | Medium, roughly 2–4 hours with complete typed provenance and controls |
| Whole computation coverage / useful root placement | Potentially several-fold on currently generic dispatch-heavy programs; cannot predict universal parity | Medium to large, separate ordinary fixtures and 60-second screens per shape |
| Lazy component validation | Could remove most checks for large mostly-unvisited graphs; can regress frequently visited small ones | Large, roughly 1–2 days for a sound prototype and adversarial controls |

For a guard fraction g and guard speedup s, total speedup is
`1 / ((1-g) + g/s)`. A twofold guard speedup is only 1.05× overall when guards are
10% of runtime. Source/native dedup cannot explain or close a tenfold gap.
The estimates are hypotheses, not promises or accumulated expected gains.

## Parity constraint and falsifiers

With freely mutable exported G entries and code/env/bound metadata, a fresh public
call cannot assume that an arbitrary dependency remains unchanged. Without a
trusted mutation/version mechanism, proving N independent mutable dependencies
has an O(N) observation floor. Freezing exports, proxying every exposed object,
or offering a closed-module API changes that contract; none is an authorized
shortcut to an apples-to-apples parity claim. Full host-hook compatibility adds a
fixed entry cost that a tiny TypeScript function may not pay.

Consequently, pursue whole-corpus parity through cheaper generated computation
and wider general worker coverage first; report tiny-entry latency separately
from useful-work scaling. A dedicated closed-world mode could be a distinct
future product decision, never a silent benchmark setting.

Every proposed guard change must falsify: post-import G/code/env/bound/arity
replacement and getters; Function.call; prototype markers and indexed setters;
String/Number/BigInt/Math/DataView hooks; partial/raw/overapplication; env/argument
getter reentry; genuine Error-hook reentry; and relevant pre-import custom hooks.
Use separate derivatives for activation and guard counts, untouched modules for
clean timings, and preserve failed controls. No repeated proof or check is removed
merely because it looks redundant in emitted JavaScript.
