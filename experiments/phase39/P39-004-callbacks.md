# P39-004 — isolate a known callback with dynamic captures

- Owner: coverage agent; executor/integration owner: root.
- Started: 2026-10-01. Initial status: source inspected, feasibility unresolved.
- Correctness and measurement: no new target observations.
- Decision: investigate; explicitly retain the first-order list finding.
- [Design](../../design/phase39/callbacks.md).
- [Report](../../implementation/phase39/callbacks.md).

Hypothesis: one fixed scalar callback with dynamic scalar captures can use a
direct private worker while retaining list materialization and current demand.
The Phase37 list pipeline contains no source callbacks; it is not a positive
witness. The closures benchmark has real `compose`/`chain` environments and is
a separate feasibility input.

Current `JPure` excludes function-valued signatures. No emission-only patch may
pretend to establish ownership or purity. First acquire a checked affine fixture,
then compare direct-unfused saved output with complete small-result oracles and
adversarial callback controls. Timings follow only after semantic checks.

Root alone runs builds/targets/profiles serially. First 20/60-second screens reuse
acquired modules. Stop if the fixture cannot express safe callback reuse, broad
environment analysis is required, or dispatch removal gives no reproducible win.
Do not change source algorithms or fuse lists in the callback variant.
