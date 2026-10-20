# Namespace flat-traversal overlay

`namespace-tail.bend` replaces the six flat list walkers with wrappers starting
a direct self-tail accumulator at `True`. The original namespace predicates,
their diagnostic string, and the complete original verification gate remain
unchanged. Frozen `namespace.bend` and `modules01.json` are preserved.

For each list, the helper invariant is: `go(xs, accumulated)` returns
`accumulated AND old(xs)`. The empty case returns the accumulator. Each nonempty
case computes exactly the old predicate for the head, combines it with the
accumulator, and directly tail-calls itself on the original rest. In the direct
body walker, a branch head contributes both original branch-body predicates;
an ordinary ignored head contributes `True`. Functions contribute their original
parameter and body predicates; segments contribute their original scalar-body
predicate. Boolean conjunction's identity and associativity establish the same
result for either incoming accumulator. The public wrappers therefore return
exactly their previous predicates on every finite input.

All six list-tail calls are the returned expression, with no conjunction waiting
for the recursive result. The overlay constructs no replacement lists and
changes no name rule or IR data. Nested branch traversal remains recursive, so
the stack claim is limited to flat list length, including the large segment
catalogue; it is not a guarantee for arbitrarily deep syntax trees. Existing
verification still precedes namespace checking and retains its original errors.

This is a source derivation, not a new kernel-checked theorem. The source author
ran no compiler/API/native/benchmark target. The coordinator owns source checking,
ordinary small-program QBE equality, and the full-source acquisition retry.
The separate inventory pins the selected parent source/API/admission and exact
transport dependency. The independent IR reviewer inspected frozen source
`8006bf1482b9ebec30da17830198b9b3ad33596e94fee5430bdea4ba2f5cdde0`
and found no concrete equivalence defect: all six self-calls are outermost
returns, conjunctions compute only the next accumulator, and the original
branch traversal and error wrapper are unchanged. Generated-JavaScript loop
inspection and target qualification remain coordinator work.
