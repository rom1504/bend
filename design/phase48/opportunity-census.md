# Phase48: measure the surviving boundaries

This is a diagnostic plan over the selected Phase47 array06 compiler. No proposed
change below is selected merely because its generated syntax looks expensive.
The [frontier report](../../implementation/phase48/frontier.md) records the exact
paired output inspected, static findings and subsequent evidence boundaries.

## Priorities from the complete comparison

The final 45-point geometric slowdown is 2.919418× TypeScript; equal-source
slowdown is 3.995808×. These are generated-program execution measurements, not
compiler latency. Six severe points contribute 50.29% of the logarithmic gap;
expression, numeric recurrence and Unicode contribute another 18.86%.

| Hypothetical change; other points unchanged | Equal-point slowdown |
| --- | ---: |
| Six severe points reach 3× TypeScript | 1.97196× |
| Six severe points reach parity | 1.70326× |
| Those six plus expression/numeric/Unicode reach parity | 1.39168× |
| Only Map churn and record aggregation reach parity | 2.78877× |

These are counterfactual arithmetic, not forecasts or CPU shares. Fixing one
large ratio cannot establish broad parity. The corpus informed implementation;
it is not an untouched holdout or a distribution of all Bend programs.

## First discriminate existing private code from missing coverage

Morning and Evening have no contextual worker. RLE and Unicode already do.
Scalar-zero, expression and numeric recurrence have older specialized private
plans. Generic row crosses a public composite result boundary, while its separate
scalar `pair` entry is already optimized. These require different interventions.

Every experiment should therefore record: the selected public assignment, the
actual private function reached, the remaining representation or call boundary,
and which fallback remains unchanged. A marker elsewhere in the module is not
an activation witness. The previous array/tree composition failure is the reason
to require an enclosing-path counter before expensive qualification.

## Two small causal probes before larger architecture

### Exact F32 constants inside a proved private loop

The selected numeric private helper repeatedly evaluates three compact literals
through `bitsFloat`; paired upstream uses `3.75`, `1` and `1000000`. Preserve all
F32 rounding operations and public guards. Compare three separately hashed
outputs:

1. Original array06.
2. Replace each private `bitsFloat(bits)` with
   `(floatView.setUint32(0,bits,true), exactLiteral)`. This retains shared-view
   writes and their order, eliminating the canonical read/helper shell.
3. Pure literals, as an explicitly unqualified upper bound. A previously hooked
   DataView method can retain the shared view, making omitted writes observable.

The [producer](../../selfhost/tools/performance/phase48/numeric-constants-derive.mjs)
requires the exact array06 module, scopes edits to one AST-selected helper and
checks that the remainder of the module is byte-identical. Its 35 independent
recurrence values cover sizes 0, 1, 2, 16, 256, 1024 and 8192 with five seeds.
The [controller](../../selfhost/tools/performance/phase48/numeric-measure.py)
uses the existing execution worker and resource supervisor: 105 finite checks,
then three sizes × five rotated rounds × three variants. Root alone executes it.
Each timed sample uses a fresh process, 1 s warmup and a 300 ms target; samples
below 100 ms do not receive a passing timing summary. No JIT-stationarity claim
follows from this protocol.

Only a surviving gain warrants a proof-context literal-emission change. Keep
ordinary fallback emission unchanged. Decode finite F32 values exactly, preserve
negative zero, and refuse NaN payload rewrites until independently specified.
Test retained views, method replacement/restoration, detached buffers, zero
iterations and errors. Do not remove the full guard because the constants happen
to be finite. A later F32-to-U32 helper experiment must retain its own conversion
semantics and remain separate from the literal ablation.

### Typed String concatenation already inside a guarded worker

Unicode's private repeat/join graph still invokes `String.append` through
`callOwned(get(G,...), [a,b])`; upstream emits `a+b`. The selected root already
captures the exact native dependency and proves scalar String boundaries.
Investigate a narrow `JWNative` consumer for the already-proved operation.

