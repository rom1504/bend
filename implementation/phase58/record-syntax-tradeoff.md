# Record syntax: compiler and generated-program tradeoff

**Both completed reversals are rejected for production.** The working source
has advanced to checked-last01; neither rejected reversal was applied and
release is held.
The final bounded last-constructor-key diagnostic is complete and its source
rule is selected for fresh qualification. This note records
completed measurements and static evidence, not publication or archive closure.

## Why another contrast was needed

[Literal-field qualification](literal-fields.md) established semantic equivalence
for ordinary quoted field keys while preserving computed `__proto__`. Its earlier
fixed-image compiler study favored quoted keys. Later, the final generated-program
comparison exposed regressions in Map/Set, edit distance and local row/pair.
[Program source isolation](program-regressions.md) reconstructs those three final
modules exactly by changing only the old computed field syntax to quoted keys.
This establishes their complete source difference, without proving a V8 cause.

The earlier compiler study preceded the other Phase58 changes. These new
contrasts change only record-key spelling in the final saved genuine B2, keeping
compiler source and runtime fixed. They do not compile a source rollback or
replace the generated-program comparison.

## Diagnostic images and retained semantics

The common parent is genuine shared01 B2:
`b7c5752d66ae4eaa8619e06b5a12655b370fba9d745d223660fbbb73da68fec8`,
**3,815,480 bytes**, emitted from checked-shared01 source
`a4ad6717934a8596c6bf707ecabf11346f57ca5b4e4e08cdcbdaac7921546d9a`.
Its checked B1 API is
`eddce7504207d91735e8369e7142f73ede8f77d8d2353b1ad6548796bdfd4569`.

The [full reversal producer](../../selfhost/tools/performance/phase58/fields/reverse-v1.mjs)
restores computed syntax for 6,870 tagged-constructor keys and three local
spread-marshalling keys. Its output is 3,829,226 bytes, SHA256
`46e58a808ca1b38d573518ff2555269d423018d119dbabe985f8eb6e9c0f7735`.

The [width diagnostic](../../selfhost/tools/performance/phase58/fields/reverse-width-v1.md)
restores 5,416 keys only in complete tagged constructors with at most four fields,
excluding the tag from width. Preexisting computed and `__proto__` fields count
in width. Wider constructors and unknown-width marshalling spreads retain quoted
keys. Its output is 3,826,312 bytes, SHA256
`d442e555db1468fda0cbbe687f378bd4cfbbe115568560698a32bf8de67ac27d`.
This was a hypothesis test, not an accepted field-count cutoff.

Both derivatives preserve runtime, values/order, member accesses, tags,
exports and computed `__proto__`. Normalized AST comparison permits only selected
`computed` changes; inverse edits recover the complete parent. These are saved
image diagnostics, not newly checked compiler images or portable releases.

## Completed request measurements

Each experiment contains two inputs × two roles × three fresh processes:
**12 processes and 48 measured requests**. Each process makes one first request
and three later requests. The first interval below includes host import, API load
and the first library request; “later” is the median of the three per-process
later-request medians. It is not a stationary-throughput claim.

All values are milliseconds: quoted shared01 parent → computed derivative.
The experiments retain separate baseline samples; they are not pooled.

| Saved-image variant | Input | First combined, quoted → computed | Later, quoted → computed |
| --- | --- | ---: | ---: |
| Full reversal | Lexer | 1,323.190 → 2,015.399 | 585.993 → 915.650 |
| Full reversal | Evening | 1,768.470 → 2,622.210 | 867.079 → 1,458.557 |
| Width at most four | Lexer | 1,325.29 → 1,541.70 | 548.90 → 698.58 |
| Width at most four | Evening | 1,873.397 → 2,176.191 | 863.273 → 1,172.289 |

Both reports are complete/pass: their output and execution gates succeeded,
while the performance result rejects the proposed reversal. Each prepared role
passes its complete catalog-value oracle; every request reproduces its own
prepared output. Cross-role complete bytes also match: lexer 28,388 bytes, SHA256
`39800331d0b0470d97f1ac2cd0905c24a1a0ddb8c9625d00d85fa156ac6f1f5a`,
Evening 99,147 bytes, SHA256
`963109d167da8c3323ecd89033acabc1523d6c87659e58dc17c1fc35ab9bba3a`.

Method06 uses Node 24.18.0, private staging and the CPU3/resource guard. Base
preparation/preflight are separate. Continuing warmup and three processes per
cell limit generalization; RSS/static fields do not establish allocation bytes.

## What the actual DP trace rules out

