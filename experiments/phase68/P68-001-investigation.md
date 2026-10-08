# P68-001: native transport and C request investigation

Status: registered, 2026-10-08. Baseline `b6eb575`, checked B1 `c76f1113…`,
genuine B2 `cbffd1f8…`, upstream `0592662`.

Hypothesis: closure currying, scheduler frames and boxed product transport
explain most of the remaining native runtime gap; redundant backend work also
inflates C request/Clang time. This is not yet measured causality.

Before changing production code, replay the six-family cached loop; collect
paired numeric/array/lexer allocation/refcount/segment deltas and bounded native
sampling if usable. Collect fresh B1/B2/TS C request clocks and request profiles,
with imports and mandatory preparation outside those clocks. Independent output
oracles, exact artifact/toolchain identity and separate diagnostic clocks are
required. Raw: `selfhost/build/phase68/`; no earlier writes.

Reject or reprioritize hypotheses when profiles lack the proposed operations,
or when removing them does not improve clean timings. Research current upstream
and primary compiler sources; rank mechanisms by broad applicability, measured
headroom and bounded implementation/validation effort.

Results: pending. Promotion: none. See [design](../../design/phase68/native-parity.md).
