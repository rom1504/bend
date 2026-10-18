# P107-012: propagate scalar invariants after representation changes

Scalar field promotion exposes ordinary U32 locals, but backend code can still
spill a counter that returns to its initial value on each loop iteration. Test a
general constant-propagation pass rather than a reference-count-specific rewrite.
The same pass should simplify scalar snapshots, branch agreements and arithmetic.

The lattice records only known U32 values; absence means unknown. Parameters start
unknown and U32 locals start at their IR-specified zero. Assignment substitutes
known scalar values and applies the existing exact wrapping-U32 literal folder.
Loads, calls and allocation remain at their original statement positions; their
results are unknown. Pointer/U64 variables never become constant facts.

At branch joins retain only agreeing facts. For each loop start from preheader
facts, repeatedly intersect the current header with abstract body exit until no
facts disappear. Facts never change value or reappear in that iteration, so the
initial known-fact count plus one bounds convergence; exhaustion yields unknown.
Only then rewrite the loop condition and body. Nested-loop abstract transfer
forgets all assignments in that nested loop, avoiding exponential nested fixed
points; its eventual rewrite computes its own safe header independently. Preserve
control-flow shape, effect ordering and every zero-trip path. No load hoisting,
branch deletion, ownership inference or memory-layout assumptions.

Freeze full-result controls before target execution: invariant counter, changing
loop condition, zero iterations, equal/differing branch joins, old-value snapshots,
load/call results, wrapping overflow, nested-loop assignment and U64 nonpropagation.
Input/output structural verification, finite source caps and nonincreasing IR node
counts gate publication. Test deliberately stale loop and branch facts against the
same independent oracle. Qualify native outputs before interpreting backend gains.
If review/checking cannot finish within this bounded slice, leave the pass prepared
and unintegrated. Existing pass behavior and installed compiler defaults remain
unchanged. This is finite validation, not a proof of global compiler correctness.
