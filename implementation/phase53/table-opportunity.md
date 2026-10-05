# Bounded scalar-table opportunity audit

Read-only audit, 2026-10-05. No compiler changes or target executions. The
reference is `comp.ts` at `018751270e800bc222a93dad7f257083ee53a5f7`.

**A real table-lowering gap remains in raytrace, but an integer/Bool-only
implementation would not address it.** Five hot helpers are Nat-to-F32 tables.
Mandelbrot has no comparable constant multiway table. Finish the ordered
intrinsic experiment before attributing its residual cost to matching.

## Exact observed opportunities

In the frozen direct06 `raytrace-active.mjs`, `sx`, `sy`, `sz`, `sr`, and `skr`
each contain eight strict Nat equality tests and nine result branches. Upstream
emits five module-level `TAB_N` arrays and one `TAB_N[Math.min(i,8)]` expression
per helper. These are **45 table cells versus 40 static equality tests**. The
direct helper bodies still perform selected arithmetic and `fl` calls on every
invocation; upstream computes all table cell expressions at module import.

| Helper | Direct06 starting line | Direct body bytes¹ | Static `fl` calls | Static caller sites² |
| --- | ---: | ---: | ---: | ---: |
| `sx` | 569 | 669 | 2 | 6 |
| `sy` | 575 | 752 | 7 | 6 |
| `sz` | 586 | 486 | 2 | 6 |
| `sr` | 589 | 505 | 3 | 6 |
| `skr` | 593 | 597 | 9 | 1 |
| Total | — | 3,009 | 23 | 25 |

¹ Bytes run from each top-level declaration to the next one, including its
trailing newline. These five direct bodies also contain 28 `Math.fround` sites.
The five upstream bodies plus their five table declarations occupy about 1,992
bytes; this is a local code-size comparison, not a whole-module size forecast.
² Counts exclude declarations and public export wrappers. The first four
helpers each appear in both branches of `nearest`, both branches of `nearest.t`,
and both hit branches of `trace`; `skr` appears once in `trace`.

This is plausibly executed work, rather than an unused source opportunity.
[The source](../../selfhost/tools/performance/phase37/fixtures-variants/raytrace-active.bend)
calls `pixel` once for each active input, four `subray` calls per pixel, and
`nearest(9n,...)` once initially per subray. Each of those initial nearest scans
visits all nine indices and calls `sx/sy/sz/sr`. Therefore the 64-active-pixel
point entails at least **9,216 logical scalar lookups** and **45,056 source-level
equality tests** in these initial scans, before additional shadow/reflection
work. These are deductions from the source control flow, **not measured machine
instructions**; V8 can inline or optimize the tests.

`sphere` has another nine-way match but returns fresh records; it is not a
scalar-table candidate and has zero calls from the emitted source functions in
this module. It remains exported. `isect5` has no match tests; its remaining
cost is arithmetic/call lowering. `trace` mixes control flow and dynamic values,
so treating its branches as constant table entries would be incorrect.

In [Mandelbrot](../../selfhost/tools/performance/phase37/fixtures-historical/mandelbrot.bend),
`b2u` is the sole constant Bool match: two arms returning U32 `0` and `1`.
Direct06 emits one `if`; upstream does too. There are 19 static source call
sites, including two per `mit` iteration. `sel.go` returns its input arguments,
and `mit`'s Nat match chooses a dynamic result or another iteration. Neither is
a constant table. A truthiness-preserving ternary for `b2u` is possible, but it
would be branch syntax cleanup, not recovery of an upstream table optimization.

## Existing reusable analysis and missing piece

[Direct pattern lowering](../../selfhost/src/back/js/direct/pattern.bend)
already has the hard part of row extraction: `jd_nat_rows` produces Nat literal
rows plus the final fallback; `jd_word_rows` records word masks, values,
constructor-prefix demand and default coverage. `jd_nat_emit` and `jd_word_emit`
currently print conditional chains. There is no direct equivalent of upstream
`emit_row`/`emit_tab` and no module-level table collector.

In [upstream `comp.ts`](../../bend2/comp.ts), `mat_rows` at line 1214 forms table
candidates from Nat rows, or dense U32 literal rows with one common fallback.
`emit_row` at line 2730 accepts only scalar word result types and closed constant
or admitted intrinsic expressions; it uses bounded `emit_fold` to expose small
source helpers such as `fl`. `emit_tab` at line 2757 deduplicates cell expressions
and emits the indexed lookup. `js_match` at line 3216 attempts this before the
ordinary row printer. `WORDS` contains U32, F32 and Nat; **Bool is not an
upstream table result type**, and Bool scrutinees do not produce table cells.

