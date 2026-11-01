# P150-003 — preserve scalar comparisons before frontend expansion

Status: validated bounded counterfactual; not a whole-compiler optimization.

This experiment was added after the first lexer made complete parser acquisition
43.87% slower despite better execution and only0.69% larger final QBE. Repeated
ordinary builds confirmed the penalty before profiling was commissioned.

Hypothesis: literal character/matrix patterns expand to large bit-level terms,
which the frontend repeatedly reconstructs and traverses before final code gets
small again. Test grouping first, then scalar predicates with the same direct
String consumption, output ABI and fused quote metadata.

Small-probe acquisition: literal30.766s, grouped24.186s, scalar8.599s (one each).
The selected scalar lexer remains4.43× faster than reference; complete parsing
is9.62% faster. Complete parser acquisition45.591s no longer shows the earlier
66.934s penalty against46.525s reference. Exact token and graph controls pass.

Profiles place97.5% of the extra diagnostic wall time in seven frontend/lowering
intervals. Owner samples are descriptive because individual stages have fewer
than500 observations. Code/runtime inspection supports the expansion mechanism;
no general dependent-pattern rewrite or whole-build speedup is established.

See [report](../../implementation/phase150/README.md),
[profile](../../research/phase150/parser-acquisition-profile-results.md), and
[remaining source targets](../../research/phase150/literal-pattern-audit.md).
