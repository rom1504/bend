# P5-014 — Named matcher arm heads

- Owner: compact_index; reviewer: root, coordinated with lexer_analysis.
- Started: 2026-09-22 during the second integration gate.
- Correctness: static diagnosis; live selected probes pending CPU release.
- Measurement: none. CPU1 short correctness probes, Node4MiB stack/4GiB heap.
- Decision: investigate a narrow isolated matcher-head condition, no source edit yet.

Pinned `parse_term_base` accepts a matcher arm before `:` only when the parsed
head is Var or Ref. A different term is the tail; the parser then expects `}`,
so `\\{0: ...}` rejects at its colon before checking erasure or constructor
membership. The port's `f_matcher_head` checks only for the colon and constructs
a Mat from any term's name. The three pinned fixtures `check/erased_match_numeric`,
`flatten/statement_beta` and `flatten/statement_lam_absorb` consequently parse
successfully and fail later at checking.

The raw Bend frontend represents unresolved variables and references as Ref.
Guard the colon arm using that raw shape; preserve the existing tail/expected-`}`
route for numeric/string/constructor/application heads. Do not implement numeric
matching or alter the checker. Actual parser/scoper shapes must be confirmed for
parenthesized and marked names before choosing the final guard.

First gates: fresh live TypeScript and genuinely checked integrated B1 on the
three pinned fixtures, minimal numeric/string/Ctr/Call heads, invalid head plus
invalid body (first-error order), valid named/qualified/parenthesized/marked heads,
ordinary tail and empty matcher, plus applicable interpreter/JS outputs. Exact
pinned diagnostics remain distinct from custom acceptance/phase oracles; never
silently override a pinned `#|` oracle. Existing cases and failed attempts remain
immutable. Use a frozen overlay and the maintained development workflow.

Adjacent hypotheses are controls, not automatic scope extensions: the port may
reject one optional tail semicolon or accept multiple arm semicolons through
`f_skip`; its backslash atom also assumes rather than checks the opening brace.
Record fresh mismatches separately and request a bounded extension only when
supported. Root owns bare-operator changes, lexer owns error transport; the matcher
condition must compose deliberately with those parser edits. No broad run or
compiler job during the current all-core hold.

The exact candidate, selected observations and retained limits will be reported
in `implementation/phase5/frontend-matchers.md`. No performance, full-conformance
or fixed-point claim follows a selected parser repair.

## Selected result

The one-condition genuine checked candidate passes16 custom checks and12 exact
interpreter/JS observations. All six original pinned parse/check phase differences
are repaired; three strict pinned diagnostic checks remain failures. Six fresh
minimal baseline gaps are repaired, with additional actual annotation/lambda/
quantity controls. The initially misclassified namespace-expression key remains
as a failed oracle attempt and is corrected in a separate manifest.

Independent lexer-analysis review finds no composition conflict with P5-011.
Three sibling grammar discrepancies are freshly confirmed and remain failed
residuals: missing opening brace, repeated arm semicolons, and optional tail
semicolon. See [frontend-matchers.md](../../implementation/phase5/frontend-matchers.md)
for exact artifacts, all scopes and preserved attempts. Root's checkpoint and
production decision remain separate; no performance claim follows.
