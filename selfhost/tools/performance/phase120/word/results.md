# Phase120 signed-word pilot: results and rejected variants

Retain the signed-word identity plus explicit word-width rendering as the
candidate for integration. Exclude both Boolean variants: the first produced
invalid IR and triggered safe fallback; the corrected variant demonstrated no
additional runtime benefit. Production/native selection is outside this pilot.
All executions and receipts below were produced by the parent serial target
lane. This note only reads existing evidence.

## Retained evidence

Word13 composes `model07.bend`, `controls.bend`, `word-width.bend`, and
`word-width-controls.bend` onto Phase118 safe03. Its compiler source hash is
`a5e15a6a38b48daf3b2acf17260f423cd1accedf54ea63e04dd7113a3876da99`;
`selfhost/build/phase111/p120-word-api13/report.json` records a complete checked
API. The preparation manifest alone says checked=false and is not the check
receipt. Only `p114s_ranges` and `p113w_look` are overridden.

Three-round internal elapsed medians from
`selfhost/build/phase120/word-scalar-screen13/report.json`:

| Workload | Qualified Phase118 | Word13 | Pinned upstream | Word13 / parent | Word13 / upstream |
| --- | ---: | ---: | ---: | ---: | ---: |
| scalar-region-8192 | 429 ms | 299 ms | 199 ms | 0.697 | 1.503 |
| mandelbrot | 800 ms | 717 ms | 199 ms | 0.896 | 3.603 |
| numeric-recurrence-1024 | 417 ms | 416 ms | 201 ms | 0.998 | 2.070 |

All screen outputs/counts passed the existing oracle. The improvement transfers
between two related Mandelbrot workloads; the unrelated recurrence control is
neutral. This is not evidence of broad workload parity or independent transfer
to a second algorithm family. The upstream products are the pinned retained
reference, not current upstream head. These are generated-program runtimes,
not B1/B2 compilation timings or native compiler qualification.

The first measured model03 already reduced scalar431→313ms and
Mandelbrot807→718ms. Its retained machine report shows scalar mit122→90 decoded
instructions,7→4 setcc and four remaining conditional branches. The missing
capability was recognizing an exact signed32 shift identity from unsigned
operations, not adding SAR support to QBE (which already had it).

Word13 then projects the verified three-instruction U64 identity to `=w sar`
followed by explicit `=l extuw`. The retained native assembly
`selfhost/build/phase111/p120-word-scalar13-scalar-region-8192-build/program.s`
contains three `sarl $8` sites in mit, replacing the three `shlq $32` / `sarq $40`
pairs from word03. The loop remains call-free. The scalar screen improves
313→299ms across the two runs; Mandelbrot718→717ms is effectively unchanged.
This cross-run difference is descriptive, not a precise isolated confidence
interval. `word-width13b.json` records all17 exact-emission/shape controls
passing. The independent ordinary boundary fixture also passed in the parent
lane; its inputs and literal expected outputs remain in this directory.

## Negative findings and cost of iteration

Earlier source modules remain preserved rather than overwritten:

| Module | Outcome |
| --- | --- |
| model.bend | Match of stmt after later scan binder rejected; API01 stderr retained. |
| model02.bend | Duplicate seed counter lacked + annotation; API02 stderr retained. |
| model03.bend | First checked, measured identity implementation. |
| model04.bend | Inferred law-backed parameters cannot use untyped + prefixes; API04 parse failure. |
| model05.bend | Repeating a typed signature for the law-backed definition failed parsing; API06 failure. |
| model06.bend | Local duplication before matching body violated structural-match ordering; API09 failure. |
| model07.bend | Root repaired helpers to match the parameter first, then duplicate flags in the Con arm; included in checked word13. |

These avoidable syntax/checking cycles consumed research budget. They did not
reach native execution and are not semantic successes. Future helpers should
copy an exact checked law/definition pattern and exercise the smallest checked
API before composing further candidates.

