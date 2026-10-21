# Phase121: eliminate constructions before lowering them

The new Bend compiler candidate removes private list pipelines and immediately
applied scalar closure chains. It reuses semantic checks from our JS backend and
the existing native scalar lowerer. The objective is to eliminate construction,
traversal and destruction together, rather than make their helpers slightly faster.

The same-run original45 comparison passes **405 output/count observations**.
Across44 timed points (plus the unchanged zero-work sentinel), geometric-mean
runtime improves **2.98762×→2.14395× pinned upstream C**, **28.24% less time on
that metric**. Equal weighting of the22 frozen families gives a similar28.22%
reduction and2.200× upstream. Three per-round ratios are0.7071/0.7191/0.7165;
these are descriptive screens, not confidence intervals.

**The gain is concentrated in four cases from two families.** The other41 programs
emit byte-identical QBE to Phase118. Summing the medians of the44 fixed batches
falls30,321→28,356ms, only **6.48% less total batch time**. Forty of44 timed points
remain more than10% slower than upstream. Thus the geometric score is substantially
better, but broad program parity remains unresolved; surplus speed on four cases
must not hide deficits elsewhere.

| Original benchmark | Phase118 | Candidate | Upstream | Speedup vs parent |
|---|---:|---:|---:|---:|
| List pipeline128 |682ms|32ms|201ms|21.3×|
| List pipeline512 |659ms|32ms|200ms|20.6×|
| Closures64 |354ms|5ms|197ms|70.8×|
| Closures256 |355ms|5ms|199ms|71.0×|

These short closure observations motivated the longer confirmation below.
The unchanged sources and runtime are authenticated; all four fast-screen QBE
outputs are byte-identical to their broad-run counterparts. The full emitted
QBE total grows39,447,110→39,467,748 bytes (+0.052%); this is text size, not memory.
[Results](results.json) retain every median, sample, family and exact-code bridge;
[candidate](candidate.json) pins the checked source/API/runtime.


[Design](../../design/phase121/construction-elimination.md) ·
[Semantic review](review.md) ·
[Backend guide](../../docs/self_hosted/native-fusion.md) ·
[Reproduce](../../selfhost/tools/performance/phase121/README.md).

## What changed, and why this cycle was different

Phase120 improved its 44-point runtime score by 3.76% while adding 17.95% hosted
compilation cost and 1199 compiler-source lines. We started from qualified
Phase118 and **did not combine the Phase120 numeric candidate** with this work.
The comparison parent, preserved runtime and qualification boundaries are explicit.

Phase119's profiles pointed to construction/take/extend work in list pipelines,
but sampled helper time was not assumed removable. We first changed ordinary
diagnostic source to test the attainable code shape. These source substitutions
were never counted as automatic compiler gains:

| Diagnostic source | Parent QBE median | Diagnostic median | Decision |
|---|---:|---:|---|
| List128: fuse only map/fold |678ms|474ms|Useful, but leaves most construction|
| List128: fuse whole pipeline |677ms|35ms|Implement general structural admission|
| Map32: fold ordered tree instead of materializing list |742ms|741ms|Neutral; stop|
| Closure64: explicit scalar countdown |355ms|21ms|Test unrelated-family transfer|
| Closure256: explicit scalar countdown |371ms|20ms|Same mechanism at larger input|

All comparisons use the original complete-result/count oracle and identical
input schedules and wrapper suffixes. These are three-round, CPU3 screens.
The diagnostic closure loop still uses the ordinary Nat path; the automatic
native loop additionally preserves the proven U32-bounded predecessor as a word.
That explains why the automatic result can outperform the diagnostic source.

The implementation adds two narrow capabilities:

1. **Private producer/filter/map/left-fold fusion.** Verify constructor owners,
   types, exact recursive shape, native primitive identity and total scalar
   expressions; emit one loop in original fold order. Shared or returned
   intermediates are outside this rule.
