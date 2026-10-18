# Bounded scalar constant propagation

API: `nx_constant_propagate(program: NxProgram) -> NxProgram`.

Only U32 constants are tracked. A known-value fact has a local/parameter name and
a wrapping U32 value. Name binding updates kill the previous fact before installing
a literal result. Nonliteral and effectful result assignments become unknown;
unrelated private scalar variables survive calls/stores/free because the IR has no
address-of-local operation. Function parameters are unknown, U32 locals are zero,
and Ptr/U64 locals are untracked. Known constants never grow expressions.

Branches analyze both arms and intersect agreeing facts. Loop headers are a
descending chain from preheader facts; intersect each candidate with abstract
body exit. Equal fact counts imply equality because intersection only removes
unchanged facts. A bound of initial fact count plus one suffices, with all-unknown
fallback. Nested loops in this abstract transfer havoc every assigned variable;
the rewriting walk computes their own fixed points recursively. After a loop only
the header facts survive, which includes the zero-iteration case. Returns remain
in place; conservatively analyzing a returning branch can only lose information.

No control flow or effect statement is deleted. Function caps: 4096 body nodes,
128 parameters plus locals and control nesting at most 16. Program caps: 256
functions and 65536 nodes. Verify input/output and require nonincreasing node count.
Unsupported/capped functions and invalid programs remain unchanged. This optional
pass has no dependency on memory provenance and can run after scalar promotion.

Before verification, `nx_cp_has_eligible` scans for any function satisfying the
same `nx_cp_eligible` predicate used by the rewriting gate. Binding count is
checked first, then body size and control depth. If none qualifies, return exact
identity without claiming validity. Program-level function/node caps remain later
gates: a true preflight is necessary but not sufficient for transformation. A
false preflight cannot skip any function that the existing pass could rewrite.
