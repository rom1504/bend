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
getters coexist with generic scheduler loops. We are now testing general,
multi-result, stack-safe tail-component fusion before migrating more algorithms.

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

This transform happens after final IR verification and extends trusted emission.
The unchanged verifier alone does not prove the new memory operations correct.
The separate [ownership audit](../../experiments/phase173/borrow-audit.md), full
upstream-derived value oracle and runtime execution controls are necessary.
It is not a BendTT theorem.

## Current architectural experiment

General tail-component fusion is implemented experimentally in Bend and passes
source checking plus **18 finite controls**, including both independent direct
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
The complete store improves0.159526→0.150364s (5.74%) in four paired rounds,
all962,601 output bytes exact. This is still much slower than the original
KTerm representation. Only edge insertion and validation cycles become direct;
the large import/export/reference/compaction loops remain generic. A diagnostic
now targets their actual admission errors. The unrelated existing verifier is
neutral:0.422187→0.425313s (0.74% slower), four paired rounds.

Before broader integration, generated worker identity must also be checked
against the pre-existing ready namespace, not just raw candidates. See the
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