2. **Private closure construction/application fusion.** Verify the factory,
   exact `g(f(x))` composition, immediate application and U32-derived count;
   execute captured scalar steps in descending order. Unknown/escaping callbacks
   and reversed composition conservatively fall back.

No source workload names, changed benchmark inputs, algebraic closed-form shortcut,
new runtime helper or public ABI. The final modules are `fusion03.bend` and
`callback02.bend`. They add258 net physical source lines (52,411→52,669), about 0.49%,
and 24 declarations. The two module files contain 262 lines; experiment sources,
retained failed versions, controls and host reporting tools are additional
repository material and are not part of that compiler-size count.

The native checked book uses erased lambda metadata different from the original
JS source view. A small analysis-only adapter verifies exact erased type formals
and runtime absence, then reruns the existing full composition check. It does
not change the book used for emission. The offline review caught unbounded
syntax traversal and fixed temporary-ID intervals; the selected implementation
has explicit syntax bounds and threads the existing lowerer's fresh counter.

## Correctness and actual activation

The complete composed compiler source passes the pinned checker before API
acquisition. Nine literal control expectations agree with both the checked Bend
admission function and the emitted private worker. Three standalone programs
match 240 complete expected output lines from independent arithmetic models:
counts 0/1/2/17/257 and seeds 0/1/4294967295; renamed helpers; wrapping; changed,
noncommutative fold and callback arithmetic; shared/returned lists; escaped
callbacks; reversed composition; and a user-defined primitive-looking name.

These controls distinguish a correct fallback from a successfully activated
transformation. Existing source checks, direct-IR verification and ABI checks
remain intact. They are finite evidence, not a formal fusion theorem. Separate
forged-metadata adapter controls, parallel/GPU qualification and arbitrary larger
source shapes were not run. Map controls were prepared but not executed after
the diagnostic was neutral; they are not included in passing counts.

Machine inspection authenticates the actual fast-screen binaries. The list
worker has 34 static instructions, zero calls and two scratch-memory references;
the callback worker has 15 instructions, zero calls and no stack references.
Both still execute dynamic loops. The removed allocation/traversal/continuation
work is visible in emitted IR and machine code, rather than inferred only from
timing. Counts include function padding and are not dynamic instruction counts.
Whole binaries grow slightly because generic segments remain available.

The longer closure256 confirmation multiplies repetitions by 20 for every role,
without rebuilding products. Its three-round medians are **7084ms parent,
84ms candidate, 4006ms upstream**: 84.3× faster than parent and 47.7× faster
than upstream on this workload. All nine complete-output observations pass.
This confirms the short-loop result without relying on 4ms timer granularity.
It is a single-family result, not a whole-language speed estimate.

## Complete compilation cost

Matched pinned Bun1.4.3, separate authenticated Base preparation for each API,
one warmup plus three rotated paired measurements; frontend, admission, lowering,
planning, verification and emission included. Output serialization/hash is separate.

| Original source | Parent prepared request | Candidate | Ratio |
|---|---:|---:|---:|
| List pipeline128 |3.5525s|3.5919s|1.0111×|
| Closures64 |3.1561s|3.1556s|0.9998×|
| Numeric recurrence1024 |3.0741s|3.1710s|1.0315×|

Geometric complete cost is **1.01407×** parent (+1.41%); admitted-entry cost
is **1.00043×**. The 24 checked warmup/measured emissions take 99.11s under the guard.
The initial list-only two-case screen was+3.78%; it is a different source/sample,
not evidence that adding callback fusion itself improved compiler throughput.
These small screens establish an economical candidate, not a universal no-cost
claim or native N1/N2/upstream compilation-speed measurement.

No complete native image rebuild was needed to test the hypothesis. The prior
native qualification costs about 21min and 5.4GiB peak memory; current disk headroom
is small. The checked-hosted source emits real native QBE programs, but this cycle
does not claim a new self-reproducing N1/N2 image, native compiler speedup or
installed default. Qualified Phase118 and installed selections remain intact.

