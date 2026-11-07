# Phase173 working report — execution and durable semantic storage

**In progress. No production compiler has changed.** The qualified Phase170
compiler remains available. This report records completed experiments and the
next architectural test; it does not claim the requested successor migration or
the 100-second cold-build milestone is finished.

## Main result so far

An exact indexed representation alone made the complete native test **2.003×
slower**, despite passing independent full-value comparisons. Reducing its root
from nine fields to seven did not recover meaningful performance.

The resulting machine-code investigation found a concrete execution barrier:
the new complete state machines form 3–36-member mutually recursive components,
but the existing direct optimizer fuses only pairs with one result. Direct
getters coexist with generic scheduler loops. General multi-result cycle fusion
and an ownership-safe product-argument adapter now make all four major loops
direct, without scheduler transitions. This recovers much of the experimental
regression, but does not yet justify replacing the original representation.

| Native complete consumer, 101 actual verifier bodies | Baseline median | Candidate median | Ratio |
|---|---:|---:|---:|
| Initial indexed store | 0.078725s | 0.157692s | 2.003× |
| Seven-field store carrier | 0.079870s | 0.157263s | 1.969× |

Each row is four balanced fresh-process pairs on CPU3, including input
construction, compaction, ordered dependency collection, export, structural
validation, complete output and exit. All eight outputs per pair equal an
independent constant oracle: **962,601 bytes**. These are extracted compiler
computations, not full compiler builds. Ratios use each row's contemporaneous
baseline. The two candidate medians are essentially unchanged; do not call the
small difference between ratios an improvement.

## What was implemented and checked

Further complete-consumer observations, each four balanced native pairs:

| Comparison | Baseline | Candidate | Candidate/baseline |
|---|---:|---:|---:|
| Same indexed source, general cycle fusion | 159.526ms | 150.364ms | 0.943× |
| Original KTerm → indexed direct destination | 79.188ms | 114.480ms | 1.446× |
| Original KTerm → indexed with argument adaptation and cycles | 78.649ms | 93.690ms | 1.191× |
| Original KTerm → direct destination with adaptation and cycles | 78.806ms | 91.048ms | 1.155× |
| Existing compiler verifier, adaptation and cycles | 422.811ms | 422.186ms | 0.999× |

The indexed algorithm therefore becomes substantially faster, but the existing
verifier does not. These results are not a measured cold-compiler improvement.
All complete indexed outputs remain identical to the original frozen oracle.

The actual obstruction was13 `product result shape mismatch` errors. A nested
boxed product reached a known flat-argument helper; lowering selected its boxed
fallback, then refused that fallback's boxed result. The adapter consumes the
owned shell through the existing guarded take, preserves fields and tail-result
vectors, and clears all13 errors. It only repairs previously failing product
result calls; existing successful boxed calls keep their original dependency.
All21 SCC and25 adapter controls pass, including both independent verifiers.
Actual QBE confirms full import9/export11/refs6/compaction36-member admission.

Constant-tag backedges still traverse the generated state dispatcher. A separate
structural emission experiment passes30 additional finite controls. Its first
native comparison measures95.102→91.818ms (3.45% less) against the ABI-fixed
indexed implementation, with the complete output exact. Only nine SCC functions
change; all other function/data blocks remain byte-identical. The largest
compaction and Word workers remain unchanged because admission rejects a valid
conditional join before a common return. Revision2 adds that general admission
case and passes36 dispatch controls; its native comparison is in progress.
No new IR variant or verifier relaxation was introduced. See the
[boundary analysis](../../experiments/phase173/product-argument-boundary.md)
and [dispatch experiment](../../experiments/phase173/constant-tag-backedge.md).

## Complete destination construction

