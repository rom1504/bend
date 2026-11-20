# Closed numeric loops: a substantial Mandelbrot opportunity

The first exact whole-program screen reduced Mandelbrot time by **24.35%** with a compact scalar loop and **37.19%** with an additional absorbing-escape exit. This is a generated-machine diagnostic. The general escape rule subsequently passed independent checking and focused actual-product controls; its measured results and the newer stable-orbit follow-up are recorded below. Broad compiler qualification remains separate. All six paired observations favor both candidates. One baseline observation was unusually slow; the complete observations are retained and independent repetition is needed.

| Role | Median within-round time / regenerated x86 |
| --- | ---: |
| Actual qualified N1 | 0.99346 |
| Compact typed scalar loop | 0.75646 |
| Compact scalar plus absorbing escape | 0.62806 |
| Existing QBE | 0.68788 |
| Mature Bend C | 0.28397 |

The compact loop preserves every iteration and exact low-32-bit operations. LLVM-MCA / Ivy Bridge predicts 3,576 → 1,505 cycles over 100 repeated straight-line bodies, ratio 0.42086. Body instructions fall 109 → 27; reciprocal throughput falls 29.7 → 7.5. This is an exact proposed body, with original/current artifact pins, not a simulated whole-program speedup. The model does not predict early-exit frequency. The physical result, rather than a fabricated current profile weight, establishes that the worker matters.

The source is signed 8.8 fixed point carried in U32, **not F32**. All catalog Mandelbrot variations use this algorithm. Current x86 keeps expanded sign reconstruction and stack traffic around a closed scalar state. Actual QBE retains similar expanded operations. The mature C worker is scalar too; vector instructions elsewhere in its binary are not evidence of SIMD across pixels. Three exact disassemblies and ELF pins are in [evidence](evidence/).

[The pre-execution freeze](frozen.json) specifies the current source/object/ELF, complete before/after function bodies, model inputs, legality, expectations and inputs. The Phase197 emitted object equals the qualified Phase195 N1 object byte for byte. Changes affect only the `mit` worker, retain its actual ABI and callee-saved registers, and use existing whole-program callers and runtime.

The escape proof is specific and reusable: `esc' = esc | predicate` remains nonzero once nonzero; under that condition both complex coordinates and the returned iteration count retain their incoming values. Remaining loop bodies have no calls, loads, allocation effects, or external observations. Returning the count is therefore valid for any remaining countdown. All arithmetic shifts, products, comparisons and wrap points retain U32 semantics. This does not authorize early termination of effectful loops or floating arithmetic with observable exceptions.

Checks include 1,024 independently computed arbitrary states × original/compact/escape workers = **3,072 exact observations**, including zero counts, wraparound, signed boundaries and arbitrary nonzero escape masks. All six complete products also agree with independent C on five inputs, giving **30 whole-output checks**. Six rotated/reversed rounds use independent per-role calibration near 160 ms; pilots are excluded, and every timed result/count is checked. This remains finite validation, not a compiler correctness proof.

The entire guarded first job took about 8 seconds, including model, assembly/linking, finite controls, calibration and 36 timed observations. Construction/model/checks took 1.007 seconds. It is sealed completed at `selfhost/build-retention/phase198/numeric-screen01-close`; receipts and raw observations are copied in [evidence/report.json](evidence/report.json). CPU3 was handed off immediately. No production source, compiler image or installed selection changed.

## What is new, and the next compiler boundary

Phase120 already investigated signed-shift recovery for QBE. This experiment does not rename that as a new idea: it tests the full closed numeric state and a separate absorbing state, and the first result combines shift selection, allocation and loop-state transport. A frozen [original-loop escape ablation](escape-frozen.json) separates termination from compact instruction selection. The completed follow-up measured **0.69886** for that escape-only change (30.11% less time, all six pairs), and reproduced compact scalar at **0.75411**. All 3,072 arbitrary-state and 30 complete-output checks passed again. [Raw follow-up](evidence/escape-report.json).

A general Bend rule should accept a pure U32 countdown loop only after a certificate establishes:

1. Assuming one mode parameter is nonzero, abstract evaluation proves the next mode remains nonzero.
2. Every other nonfuel state returned by the backedge aliases its incoming state; the fuel has the recognized countdown predecessor.
3. The zero-fuel return depends only on those stable values, not on the changing mode or fuel.
4. Both the evaluated operations and discarded paths meet an explicit effect-free whitelist; unknown operations or branch joins refuse the rewrite.

This requires a nonzero-mode fact plus alias/constant evaluation through the actual nested scalar branches. Phase198's separately developed BST rule accepts a simpler pure branch immediately before a backedge and does not yet provide this certificate. A guard on the mode can then jump to the existing return. General loop placement and typed-word selection remain separate mechanisms and must not be credited to the early-exit rule.

SIMD across pixels is a plausible larger follow-up, because pixels are independent and have a uniform iteration bound. It requires exposing a bounded map through both histogram and recoloring traversals, preserving modulo-32 reductions and lane masks, and an ISA/fallback boundary. A four-lane kernel alone would not establish whole-program SIMD benefit. No SIMD performance or implementation claim is made here. The scalar root cause already warrants attention before adding that substantially larger mechanism.

