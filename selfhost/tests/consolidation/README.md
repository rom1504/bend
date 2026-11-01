# Consolidation continuity controls

These are maintained fixtures, not alternate compiler implementations.

* `native-focused/` contains 19 exact retained sources: 16 whole-output positives
  and 3 explicit refusal controls.
* `native-broad/` contains 45 exact retained small programs and their full output
  oracles. They are correctness controls, separate from runtime timing points.
* `cli/` contains the public hosted CLI fixtures; its catalog also specifies
  exact option/refusal behavior.
* `hosted/` contains the separately captured hosted/installed continuity probes.

Use [the qualification guide](../../tools/conformance/qualification.md) and
[`qualification.py`](../../tools/build/qualification.py). Catalog provenance
identifies independently written versus retained reference observations; no
candidate output is promoted into an oracle. The runner reads these copied
sources and current maintained adapters only. Historical sources, failed
attempts and lineage records remain available separately.

The finite controls do not prove full conformance or mathematical validity.
Unsupported target/refusal combinations remain explicit. The installed public
native CLI, parallel execution, GPUs and independent BendTT proof checking
require their own evidence.
