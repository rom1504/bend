# P120-001: operands, lanes, then a bounded numeric region

Status: first bounded cycle completed,2026-10-21. Parent qualified Phase118 safe03 at`962a3ef`.
Question: does preserving numeric representation across a larger structured
computation remove materially more work than the existing local prototypes?

First reacquire separate exact-parent ablations for Phase114 scalar-operands,
then scalar-operands plus local float lanes. Those are existing mechanisms;
their benefit must not be described as a new region optimization. Original
verification, runtime and integer public/private ABI remain unless explicitly
identified by a later candidate. Phase120 region modules are separate.

Use original active-ray256, raytrace, numeric-recurrence1024, scalar and ordinary
float/copy controls. Reserve the full45 for a useful transferred candidate.
No workload names in compiler selection. Arithmetic order, rounding, NaNs,
signed zero and source error behavior remain obligations. Inputs and whole-output
oracles stay frozen. Actual current parent binaries are the Phase118 screen,
not the older Phase117 default in the historical screen harness.

Record source/API/emission/build/runtime identities and all failures. Compare
clean execution independently from profiles/static counts; inspect the actual
changed functions. Root owns serial CPU3 target runs; an offline agent develops
isolated Bend modules. No full native-image/default change in this first test.

Initial source:`selfhost/build/phase120/operands-source01/manifest.json`.
Later evidence and conclusions will be added after measured runs.

## First-cycle outcome

Completed focused ablations and original45 integration; see the
[report](../../implementation/phase120/README.md) and Phase120 receipts.
Operand-only/local-lane/initial-region/metadata/profit active-ray ratios are
0.9728/0.8698/0.8297/0.7994/0.7825× their paired parents. The integrated original45
run improves active ray21.69% and ordinary ray2.39%; no broad2× claim.
Both intended intersection calls disappear under unchanged growth/stack limits.
The exact-output shortcut avoids range cleanup on unchanged functions. Original
ABI/runtime stay fixed; no full native-image or production promotion.
