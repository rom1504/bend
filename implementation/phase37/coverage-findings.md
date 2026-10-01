# Phase37 coverage findings before optimization

The expanded suite exposes performance behavior that the historical fifteen
points did not show. Both reference compilers check all **23 source files** and
agree with the selected exact outputs. This establishes a usable broader
baseline before changing the compiler; it does not establish full language or
production-workload coverage.

This report currently contains the completed reference acquisition, untimed
correctness gate, fourteen input/workload-variation measurements and ten new
development-application measurements. The root will add the remaining historical,
heldout and candidate results separately. No candidate improvement is claimed here.

## Frozen inventory and correctness

The [catalog](../../selfhost/tools/performance/phase37/catalog.json) has **45
points**: fifteen historical points, fourteen additional input/workload variants,
and sixteen points across eight new application families. The sources comprise
thirteen historical files, two appended-wrapper variants and eight new-family
files. Thus the inventory has 21 historical/new source families but 23 concrete
source files, because the extra Mandelbrot and ray wrappers each form a separately
compiled file. This accounting does not assert that all 21 families are independent
applications: the historical group includes diagnostics derived from other
algorithms. Two input points are not two independent programs, and the extra
wrappers are not independent algorithms.

The historical catalog remains byte-identical. The expanded Phase37 comparison
uses the Phase36 checked03 API
`93e55ad7ee456eebb5fa3dd9606c2cf262ea386c6f66bfd891ffe187d8f50a75`
and the unchanged TypeScript pin
`018751270e800bc222a93dad7f257083ee53a5f7`.
Both [Bend preparation](../../selfhost/build/phase37/baseline01/manifest.json) and
[TypeScript preparation](../../selfhost/build/phase37/typescript01/manifest.json)
are complete, with one emission per distinct source and all forty-five points
bound to those emissions.

The [Phase36](../../selfhost/build/phase37/baseline01/preparation.json) and
[TypeScript](../../selfhost/build/phase37/typescript01/preparation.json)
preparation receipts sum to **113.975 seconds for Phase36** and **17.378
seconds for TypeScript** across the 23 serial source processes. Those totals
include process startup, compiler import, provenance verification, source
checking and JavaScript emission; they are workflow acquisition costs, not pure
emission or steady-state compilation throughput. They are excluded from all
generated-program execution measurements below. Receipt-internal acquisition
timers sum to 111.331 and 14.806 seconds respectively; the difference includes
outer process/supervision overhead. Preparation peaks are 511,811,584 bytes for
Phase36 and 184,086,528 bytes for TypeScript. A normal checked-request compiler
benchmark remains a separate experiment.

The [untimed correctness gate](../../selfhost/build/phase37/correctness01/report.json)
passes **154/154 observations**, with zero failures or unrun observations:
45 catalog points plus32 small application controls, each executed through both
compilers. Small controls include empty, singleton and mixed inputs. Its
[supervisor receipt](../../selfhost/build/phase37/correctness-outer01/run.json)
records **7.439 seconds** and **204,349,440 bytes (194.9MiB)** peak process-tree RSS.
This is correctness execution with provenance verification, not a compiler-speed
or steady-state runtime measurement.

Existing goldens remain unchanged. New integer-algorithm reference calculations
are independent Python code, cross-checked against four historical upstream
goldens. New application references use different representations and algorithms
where practical. The two new ray expectations are frozen checked-TypeScript
differential results, explicitly not an independent F32 reference. Most results
are digests that can collide; Unicode and record aggregation observe complete
returned strings. All internal representations and semantic boundaries still
need their own optimizer controls.

## Completed variation measurements

The [fourteen-point reference run](../../selfhost/build/phase37/variation-reference01/report.json)
passes all selected outputs and completes **140 samples** in **183.543 seconds**
under the300-second ceiling. Each point has five fresh serial rotations of
TypeScript and Phase36, with at least three warmup calls and600ms warmup, then
calibration and a250ms target timing block. Import and first-call costs are
recorded separately. No historical median is used as a denominator.

The active-ray workloads are particularly informative:

| Point | Actual measured work | Phase36 median | TypeScript median | Phase36 / TypeScript |
|---|---|---:|---:|---:|
| `variation-ray-active-64-2440` |64 consecutive pixels from linear index2440 in the80×64 viewport |22.3975ms |0.300857ms |74.446× |
| `variation-ray-active-256-2240` |256 consecutive pixels from linear index2240 in the same viewport |106.506ms |1.24726ms |85.392× |

Every sampled position calls the original pixel geometry, shadow and bounce
computation, including four subrays. The wrapper hashes outputs in order. This
removes the original benchmark's large population of inactive column probes and
changes the position distribution. The historical complete raytrace workload
had a23.47× gap in Phase36; these are **different workloads**, not evidence of a
new regression or a direct before/after speed ratio. The larger gaps demonstrate
why the prior full-image checksum was insufficient to summarize ray computation
performance. They motivate inspection of the active computation; they do not
identify the cause by themselves.

