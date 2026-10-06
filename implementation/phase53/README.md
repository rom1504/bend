# Phase53: correct default JavaScript and faster generated programs

The compiler remains implemented in Bend. Selected **ordered02** fixes the NaN
payload mismatch and an additional callback-order gap, makes direct JavaScript
the ordinary output, and improves generated-program execution by **5.6%** on the
complete maintained benchmark. It is installed and qualified: all 66 release
interface checks and the final portable replay pass.

[Design](../../design/phase53/default-direct-and-ordered-expressions.md) ·
[All results](results.md) · [All-point diagram](ratios.svg) ·
[Qualification](qualification.md) · [User guide](../../selfhost/docs/direct-javascript.md) ·
[Independent review](review.md) · [Source accounting](complexity.md) ·
[Generated-code shape](generated-shape.md) · [Time accounting](timing-accounting.md) ·
[Publication index](../../selfhost/tools/performance/phase53/publication.json).

## What changed

- **Correct NaN bit transport.** `f32_bits` writes directly to fresh typed-array
  storage. The intermediate ordinary array could lose a NaN payload on a cold
  call. The original source expectation remains 40: selected output returns 40;
  pinned TypeScript returns 1 because it has a separate constant-table defect.
  Storage is per call, with once-only conversion and no shared buffer.
- **Direct JavaScript by default.** Ordinary program/library emission and
  `--run` use lexical functions, native closures and native data layouts.
  `--legacy-js` retains mutable descriptors and `G`; explicit `--direct-js`
  remains an alias. Pure interpretation, native targets and compiler bootstrap
  retain their existing explicit routes. There is no TypeScript fallback.
- **Composable ordered expressions.** The Bend emitter carries statement prefixes
  and pending values through calls, constructors and lets. It collects child
  prefixes before holding pending intrinsic operands, matching the pinned
  emitter's observable order. Partial calls defer supplied work until full
  application; captures use separate held-local names. This removes primitive
  wrappers without adding one function boundary per computed operation.

The [evaluation-order refinement](../../design/phase53/ordered-prefix-evaluation-order.md)
explains why the first universal-left-to-right idea was wrong for the promised
upstream-callable interface. That uncompiled prototype and the original failed
expectations remain preserved. A later let-result-slot idea was also rejected
in review because it would evaluate a pending body too early. Source values,
errors and the NaN golden were never weakened to obtain a pass.

## Complete performance result

One frozen checked compiler, the exact previous direct06 modules and the pinned
TypeScript modules were measured together on **45 points from 23 source programs**.
All output checks and **669 fresh rotated samples pass**. No historical median,
prototype row or incomplete campaign supplies a denominator.

| Weighting | Previous direct06 / TS | Ordered02 / TS | Speedup |
| --- | ---: | ---: | ---: |
| Equal point | 1.129266× | **1.069599×** | **1.055785×** |
| Equal source | 1.135543× | **1.078076×** | **1.053305×** |

Thus the point-weighted average time deficit falls from 12.9% to 7.0%, while
source weighting shows a 7.8% remaining deficit. Fifteen points are faster than
TypeScript, 34/45 lie within ±10%, and 39/45 within ±20%. The slowest relative point
is a Mandelbrot grid variation at 1.911888× TypeScript; average near-parity is not
per-program parity or a claim about every possible Bend program.

Twelve points regress against direct06, all by less than 3.4%. Evening is the
largest at 3.3899%; the other regressions are retained in the complete table.
Six descriptive role/point flags remain: candidate fold8192, candidate
expression128, candidate records256, and TypeScript closures256, list512 and
records64. No row is excluded. These are round-spread/half-drift observations,
not confidence intervals, and unflagged measurements do not prove JIT convergence.
The corpus informed development and is not an untouched holdout.

Distinct emitted module bytes, including runtime and the complete-row observer,
fall from 1,053,920 to 1,046,375 (about 0.72%). TypeScript totals 543,407 bytes. There
are 24 distinct used modules for 23 sources, because the observer is separate.
This is generated-source size, not optimized machine-code size or compiler LOC.
Compilation, import and first calls are separate from the timed steady workload.

## Causal screen and syntax evidence

The correction/default-only baseline leaves speed effectively unchanged:
1.001759× improvement over direct06 in its paired eight-point screen. Its API
hash is unchanged, but its runtime/driver hashes differ; all identity bindings
therefore include the whole compiler configuration.

The ordered optimization's own eight-point comparison holds that corrected
runtime and driver identical. It measures **1.068387×** speedup across 72 fresh
samples in 57.503 seconds, exceeding the prewritten 1.05 threshold with no point
regressing more than 10%. Mandelbrot, local pair, edit distance and active ray64
improve 12–17%; Morning and closures64 regress 5.01%/3.78%. This causal screen has a
different denominator from the final full45 table above; the two are not pooled.

A separate 0.11-second [syntax census](generated-shape.md) finds 202 primitive call
sites and 30 wrapper declarations removed across four inspected modules, replaced
by 256 ordered holds. Mandelbrot and raytrace arithmetic-operation counts match
pinned TypeScript in the examined functions. These are static counts, not
allocation measurements or proof of a particular V8 optimization mechanism.

## Correctness, interfaces and limitations

