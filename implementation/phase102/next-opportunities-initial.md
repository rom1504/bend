# Next opportunities after the Phase102 candidate

Offline audit of `trmc-reuse-source02/compiler.bend`, SHA256
`8b895aec2dc9eac2eaee0036239367f83b53910c309ba26ebab4c9a47fa5affa`:
39,215 physical lines, **425 more than installed Phase98**. No new target was
run for this note. Native B1 acquisition has completed; root owns the remaining
chain and qualification results. Application execution, compiler request time,
Clang build time and test-harness preparation remain separate clocks.

## Highest-value follow-ups

1. **Compose observer results with their consumers.** The final emitted indexer
   (`reuse-emission02/source-index/emitted/program.c`, SHA256
   `c05d2f554b2482f2604911cc7e19248306646abc30cbc5cd2f04349c482dca7d`)
   still calls `String.eq -> String.order -> String.cmp`. The last function now
   forwards to its proved owning observer adapter. That adapter contains two
   explicit `heap_alloc` sites building nested Tuple shells; `String.order`
   immediately calls `Pair.snd`. These shells transport roots that the consumer
   immediately discards. This is a concrete remaining generated-code pattern,
   not a measured dynamic allocation count or savings estimate.

   A general result-projection or existing product-return route could carry
   the owned fields directly, preserve disposal of discarded roots, and avoid
   these shells. Prefer a structural observer-wrapper/projection certificate
   over recognizing String names. The current early observer bridge runs after
   ordinary/product retry; newly ready callees do not automatically recover all
   earlier caller product specialization. Start with the exact saved-C pattern
   and full output controls, then integrate only if it earns a whole-app gain.
   Main risks: escaping children, aliasing, discarded-root disposal, result order
   and moving an effect/failure across the observation. No borrowed caller ABI
   is required for the initial owning product result.

2. **Bring retained aggregate observation into the composable worker plan.**
   Final source has neither Phase99's `nob_*` certified borrowed-call helpers nor
   its `nog_*` aggregate-root schema extension. Phase98's complete native profiles
   identified consuming KDef/KTerm projections and equality boundaries as
   substantial work; upstream's generated compiler already peeks at retained
   KTerm tags and calls a borrowed String walker. This is a demonstrated backend
   difference, not an assumption that the language itself must be slower.

   Reuse the existing Phase99 prototype and controls before inventing another
   representation. Its aggregate probe passed nested aliases/Unicode/full-field
   checks, and the combined historical native experiment improved full compiler
   request time. However, that combination also included selector specialization
   already present here: its historical 28.2% reduction is **not** a forecast
   for this candidate. First refresh a small native compiler profile and inspect
   whether retained projections still dominate. Keep scalar-only borrowed
   results initially; an escaping child needs a separate ownership rule. Main
   risks are root ancestry, lifetime across helper calls, mutable/opaque fields,
   raw-provider authority and conflating shared with unique roots.

3. **Remove repeated analysis work added by optimization.** `nd_comb_fresh`
   still scans the same body/actuals/environment once per reserved ID; selector
   specialization asks it for 64 IDs. Phase99 already contains a single-interval
   scan in `branch-closures/interval-helper.bend`, with 44 finite comparisons
   covering malformed Var leaves, interval endpoints and first-binding/sentinel
   environment behavior. That helper is absent from this final source.

   This is the cheapest next compiler-speed experiment. Reuse those differential
   controls, require exact emitted C for unchanged test inputs, and time a small
   branch-heavy compilation before a full image rebuild. It changes the cost of
   proving eligibility, not which programs should optimize. Preserve nc_id's
   reversed numbering, overflow bounds and malformed-input behavior; a simple
   min/max shortcut without those rules would be wrong. Its current total-time
   importance has not been measured, so no overall gain is promised.

4. **Replace the blunt inlining threshold with bounded compositional policy.**
   The measured 4KiB→8KiB change made the indexer's `next_mode` inline and improved
   the app. It does not establish that larger global thresholds are better.
   The native compiler has many more workers; transitively expanded bodies and
   instruction-cache pressure can cost both Clang time and execution time.
   First inspect the new native image's actual hot call edges, code size and
   build receipt. Then test a bounded cost rule that accounts for callee count,
   loops and repeated call sites. Keep ordinary Clang inlining available. This
   targets broad small predicates and state transitions rather than app names.

## What not to repeat immediately

Changing String storage globally is still unsupported: Phase101's chunked
renderer win came with graph/index regressions; linked TRMC now obtains broad
construction wins without that ABI change. Phase99's scalar-width cleanup made
assembly simpler but did not improve its controlled runtime screens. Small
dispatch accessor and PCH/identifier experiments also lacked an established
whole-workflow win. None should displace the concrete ownership, result-transport
and repeated-analysis gaps above without new evidence.

The NC_Text emitter is already a rope: `nct_render_work` visits leaves in reverse
and prepends each leaf once to the output suffix. Do not label that loop quadratic
without counting actual leaf copying. TRMC/reuse changes the cost of its append
operations, so the old append profile is a motivation to remeasure, not a current
bottleneck ranking.

## Efficient next loop

Freeze this candidate first. Use the new native B1/B2 small same-source screen
and one complete unchanged-binary profile to identify what remains; historical
Phase98 samples cannot quantify Phase102's residual cost. Run saved-product
ablation plus focused ownership/refusal controls before a compiler image build.
Use batched checked-API acquisition for candidate source changes, preserving
complete per-program outputs. Keep one slow chain/inheritance gate for a selected
winner rather than repeating full qualification after every idea.

The four mechanisms compose because each preserves a usable owned result:
selector specialization exposes control flow, TRMC removes construction
continuations, the observer bridge removes a dependency-admission barrier, and
local calls let scheduler parents use admitted workers. The important finding
is that existing correct analyses were isolated from one another. Making their
results composable produced gains across text indexing, rendering and graph
construction without an application-specific backend or new String ABI.

## Suggested final-report narrative

Lead with the final selected source, complete-app scoreboard and actual native
qualification level. Explain the composability finding in the preceding
paragraph, then the separate one-cell reuse and measured inlining refinements.
State the +425-line cost and retained fallback boundaries. Put the faster batch
harness in its own timing row so preparation savings are not presented as
compiler-speed gains. Group inactive permissions, annotation mismatches, witness
repairs and rejected storage/build approaches after the accepted result. Update
the modular integration note for the final reuse hooks (`nc_destructure`,
`nc_match_apply_join`, `nf_finish_ready`) and the 8KiB hint before claiming that
its earlier source02 map describes the final source. Keep all final measurements
and native chain conclusions root-owned.