Before changing the emitter, review the exact dependency guard and left-to-right
argument evaluation, including failure and nested-entry behavior. Retain all
source/native guards and public fallback. A renamed recursive String fixture
must cover empty, BMP, astral and lone-surrogate content, native replacement and
descriptor getter mutations. Use a second composition such as records to test
transfer, not a program-name admission rule. Count removed generic call sites
and argument vectors as static evidence; clean timing establishes benefit.

## Larger representation experiments, each with a concrete consumer

| Consumer | Missing reusable fact or operation | Smallest useful witness | Stop condition |
| --- | --- | --- | --- |
| Morning recursive function factories | Finite function targets and captures across a match result and helper argument | Renamed recursive matched factory returning a partially applied helper, consumed by a finishing helper | A leading-lambda-only pass does not reach this path; record refusal rather than claiming coverage |
| Evening's F32 array subgraph | Canonical Array constructors, swap result transport and exact F32 operations | Fresh two-leaf F32 array, two swaps, scalar result; then changed aliases and lazy materialization hooks | Native new/get/set admission alone cannot handle literal ALeaf/ANode construction |
| Generic row's composite return | Private ownership plus public materialization/demand and alias maps | Four-array record with a terminal role swap, shared/distinct fields and later public mutation | Returning raw arrays or eagerly forcing deferred fields changes the ABI |
| RLE private state loop | Product parameter/result convention across a branchy helper and tail edge | Two nested transient state tuples; persistent output list still has two consumers | Eliminate the state transport itself; copying the helper without removing shells repeats the rejected worker pass |
| Expression producer followed by fold | Producer/consumer fusion, demand/usage and error-order facts | Renamed unary tree producer with one recursive child and a separate algebraic fold | Do not generalize from a fully executed helper when sharing or public escape forces materialization |
| Scalar-zero and short loops | Fresh public contract cost versus useful work | Zero/small/large inputs through one unchanged export; isolated guard-class counters | No cross-call permission cache or benchmark-specific loop threshold |

The expression plan already avoids generic recursive dispatch but still allocates
the produced tree, producer continuation records and fold frames. Fusion could
remove a whole intermediate representation; ordinary constructor inlining alone
does not do that. Shared facts should be introduced with this or another real
consumer, not as a new optimizer justified only by hypothetical future use.

## Experiment sequence and selection

Run syntax/source checks and independent renamed controls first. Require actual
activation or an explicit refusal, then a 20 s rejection screen and the core8
screen. Use distinct jobs for timing, profiling and publication. Expand to the
two sizes already present for numeric/expression/Unicode and nearby variants
before interpreting a gain as transferable. Root owns serial quiet CPU3 target
execution; agents inspect saved data and author independent changes concurrently.

For larger projects, record intermediate refusal gates without claiming runtime
progress. Prefer a representation contract shared by an existing private path
over another guarded public wrapper. Retain successful old root ranking until a
new implementation wins without reproducing the known tiny-entry regressions.

The 405-line Phase47 worker cleanup is preserved and deferred. It did not remove
the intended actual-program shells; a new product pass must explain why its
consumer crosses the return/branch boundary that that experiment missed.
Likewise, String equality for Map/Set was already tested as an unselected
prototype. Reusing it is a composition experiment, not a new discovery.

Measure code size and compiler cost separately from program execution. An
optimization that expands private graphs needs source/module growth and import
cost evidence. Compiler-query reuse has its own request-level evidence and must
not be multiplied into generated-program speedups.

## Reproduction and preservation

The [data-only census](../../selfhost/tools/performance/phase48/frontier-census.mjs)
hashes both published archives, parses selected modules with Node's bundled
Acorn, and never imports generated programs. It also compares all top-level
`G` assignments with worker23. Run from the repository root with a fresh output:

```sh
taskset -c 0 /home/ai/.nvm/versions/node/v24.18.0/bin/node \
  selfhost/tools/performance/phase48/frontier-census.mjs NEW_CENSUS_JSON
```

Preserve all 103 protected starting files and closed historical raw directories.
New experiments use new destinations and retain failed producers, refusals and
negative timings. This design authorizes no historical rewrite and supplies no
new conformance, installation or promotion claim.
