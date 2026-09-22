# P5-013: reject unresolved operator namespaces in the frontend

Started2026-09-22 22:54UTC. Baseline is checked integration/attempt-02
API`c3c2ac7b1456…`. No result is assumed by this record.

Pinned `term_higher` rejects a Ref beginning with one dot before checking. The
Bend frontend currently carries generated `.add`, `.mul` and similar names into
the checker, which reports an undefined name. Four pinned fixtures demonstrate
the wrong phase (`op_bare_refused`, `op_brace_refused`, `op_ns_call_arg`,
`template_ns_late`). Existing operator namespace lowering already replaces
annotated operators; named calls and fixed String/Bool/Pair operators differ.

First candidate: the corresponding single-dot Ref guard in `f_scope_reference`,
with an explicit operator-annotation error. Keep raw grammar, namespace traversal,
core representation and accepted operators unchanged. Reverse operator display
uses the existing f_operator mapping only on this rejected path. This first
candidate does not claim source-location/complete error-text parity. It must
not fabricate positions, introduce a host semantic check, or reject ordinary
qualified names. Earlier/later parser errors expose the existing whole-book
parse/elaboration ordering; record those residuals separately.

Cheap gates: fresh paired live-TypeScript neighbors covering parenthesized
namespace annotations, braces, nested calls/operators, comparisons, direct
methods, fixed operators, and competing earlier/later errors. Preserve all
proposed-oracle failures. Genuine isolated checked build; exact execution for
valid arithmetic neighbors; all previous positive frontend fixtures at combined
gate. Inspect and bound accepted-path cost of the added name-prefix test before
promotion. Record any remaining first-error or diagnostic differences explicitly.