## Rejected attempts and limits

- First diagnostic sources defined helpers after use; the checker rejected an
  unfilled law. Corrected sources put definitions first; the failure is retained.
- `fusion02` used an affine worklist item more than once; the checker rejected it.
  `fusion03` fixes the binder. No failed source produced a measured candidate.
- `callback01` conservatively refused checked erased-lambda metadata. Diagnostic
  admission localized the exact mismatch; `callback02` fixes only its analysis view.
- The first host admission inspector expected a tagged Bool, whereas this API
  returns a native JS Boolean. The emitted worker was already present. A separate
  corrected inspector passes all literal expectations; the failed receipt remains.
- Tree-to-list digest fusion was neutral. No general map/tree transformation was
  added on the assumption that every removed allocation must matter.

## What we learned and what should come next

The strongest result is a backend capability gap: existing JS semantic admission
could prevent native materialization before information was lost. Reusing it
gave two large family-level wins with little compiler growth and low measured
request overhead. Searching harder among the old runtime policies would not
have created either capability.

The useful extension is to preserve small checked producer/consumer descriptions
across backend boundaries, rather than copy a new recognizer for every workload.
First find one compiler-hot temporary structure, measure its producer's inclusive
cost, and test a source-level elimination ceiling with exact emitted-output checks.
Text/IR-building intermediates are candidates; `nt_append`'s double reversal is
a source lead, not a measured bottleneck. Preserve stack safety and sharing.
Do not infer a compiler speedup from these user-program results.

Phase120 arithmetic improvements remain potentially composable, but their
analysis cost needs repair before combining profiles and paying for native
qualification. The largest remaining same-run ratios are active ray8.43–8.47×, ordinary
ray8.23×, RLE7.62×, evening-program7.02× and tree-bitonic4.83–5.28×. These
unchanged cases deserve the next ceiling experiments. Further numeric polish
and SIMD are separate opportunities;
this work does not magically close deficits in unrelated arithmetic or tree
programs. A future native promotion needs its own source/image/ABI/self-hosting
gates. Neither repeated commits nor a faster generated program demonstrates
recursive research acceleration: acquisition, qualification and subsequent
experiment productivity still have to be measured.

## Research cost and retained evidence

Through18:14:31UTC, this cycle took **42.69min wall time**, with **20.63min guarded
work**. Final reporting/sealing/push follows that snapshot. There were26 serial
guards: five checked-API acquisitions, nine program-emission jobs, seven native
build/output/runtime jobs, two compilation-cost screens and three finite-control/
analysis jobs. Three rejected attempts used16.85s in total, already included.

Exclusive guarded wall times:0.85min API acquisition,11.12min emission,5.39min
native build/output/runtime,2.88min compiler cost and0.39min finite controls.
The one broad campaign accounts for7.71min emission plus4.09min build/runtime;
no full compiler image was built. Peak tree RSS is1.803GiB under the2GiB cap;
minimum available memory23.30GiB, above the16GiB floor. No resource-limit or native
output failure occurred. One reused offline agent prepared independent controls
and reviewed semantics; root alone owned target execution on CPU3.

[Accounting](accounting.json) includes failures and verifies non-overlap. Agent
inference/token cost is not metered. Residual wall time is not an inference-cost
measurement. Compared with Phase120's86.65min snapshot and47.04min guarded work,
this cycle reached a stronger but still concentrated result with roughly half
the wall time and less than half the target time. These are different experiments,
not a controlled claim about agent efficiency or recursive acceleration.

The [evidence capsule](evidence/receipts01.tar.gz) preserves small receipts,
commands, logs, outputs, failures and bounded disassembly. Its
[manifest](evidence/manifest.json) distinguishes retained payloads from external
large artifacts; [summary](evidence/summary.json) records integrity replay.
Digest replay verifies archived bytes, not correctness or timing. The exact
source recipe was recomposed successfully. All completed work is on
`selfhost/bootstrap`; no PR comment or installed selection is changed.
