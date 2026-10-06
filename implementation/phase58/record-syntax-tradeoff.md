# Record syntax: compiler and generated-program tradeoff

**Both completed reversals are rejected for production.** The working source
remains checked-shared01; no rollback has been applied and release is held.
A final bounded last-constructor-key diagnostic is pending. This note records
completed measurements and static evidence, not publication or archive closure.

## Why another contrast was needed

[Literal-field qualification](literal-fields.md) established semantic equivalence
for ordinary quoted field keys while preserving computed `__proto__`. Its earlier
fixed-image compiler study favored quoted keys. Later, the final generated-program
comparison exposed regressions in Map/Set, edit distance and local row/pair.
[Program source isolation](program-regressions.md) reconstructs those three final
modules exactly by changing only the old computed field syntax to quoted keys.
This establishes their complete source difference, without proving a V8 cause.

The old compiler experiment preceded the other Phase58 changes. Its benefit
cannot be assumed unchanged in the final image. The two new compiler-request
contrasts therefore use the **same final compiler source and runtime**, changing
only record-key spelling inside its saved genuine B2 image. They do not compile
a source rollback, change the emitted program printer, or replace the final
program-execution comparison.

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

Both producers preserve the runtime prefix, value expressions, evaluation order,
member accesses, tags, export map and preexisting computed keys. Exact
`__proto__` remains computed. Normalized AST comparison permits only the selected
`computed` flag changes, and inverse edits recover the complete parent bytes.
These saved-image derivatives are diagnostic APIs, not newly checked compiler
images or portable releases.

## Completed request measurements

Each experiment contains two inputs × two roles × three fresh processes:
**12 processes and 48 measured requests**. Each process makes one first request
and three later requests. The first interval below includes host import, API load
and the first library request; “later” is the median of the three per-process
later-request medians. It is not a stationary-throughput claim.

All values are milliseconds. “Quoted” is the unchanged shared01 parent;
“computed” is the derivative. The separate experiments retain their own baseline
samples; they are not pooled.

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

The unchanged method06 clean runner uses Node 24.18.0, fresh private staging and
request-local roles, with the existing CPU3/resource guard. Base preparation and
preflight are separate from these intervals. Continuing warmup, only three
processes per cell and two sources limit generalization. Neither lower RSS nor a
static field count would establish fewer physical allocations.

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

## Final bounded hypothesis and evidence

The [last-key producer](../../selfhost/tools/performance/phase58/fields/last-key-v1.mjs)
changes only an eligible final property of a tagged constructor back to computed
syntax, retaining earlier quoted fields and all unknown marshalling spreads.
It has no field-count or constructor-name rule. Its experiment is **pending**;
no outcome, production patch or release approval is inferred here. This is the
last bounded key-placement variant, not another threshold-tuning campaign.

A synthetic constructor grid is prepared but unexecuted, with the width contrast
correctly using computed keys at width ≤4. Preparing a proposal does not oblige
executing it or supply qualification evidence.

Frozen raw receipts, retained as raw member paths until publication:

- `selfhost/build/phase58/fields-reverse01/derivation.json`: SHA256
  `e182ec365da8a6fe4c5477cf7966c7555c9e76266ee12392bce284b0e1a397e8`.
- `selfhost/build/phase58/fields-reverse-latency01/report.json`: SHA256
  `90e3918a81b6bc6a439ad36b6e061565dfb93f6212df353dd0be3b6d6197034c`.
- `selfhost/build/phase58/fields-width01/derivation.json`: SHA256
  `675ccb07d927e9a947cd1c135c4818c4697238e2295aaac820c99669a18873e7`.
- `selfhost/build/phase58/fields-width-latency01/report.json`: SHA256
  `f0bc00b98ff94a0cf767b29ad05daf913e4fbcc9cb782e557f77f156a10321e8`.

Their bindings join the checked attempt, genuine emission, producer and exact
parent/output hashes. This note was prepared by reading reports and source only;
no compiler, trace, benchmark, install or archive was executed.
