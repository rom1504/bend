# P101-001: native text representation

Status: investigating; no production promotion.

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
