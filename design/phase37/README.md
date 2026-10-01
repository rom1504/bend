# Phase37: broaden coverage before another optimization

## Sequence and frozen baseline

First expand the execution benchmark, then measure the installed Phase36 compiler
before touching production compiler source. Preserve the historical catalog of
15 points / 13 sources byte for byte. The starting release is commit
`dfa5e03f02692d60b212b1d7e852213634fcfd93`, checked03 API
`93e55ad7ee456eebb5fa3dd9606c2cf262ea386c6f66bfd891ffe187d8f50a75`.
The unchanged TypeScript reference pin is
`018751270e800bc222a93dad7f257083ee53a5f7`.

1. **Coverage.** Freeze additional input sizes, seeds, active work, and program
   families before inspecting optimization outcomes. Record source ancestry,
   coverage dimensions, exact inputs and independently computed or explicitly
   differential oracles. Retain unsupported or failed acquisitions as evidence.
   Reserve whole program families for final validation, not optimizer tuning.
2. **Baseline.** Acquire checked Phase36 and pinned TypeScript outputs serially.
   Execute bounded development chunks. Budgets select measurement depth and remain
   independent of workload selection; a larger catalog need not fit one 600-second
   run. Keep compilation, ordinary timing, profiles and syntax analysis separate.
3. **Discriminating experiment.** Test the smallest useful private finite-sum /
   tree-to-tree operation using frozen generated output, guard-only controls and
   complete outputs. Start with tree-bitonic. This is an experiment, not a checked
   compiler optimization. Preserve demand, error order, sharing, public mutation,
   dependency guards and recursion semantics. Purity alone does not allow eagerness.
4. **Implementation conditional on evidence.** Implement a surviving general rule
   in Bend, never by benchmark name or constants. Obtain a fresh checked B1, prove
   actual entry with controls, rerun relevant semantic gates, then compare fresh
   baseline/candidate/TypeScript timings on both old and new development coverage.
   Use reserved families once for final acceptance. If no proposal survives,
   retain the improved suite and report the rejection without claiming a speedup.
5. **Report and publish.** Report every measured point and failed attempt, observed
   ranges and costs, lines/concepts, semantic scope, source and compiler identities,
   and remaining coverage gaps. Commit and push authorized work. Do not comment
   on the upstream PR. Install a changed compiler only after applicable release gates.

## Scope and constraints

Expanded coverage is purposeful diversification, not a random sample of all Bend
programs or proof of full variability. Measure sequential generated JavaScript;
compiler throughput, startup, native/GPU execution and full-language conformance
remain separate. No arithmetic mean of fixed-point slowdown ratios is a claim
about usual applications. Keep the original suite as a historical regression gate.

Root alone runs builds, tests, timing, profiling and archive jobs, serially on CPU3
with Node24, heap at most1024MiB, process-tree RSS at most2048MiB, at least2048MiB
available memory and deadlines. Agents author and inspect independent files.
Preserve the103 unrelated starting files, human-written bend2/bend.ts, and closed
Phase35/36 raw evidence. Every attempt gets a new output directory; never overwrite
failures. Use the shared supervisor once per job, never nested.

See [coverage](coverage.md), [applications](applications.md), and the
[direct-worker hypothesis](direct-workers.md). Outcomes belong in the
[implementation report](../../implementation/phase37/README.md).