## Typed entry and acquisition cost

The read-only capture binds the existing compiler's `P113DFunction` entry and normalized scalar body to **byte-identical whole-program assembly**. It confirms one `N_Imm64` fuel and six `N_W32` fields, retaining the metadata needed to distinguish low-word identities from arbitrary ABI words. [Entry metadata and raw capture pin](evidence/mit-typed-entry-summary.json), [normalized body](evidence/mit-ir.json), [identity receipt](evidence/capture.json).

The first attempt exceeded its explicit 12-second capture cap, producing no usable IR or ablation. It is preserved as failed, without claiming a pass. With an adequate cap, the repeated capture took about 17.4 seconds; Base preparation, source planning, native preparation and final selection are separately recorded. The full successful follow-up guard took 26.224 seconds, including the 8.597-second ablation screen. Both jobs are closed, and their failed/successful receipts are retained.

The staged `numeric.bend` and `hook.bend` implement bounded abstract evaluation over the actual IR, retaining parameter-kind metadata at the direct worker entry. They require canonical N_W32 fields, full-width countdown tests/subtraction, a nonzero mode invariant and identity of every other nonfuel backedge field. Effects, width loss, changing state, unsupported branches and excessive bodies retain the original body. The escape-rule version passed independent checking in numeric-api03; numeric-affine.bend and affine.bend stage its stable-orbit extension, which requires a new check. Neither is in the live manifest.

The independent [source incidence evaluation](incidence.json) finds 71.43% frozen iteration bodies on the ordinary point, 32.37% on the complete-viewport grid4/7 point and 68.63% on grid5/31. Those are source evaluations, not sampled hardware weights or predicted runtime percentages. Focused checked-rule timing for all four points is recorded below.

## Checked compiler rule and actual products

`numeric-api03` independently checked source06 (SHA256
`2b535836fe5260150388124c1d9d623ef2ae1f9f53b2c6fbc18fe873503eec4b`).
The preserved v1 module is `evidence/numeric-v1.bend`; the metadata hook ends at
`x185_function_copied`, retaining the common absorbing/permutation selector tail.
`numeric-products01` passed 23 acceptance/refusal controls, 1,031 independent IR
interpretations, and 9,720 independent abstract-fact observations, and completed
all four actual emissions. Its first timing harness stopped at an overstrict
historical whole-object assertion. No output mismatch occurred. The repaired
`numeric-products02` reuses those emissions and controls, pins actual current
`native45-02` products, and proves the historical/current `mit` worker is exactly
the same 627 bytes in all four cases (`worker-identity.json`).

The repair passed 52 complete output checks and acquired 96 timed observations
(six rotated paired rounds, separate per-role calibration, fresh processes), in
21.836 seconds. Median checked-rule/current ratios:

| Case | Numeric/current | C/current | QBE/current |
|---|---:|---:|---:|
| Mandelbrot | 0.755151 | 0.285520 | 0.697304 |
| Grid 4/7 | 0.818996 | 0.343959 | 0.567369 |
| Grid 5/31 | 0.412071 | 0.423234 | 0.636232 |
| Scalar 8192 | 1.114217 | 0.426067 | 0.743892 |

All six numeric pairs favor the candidate for each grid/Mandelbrot case. Scalar
is an explicit negative transfer: its seed 524800 gives zero coordinates and a
never-escaped orbit, so the escape guard cannot skip work; five of six pairs
regress. Do not promote a whole-suite claim from these focused measurements.
The new guard also changes register placement and retains a redundant inner fuel
test, explaining why the original-machine early-exit ceiling overstates transfer.

The follow-up `affine.bend` stages a separate general fixed-state certificate.
It requires pure state/control independent of both counter and fuel, a U32
counter with coefficient one, and exact full-width decrement. After executing one
ordinary transition it compares all other next/current state words, and, if equal,
returns `nextCounter + low32(pred) * (nextCounter-counter)` modulo U32. The guard
is over actual state equality, with no seed, function-name, or zero-coordinate
recognition. It composes with escape absorption; its checking and timing remain
separate from the completed v1 results above.

The stable-orbit extension passed independent checking as `numeric-api04` in
14.876 seconds. Its immutable source09 is 1,862,877 bytes, SHA256
`550b513b446c5b45ed1fdf0e7fcab11e9f45b7b15a582baa4251a50c6fffb875`.
Use `numeric-affine.bend`, `affine.bend`, and unchanged `hook.bend` for this
version; `numeric.bend` and `controls.mjs` were restored byte-for-byte to the
measured escape version so old audit pins remain valid. The new controls live in
`controls-affine.mjs` and are not yet executed. The two-case plan02 has unchanged
preparation closure (4,081 declarations / 1,367,502 bytes), with actual ordinary
Mandelbrot and scalar8192 products queued after the shared qualification window.
No stable-orbit performance or semantic-control pass is claimed yet.
