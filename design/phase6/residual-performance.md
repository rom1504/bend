# Closing the remaining compiler throughput gap

The consolidated Phase 5 default is equality-derived checked B1, API e2b5463678a2…,
from source e3b927d13dc2…. Its controlled complete-source process mean is363.392s
versus60.248s for pinned TypeScript,6.03×, with the documented Base-cache policy.
The edit loop is much shorter: a checked API bootstrap observed14.63s and focused
paired validation can select only affected cases. Full self-emission is an
integration gate. Keep this usable release fixed during new experiments.

## What the current evidence supports

The final-source top-level observations put checking and annotation among the
largest remaining costs. A fresh diagnostic profile of the exact optimized
release on the60,909-byte core component now shows substantial trampoline,
closure and GC activity alongside equality, term construction and index walks.
See [P6-001 results](../../implementation/phase6/optimized-residual-profile.md).
These samples overlap correctness work and are neither speed measurements nor
removable-cost ceilings. Old unoptimized B1 string-comparison percentages cannot
be reused after the equality fix. Private H's generic matcher overhead describes
a different artifact and cannot explain the entire default-versus-TypeScript gap.

To reach TypeScript speed from6.03× requires removing about 83.4% of present wall
cost on that workload. A small local optimization may help iteration but cannot
plausibly close that gap alone. The next campaign should test an algorithmic
change alongside inexpensive control-flow improvements, without abandoning the
seconds-scale focused loop to rebuild H after each idea.

## Ranked experiments

Estimates below are planning hypotheses, not measurements or additive gains.
They refer to the current optimized default on representative compiler work.
Each early result can stop its experiment before the larger implementation.

| Priority | Mechanism and expected benefit | Complexity / first decisive check |
| --- | --- | --- |
|1|Expose direct Boolean branches in hot source helpers, removing two thunk closures and a choice bounce per decision. A narrow predicate may yield0–10%; broader proven lowering could plausibly yield10–30%.|Small predicate:1–2hours including controls/pilot. General generated lowering:1–3days with scope/demand/stack proofs. P6-002 tests the small version first.|
|2|Retain typed results/facts from checking for annotation, or share exact signature facts across layout/emission. A successful broad design could plausibly yield1.2–1.6×, but specialization and environment changes may defeat reuse.|Conceptual change:several days, not a quick memo patch. First2–4hours instrument exact immutable book/term/type/context dependencies and count repeated work; prototype one fact in a component.|
|3|Intern identifiers or carry a precomputed hash/name ID through repeated index operations; replace hot membership lists with persistent exact sets only where measured.|Medium/high:1–3days for a coherent source representation,1–2hours for counters and one local set/hash ablation. Planning range0–30%; collision work may already be small after native equality.|
|4|Improve the Bend emitter's typed workers across match boundaries and constructor continuation lowering, to make the self-emitted compiler approach default speed.|Large:several days and deep evaluation-order/stack tests. This closes the H/default gap first; it is not credited against the6× default/TypeScript deficit. Prior one-site fusion failed its gain gate.|

Numeric tags/flat nodes are deferred until allocation and traversal measurements
identify a benefit beyond the existing private accessor optimizations. Prior
accessor/no-copy experiments showed modest workload-dependent gains. General
normalization WeakMap memoization increased cost; a new proposal needs narrower
facts/dependencies, memory accounting and a different mechanism. Repeating a
large identity reuse count is not sufficient evidence of useful memoization.

## Invariants and falsifiers

Direct branches must preserve Var rejection before child inspection, child order,
App canonicalization and beta behavior, as well as exceptions/divergence in
unselected branches. Bend cannot match a local binder: a valid source experiment
must use parameter/field scrutinees or explicit helper definitions. A generated
transform must preserve lexical captures and malformed fallback; no arbitrary
regex replacement of nested JavaScript is acceptable. Selected direct graphs
must include successful deep cases, not two matching stack-overflow errors.

Typed reuse belongs to one immutable context and must account for specialization,
book replacement, dependent arguments, quantities, binder freshness and selected
error order. Names alone are not safe cache keys. A promising first fact is a
fixed definition signature in one annotated book; capture actual call identities
before implementing it. Compare exact annotation graphs and full emitted bytes,
then changed-import A→B→A requests and negative type/ownership/termination cases.

Identifiers retain exact spelling for diagnostics and external ABI. Cached hashes
must obey the same Unicode/scalar policy, collision buckets and shadowing order.
Use empty names, non-BMP text, malformed host UTF-16 fallback, duplicate names,
forced32-bit collisions and older book versions as direct controls. Count hashes,
trie steps and equality calls separately; string equality samples also include
short term tags and do not by themselves identify name lookup.

## Fast validation ladder

1. Preserve a hypothesis/plan and its smallest falsifier. Read prior rejected
   work before editing. Build isolated source with checked upstream bootstrap.
2. Run direct contract controls and focused fresh TypeScript comparisons. Use
   persistent frontend workers; compile/run small emitted JS/native witnesses for
   backend-impacting changes. Retain failures exactly and keep source/default fixed.
3. Compile the real core component and require unchanged checked status and exact
   output bytes where the intervention cannot alter emission. Freeze every input.
4. After all competing compiler work stops, run two opposite-order fresh-process
   pairs with equal cache policy, Node flags and CPU affinity. Require at least 5%
   reduction in both pairs to earn broader work. Report RSS and all samples.
5. A survivor receives repeated representative programs, complete frontend and
   backend regression, then one controlled whole-source comparison. Only the final
   combined source earns another genuine checked fixed point and release promotion.

No compiler timing measured during the current broad backend sweep is admissible
for a speedup. If the authorized window ends before an uncontended pilot, publish
the candidate as unmeasured/unpromoted. User-program runtime gets its own executed
benchmarks; preserving emitted bytes demonstrates compiler-only improvement.