A literal-only U32/Nat implementation can reuse the existing direct rows and
reject everything it cannot prove. It has **zero matching whole-function
opportunities in these two sources**. It would be a semantic infrastructure
slice requiring new renamed controls, not an evidence-backed speed fix here.

The smallest useful raytrace slice is broader: whole-function, single live
Nat/U32 scrutinee; a bounded set of rows; closed scalar results after bounded
substitution of small nonrecursive helpers; and exact upstream intrinsic
expressions in a module-level private table. Emitting a fresh table inside each
call would miss the principal opportunity. Restricting the first version to
whole functions avoids adding a table accumulator to every expression emitter,
while still recognizing a structural class rather than source names.

## Cost, gain and semantic limits

Planning estimates, not measurements:

| Slice | Expected effect on these points | Implementation / validation cost |
| --- | --- | --- |
| U32/Nat literal tables only | No identified raytrace/Mandelbrot gain; do not budget more than noise | Roughly 60–120 Bend lines; 30–60 minutes plus checked build and controls |
| Bool constant branch cleanup | Likely 0–2% Mandelbrot, possibly none; upstream has the same branch | Small printer change, but no strong reason to prioritize it |
| Whole-function scalar tables including finite F32 expressions and bounded helper unfolding | Raytrace planning range 1.05–1.30×; uncertainty includes no gain. No identified Mandelbrot gain | Roughly 150–300 Bend lines; 1–2 hours implementation/controls, then focused timing; full qualification additional |

The raytrace range is based on repeated lookups and removal of per-call work,
not an allocation or CPU profile. A saved-output experiment can falsify it in
approximately 10–20 minutes including a paired warm screen, before adding a
compiler pass. It must compare against the **ordered-intrinsic candidate** once
that is available; direct06 still has a separate source of arithmetic overhead.
There is no defensible whole45 gain estimate from these two modules alone.

Even integer tables change host observations if introduced where upstream would
not choose one. `Math.min` can coerce an invalid Nat host value that a chain of
strict equality tests never coerces; property lookup on a table adds indexing
behavior. Port the same admission and interface behavior, rather than assuming
that scalar source types erase these boundaries.

For the useful F32 extension, preserve upstream's **runtime table initialization
expressions and order**. Computing equivalent constants in the Bend compiler
would erase observable import-time `Math.fround`/`Math.imul` hooks, change error
timing and risk NaN/signed-zero differences. The currently open NaN investigation
is a reason to separate this extension, not to silently generalize a safe
integer pass. A finite-only first table cannot claim full upstream table parity.

## Cheapest falsifier and controls

First replace only the five proved helper bodies in a saved module and add the
exact independently derived table expressions. Preserve all other bytes and
full benchmark results. Check every index 0–8, the fallback at 9 and a large Nat,
then compare active raytrace 64/256 points with unchanged Mandelbrot as a canary.
Keep profiled runs separate from clean timing.

A source implementation needs renamed dense/sparse U32 and Nat fixtures,
constant/default rows, a row using its predecessor (must refuse), a row depending
on another argument (must refuse), an untaken throwing expression, helper-cycle
and budget refusal, and identical tables eligible for deduplication. Compare
invalid Nat host inputs and ordered coercion against the pinned upstream.
If F32 is admitted, add exact signed-zero/subnormal/infinity/NaN bit observations
and before-/after-import host-hook tests. Verify actual table emission as well
as full values; passing only the scalar checksum is insufficient.

## Frozen evidence identities

Raw modules are retained under `selfhost/build/phase52/`:

| Artifact | SHA-256 |
| --- | --- |
| `prepared-direct06-intrinsics/modules/raytrace-active.mjs` | `46b72f006783dcde7f5e2cb1fb1ba32d5622b0e27fdda99ee4944b473c987ffc` |
| `prepared-direct06-intrinsics/modules/mandelbrot.mjs` | `1de3ba41fdd195158b7f6f8944ec7c52214f9a7271d9917f3d9b586779f0e227` |
| Upstream raytrace in `intrinsic-reference05/modules/` | `6ec766bd399abe64a706e778efd247cf84fe1cc37e183704a44d17bfbf162895` |
| Upstream Mandelbrot in `intrinsic-reference05/modules/` | `037f070e948ab7701364b7413c624bca4327db0bc6171ac4523b906d2ae9e222` |
| Frozen06 `src/back/js/direct/pattern.bend` | `5dfd61759478a5a94143cf44fb93b0f396901a5bf9852b0e4cce11a62b56f46e` |
| Pinned `bend2/comp.ts` | `3bd7ed49d33f1c61334d75a905e38c0345fb15a10b45d85884b77f49833dc5ee` |

Counts used bounded text spans between generated top-level function declarations,
exact call spellings, and direct reading of the corresponding Bend functions.
They are static source/output accounting, not V8 IR or executed allocation counts.
