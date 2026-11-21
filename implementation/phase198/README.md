# Direct x86 program runtime against mature Bend C

The target is the runtime of complete Bend programs compiled to direct x86 ELF. The reference is the mature self-hosted Bend C backend. Both execute the original benchmark source and inputs. Native45 contains 45 correctness cases, of which 44 do nonzero work and count toward the geometric mean. Each measured program reports its full expected output, completed warmups, repetitions and elapsed time. Calibration and linking sit outside program runtime.

## Full native45 result

The fastest measured configuration took **1.27813× mature Bend C runtime**. Against the incumbent on the same CPU in the same session, geometric program time fell **30.64%**. The native45 result alone would overstate the breadth of the progress. Excluding the single benchmark whose fixed point dramatically shortens execution, geometric time fell **16.47%**, from 1.83610× to 1.53373× C. The families outside the studied compiler transformations changed by 0.15% collectively.

| Full suite measure | Phase197 | New compiler, original runtime | New compiler, live constructor runtime |
|---|---:|---:|---:|
| Geometric runtime / C | 1.84264× | 1.28731× | **1.27813×** |
| Geometric runtime / C, omit scalar-8192 | 1.83610× | 1.54620× | **1.53373×** |
| Original fixed-batch runtime | 22.59 s | 19.55 s | **19.31 s** |
| Fixed batch / C | 2.188× | 1.894× | **1.871×** |
| Above 1.1× C | 37 / 44 | 35 / 44 | **34 / 44** |
| Above 2× C | 26 / 44 | 22 / 44 | **21 / 44** |
| Mean positive log-slowdown | 0.7390 | 0.6402 | **0.6318** |

All four roles passed complete-output checks in 624 pilot and 720 timed observations. The same-object live runtime saved 0.71% geometrically in this run. Four rounds and dispersion above 10% on 23 cases limit individual small timing claims. [Per-case, independent reference and raw evidence](../../research/phase198/runtime-broad/orbit-summary.md) · [Family split and denominator audit](orbit-breadth.json)

## What removed work

- A checked affine consumer can accumulate a recursively generated expression as a pair of modular coefficients. At expression depth 128 it eliminated the intermediate tree entirely and used 14.0% of the previous x86 time. A separate invoice datatype, with different constructors and arithmetic, used 21.2%. [Recognition, transfer and limits](../../research/phase198/fusion/results.md)
- A checked pairwise tree worker carries pending child pairs locally and eliminates continuation-scheduler round trips. The real native object dropped from 48 instructions to nine for scheduling an internal-node pair. Ivy Bridge LLVM-MCA modeled reciprocal throughput of 14 and four cycles respectively. Independent dynamic counts found 2,815 relevant descents. The fully generated tree sort took 51.3% of incumbent x86 time and 1.709× C time. [Hardware model and literal machine bytes](../../research/phase198/reuse/mca/results.md)
- Two countdown rules recover information lost at backedges. One recognizes an absorbing value under a checked branch, eliminating work in BST search and an unrelated queue. The other uses an invariant state and a word accumulator to skip the remaining iterations after an observed fixed point. It admits only the supported pure operations and verifies the induction and return shape. Ordinary Mandelbrot gains principally from escape recognition. The 8,192-step scalar case actually stabilizes, so it is unusually favorable. [BST and queue](../../research/phase198/absorbing/) · [Numeric rule and controls](../../research/phase198/numeric/)
- The serial constructor fast path keeps live descriptor reads and separates common raw construction from shared/packed cases. Caching descriptor fields at bind time was faster on the benchmark but failed a foreign metadata mutation control. The live variant passed that control. It can be linked independently with the same compiler-emitted program objects. [Runtime comparison](../../research/phase198/runtime-broad/summary.md)

## Intermediate broad result and cost

Before the fixed-point extension, the independent native compiler and the constructor runtime together took **1.54663× C time**. The first five-rule compiler with the original runtime took 1.57487×, versus 1.87495× for Phase197 in the same four-way run. The fixed batch fell from 22.90 to 19.72 seconds versus 10.31 seconds for C. Source-rule gains were concentrated in the studied semantic families. [All cases and transfer partition](checkpoint.md)

The frozen fixed-point source contains 44,321 lines and 1,942,906 bytes in its selected direct x86 profile. Phase197 had 42,690 lines and 1,858,809 bytes. The new source adds 214 reachable declarations and changes five original definitions. Across the 45 identical source files, compiler-to-object wall time was 77.47 seconds versus 77.30 seconds for Phase197. Process CPU time was 75.57 versus 76.24 seconds; the maximum per-request RSS was 57,680 versus 57,216 KiB. These are one-pass cost observations from separate catalog runs. QBE-to-N1 cold compiler acquisition took 179.36 seconds versus 177.17 seconds for the earlier source. [Same-request compiler cost](orbit-compiler-cost.json) · [Clean source replay](../../research/phase198/maintenance/checkpoints/orbit-portfolio03/replay.json)

## Which programs did the compiler actually change?

Comparing the incumbent and the new compiler using the **same original runtime**, exactly **12 of the 45 program objects changed**. Eleven of those cases have nonzero timed work. On those eleven, the new compiler took 0.2415× the incumbent's time geometrically. On the other 33, both the object bytes and loaded executable sections, including layout, were identical. Those 33 measured 0.9955× incumbent time with the original runtime and 0.9985× with the live runtime. The largest measured regressions on the live variant were closure-64 (+19.4%) and generic edit row (+18.0%). Both had identical compiler output. On closure-64, the original-runtime pair measured 0.994×. On the edit row, even the pair with identical loaded machine images differed by 14.1%. The four complete round scores for the live variant ranged from 1.269× to 1.280× C. Individual ratios require more caution than the suite score. [Object and executable comparison](identical-machines.json)

