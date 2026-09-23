# P5-018 — Natural-number prefix adjacency and precedence

Owner: compact_index. Preregistered during the P5-017 timing hold. No compiler
experiment has run for this hypothesis; no production source changes or speed
claim are authorized by this file.

Pinned `parse_term_num` consumes `+` immediately after the `n` suffix, without
whitespace skipping, then parses a full term. Thus `1n+2n` is constructor-prefix
syntax but `1n + 2n` is an ordinary operator requiring a namespace. The port
instead recognizes the literal suffix in `f_rhs_for` and `f_binary_node`, ignoring
operator position. Both decisions must be repaired together: merely changing
construction would leave the wrong precedence on the right side.

Initial architecture considered carrying operator location into both helpers.
A smaller and more faithful candidate is raw-atom recognition in `f_atom_name`:
require a numeric token ending in `n`, immediate next `+`, same line, and next
column equal to start column plus literal length. Parse the remainder at zero
precedence and use existing `f_nat_plus`; remove the two unconditional binary
special cases. This uses existing token positions and no new lexer token or
persisted term metadata. It also matches an upstream subtlety: the prefix belongs
to `parse_term_base`, so it is consumed even when the surrounding caller has a
minimum precedence above addition. An adjacency guard solely inside `f_grow`
would not establish that equivalence.

Fresh live TS/B1 controls: adjacent/nonadjacent `+`, spaces after plus, newlines
and comments before/after plus, parenthesized left literal, explicit Nat namespace,
chained prefixes, mixed multiplication and addition, prefix inside a high-
precedence right operand, ordinary U32 operators, zero and large Nat literals,
malformed suffix and missing RHS. Use actual output to distinguish association,
not just acceptance. Earlier-error controls must prevent a missing RHS from being
hidden by constructor-prefix rebuilding. Existing arbitrary raw internal helper
calls are not automatically an API compatibility promise; maintained host roots
and emitted source behavior remain the contract.

Keep P5-013 unresolved-operator rejection separate. Its inclusion affects the
phase of nonadjacent Nat operations but does not justify accepting their syntax.
Use the latest genuine integrated snapshot, a isolated overlay, and maintained
workflow. Preserve failed oracles and original artifacts. Stop on any unexplained
nearby acceptance/output change; request review before promotion. Selected gates
are not full conformance, native validation or self-reproduction.

## Selected outcome

The actual wrong-result witness produced8 upstream and5 in the baseline in both
execution lanes; the candidate now produces8. Six invalid acceptances are also
repaired. A first-error regression discovered after v2's initial passing gates is
retained and corrected by validating the literal before its RHS in v3. V4 removes
two unreachable helpers, has a fresh checked source proof and produces API bytes
identical to v3. Root approved promotion after focused/raw/execution gates.
The semicolon acceptance and malformed float-suffix diagnostic residuals remain
explicit. See [the report](../../implementation/phase5/frontend-nat-prefix.md)
for exact artifacts, failed attempts, scope and archive; no performance or
full-conformance claim is made.
