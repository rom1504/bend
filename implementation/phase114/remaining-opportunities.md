# Remaining parity and complexity opportunities

Source-only review of selected `final-source02/compiler.bend` (2,306,979 bytes,
SHA256 `500211d484785778e75d5d4388b0d5ebc7282effd233c6b8f3d0e0269ac777f8`).
No compiler, benchmark or target was run for this note. Runtime numbers are
the completed final-source01 campaign in [results.json](results.json) and
[broad-runtime.csv](broad-runtime.csv). Source02 changes only six namespace
walkers and adds their tail helpers; its full native chain is a separate gate,
still in progress when this review was requested.

Final update: the source02 native chain now passes; see [native results](native-results.md).
The local F32 prototype subsequently removes some conversions and improves two
ray variants, while leaving the integer ABI in place. The typed-call proposal
below remains unmeasured. Two additional nominal numeric workloads use integer/
fixed-point code and emit identical products, so they do not establish broader
F32 coverage. [Initial prototype](../../selfhost/tools/performance/phase114/float-lanes/results.md)
and [family extension](../../selfhost/tools/performance/phase114/float-lanes/family-results.md)
record these distinctions; this review's original ranking is not a measured gain estimate.

## What the ambitions currently mean

All 405 complete-output observations passed: 45 programs, three roles, three
rounds. Across 44 timed points, Phase114 reduced the same-run geometric mean
from **7.0818× to 5.3861× upstream runtime**: **1.315× faster than Phase113**, or
23.95% less time. Summed measured batch time fell 21.63%. The 36 timed points
outside the frozen eight improved by a geometric factor of 1.2975; these are
previously seen historical workloads, **not a blind holdout**.

The largest individual improvement is expression-128, 485→134 ms, **3.62×**.
Symreg improves about 3.37× and list-pipeline-512 about 2.44×. Thirty-three
medians improve, six tie and five worsen; three rounds do not establish the
significance of small differences. None of the 44 timed points reaches upstream
parity. The closest is 1.84×; local-fold-128 remains 11.53×, raytrace 10.83×,
map workloads about 8.5–8.8×, and the active-ray cases 8.5×.

Thus broad **upstream parity has not been achieved**. The design’s1×/10×/100×
labels describe scope, not promised runtime multipliers. The1× scope produced
checked verification reuse and bounded runtime templates; the10× scope produced
local recursive regions and a closed continuation table with ordinary/broad
qualification. The100× scope—joint control/ownership/layout specialization that
removes intermediate structures—is still a research proposal, not an achievement.
From the current geometric mean, parity requires another5.386× speedup. For a
fixed program, perfect removal of a category occupying fraction `f` of execution
gives at most `1/(1-f)` speedup absent other effects. Static helper counts do
not establish those fractions or justify projecting a whole-program multiplier.

## Ranked runtime hypotheses

| Priority | Remove a category of work | Existing evidence and bounded next check |
| --- | --- | --- |
| 1 | Preserve owned constructor extraction and flat results throughout a recursive region. | Selected `p111_take` at source02:39896 drops ordinary constructor identity after the checked match; generic extraction revalidates the descriptor and uses a scratch buffer. Tree `scan` still builds four-U32 `Stat` results, takes them later, and transfers one boxed Term through H. Preserve checked constructor/field facts and existing product shapes through the region, then require disappearance of the corresponding allocation, seal, take and scratch round trips. Keep shared/static/unknown fallback and boundary boxing. |
| 2 | Preserve array handles and tagged state across complete loops. | The preserved candidate31 machine audit shows array row still calls a 392-instruction cell containing repeated guarded accesses; its heap base is already cached. Lexer removes an outer tuple but still allocates/takes tagged `Mode` states. Carry exact handle/layout/ownership facts across calls and joins, or scalarize a closed state union. First require fewer guards, address computations and state objects, with the same owner/alias controls. More inlining alone does not prove these operations redundant. |
| 3 | Admit broader closed recursive regions, then private constructor destinations where lawful. | H admits only one owner, ≤8 arguments, ≤8 continuation FIDs and ≤8 captures, with bounded bodies; dynamic apply and other recursive targets fall back. A closed multi-owner region can remove further bank handoffs/dispatch while retaining explicit captures and bounded native depth. Separately, a proven constructor spine can replace pending rebuild frames with one private unfinished destination. It must preserve evaluation order and sealing, prevent publication of holes, and state changed allocation/OOM order. Ordinary tree/list/string witnesses must establish admission before timing. |
| 4 | Preserve scalar signed-shift/Boolean/width identities to machine operations. | Candidate31's actual `mit` loop already has no machine calls and no spills; its remaining 121 instruction lines include sign-fill and repeated comparison/extension sequences. Phase114 scalar-region is essentially unchanged (107→109 ms). This needs algebraic scalar cleanup, not another ownership helper template. The existing scalar-operands experiment is separate and unselected; no gain is assumed here. |