An independently written loop that never stabilizes exposed a **65.9% runtime regression** from checking for a fixed point every iteration. The revised Bend pass looks for a changing 32-bit state field in straight-line arithmetic. A certified nonzero add, subtract or XOR step suffices to skip speculation; wraparound does not invalidate that reasoning. With this change the cycling loop regenerated the exact original object and took 1.0021× incumbent time. Mandelbrot, scalar-8192 and an unrelated converging loop retained their exact earlier optimized objects. The screen exercised 45 admission examples, 1,346 independent interpretations, 9,720 fact checks, 80 complete outputs and 96 timings. More complex nonconverging loops can still incur the speculative cost. [Adverse case and repair](../../research/phase198/numeric/selective-results.json)

The revised selected source has 44,408 lines and 1,947,566 bytes, 229 additional declarations and five changed existing definitions relative to Phase197. Its independent source check accepted it with zero holes. A clean checkout reproduces the exact source and map and verifies the original source and maps for the other five profiles. [Corrected source replay](../../research/phase198/maintenance/checkpoints/progress-portfolio01/replay.json)

## Where the remaining time goes

Reaching geometric parity from 1.2781× takes another **21.8%** reduction across this set. Reaching fixed-batch parity from 1.871× takes **46.6%**. The lexer accounts for 10.5% of the remaining positive log-slowdown across all programs. Map churn accounts for 9.0%, scalar array folds for 8.6%, record aggregation for 7.9% and BST for 7.7%. As a counterfactual, bringing every slower member of those five families exactly to C and holding everything else fixed would put the geometric ratio around 0.97×, but the fixed batch would still take about 1.50× C time. Ray tracing contributes the largest share of positive excess *batch time* (11.8%). [Per-family time budget and assumptions](orbit-opportunities.json)

Several independent backend changes now have real localized timing evidence. A verified tail transfer removes 417 scheduler transitions and saves 12.3% on Map; the same transformation removes 1,026 transitions in the lexer and saves only 0.4%. Native constant-division lowering saves 3.6% on the lexer and 4.4% on record aggregation. Direct word operations save 2–4% on ray, Map and Unicode. These candidates were measured individually. Their effects can overlap when composed. General runtime PGO achieved only a 0.3% geometric difference across six evaluation programs. [Tail transfer](../../research/phase198/reuse/) · [Constant division](../../research/phase198/quotient-machine/README.md) · [Word operations](../../research/phase198/word-primitives/RESULTS.md) · [Ord selection](../../research/phase198/ordering/results.md) · [PGO ablation](../../research/phase198/reference-counts/results.md)

## Using the corrected compiler on the research machine

The actual native N2 is `selfhost/build/phase198/progress-native-self01/program`, SHA-256 `c32559bfa6a455c43dbba8ca4cf13a342229505aa0fd95a03df791c2625a3e4b`. From the repository root, the following builds a direct ELF object and links a program with the original runtime. Use a fresh output directory for each run.

```sh
python3 -B research/phase198/qualification/job.py progress-hello01 90 32 \
  python3 -B selfhost/tools/build/native.py \
  --assets selfhost/build/phase194/assets.json \
  --image selfhost/build/phase198/progress-native-self01/program \
  --image-receipt selfhost/build/phase198/progress-native-self01/report.json \
  --host native --stage N2 --target x86 --mode cache --emit object \
  --source selfhost/tests/fixtures/hello.bend --out selfhost/build/phase198/progress-hello01 --seconds 60
```

The 1.2781× runtime configuration uses the same compiler-produced object and the ABI11102 live-constructor runtime. The equivalent final link on this machine is shown below. The checked object, runtime and toolchain were pinned during the benchmark. The installed public launcher selects Phase189; these commands select the experimental image explicitly. The repository contains the source checkpoint and reproduction evidence. The materialized compiler and runtime are local build artifacts.

```sh
/usr/bin/x86_64-linux-gnu-gcc-10 -no-pie \
  selfhost/build/phase198/progress-hello01/program.o \
  selfhost/build/phase198/runtime-split-prepare01/runtime-live.o \
  -pthread -lm -o selfhost/build/phase198/progress-hello01/program-live
```

## Cost of the corrected version

The corrected N1 emitted the 45 objects from the identical source requests in **79.40 s** versus **77.30 s** for Phase197 (+2.72% wall, +2.05% process CPU). Maximum per-request compiler RSS was 57,644 KiB versus 57,216 KiB. QBE-to-N1 acquisition took 180.32 s. N1 built N2 in 312.70 s and N2 built N3 in 373.57 s. Phase197 took 288.06 s and 352.85 s on its own smaller compiler source. The latter comparisons include the cost of compiling the additional implementation. N2 and N3 emitted exactly the same 32,448,072-byte compiler object, SHA-256 beginning `b3a382d4600dcbb`. [Full per-request cost](progress-compiler-cost.json)

The fixed-point transformation applies to verified private word computations with a full-width countdown and a canonical 32-bit accumulator. Once the other fields repeat, the state-dependent accumulator delta repeats as well. The emitter computes the remaining contribution modulo 2³². Recognition rejects effectful operations, floating-point operations, division, incompatible exit shapes and temporary name collisions. The nonconvergence filter can decline an optimization whenever it finds evidence of changing state. Independent finite checks, source checking and native reproduction establish different properties; end-to-end correctness for arbitrary programs remains open.
