# P61-006 — Preserve private native prefix provenance

Registered 2026-10-07 before this prototype's outcomes. Root authorized this
follow-on to [checked frontend reuse](P61-001-shared-frontend-state.md).
Correctness unqualified; measurement not run; decision investigate.

**Hypothesis:** Track the actual leading authenticated Base seed through native
module completion and suffix freshening, so the ordinary private checker can
consume its actual suffix without comparing every Base term twice. State04
Numeric/MapSet profiles attribute approximately 92 ms to the two disjoint
comparison subtrees. This observation is a reason to test, not a speedup claim.

**Invariant:** Only actual successful leading/global seed injection creates the
carrier. Native completion preserves prior KDefs, rewrites its new fragment and
retains the actual suffix. Whole graph diagnostics/name validation, freshening
and checker context/world guards remain. Public raw graphs/seeds/APIs never
acquire private permission; their exact mismatch/fallback behavior stays intact.
The local final-Base-definition list may be reused within one resume only.

**Cheapest disproof:** Complete old/new trace/world equality on actual Base plus
Numeric/MapSet, deep-comparison avoidance counters, and leading/nonleading,
namespace/error/collision/fresh-floor/refusal controls. Retain raw dropped,
reordered and changed-prefix mismatch controls. Stop on any changed source
diagnostic, completed book, emitted bytes or escaped private permission.

[Design and exact dataflow](../../design/phase61/prefix-provenance.md).
Root owns target execution. No target, installed change or promotion is part of
this registration; the transport frame experiment is independently scoped.