The direct-destination variant avoids constructing an indexed output graph that
would immediately be traversed for references and exported to KTerm. It produces
the final terms and ordered references together, then validates the unchanged
input store. Source analysis counts45,139 fewer output-store writes and135,417
fewer subsequent reads on this corpus; these are logical operations, not runtime
event counts. The new traversal passes16 finite complete-value controls and all
101 actual bodies. The26 original store controls exercise the old compactor and
must not be counted as new-traversal controls. Its combined20M fuel is a different
refusal boundary from two separate10M bounds. See the
[independent audit](../../experiments/phase173/direct-store-audit.md).

## Checked-plan reuse for experiments

Repeated hosted frontend preparation of the unchanged native corpus costs about
45–46s. The first JSON transport stopped at its declared1M-node bound. A pinned
Bun structured-clone transport captures the complete P86Plan in93,984,983 bytes,
including its verdict and sharing, in1.989s after full checking. A separate
16,384-deep ordinary-data control verifies exact values, sharing, cycles and
isolated decodes. The full capture took58.241s.

Same-API replay decodes in0.578s and emits byte-identical12,717,939-byte QBE.
One full hosted request took102.322s; one complete warm replay took64.274s.
These are diagnostic observations, not a new cold-build score. Authentication,
lowering, independent verification and rendering remain charged. Reuse requires
the same source/path, Base, carrier, engine, acquisition ABI and exact2,135-
declaration frontend closure. This is bounded experiment transport, not an
incremental production compiler or a mathematical certificate.
See [plan reuse](../../experiments/phase173/plan-replay.md).

## Original indexed-store implementation

The all-Bend store preserves KTerm/KLambda/KLiteral fields, source spans,
removed-name metadata and lambda quantity presence. IDs are append-only and
postorder, with checked ranges, fuel refusals, and physical capacity validation.
Compaction and ordered reference discovery operate directly on IDs; no legacy
term conversion occurs inside either consumer. Import and final export remain
charged. Twenty-six complete-value controls and three refusal controls passed.
The real verifier corpus additionally compared 321,590 output values and all
101 bodies, using a separately acquired unchanged compiler API.

Native arrays already use contiguous storage, including under File effects.
The global scalar flag controls packing, not whether native Array.get traverses
a tree. The JS direct backend also has array primitives. The source Array tree
definition was insufficient evidence about either selected execution path. See
[the source audit](../../experiments/phase173/native-store-interface.md).

The initial native corpus transport placed too many literals in one function.
The unchanged verifier rejected it at its 65,535-local limit after 32.05 guarded
seconds. Bounded helper transport preserves the entire corpus and output while
avoiding that unrelated limit; the verifier was not weakened. Successful native
acquisitions took 31.582s baseline, 31.125s store candidate, and 49.209s for the
larger constant oracle. These acquisition costs are separate from runtime.

## Competing borrowed-record experiment

The experimental backend can recognize a complete take/update/constructor/return
region and reuse a privately owned record while retaining untouched fields.
Unknown calls, effects, escaping fields, incompatible layouts, and unsupported
ownership use the original path. It is a semantic plan with a separate emission
template, not a source-name recognizer.

The first real verifier request emitted exactly the baseline QBE (2,309,376
bytes, SHA256 `8be3a072b84dfc8bb85ddb9478c00d05179f7de89c8d4079af9ca3a5190bfbfb`).
There were zero admitted regions, so rebuilding the identical program would
have established no optimization result.

Investigation then exposed selected typed emitters which bypass the original
hook. The experimental dispatchers now share one planner; a terminal accepted
region needs no outgoing typed facts, and refusal preserves original dispatch
and invalidation. The actual compiler driver now emits templates in
`k_with_children` and `k_with_span`.

A further eligibility issue was caught before execution claims: capability13
contains the global cold-publication bit, but the driver's KTerm constructors
are individually hot. Revision03's conservative guard blocked every fast arm.
Revision04 preserves authenticated constructor hot metadata and exactly matches
the runtime's per-constructor publication rule. Thirty-eight finite controls
pass. Independent review covered aliasing, publication, existing metadata
consumers and the common constructor-table origin. Native execution matches the
complete 1,724-byte upstream-derived result. Authenticated runtime event counts
decrease from180 to177 allocation requests,412 to388 requested words, and57 to54
constructor takes. Other categories are unchanged. This establishes actual
removed work; the small driver is too short for a runtime claim.

