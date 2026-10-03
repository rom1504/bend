# Phase42 time and efficiency account

The experimental execution window was 2026-10-03T18:12:27+00:00 through 2026-10-03T23:17:30.650551+00:00. Final documentation, archive publication and Git delivery follow this explicit cutoff; they are not included in the experiment-window totals.

- Elapsed: **5.08 hours** (305.06 minutes).
- Union of recorded enclosing jobs: **88.79 minutes**.
- Unclassified wall time: **216.27 minutes**.
- 335 completed enclosing jobs: 292 zero-return and 43 failed; 0 incomplete.

Unclassified time includes uninstrumented analysis, editing, reviews, handoffs, documentation and tools. The ledger cannot divide those activities or call the remainder idle time, model latency or agent latency. This campaign was **not mostly time spent waiting for recorded validation**. Failure counts are job outcomes, not counts of compiler defects.

| Recorded category | Jobs | Failed | Summed minutes |
| --- | ---: | ---: | ---: |
| derivation, preservation and accounting | 61 | 8 | 2.89 |
| controls and verification | 126 | 20 | 18.69 |
| generated-program timing | 28 | 0 | 30.13 |
| profiling | 4 | 0 | 1.22 |
| checked build | 8 | 2 | 4.50 |
| checked acquisition | 47 | 4 | 11.05 |
| other recorded work | 55 | 9 | 13.07 |
| compiler-request sampling | 6 | 0 | 7.26 |

Categories are classified from commands/labels; compiler-cost preparation is included with cost work. Summed intervals may overlap; the union is the wall-time measure. Nested child supervision is not added again. Complete commands, UTC boundaries, receipts, source counts and every failed job are in the [timeline](accounting-timeline.md) and [machine account](accounting.json).

## What the team accelerated, and what delayed delivery

Seven owner/review roles investigated calls, frames, layout, fusion, facts, validation and independent correctness concurrently. Root serialized heavy jobs to preserve memory bounds and timing quality. Saved-JavaScript ablations quickly rejected several frame/Map/representation proposals, while positive mechanisms transferred to checked source and independent fixtures. No causal speedup or cost saving from seven agents can be inferred without a comparable serial campaign.

The main avoidable integration problem was late discovery of overly specific instrumentation and collector assumptions. Lexical private clones exposed global-only counters; cross-role runtime equality was inappropriate after a runtime change; filename, relative-path and row-adapter assumptions required versioned repairs. Those were different from the real shared-equality regression caught by the unchanged vector gate. The source was frozen throughout the later assay repairs; broad frontend/backend work was retained for that exact image.

The full 45 clean runtime protocol alone took 19.59 minutes across three batches. Four-case compiler-cost sampling took 4.36 minutes; profiles of six programs took about 1.09 minutes. A single600-second full-catalog run would have been impossible because its mandatory warmup exceeds600seconds. The final three batches preserve the requested669samples.

## A tighter next loop

1. Give agents separate, testable mechanism questions with a small saved-output ablation and a concrete stop decision. Reassign closed investigations; do not start more tool scaffolding merely because slots are free.
2. Run old-consumer admission checks immediately after a shared predicate changes. The quantity-2 vector preflight belonged before the candidate freeze.
3. Make instrumentation scope-aware and bind each role to its own receipt. Inspect actual emitted paths before writing counter expectations; keep semantic oracles independent of code shape.
4. Use the portable20-second changed-family screen first. Its tree/list/BST replay completes in9.90seconds here; the standard five-point replay takes16.48seconds. Compiler acquisition and semantic controls are separate costs.
5. Freeze once, reuse already-passing exact-image receipts, and perform broad qualification once. Batch final runtime/cost/profile work explicitly, with no competing heavy processes.

See [failure lessons](failure-lessons.md) and [iteration efficiency](iteration-efficiency.md) for examples. No additional source tuning was hidden in final qualification.