| Gate | Selected result |
| --- | --- |
| Checked build | Equality-derived B1; 36 strict frontend witnesses |
| Original independent direct semantics | **96/96 candidate**, 95/96 TS/differential; 29 freshly checked fixtures |
| Numeric/cold controls | **34/34 candidate**, 28/34 TS; six healthy reference NaN-source failures retained |
| Composed order / genuine overapplication | **18/18 + 2/2**, both roles, exact values/errors/events |
| Maintained JS census | **26/26 agreement**: 18 runtime passes, four expected rejections, four N/A |
| Maintained compatibility suites | **8/8** with explicit legacy selection where assertions require that ABI |
| Full benchmark | **45/45 outputs; 669/669 samples** |
| Installed and relocated interfaces | **42/42 legacy + 24/24 default/legacy**, integrity, relocation and tamper controls pass |
| Installed direct-row acquisition / portable replay | **1/1 complete-row oracle; 3/3 portable cases, 27/27 samples** |

These inventories overlap; they are not a summed unique language-test count.
The [selected semantic receipt](../../selfhost/tools/performance/phase53/semantic-qualified-ordered02-v1.json)
binds all six completed semantic scopes. New strict controllers independently
check healthy execution, outcome, value/error and events, preventing matching
assertion failures from masquerading as agreement.

The first maintained compatibility run failed because two test scripts requested
the newly changed default but asserted legacy code structure. Four requests now
explicitly select `backend:'js'`; all assertions and frozen compiler bytes remain
unchanged, and the fresh eight-suite run passes. The original failure is retained.
The generic benchmark acquisition also needed a direct-aware entry point because
its old complete-row observer expected legacy fields. The additive
[prepare-direct.py](../../selfhost/tools/performance/programs/prepare-direct.py)
forwards the already qualified direct acquisition method; pinned historical
producers remain unchanged.

The [installed-release receipt](../../selfhost/tools/performance/phase53/evidence/installed-release.json)
binds the selected image, ordinary and relocated CLI checks, tamper rejection
and the complete-row probe. The first legacy release attempt encountered six
sandbox Clang spawn refusals; its unchanged retry passed all 42 checks. Both
attempts remain preserved. The
[portable replay](../../selfhost/tools/performance/phase53/evidence/portable-replay.json)
checks RLE, Morning and numeric recurrence from the published bundles.

Direct call analysis still caps 512 conservatively eligible runtime definitions
before exact emitted pruning. [The scaling audit](scaling.md) explains why simply
raising that cap is insufficient. This is a checked B1 derivative, not a newly
qualified direct self-emitted fixed point. Broader native/GPU/proof validity,
compiler-throughput parity and arbitrary replaced host-hook equivalence remain
separate. Pinned upstream stays `018751270e800bc222a93dad7f257083ee53a5f7`.

## Source and iteration cost

[Source accounting](complexity.md) records **26,151 physical / 21,523 code Bend
lines**, 3,004 definitions, 99 types and 103 modules. Compared with Phase52, the
change adds 361 physical lines (+1.40%) and 288 code lines (+1.36%), 47 definitions and
four small representation types. Only one old module changes; the other 100,
including all 92 pre-direct modules, are byte-identical. The direct backend now
occupies 11 modules and 2,034 code lines. Declaration counts are not concept counts.
Runtimes, host tools, tests, experiments and generated artifacts are separate.

The selected checked build takes 61.092 seconds and peaks at 1.513 GB process-tree
RSS. The two eight-point timing screens each take about 58 seconds. Final timing
alone takes 1,121.170 seconds (18.69 minutes), plus checked acquisition and smoke.
An automatic approval timeout delayed only the last batch launch; the one accepted
retry repeated no completed sample. This remains a relatively cheap narrow loop
and a deliberately longer integration gate. At the 00:09:58 UTC accounting
cutoff, 80.13 minutes had elapsed and recorded process intervals occupied
35.12 minutes. The remaining 45.01 minutes combine analysis, implementation,
review, documentation, orchestration and unrecorded work or idle time; they
cannot all be labeled waiting. Final packaging follows that explicit cutoff.
See [time accounting](timing-accounting.md) for the method and limits.

Heavy targets are serialized on CPU 3 with a 1 GiB Node heap, a 2 GiB process-tree RSS and a
4 GiB available-memory floor. Agents independently handled lowering, controls,
routing, measurement, code-shape analysis, review and packaging. Compression
waits until clean timing finishes. Failed builds/harness attempts and superseded
sources are preserved. No PR comment was posted.

## Best next experiments

1. **Numeric match tables.** Five raytrace Nat→F32 helpers still use 40 comparisons
   and repeated float work where TypeScript initializes five short tables once.
   [The audit](table-opportunity.md) defines a general scalar-table experiment,
   with NaN payload and observable-demand controls. Do not copy upstream's
   incorrect bare-NaN constant folding.
2. **Remove unnecessary loop structure.** Even acyclic helpers retain loop/block
   scaffolding and aliases. Preserve the singleton self-edge fact, then first
   test a saved-output ablation and V8 evidence. A speed benefit is unproven.
3. **Scale graph analysis before self-emission.** Replace repeated reachability
   with linear graph algorithms and retain explicit resource bounds, then measure
   compiler-sized inputs separately.

Finite F32 literals are already specialized, and Mandelbrot uses U32 fixed-point.
The inspected Mandelbrot/ray modules have no generated `f32_from_bits` calls;
repeating that proposed literal optimization would solve no present problem.

## Reproduction and publication

Use the [current benchmark recipes](../../selfhost/tools/performance/programs/README.md),
[fixed campaign plan](../../selfhost/tools/performance/phase53/PLAN.md) and
[publication recipe](../../selfhost/tools/performance/phase53/publication-plan.md).
The [publication index](../../selfhost/tools/performance/phase53/publication.json)
binds the installed release, semantic qualification, all-point results, portable
bundles, replay, accounting and one closed raw archive. The archive retains
failed attempts, rejected proposals and complete source/process snapshots.
All 135 portable point/role mappings match the measured acquisitions. Published
replay bundles work from a normal clone; detailed historical paths in receipts
identify members of the closed raw archive.