These priorities are hypotheses about removable work, not speedup estimates.
The [actual selected-route ABI audit](next-category-removal.md) confirms that
local-fold already calls a flat `$product.fold.loop`, and ray's executed
`nearest`/`trace` workers already carry `Hit` without generic ctor/take calls.
Missing tuple or Hit boxing does **not** explain those gaps. The array-invariant
proposal applies to local-fold's remaining guards; tagged `Mode` is a separate
lexer case. Ray also has a distinct representation opportunity: canonical F32
values repeatedly cross between integer Term bits and float registers, including
49 GPR/XMM moves in inspected `isect5`. A typed private F32 region could remove
those boundaries; this is an unmeasured hypothesis with explicit rounding/NaN
and boundary-conversion obligations, not a gain implied by that static count.
The first two retain facts already available before generic Term lowering;
the third extends a closed, stack-safe representation rather than admitting
unbounded machine recursion. No source-function name should be an admission
rule. The first gate for each is an ordinary complete-output/ownership case
plus an actual emitted witness of the whole category disappearing. Only then
measure the matched broad workloads and identify the affected runtime fraction.

There is evidence against spending the next cycle on isolated call shortcuts:
packed Take1 improved its selected screen only about 1.6%; the complete-call
bridge about 1.5%. Both remain excluded. The bridge's 470 potential static
edges across 34 programs did not imply a large measured effect. H removes
generic dispatch but still stores captures required by strict recursion;
erasing those values without an alternative representation is not an
optimization. Destination passing is not automatically allocation elimination,
and typed extraction is not automatically unique ownership.

## Complexity cleanup before adding more layers

1. **Build one selected emission plan per segment.** The selected H-first hook
   (`p113e_public_chunk`, source02:45290; `p114hf_planned`, :50536) can retry H
   after R and G also refuse (:50240–50249). Preserve exact route precedence,
   limits, namespaces and failure behavior, but retain the first plan/refusal
   in a small explicit sum type. This is an exact-output candidate for reducing
   duplicate scans and simplifying future representation passes, not a runtime
   speed claim. Require byte-identical QBE on the existing witnesses and time
   the emission stage separately.
2. **Remove known-flat suffix reconstruction.** `p113px_known` (:46264) and
   `p113pl_bind_flat` (:45888) still rebuild, inspect, substitute and replan the
   remaining syntax for each known product binding. A chain can visit suffixes
   of lengths `n,n-1,…,1`. A scoped virtual-bundle environment with the existing
   persistent use information could remove that quadratic pattern. Preserve
   mature min/max-use and ownership decisions; deleting their checks is not an
   equivalent shortcut. First isolate product lowering and compare exact QBE.
3. **Cache immutable analysis summaries, not trusted caller certificates.**
   Inlining still scans callee size/scratch shape per site, and range joins
   traverse accumulated facts (:47263, :48080), with range processing both
   during bottom-up inlining and afterward. Cache exact function summaries;
   investigate changed/live-name joins only with equivalence evidence. The
   already selected catalogue index and verification session fix real repeated
   work; do not undo the final whole-program verifier to chase another saving.
4. **Separate production composition from diagnostic baggage after qualification.**
   Keep frozen history and exact recipes, while giving the production root set
   a clear module/interface boundary. The existing Phase111 `--slice` is
   documented for module checks, not a qualified full-image replacement; a
   production slice needs its own public-entry and self-reproduction gates.
   The namespace failure also shows why every new whole-program list traversal
   needs a bounded-stack implementation. API02 now contains real JS loops for
   all six repaired walkers; nested branch depth remains recursive.

The immediate milestone is a completed native compiler chain with attributable
frontend/lowering/verification/emission times. Small-kernel stage improvements
and hosted program-runtime parity are different claims. Adding representation
passes before controlling compiler scaling risks repeating the previous full
image deadline failures.

Evidence: [namespace JS review](namespace-js-review01.json);
[selected H ablations](../../selfhost/tools/performance/phase114/recursive-table/ablations.md);
[owned-access boundary](../../selfhost/tools/performance/phase114/runtime/next-owned-access.md);
[recursive product evidence](../../selfhost/tools/performance/phase114/runtime/next-architecture.md);
[candidate31 machine audit](../../selfhost/tools/performance/phase113/direct/remaining.md);
[destination-passing constraints](../../selfhost/tools/performance/phase113/direct/tmc-feasibility.md);
[remaining lowering costs](../../selfhost/tools/performance/phase113/direct/scaling.md).
Machine counts in those audits are static, include fallback paths and are not
dynamic cost attribution. This note changes no production source or recipe.
