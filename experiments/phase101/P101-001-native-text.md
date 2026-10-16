# P101-001: native text representation

Status: initial experiment complete; retain prototype, no production promotion.

Design: [ambitious agenda](../../design/phase101/ambitious-native-agenda.md).
Baseline: [Phase100](../../implementation/phase100/README.md).

Hypothesis: replacing per-character linked storage and reconstruction at a
general native String boundary can substantially improve text-heavy application
execution and compiler text processing. The 2–5× estimate is a hypothesis.

Falsifiers: real application profiles show little relevant work; contiguous
storage merely moves cost into materialization; aliases or append force copying;
generated code bypasses the proposed boundary; memory/thread/GPU requirements
outweigh the gain; the independent complete-output contracts disagree.

Root runs guarded serial targets. Offline reviewers inspect ABI/ownership and
prepare semantic controls. Experimental C interventions, compiler-produced
implementations and installed releases are reported separately. Exact run
evidence, failures and the decision will be linked here as they become available.

## Result

[Report](../../implementation/phase101/README.md) ·
[Results/evidence bindings](../../implementation/phase101/results.json) ·
[Verified capsule](../../implementation/phase101/evidence/README.md).

The final six-round renderer comparison takes 0.585×/0.603× installed-B2 time
at one/four workers, 0.763×/0.894× upstream time, and about one-third the memory.
Indexing remains 1–3% slower while using less memory; graph planning regresses
4–6%. The stronger two-application speed gate is unmet, so no compiler-image
rebuild, compiler-latency claim, emitter integration or global promotion follows.

Storage alone was insufficient; naive sparse chunks used about 506 MiB and
regressed. Packing short prefixes and eliminating character-by-character append
continuations produced the win. Borrowed chunk comparison helps but does not
remove graph overhead. All failed interventions/captures are retained.

Final checks: 90 independent String controls, 165 executions over all 50 app
inputs, and 108 repeated-screen executions pass complete outputs. Accepted
physical profiles separate append/reconstruction from indexing's large saved
continuations. Next: cursor/consumer cost, adaptive small strings, an iterative
append ablation with old storage, and certified whole-function typed lowering.
