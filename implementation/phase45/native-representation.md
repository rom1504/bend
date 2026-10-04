# Native workers and value representation checkpoint

Worker11 reduces the two selected execution gaps to **2.953× TypeScript for Map
churn** and **2.543× for record aggregation**. In a fresh comparison against the
same backend retaining BigInt Nats, the gains are **1.694× and 1.725×**. Exact
Nat boundary controls and independent deep-recursion controls pass. These are
development results on two reused optimization workloads; the installed compiler
and the previous full 45-point result are not replaced by this checkpoint.

## What changed

[P45-009](../../experiments/phase45/P45-009-bounded-native-workers.md) gives each
proved private graph one shared native recursion allowance and retains its
continuation machine at exhaustion. Worker09 adds same-component tail transfers
that capture arguments, update scalar locals and continue in the same frame.
Tail depth no longer consumes the allowance. Non-tail depth still falls back
without depending on an enlarged JavaScript stack.

[P45-010](../../experiments/phase45/P45-010-private-named-fields.md) stores private
tagged ADTs in one `{$: tag, _0: field, ...}` object instead of an array plus
wrapper. Constructor and projection layouts come from the typed worker IR;
case tags, evaluation order and native Bool/Nat/String/Char/Tuple layouts remain.
An explicit native-signature fence prevents private fields escaping through a
future broader native whitelist. Public representations are unchanged.

[P45-011](../../experiments/phase45/P45-011-number-nat.md) rewrites Nat representation
through a complete eligible worker graph. Literals, fields, matches, constructors
and operations compose with Number Nats internally. Public Nat inputs/results
remain BigInt. The pass also replaces proved Nat-native descriptor calls with
direct arithmetic helpers. Unknown boundaries retain the BigInt graph; this
includes non-String literal globals, multiplication and exponentiation. There is
no partial execution followed by restart, new public entry or workload selector.
The rejected nullary-entry experiment remains excluded.

## Controlled execution results

All successful screens below use three fresh rounds per role, rotated order,
at least 350 ms warmup and a 150 ms sample target. They run serially on CPU 3
with Node 24.18.0, a 1 GiB heap, 2 GiB process-tree RSS limit and
`--stack-size=4096`. Compilation, diagnostic counters and profiles are excluded.
Each screen contains two points and 18 role samples. The upstream pin is
`018751270e800bc222a93dad7f257083ee53a5f7`.

| Screen / point | TypeScript ms | Control ms | Candidate ms | Control / candidate | Candidate / TypeScript |
| --- | ---: | ---: | ---: | ---: | ---: |
| Worker09 / Map 128 | 0.790373 | 22.338640 | 4.333730 | 5.15460× | 5.48314× |
| Worker09 / records 256 | 1.257469 | 100.673655 | 5.794293 | 17.37462× | 4.60790× |
| Worker11 / Map 128 | 0.800488 | 22.536976 | 2.321814 | 9.70663× | 2.90050× |
| Worker11 / records 256 | 1.233448 | 100.965691 | 3.158566 | 31.96567× | 2.56076× |
| **10b→11 / Map 128** | **0.793806** | **3.969341** | **2.343764** | **1.69358×** | **2.95256×** |
| **10b→11 / records 256** | **1.268730** | **5.565618** | **3.225962** | **1.72526×** | **2.54267×** |

The first four rows freshly execute saved Phase44 output as control. The final
two use worker10b, which combines worker09 with named fields while retaining
BigInt Nats. Only that last same-run comparison isolates the **combined** Number
representation/direct-Nat-operation change. Worker09 and worker11 results from
different runs are progression observations, not an isolated causal estimate.

The causal run finishes in 15.377 seconds. Worker11 Map samples are
2.322388–2.387443 ms and records samples 3.169384–3.228167 ms. Within each sample,
the second half is +19.96% to +21.69% slower for Map and +8.30% to +8.80% slower
for records. The large gain merits continued qualification, but the short screen
does not establish a stable long-run rate. A BigInt-direct-operation ablation
would be needed to separate arithmetic representation from native-call removal.

The separate field-layout worker08 screen remains inconclusive. It measured
7.312435 ms Map and 11.100855 ms records, compared with worker05's earlier
7.262652 and 11.055931 ms. That is a cross-run comparison with substantial drift:
worker08 Map TypeScript samples ranged 0.805–1.531 ms, and candidate records
within-sample drift ranged +13.35% to +42.90%. The structural removal of one
allocation per private tagged constructor is established by emission; a separate
execution-speed gain from named fields has not been established.

## Correctness and activation

Worker11 passes the checked build and eight maintained suites. The independent
Nat controller v2 compares worker10b, worker11 and pinned TypeScript:

