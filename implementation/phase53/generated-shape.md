# Phase53 generated-code shape

Ordered02 removes all **202 static calls to primitive wrappers** and all
**30 primitive wrapper declarations** in the four inspected modules. It replaces
computed operands with 256 statement temporaries and expands the existing
intrinsic templates. These are counts of emitted syntax across modules, not
dynamic call counts, sampled hot-path coverage or proof of V8 inlining.

The data-only [producer](../../selfhost/tools/performance/phase53/generated-shape.py)
reads saved corrected01, ordered02 and pinned TypeScript modules. It verifies
module hashes, source/point identities and the primitive catalog, then scans
generated named function bodies while excluding strings and comments. It does
not import or execute JavaScript. The CPU0 census completed in approximately
0.11 seconds; all input modules and manifests were rehashed afterward.

The complete machine-readable result is
`selfhost/build/phase53/generated-shape01/report.json`, SHA-256
`da8548b1a9a21b09569cd67df0e682cd0d1f869c59fda62a7c61c2671c65a924`.
Each function row records its source line, exact text hash, size and counts.
Both Bend roles embed the same corrected direct runtime:
`c328b77360c98489343d4752d4644d93f64de9d697d2c964f5fbae6442a77d23`.
The earlier F32 runtime correction therefore cannot explain their differences.

## Whole inspected modules

Primitive calls count direct references to the checked emitter's 89-operation
catalog inside nonprimitive generated functions. Declaration counts count each
module separately. `$ord` counts are unique declaration occurrences, including
reused names in separate scopes. TypeScript uses another naming scheme, so its
zero `$ord` count would not mean it has no statement temporaries.

| Source / point | Primitive declarations, before → after | Primitive call sites, before → after | New `$ord` holds | Library bytes, before → after | TS library bytes |
|---|---:|---:|---:|---:|---:|
| Mandelbrot | 7 → 0 | 51 → 0 | 60 | 32,626 → 32,194 | 15,442 |
| Local pair | 6 → 0 | 11 → 0 | 12 | 26,895 → 26,573 | 12,457 |
| Edit distance | 5 → 0 | 10 → 0 | 11 | 25,876 → 25,638 | 11,907 |
| Active raytrace | 12 → 0 | 130 → 0 | 173 | 53,409 → 52,162 | 29,926 |

Library bytes include runtime, exports and emitted metadata. Their difference
from TypeScript is not an optimized machine-code size comparison. The census
finds zero arrow expressions in the inspected nonprimitive function bodies in
both Bend roles; the expansion introduces no parameter-IIFE there.

## Representative arithmetic and array paths

In Mandelbrot's `mit`, six primitive wrapper calls become inline arithmetic
with six `$ord` holds. The body's lexical `Math.imul` count rises from three to
four, matching TypeScript's four: one multiplication moved from a wrapper into
the caller. This is not an extra multiplication introduced into the source
algorithm. `asr8` similarly replaces its remaining `U32.or` call with two held
operands and the bitwise template. The source helpers `asr8`, `sel` and `b2u`
remain ordinary functions.

The edit-distance `cell.f4` path used to call `Array.set` with a computed index
inside the returned `Dp` constructor. It now holds that index and emits the
same assignment/comma template in the constructor field. `cell.f2` holds its
computed index and emits the existing tuple/read template directly as the
next helper's argument. The `Dp` and `Tuple` representations and the ordinary
helper calls remain; this pass does not perform aggregate elimination.

In active raytrace, `isect5` loses six primitive wrapper calls and gains twelve
holds. Its visible `Math.fround` occurrences become 17, exactly TypeScript's
count for that function. `trace` loses 63 wrapper calls, gains 81 holds and now
contains 111 `Math.fround` plus two `Math.sqrt` occurrences, also matching the
pinned function's counts. Again, operations formerly inside wrappers have
moved into the caller; equal lexical counts do not prove equivalent optimized
control flow or latency.

| Generated function | Primitive calls, before → after | New `$ord` holds | All `const` declarations: corrected / ordered / TS |
|---|---:|---:|---:|
| Mandelbrot `mit` | 6 → 0 | 6 | 30 / 36 / 21 |
| Mandelbrot `asr8` | 1 → 0 | 2 | 1 / 3 / 2 |
| Edit distance `cell.f4` | 1 → 0 | 1 | 12 / 13 / 4 |
| Edit distance `cell.f2` | 1 → 0 | 1 | 8 / 9 / 3 |
| Raytrace `isect5` | 6 → 0 | 12 | 18 / 30 / 16 |
| Raytrace `trace` | 63 → 0 | 81 | 134 / 215 / 145 |

The generated source lines are recorded in the raw report. Examples in the
ordered modules begin at `mandelbrot.mjs:488` (`mit`), `editdist.mjs:515`
(`cell.f4`) and `raytrace-active.mjs:520` (`isect5`), under
`prepared-checked-ordered02-screen8/modules/`.

## What remains, and what this evidence does not establish

The emitted code still has more parameter aliases and local declarations than
TypeScript. V8 may eliminate some or all of those; this census supplies no
reason to predict a speedup from deleting them. The five raytrace scalar scene
functions `sx`, `sy`, `sz`, `sr` and `skr` also remain branch chains, while pinned
TypeScript emits short table lookups. Ordered lowering removes their wrapper
calls but does not add constant folding or numeric tables. Any table experiment
needs its own source-value, NaN-bit and observable-host-demand qualification.

The maintained eight-point screen independently reported a 1.068387× geometric
speedup and passed its prewritten gate. That is timing evidence for the complete
candidate, not an allocation of time saved to these 202 sites. This report has
no profiles, tier traces, machine-code inspection or evidence of a particular
V8 optimization mechanism. Full-corpus performance and semantic qualification
remain separate gates.
