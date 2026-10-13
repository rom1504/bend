# Unpromoted scalar-pattern compiler

`candidate10.patch` reconstructs the full source prototype from baseline
6becf8675ce6b485ea8072df374bf61aeb564d09. `word-pattern.bend` is the same module
for direct inspection. Neither is in the active compiler manifest.

The rule is structural, not specific to function names or benchmark inputs.
It collects scalar bit-prefix rows, proves inherited fallback equivalence under
binder identity, retains a private prepared term and removes exact scalar
reconstruction round trips. Unsupported shapes keep ordinary lowering.

Candidate10 passed its checked frontend build and 20,521 independent controls.
It was not fully release-qualified. Candidate08 has the strongest complete
compilation/runtime comparison; candidate10 is a follow-up rejected on the fast
runtime gate. See P76-008 and the Phase76 report before reusing either.