The larger active-ray point also retains material within-block variation:
Phase36's second timing halves are **27.64% to33.30% slower** than their first
halves across the five samples. Its complete-block medians and ranges remain
valid observations of the stated short protocol, but they must not be described
as stabilized V8 or long-running application performance. The TypeScript halves
range from−1.53% to+1.69%. A later claim about small gains on this point needs
explicit attention to this behavior rather than selecting favorable samples.

## Completed development-application measurements

The [ten-point development reference run](../../selfhost/build/phase37/development-reference01/report.json)
passes all selected outputs and completes **100 samples in 121.296 seconds**
under the 300-second ceiling. It uses the same five-round protocol described
above, comparing the unchanged Phase36 compiler against TypeScript. Each number
is a median per complete exported call, including exact-result validation and
the harness checksum; startup and first calls are recorded separately.

| Point `(size, seed)` | Phase36 ms | TypeScript ms | Phase36 / TypeScript |
|---|---:|---:|---:|
| Captured closures `(64,17)` | 0.0475154 | 0.00593780 | 8.002× |
| Captured closures `(256,123)` | 0.187208 | 0.0226126 | 8.279× |
| List pipeline `(128,17)` | 0.321711 | 0.00656926 | 48.972× |
| List pipeline `(512,123)` | 1.22934 | 0.0288456 | 42.618× |
| Unicode text `(16,17)` | 0.474216 | 0.0216276 | 21.926× |
| Unicode text `(64,123)` | 2.01512 | 0.0874681 | 23.038× |
| Map churn `(32,17)` | 13.1228 | 0.141576 | 92.691× |
| Map churn `(128,123)` | 76.6419 | 0.761228 | 100.682× |
| F32 recurrence `(256,17)` | 0.0394265 | 0.00198151 | 19.897× |
| F32 recurrence `(1024,123)` | 0.130912 | 0.00787899 | 16.615× |

These expose gaps in new computations rather than merely adding larger inputs
to already tuned algorithms. They still do not identify which generated-code
mechanism causes each gap: that requires separate profiles and controlled
changes. The two points within each family differ in both size and seed, so
their ratio is not a controlled size-only scaling experiment. Do not average
the slowdown column into an application-performance claim.

Both map-churn points retain consistent within-block change: the second halves
of the 32-key Phase36 samples are 11.91% to 16.73% faster, and those of the 128-key
samples are 9.84% to 11.05% faster. This is another reason to preserve the raw
samples and describe these as bounded warmed executions, not stabilized
steady-state throughput. Unicode observes the full string; map and list results
remain digests. The list input limitation below applies directly to its table
rows.

## A remaining input-diversity limitation

The new list pipeline improves coverage of allocation and composed list
traversals, but its seeds do **not** create distinct value distributions. The
generator advances a32-bit LCG and emits `seed %16`. Modulo16 its recurrence is

`next = (13 * current +15) mod16`.

The multiplier is1 modulo4 and the increment is odd, giving a full period of16.
Every complete cycle contains each value0…15 once. The selected lengths128 and512
are respectively8 and32 complete cycles. Changing the seed rotates the same
cycle; it changes order and starting branch positions, not the value histogram
or total filter selectivity. Removing0/1 and doubling the remaining values yields
238 per cycle, so the selected sums are1904 and7616 regardless of seed.

These points therefore establish size scaling and repeated traversal of the
same distribution. They do not establish varied selectivity, adversarial order,
high-entropy values or seed-sensitive checksum coverage. Short untimed controls
partly expose non-cycle prefixes, but they are not replacement performance
observations. Preserve this frozen selection and describe the limitation; a
future addition should use separately selected non-cycle lengths, different
value projections and explicit selectivity distributions rather than silently
changing these inputs after seeing timings.

## Scope of the stronger coverage claim

The expanded selection adds higher-order closure construction, composed list
passes, larger maps with replacement/deletion, Unicode text including non-BMP
characters, rounded F32 recurrence, irregular/skewed trees, unbalanced expression
trees and record aggregation. Varied original inputs broaden seed, scale and
active-work distribution evidence. These are purposefully chosen mechanism
samples, not a random or population-weighted sample of Bend programs.

The BST, expression and record-aggregation families remain held out from
performance tuning. Compiling them and checking semantic outputs before an
optimization does not consume that performance holdout; using their timings or
profiles to choose a subsequent change would, and must be disclosed.

The enlarged inventory still misses many interactions, large memory-resident
applications, realistic external IO/FFI, native execution, parallel/GPU behavior
and whole-compiler throughput. Most program families still have only two small
points. Full correctness suites remain separate. No average across these ratios
is used to imply typical application speed, and no parity timeline follows from
this coverage expansion.