| Evidence | Completed checks |
| --- | ---: |
| Exact oracle cases across all three roles | 215 across 16 public roots |
| Overflow cases across all three roles | 5 |
| Exact predecessor/candidate ABI and mutation cases | 28 |
| Separate untimed activation observations | 73 |
| Complete candidate AST public-Counter assignment checks | 1, generic |

The 215 cases include 112 quotient/remainder points, values around 2³² and the
48-bit maximum, shifts, conversions and nested private fields. The boundary
checks include Number/BigInt replacement/accessor hooks, source/native descriptor
mutation, real source overflow, Error-constructor reentry and successful replay.
No injected diagnostic fault is used to establish Nat overflow behavior. The
compact-literal overflow fixture is retained but not executed by this controller;
its separate frontend refusal check is outside these totals.

TypeScript uses Number internally but its typed library exports use `nat_host`
for inputs and BigInt conversion for outputs, including public Counter fields.
V2 supplies identical BigInt Nat arguments and requires exact BigInt results in
all three roles. Their error-object ABIs differ: selfhost throws Error with the
existing message; TypeScript throws a string. Error-hook identity/order is
therefore compared exactly between the two selfhost versions, while TypeScript
must also signal each overflow.

The separate worker composition controls pass 135 small oracle cases across
three roles, five public-data checks, five descriptor refusals, 15 small
activation observations and two diagnostic unwind/reentry cases. Five deep
root suites each pass depths 4,096 and 50,000 with two seeds at
`--stack-size=984`: 20 candidate-only deep oracle cases, plus shallow/deep/shallow
activation and budget-restoration observations. These finite unsafe source
fixtures test backend execution, not a termination proof or complete language
conformance. Counter/profile timings never enter the execution table.

## Preserved failures and source identity

Worker10 was an invalid isolation baseline: removing the Number mode accidentally
removed `let $workerBudget=32;`. Its first Map invocation threw ReferenceError and
the run completed zero measured cases. Worker10b restores exactly that declaration
in the emitter; `number-nat-isolation02/fix-worker10.patch` and the before/after
identities preserve the repair. All reported Nat causal timings and successful
Nat controls use **10b**, not the failed worker10 run.

The original Nat controller stopped before completing an oracle because it
mistook TypeScript's internal Number representation for its public ABI and
expected `0` instead of `0n`. The original controller and failed receipt remain.
V2 corrects the typed boundary based on the actual emitted wrappers; oracle
constants remain unchanged and unexpected values are not coerced into passing.

| Selected equality-derived API | SHA-256 |
| --- | --- |
| Worker09 | `ff2c23761dd664ca2668c1bacffcae736cb0e159a578b3d4f0d249d0a94dbaa3` |
| Worker10b | `5ada9ab4b60b1f4a7b82a90436e5682bc596cb7eab340fbe8e96215ba7e6a443` |
| Worker11 | `319d06fd039a2ed51881ad824d5371c29ad3b41d332f4bb4906e256ce7c65bf2` |

The worker10b→11 source delta adds 167 physical Bend lines and one module,
including the 135-line representation pass: 22,643→22,810 lines and 84→85
manifest modules. This is additional modular functionality, not a line-count
reduction. Generated Map output slightly shrinks 250,235→250,013 bytes and
records 244,701→244,507 bytes. No compiler-throughput gain is claimed.

## Profiles and remaining limits

All 12 requested worker11 CPU/allocation profiles complete. Sampled allocation
estimates are 3.86 MB/call for Map and 5.52 MB/call for records, against 2.17 MB
and 2.71 MB for TypeScript in the same diagnostic campaign. These are sampled
allocation estimates, not exact allocations or retained memory. The diagnostic
baseline is Phase44, not worker10b; these profiles cannot attribute an allocation
change specifically to Number Nats.

The remaining gaps warrant general IR allocation/copy work and fresh profiles.
Broader program coverage, longer timing, compiler cost and release integration
remain necessary. The 45-point aggregate cannot be recomputed from two selected
points, and this checkpoint does not claim TypeScript parity or full conformance.

Evidence paths below are relative to `selfhost/build/phase45/` and refer to raw
campaign receipts, not committed public artifacts: `runtime-worker08/report.json`,
`runtime-worker09/report.json`, `runtime-worker10/report.json`,
`runtime-worker11/report.json`, `runtime-worker11-vs10b/report.json`,
`number-nat-controls11/report.json`, `number-nat-controls11-v2/report.json`,
`qualify-worker11/report.json`, the six `worker-controls11-*-defaultstack/report.json`
receipts, `diagnose-worker11/report.json`, and `number-nat-isolation02/`.
The causal timing receipt SHA-256 is
`8851cf1bdb499169d349ac9f5c1186df0505aadd25d326ca482e671a16bc8bf6`;
the passing Nat receipt is
`065e51b379fec9ce70aab9be962d218ae776f79c2ad029da67c8edd689fa0cee`.