A subsequent two-million-update loop calls unchanged `k_with_span` and retains
the original shared alias. Four clean balanced pairs measure54.910→41.203ms,
25.0% less runtime, with the complete upstream-derived output identical. The
earlier500,000-update pilot was below the30ms resolution gate and is not used
for this speed claim. This does not establish a25% compiler speedup.

A full8,223-node `f_span_created`→`g_share_head` computation now matches its
complete independently checked upstream output, including a retained shared
alias and all metadata. Both runtimes are below30ms, so no speed claim follows.
Separate diagnostic execution removes3,600 of145,197 allocation requests and
28,793 of333,733 requested words. Dispatcher and continuation counts are
unchanged. This is real transfer of work removal, but only2.48% of this
computation's allocations. A digest consumer is being prepared to isolate
execution from printing the large result; it does not replace the full-value
correctness gate. The broader audit finds the current terminal-region admission
does not cover recursive reconstruction across allocating calls.

This transform happens after final IR verification and extends trusted emission.
The unchanged verifier alone does not prove the new memory operations correct.
The separate [ownership audit](../../experiments/phase173/borrow-audit.md), full
upstream-derived value oracle and runtime execution controls are necessary.
It is not a BendTT theorem.

## Current architectural experiment

General tail-component fusion is implemented experimentally in Bend and passes
source checking plus **21 finite controls**, including both independent direct
verifiers, renamed array imports, two-result cycles, argument/result mismatch,
non-tail refusal, duplicate names, stale call metadata, and size limits.

It discovers components with an indexed, explicit-worklist Tarjan traversal,
retains original interfaces as wrappers, and transforms exact internal tail
transfers into existing P113DAgain local loops. Bounds are 64 members, 31 input
lanes plus the private state tag, and common result widths1–8. Ownership actions
and external-call order remain unchanged. The transformed bodies themselves go
through the independent final verifier.

Review caught ineffective saturating budget counters and scratch names that the
array-import verifier would not authenticate. Both were fixed before native
execution. Native owned-list and argument-swap workloads pass at200,000 steps.
Three-member cycles use local jumps with no per-transition scheduler calls.
The initial complete store improves0.159526→0.150364s (5.74%) in four paired
rounds, all962,601 output bytes exact. That revision admits only edge insertion
and validation cycles. The subsequent owned-argument repair admits all four
major loops and produces the stronger results in the table above. Both stages
remain slower than original KTerm. The unrelated existing verifier is neutral.

Revision2 checks generated worker identity against the pre-existing ready
namespace as well as raw candidates. See the
[execution barrier](../../experiments/phase173/store-execution-barrier.md) and
[independent SCC audit](../../experiments/phase173/scc-audit.md).

## Evidence and resources

The [reproduction guide](reproduction.md) preserves measured module versions,
receipts, commands and negative findings without copying generated compiler
images or IR into Git.

Exact current run locations are in
[checkpoint.json](../../experiments/phase173/checkpoint.json). Native pairs:

- `selfhost/build/phase173/store-native-pair01/report.json`
- `selfhost/build/phase173/store-flat7-pair01/report.json`
- `selfhost/build/phase173/store-verifier-controls01/report.json`
- `selfhost/build/phase173/scc-finite02/report.json`

Root owns one guarded CPU3 execution lane; agents implement or audit without
running targets. Reviewed completed Phase171/172 assembly/object files were
archived, reopened and hash-verified before exact-file pruning. Binaries,
qualified chains and profiler dependencies remain hot. The 5GiB reserve stays
in force. Parser, transport, guard-admission and negative optimization results
are retained rather than silently rerun under the same artifact names.
