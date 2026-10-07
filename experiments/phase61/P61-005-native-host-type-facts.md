# P61-005 — Proved native leaves in host type analysis

**Status:** proposed implementation and focused falsifier; not yet qualified.
**Parent:** [Phase61](../../design/phase61/architectural-compiler-speed.md).
**Design:** [Native host type facts](../../design/phase61/native-host-type-facts.md).

The state04 MapSet diagnostic places 27.55% of CPU samples and 54.65% of sampled
allocation under host Nat classification. U32/F32 unnecessarily expand Word(32)
types there; the pinned TypeScript marshaller treats them as Nat-free leaves.
The shares overlap other named families and do not predict a clean speedup.

Hypothesis: once-per-export-context proofs from the unchanged classifier can
avoid repeated native scalar graph construction, normalization and serialization,
while preserving supported host wrappers and all required Nat conversions.

The candidate adds `direct/host-native.bend` and four host hooks. A native nullary
owner receives a fact only after a completed old zero result. Facts are immutable,
local to the export context, freshly overwrite reserved metadata, and are absent
from the emitted definition list. The actual ADT must also be nullary. Positive,
unknown and unprepared cases retain the original behavior.

The public old classifier is unchanged. The internal 1,024-node limit now counts
proved native types as leaves; formerly budget-refused valid graphs may complete.
Root explicitly authorized this resource-policy improvement instead of preserving
the accidental cost of expanding primitive representations. Depth64 remains.

First disproof: actual checked B1 helper comparisons in
`selfhost/tools/performance/phase61/host-native/controls-v1.mjs`. Eight inherited
wrapper/event cases plus native-owner, forged-fact and budget controls precede
timing. Any false no-Nat result, changed supported wrapper/event, or mutation
rejects the candidate. Saved complete output, genuine B2 and unchanged contrasting
request measurements decide whether the additional source earns retention.

Source proposal and before/after patch are under
`selfhost/tools/performance/phase61/host-native/`. No target result, performance
claim, installation or selection is recorded at this registration checkpoint.
