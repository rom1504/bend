# P140-001 — Skip unchanged source-to-QBE work

Status: implementation started 2026-10-25 18:12 UTC at `7e5067c`.
[Design](../../design/phase140/README.md).

Hypothesis: composable parser/checker/preparation/rendering reuse can make real
localized compiler edits much cheaper than fresh whole-program compilation.
Aim for 10× warm source-to-executable improvement, without material runtime
regression. Existing late caches did not establish such a gain.

Falsifiers: local edits invalidate most weighted work; mandatory fresh stages
exceed the budget; exact dependency checks or retained-state destruction cost
more than skipped producers; any stale reuse changes diagnostics or output.

Evidence will separate small controls, skipped producer time, complete requests,
native acquisition, machine construction and qualification. Preserve all failed
attempts. No speed improvement or compiler promotion is established yet.