The rejected Boolean version01 incorrectly equated result representation with
operand representation. An N111Bin U64 comparison reads U64 and produces U32;
a replacement U32 copy/XOR cannot read that same U64 local under
`p111v_value`'s exact-width contract. `p113k_function` also runs after inlining,
so independent verification rejected both the inline candidate and range
candidate. Correct fallbacks preserved all outputs while restoring expensive
calls. In mit, word13 has three SAR and only the failure call in IR; word14 has
zero SAR and seven ordinary calls (three asr8, two b2u, two sel) plus that failure
call. This explains scalar1633ms and Mandelbrot1808ms in
`word-scalar-screen14/report.json`, versus word13's299/717ms. The eleven original
shape controls were insufficient because they did not verify complete IR.

Version02 preserves operand width and normalizes only proved eq(x,1)→ne(x,0)
and ne(x,1)→eq(x,0). It passes fourteen controls, including full-function
verification before/after and exact rejection of the old invalid copy. It also
passes ordinary outputs. However, `word-scalar-screen15/report.json` records
scalar301ms, Mandelbrot721ms and recurrence418ms, compared with word13's
299/717/416ms. No additional benefit is demonstrated; exclude it for simplicity.
`word-boolean15.json` retains the passing controls. No verifier was weakened.

## Compiler cost and next opportunities

`selfhost/build/phase120/word-stage13.json` times a fixed prepared Mandelbrot
checked graph with one warmup and three measured rounds. Medians:

- Signed-word analysis: **2.368 seconds**.
- Its independent verification: **0.519 seconds**.
- The preceding range pass:0.864 seconds and its commit0.536 seconds in this
  diagnostic's initial preparation (single observations).

The repeated analysis plus verification costs about2.887seconds; analysis is
about82% of that sum. These are hosted stage diagnostics, not whole compilation,
not native B1/B2 performance, and not independent medians of a full research
loop. All measured candidate commits were accepted. This evidence argues for
reducing analysis work before optimizing validation.

Ranked next cost experiments, not implemented here:

1. **Remove quadratic environment maintenance.** `p120w_put` filters and rebuilds
   the whole binding list at every definition; lookup and joins also scan lists.
   Reuse an indexed persistent map for current name facts, with explicit current
   identity checks when locating a surviving origin alias. Preserve overwrite,
   branch and invalidation controls and require exact emitted QBE. Measure this
   on the existing prepared graph first; no full compiler build is needed.
2. **Make the necessary-condition prefilter more selective.** Current model07
   admits any function containing shr and or. A sign-producing shr must have
   right operand literal31 or a Local whose fact may prove31; other literal
   counts and nonlocal symbols cannot produce the required fact in this domain.
   Refuse more impossible functions without changing successful rewrites. First
   count admitted functions and analysis time; do not infer hotness from counts.
3. **Share range-derived facts or fuse successful commits only after profiling.**
   Constant/width/copy work overlaps the preceding range pass. A small shared
   prepared summary may remove repeated analysis, but extending the domain must
   justify its complexity. A combined range+word commit could avoid one full
   successful verification while retaining separately verified range fallback
   on rejection; it needs an explicit compositional proof and unchanged output.
   Merely deleting verification is not an acceptable optimization, and saving
   the0.519s verifier cannot address the dominant2.368s analysis.

Preserve the inexpensive algebra/IR-boundary controls, inspect actual emitted
machine code, and make one cost change at a time. There is no evidence here for
another backend, a new IR, broader speculative search, or retaining the neutral
Boolean pass.

## Late cost-only refinement: retained as an unselected experiment

The narrower three-bit syntax filter is checked as word18 using
`prefilter09.bend` and `prefilter09-controls.bend`. Earlier word16 lost required
law declarations during whole-declaration replacement; word17 lacked an explicit
control-constructor type. Both failed check receipts remain. Word18 passes13 new
filter controls,14/60 existing word controls and17 width controls, with exact
three-case QBE identity. Mandelbrot analysis falls2.368→0.966s; ray analysis
0.0565→0.0167s while ray verification remains about1.43s.

Combined03 then reproduces the exact45+6 products, but its complete four-case
cost is1.20558×parent versus combined01's1.17954× in separate paired screens.
No aggregate cost gain is demonstrated. The final recipe therefore retains
combined01/model07, and preserves the narrower filter as unselected. Stage
improvement alone does not justify a general research-loop speedup claim.