The bounded optimized-caller capture in [program-regressions.md](program-regressions.md#actual-optimized-caller-inspection)
shows both actual `$jd$row` versions inline the same eight functions, reserve the
same stack space, retain four static 64-byte record allocation paths and record
no executed deoptimization bailout. Neither retains a keyed-property runtime
call. Thus “quoted keys lost inlining/SROA” and “quoted keys allocate more record
bytes” are unsupported explanations for that capture.

Partial versus final object-map initialization, filler versus uninitialized
sentinel, scheduling and code offsets differ. Those differences motivate the
last-key diagnostic; they do not identify a measured causal instruction or
justify constructor-name or benchmark-specific policies.

## Completed last-key diagnostic and selected source

The [last-key producer](../../selfhost/tools/performance/phase58/fields/last-key-v1.mjs)
changes only an eligible final property of a tagged constructor back to computed
syntax, retaining earlier quoted fields and all unknown marshalling spreads.
It has no field-count or constructor-name rule. This was the final bounded
key-placement variant; no further threshold-tuning campaign is proposed.

The three-point execution screen completes **45 samples**, five fresh balanced
rotations per role, in 73.944 seconds. All complete oracles pass; zero role-points
cross the configured spread/drift flags (max/min >1.20 or absolute sample half
drift >20%). These descriptive flags are not a significance test.

| Point | Phase56 µs | Saved diagnostic µs | TS µs | Diagnostic / Phase56 |
| --- | ---: | ---: | ---: | ---: |
| Map/Set | 19.099362 | 18.557730 | 22.232178 | 0.971641 |
| Edit distance | 5,601.102741 | 5,611.975389 | 5,014.875267 | 1.001941 |
| Morning | 3.292568 | 3.328507 | 3.667171 | 1.010915 |

The fixed-source compiler-image contrast also completes 48 requests. Lexer
first combined is **1,323.509→1,496.333 ms**, later **554.979→648.819 ms**;
Evening first is **1,765.094→2,011.224 ms**, later **853.888→1,001.888 ms**.
These are adverse increases of 13.06% / 13.94% first and 16.91% / 17.34% later.
The approximately 10% compiler screen is missed, not relabeled as passed.
They are smaller penalties than the two rejected reversals. Ratios from separate
studies are not multiplied into a claimed selected-release result.

The [source-selection design](../../design/phase58/last-field-selection.md)
accepts this as a compromise for qualification: quoted prefix fields and a
computed final live field in ordinary and ordered direct constructors. Every
`__proto__` remains computed. Host spread marshalling retains its literal-key
rule. One field-join helper adds five physical lines across three modules;
rendered suffix length handles erased trailing fields without new analysis.

Root applied the reviewed three-module proposal and froze checked-last01;
the application receipt is not correctness or release qualification. Fresh final
full45 and selected compiler latency/allocation/emission remain pending here.
The three-point screen is not the full corpus; installation remains held.
The corrected width ≤4 synthetic grid is prepared but unexecuted.

Additional frozen last-key receipts:

- `selfhost/build/phase58/last-key-program-analysis01/report.json`: SHA256 `53d13bac1438cbd98686bebc7bd6fe90d3d7ac4fd73aa2237948069c1f58b751`.
- `selfhost/build/phase58/fields-last-latency01/report.json`: SHA256 `4db8839e83bfa56dcef20dea9ddd5dec48fd8ad2b04768a7a1f93986ff020753`.
- `selfhost/build/phase58/fields-last01/derivation.json`: SHA256 `b229f48d88164d518eff5bc385110d58b4c3e30e3754d794bcfde414d3374219`.
- `selfhost/build/phase58/last-source-selection.json`: SHA256 `d26c9217da3f4272836a44d4953716b2c13d611abe56e4d87c666835f9947c87`.

Frozen earlier receipts, retained as raw member paths until publication:

- `selfhost/build/phase58/fields-reverse01/derivation.json`: SHA256 `e182ec365da8a6fe4c5477cf7966c7555c9e76266ee12392bce284b0e1a397e8`.
- `selfhost/build/phase58/fields-reverse-latency01/report.json`: SHA256 `90e3918a81b6bc6a439ad36b6e061565dfb93f6212df353dd0be3b6d6197034c`.
- `selfhost/build/phase58/fields-width01/derivation.json`: SHA256 `675ccb07d927e9a947cd1c135c4818c4697238e2295aaac820c99669a18873e7`.
- `selfhost/build/phase58/fields-width-latency01/report.json`: SHA256 `f0bc00b98ff94a0cf767b29ad05daf913e4fbcc9cb782e557f77f156a10321e8`.

Their bindings join the checked attempt, genuine emission, producer and exact
parent/output hashes. This note was prepared by reading reports and source only;
no compiler, trace, benchmark, install or archive was executed.
