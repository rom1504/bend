# Phase65: unchanged composite-term allocation

Status: **State04 shallow guard rejected; State06 leaf-only controls pass but timing is mixed, so B2 investigation is deferred**.
No production source, compiler image or installed artifact changed in this lane.
Root owns execution and qualification. Phase64 raw evidence remains closed.

The hypothesis is that ordinary substitution and function-spine beta preparation
rebuild enough semantically unchanged composite trees to justify returning their
existing immutable representation. This is separate from the already selected
leaf shortcut, delayed telescope substitutions and graph evaluation, and does
not propose general weak-head-normalization memoization.

## Existing work and a code-generation qualification

[`subst_node`](../../selfhost/src/core/term.bend#L360) reconstructs every composite
parent and its child list. [`core_rebuild`](../../selfhost/src/core/term.bend#L388)
additionally rebuilds/canonicalizes Apps or beta-reduces a Lambda application.
[`core_beta`](../../selfhost/src/core/term.bend#L400) visits the function spine
and allocates another App at every non-reducing level. Its argument is not
recursively normalized. Stable trees therefore exist, but absence of the target
variable alone does not establish that any of these traversals are identity.

There is also an important limit to the earlier source-level leaf saving.
Selected genuine B2 `b09fe54ad58d105d1c77ccb399f4076660d6109cf2a7f4b21e13933b89c22c2e`
contains new object literals in the `subst` SCC's `subst_node` leaf and literal
arms: a Bend `case KTerm{...}: t` return is lowered by the existing compiler into
a reconstruction of the matched constructor. The checked-B1 reference emission
does the same. The prior shortcut still removes recursive child work and
`core_rebuild`; its source expression is **not evidence of preserved object
identity**. This is a source observation, not a measured allocation attribution.
An eventual unchanged-composite path should return a separate original parameter
outside the destructuring match, then inspect its actual generated code.

The [Phase62 term-processing research](../../research/compilers_architecture_and_techniques/phase62-term-processing.md)
already proposed measuring this exact boundary, informed by Lean's immutable
expression update helpers and guarded instantiation. We are now preparing that
discriminator, rather than claiming those ideas are new or rewriting the core.

## Fresh profile budget

The newly selected-B2 [allocation survey](evidence/baseline-state09-allocation.json)
reports the following inclusive substitution ancestry. These are sampled bytes,
including collected allocations, across the profiled import/request envelope;
they overlap semantic stages and are not whole-compilation savings.

| Source | Sampled bytes under substitution ancestry | Share of all sampled bytes |
| --- | ---: | ---: |
| Numeric recurrence | 393,360 | 1.80% |
| Lexer | 2,360,592 | 3.40% |
| Map operations | 31,870,832 | 20.84% |
| Active raytrace | 9,574,304 | 9.39% |

The [fresh CPU survey](evidence/baseline-state09-cpu.json) separately attributes
about 1.3/16.8/79.5/21.5ms to substitution ancestry in those four sources. Shared
generated SCC labels cannot uniquely identify one source function. These values
favor a cheap Map discriminator and then held-out programs; they do not support
claiming that substitution removal alone reaches broad TS parity. None of these
numbers come from Phase64's earlier baseline compiler.

## Exact semantic contract

The [observer](../../selfhost/tools/performance/phase65/term-reuse/observe.mjs)
defines only sufficient no-op conditions:

- `Var(id)` returns the replacement directly on a matching ID, or the original
  variable otherwise. Its attached children are not visited. Binder IDs on `All`
  or `Lam` are not variable occurrences; substitution retains them.
- Literals retain kind, number/text and source intervals. Ordinary non-App nodes
  retain constructor variant, tag/name/ID/quantity, removed fields and spans.
  `KLambda.quantityPresent` is preserved exactly.
- An App is reusable only if both substituted children are unchanged, the
  function remains non-Lambda, name is empty, ID/quantity are zero, removed fields
  are empty, and it has exactly two children. Even an unrelated substitution
  beta-reduces an existing Lambda application and canonicalizes malformed or
  metadata-bearing Apps today. Missing children become `Absent` through `kid`;
  extra children are still traversed before being discarded by rebuilding.
- `core_beta` checks the function spine only. A reducible argument can remain
  untouched, while a reducible function or noncanonical enclosing App cannot.
- No fresh IDs are introduced by either operation. Existing global unique IDs,
  immutable sharing and ordered environment application remain unchanged. A
  replacement can contain a later binding's ID; that later substitution still
  acts on it. This pilot introduces no cross-operation/context reuse.

The synthetic controls include unrelated-ID beta work, introduced Lambdas,
Var payloads, explicit/omitted quantity, nested annotation type variables,
nonzero spans, removed metadata and Apps with zero/one/three children. They
compare complete results for admitted cases and check input immutability. The
28 finite controls are not a proof of general soundness or language conformance.

## Discriminator and allocation model

The [controller and recipe](../../selfhost/tools/performance/phase65/term-reuse/README.md)
derive an **observation-only** copy of the selected genuine B2. Logical SCC entry
instrumentation leaves original compiler expressions intact; an exact inverse
recovers the source bytes. It preserves the actual API owner, primes its own
cache with observation disabled, and compares every real-source emitted byte
with the qualified oracle. Counters are bucketed by actual API demand. No
JavaScript replacement reducer or semantic optimization is a proposed product.

For each eligible composite substitution entry, count its immediate original
parent and original child-list cells once. These local counts sum across actual
entries without treating each entire subtree size as another saving. Stable Apps
also currently construct an intermediate parent before rebuilding the final App;
their extra parent and two extra child-cell counters are separate. Substitution
Nil objects are omitted from this conservative model. `subst_terms.cons` records actual list
work regardless of admission. Stable `core_beta` App entries imply one parent
and two child cells could be avoided, plus a Nil object in this emitted image.
Nested beta work and failed eligibility remain explicit; summaries never claim
their allocations removable. Public structural equality does not establish
arbitrary external mutable alias compatibility.

A fused changed-result substitution needs an extra flag/result carrier or
another safe representation. One wrapper per visit can erase the object saving,
and a wrapper per list cell can make it worse. A pre-scan instead adds metadata
checks and a second traversal on rejection. Identity-map lookups/hashing are
diagnostic machinery here; adding them to production may cost more than copying.
Returning a matched `t` may still reconstruct it in generated code. All three
costs must be considered before translating counts into a source change.

Decision order: run Numeric/Map counts, include Lexer/raytrace if the census is
cheap, then choose either a small `core_beta` stability guard or fused changed
substitution only if enough affected work survives. Reject this lane if eligible
composites are scarce, unknown/capped counts dominate, or the fresh-request screen
does not beat noise. Require a checked-B1 exact-result screen and unchanged real
modules before a genuine-B2 comparison. The small core-beta guard is lower risk
than a core-wide changed-result rewrite; neither has been implemented or timed.

Per-source diagnostic limits are five million predicate visits, 250,000 cached
facts and depth256. A cap yields explicit unknowns and a conservative lower bound,
never silent admission. The report retains identities, controls, limits and every
failed attempt. Root's resource guard remains responsible for process memory and
deadlines; the observer's limits are additional safeguards, not an RSS guarantee.

## Executed first census

Root ran the frozen first controller under the normal CPU3 resource guard in
8.14 seconds. All 28 controls and four complete emitted-module comparisons pass;
no predicate or cache limit was reached. The [tracked summary](evidence/term-reuse01.json)
binds the exact original raw report and selected genuine-B2 identity.

| Source | Stable / visited composite substitutions | Conservative reusable parent/child objects | Stable / visited beta Apps |
| --- | ---: | ---: | ---: |
| Numeric recurrence | 450 / 908 (49.6%) | 1,331 | 80 / 97 |
| Map operations | 50,264 / 106,483 (47.2%) | 174,644 | 1,776 / 2,046 |
| Lexer | 2,630 / 5,458 (48.2%) | 9,113 | 577 / 764 |
| Active raytrace | 18,170 / 21,540 (84.4%) | 78,770 | 4,020 / 4,393 |

These structural counts establish a real opportunity, not its profitability.
Map's eligible composites include 14,391 ADTs, 10,986 Apps, 10,014 Alls, 7,880
Typs, 4,396 annotations and 2,597 Lambdas. Most substitution work is outside the
checker: `jd_plan_selected` has 102,461 Map entries, annotation 47,393, layout
validation 47,096, plan rendering 29,451 and checking 4,724. Core-beta reuse alone
has a much smaller Map object budget than composite substitution.

The independent reviewer recommends a guarded public entry plus a distinct old
recursive worker if a recursive predicate is tried. Recursing back into the
guard at every failed subtree can turn a deep late occurrence/redex into
quadratic rescanning. A result-carrier rewrite also risks replacing saved nodes
with newly allocated flag wrappers. Neither is selected yet.

Root therefore requested the cheaper discriminator first. The unrun
[`run-shapes-v2.mjs`](../../selfhost/tools/performance/phase65/term-reuse/run-shapes-v2.mjs)
retains the consumed v1 files unchanged and counts parent tag/arity/child shapes.
Its proposed constant-work predicate admits a parent with at most two children
when both are unchanged leaves or nonmatching Vars, retaining the complete App
canonicalization guard. Nonmatching Var payloads remain opaque. Twelve new
controls supplement the original 28. These counts will decide whether a small
allocation guard is worthwhile before introducing a recursive presence analysis.

## Executed shape census and isolated source candidate

Root subsequently ran the frozen successor in 8.54 seconds: 40 controls, four
exact emitted-module comparisons, and no cap reached. The
[shape summary](evidence/term-reuse-shapes02.json) binds the exact raw report.

| Source | Shallow eligible composites | Parent/child object model | Additional non-Var leaf entries |
| --- | ---: | ---: | ---: |
| Numeric recurrence | 364 | 1,067 | 755 |
| Map operations | 28,740 | 87,348 | 54,862 |
| Lexer | 1,781 | 5,824 | 5,272 |
| Active raytrace | 5,792 | 26,001 | 19,344 |

The fixed-work predicate captures 57.2% of Map's eligible stable composite
entries without scanning arbitrary descendants. Common admitted Map shapes are
`ADT(Var,Var)` (7,446), `Typ(Qua)` (5,776), `ADT(Qua,Ref)` (3,313), `App(Ref,Ref)`
(2,186), `Typ(Var)` (2,104) and `Lam(Var)` (2,005). Names of user programs or
definitions do not appear in admission. Nonmatching Var IDs are checked at the
actual substitution demand. Counts of stable variables are not themselves
counted as saved allocations, since that existing branch already returns them.

The isolated
[`shallow-v1/candidate.patch`](../../selfhost/tools/performance/phase65/term-reuse/shallow-v1/candidate.patch)
adds five private helpers and no types to `core/term.bend`; its manifest records
the exact before/after bytes. `subst` retains the existing matching/nonmatching
Var branch, then returns its original `t` parameter if the constant-work guard
admits. That return is outside all constructor-match scopes. On refusal it calls
the unchanged `subst_node`, preserving recursion, beta work and App metadata
canonicalization. The guard checks at most the parent, two immediate children
and fixed-size list/metadata fields. It has no occurrence map, recursive absence
scan, cache, result carrier, fresh-ID mutation or new term representation.

The independent source review found no semantic blocker on the declared KTerm
domain. The [focused controller](../../selfhost/tools/performance/phase65/term-reuse/shallow-controls-v1.mjs)
is prepared but unrun: 40 inherited controls plus 225 complete before/after term
comparisons, raw `subst_node` and `core_beta` comparisons, ordered replacement
checks, and strict JavaScript `actual === original` witnesses for admitted terms.
It verifies the selected candidate source hash and appends diagnostic exports
without changing compiler bodies. An optional separately supplied B2 image can
repeat the identity witness; root must still bind that image to its bootstrap
receipt. Actual generated identity is a correctness condition for the proposed
allocation mechanism, not a speed result.

Production application, checked-B1 validation, clean timing and genuine-B2
confirmation remain root-owned and pending. Metadata/guard calls can still exceed
the saved copying cost; substantial counts alone do not promote this candidate.

## State04: actual generated reuse succeeds, speed screen does not

Root applied the isolated patch in checked State04 and ran
`state04-shallow-controls01` in 12.26 seconds under its CPU3 guard. The
[semantic summary](evidence/state04-shallow-controls.json) binds raw report
`784996c13f32bf930dcdd6fcf372dcbd41b6bc3fb1f25fd6b69cab5d82376fc8`,
candidate B1 `53a80b9fb81143a5b4b606fb63f6e15143ec88129dafb1641b119d39121b8e2a`
and baseline B1 `a2f8b021…`. The source before/after hashes match the isolated
manifest. Both query images append exports without modifying function bodies.

The 40 inherited cases pass on both images. The 225 new rows each compare full
`subst`, `subst_node` and `core_beta` outputs, check input/replacement immutability
and verify the candidate Bend predicate against the independent shallow predicate.
An additional ordered-replacement check passes. These are 265 distinct fixture
rows, with multiple checks per new row; they are not 265 independent language
conformance tests. The normal 36-case strict checked-B1 selection also passes
with zero exact differences.

**105 rows actually return the original JavaScript object.** This covers refs,
literals, nonmatching variables/payloads, Typ/All/ADT/Ann, empty/one/two-child
Lambdas with real boolean quantity-presence flags, and canonical Apps. The
captured generated `$subst$` body explicitly branches from
`$core_subst_shallow$(_t_0, _id_0)` to `return _t_0`; it does not reconstruct a
matched constructor. Thus the intended allocation mechanism works in checked
B1. Genuine-B2 reference preservation remains untested; a future surviving
variant should establish it early with the optional-image control mode.

The [balanced eight-worker screen](evidence/state04-b1-screen.json) preserves
all exact output comparisons but provides **no aggregate speed gain**:

| Source | Baseline B1, ms | State04 B1, ms | Change |
| --- | ---: | ---: | ---: |
| Numeric recurrence | 298.59 | 287.60 | −3.68% |
| Map operations | 1,281.21 | 1,335.51 | +4.24% |

Equal-source compile geometric ratio is 1.001997, or 0.20% slower; the combined
import/first-request ratio is 1.00369. Both Map candidate observations exceed
both baseline observations. Numeric's apparent improvement depends on a split
300.31/274.88ms candidate pair. This is a small two-round screen, not a confidence
interval or evidence about the unbuilt candidate B2.

Recommendation: do not advance this unchanged guard to B2 or installation.
Keep the semantic/identity success separate from the negative speed decision.
The result is consistent with the stated risk that repeated tag, child and
metadata tests cost more than avoided copying; the screen alone does not isolate
which helper dominates. No additional broad shape-predicate patch was prepared.
A broader metadata/arena framework is not justified by these counts.

## Root-requested leaf-only successor

Root rejected the 41-line State04 guard and requested one narrower intervention:
preserve the intended existing leaf shortcut in actual generated code, without
testing a new two-child shape at every substitution. The isolated
[`leaf-only-v1/candidate.patch`](../../selfhost/tools/performance/phase65/term-reuse/leaf-only-v1/candidate.patch)
changes three physical lines and adds no definitions or types.

The existing Var branch is unchanged. `subst` then returns its original parameter
for literals, before calling `ks`, so this path does not create an empty child
list. The existing empty-child/non-App condition returns that same original
parameter. Other terms use existing `subst_terms`, `k_with_children` and
`core_rebuild` directly, retaining every metadata field and beta step without
repeating the leaf test in `subst_node`. The public raw `subst_node` body itself
is byte-for-byte unchanged. There is no arbitrary subtree scan or new cache.

The unrun [leaf controller](../../selfhost/tools/performance/phase65/term-reuse/leaf-controls-v1.mjs)
retains the 225 complete before/after rows and 40 inherited controls, and changes
only source-manifest binding and the admitted reference-identity predicate.
All consumed shallow-predicate controllers and reports remain unchanged. This
successor is a new source candidate, not a reinterpretation of State04's failed
timing. Root still owns its build, measurement and any B2 advancement.

State06 subsequently built successfully, but the first leaf control stopped at
preflight with `AssertionError: subst_node`, before any fixture row ran. The
[failure record](evidence/state06-leaf-controls01-failure.json) preserves that
unsuccessful attempt. The new `subst` path does not call `subst_node`, so the
checked-B1 reachability pass no longer emits that unused private declaration.
Keeping its Bend source does not imply it belongs to the published 95-export
API; this failure exposed an overstrict diagnostic assumption.

The unrun [v2 controller](../../selfhost/tools/performance/phase65/term-reuse/leaf-controls-v2.mjs)
requires exact `subst_node` source-body preservation and records its hash. It
compares the raw helper dynamically only when both selected images contain the
declaration; otherwise it reports an explicit skip, per-image presence and zero
compared raw-helper rows. All 225 `subst`/`core_beta`/input/leaf-identity rows and
40 inherited controls remain mandatory. No production export was added for the
diagnostic, and the consumed v1 controller and failed raw run remain unchanged.

## State06 result and whether to spend another B2 build

The corrected controller now passes. Its
[semantic summary](evidence/state06-leaf-controls02.json) binds complete raw report
`bcd7ad5d766d68494cca017eec565205bcce6d4d38e06317a833590a2ba21ec6`
and candidate B1 `63ecf30d…`. All 225 full substitutions and beta results, 40
inherited controls on each image, input/replacement immutability and ordered
replacements pass. **48 strict original-reference witnesses** cover refs,
literals, nonmatching variables (including payloads/max IDs) and empty Lambdas.
The raw `subst_node` comparison is explicitly skipped: baseline declaration
present, candidate declaration absent, zero dynamic rows. Its source-body
SHA256 is unchanged at `4b3f3e4cece19531a2d4dcc551229a9d5d84df0eebeb9b7835365354f4c55bc3`.

The separate [eight-worker screen](evidence/state06-b1-screen.json) passes all
output oracles but is slower in aggregate:

| Source | Baseline B1, ms | Leaf-only B1, ms | Change |
| --- | ---: | ---: | ---: |
| Numeric recurrence | 275.02 | 295.04 | +7.28% |
| Map operations | 1,285.80 | 1,252.37 | −2.60% |

Equal-source compilation ratio is **1.02221**, and import-plus-first-request ratio
is **1.01906**. Both Numeric candidate samples are slower than both baseline
samples; both Map samples are faster. These separated two-round ranges establish
the observed mixed screen, not general statistical confidence or a B2 result.

There is a concrete reason B2 could behave differently. The observed State06 B1
`$subst$` has three textual `run_tail` choice sites: Var selection, literal
selection and empty-child selection. The non-Var paths add closure/Unit/tail
machinery around the literal and leaf guards. The selected baseline genuine B2
instead emits the corresponding substitution SCC choices as direct conditional
control flow, with no `run_tail` in that SCC. Candidate B2 has **not** been built;
its exact lowering and actual reference identity remain questions, not facts.
This distinction means the B1 regression does not prove that leaf reuse is
intrinsically bad in B2.

It still does not make this the best immediate target. Leaf-only reuse removes
node shells, while keeping `subst_terms` child-list reconstruction and all required
composite/beta work. Numeric's original census has just 755 non-Var leaf entries,
and its selected-B2 substitution CPU ancestry is about 1.3ms. Map has 54,862
eligible non-Var leaf entries, while the 209,798 observed child-list cell rebuilds
remain required by this slice. `subst_terms` is the largest named sampled
substitution allocation site; those samples do not classify object kinds or
separate inlined callees. Neither allocation-site counts nor B1 choice-site counts
justify forecasting a broad or parity-sized gain. Numeric's observed roughly20ms
B1 regression also cannot be explained from that B2 ancestry budget; the timing
does not isolate the responsible startup, generated-code or V8 effect.

**Recommendation: defer, with no standalone B2 run now.** Prioritize the clearer
H6 host-decoder opportunity and H2 prepared-annotation work. Keep the three-line
patch, exact controls and failed/mixed evidence available; do not incorporate it
into a selected bundle merely because the source change is small. No additional
patch or microtest was made for this review.

A single genuine-B2 discriminator is defensible later if the higher-value lanes
are blocked or an explicit investigation budget remains: emit exact State06 once,
bind its bootstrap receipt, repeat the existing v2 reference-identity control with
that image, then run one balanced fresh Numeric/Map screen. Stop on failed identity,
no material aggregate improvement or a meaningful per-source regression. Only a
clear survivor earns held-out coverage. Do not repeatedly retune guard forms or
claim success from the old diagnostic's removed-allocation count. This is a
bounded option for resolving a real generation-cost uncertainty, not authorization
to displace the current higher-priority target queue.
