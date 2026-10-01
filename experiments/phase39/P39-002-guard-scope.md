# P39-002 — amortize guards at an existing scalar root

- Owner: coverage agent; executor/integration owner: root.
- Started: 2026-10-01. Initial status: source inspected; target runs pending.
- Correctness: prospective; existing Phase37 gates are inherited only.
- Measurement: none in this experiment yet.
- Decision: investigate; no production source changed by this record.
- [Design](../../design/phase39/guard-scope.md).
- [Report](../../implementation/phase39/guard-scope.md).

Hypothesis: `coverage.active` can reuse its complete valid entry proof throughout
its existing synchronous scalar body, reducing repeated host/dependency checks.
The exact final module SHA256 is
`a4bb4434cc19e9adfbe283a2679a032ca59577c531de9d407ea627080324bfaa`.

Derive unchanged, scoped, and scoped-without-finite variants. Keep every public
entry check and fallback. Separate counters from timing. Source integration,
if earned, reuses `j_tree_scope`'s independent original-term purity proof.

Root executes exact controls before 20/60-second paired screens on active-ray
64 and 256. Use CPU3, Node24.18, 1024 MiB heap, 2048 MiB process-tree ceiling and
2048 MiB available-memory floor. Preserve all failed attempts and source hashes.
Stop at changed observable behavior, incomplete graph coverage, no actual entry,
or a null performance result. A scope is never cached across public calls.

Commands, observations, independent review and eventual admission are appended
to the implementation report; this prospective design remains a distinct input.
