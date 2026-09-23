# P5-022 — Render the selected embedded parser Error

Preregistered before execution, 2026-09-22; owner lexer_analysis, root promotion.
Bounded25-minute isolated prototype, separate from P5-019 expectation sites.

Integration03's `flatten/statement_lam_absorb` exposes a transport composition
gap: an Error nested under a local body has explicit ParseExpected metadata,
but FRawResult.error is Absent. Later f_error_defs extracts only Error.name.
The accepted matcher correction must not be reverted or duplicated.

Hypothesis: after the existing graph result has selected a nonempty error, a
second traversal in exactly f_error_defs order can retain the selected Error term
and its top-level declaration index. Existing Loaded declaration counts map that
index to the actual source. Verify the selected term's name equals the original
authoritative error, then invoke the existing source-aware renderer. This is an
error-only refinement, not legacy English parsing or a new error selector.

The accepted/error-free path must not scan the book again. Existing graph errors
and freshness checks retain precedence. Empty-name Error handling, definition
type/value/constructor order, module ordering, law/fill events, seeded Base counts,
ambiguous/missing source and already complete diagnostics require explicit gates.
Unknown metadata or missing source retains the original text. No source guessing,
early AST Error bubbling, public result-type change, or successful-path rendering.

First gates: genuine checked wrapper; actual upstream regression plus nested local
and imported-module controls; two-errors/first-error controls; ordinary/traced/
seeded loader parity; P5-011 targeted controls and existing167 comparison where
feasible. Accepted raw parse results remain untouched. Broad conformance verdicts
and exact-diagnostic changes stay explicit, and any changed-but-mismatching case
is a failed candidate gate. No performance claim or automatic promotion.

The wrapper calls the existing f_graph_result rather than replacing its freshness
chain, preserving independent P5-020 work. Legacy standalone f_elaborate without
source text may retain legacy formatting; its unsupported scope is explicit.

## Explicit gate amendment after the first full selection

The original unchanged-or-exact gate **failed** and remains preserved. In167
fresh baseline/candidate/live-reference observations, three diagnostics changed:
`check/undo_residual_lane` became exact, while `parse/array_key_range` and
`parse/duplicate_buffer_key` remained mismatches. Both residuals formerly selected
`expected ]; got :` at line10, columns13/8. The candidate renders that same Error,
expectation, observed character and source location; TypeScript already selected
an earlier comma and expected `^`. These are unresolved parser/first-error
differences, not two new repairs. All seven formerly exact diagnostics remain
exact, and no classification changed. The focused statement_lam_absorb fix is a
separate control, not the newly exact member of this167 selection.

Root and independent reviewer explicitly approved a revised *presentation* gate:
retain the authoritative chosen Error, source ownership and first-error order;
preserve every prior exact observation; verify the two residual raw parse results
and actual Error metadata are unchanged; retain faithful but still divergent
rendering visibly. This amendment does not redefine the failed original gate as
passing. No fixture-specific filters or matcher-context tags were introduced.
The general renderer is preferable to hiding known parser divergence behind
special formatting exceptions. Final promotion requires the remaining controls
and narrow composition with the unchanged P5-020 freshness chain.

## Promotion and retained integration residual

All remaining raw-result and metadata/order controls passed. The general wrapper
was promoted with explicit P5-020 graph SHA/body guards; no grammar-context tags
were added. The original33 focused controls prove unchanged baseline behavior or
exact repairs, not universal paired agreement. Combined04 retained a missing-file
control that both old/new Bend hosts label load while TypeScript labels parse;
that pre-existing phase/diagnostic difference remains in the original failed
run. The new confirmed integration manifest explicitly excludes only this case.
No oracle or historical outcome was silently changed.
