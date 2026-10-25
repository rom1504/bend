# Second falsifier: shared source, statically specialized traversal

This small experiment follows the parser deletion. It tests an existing Bend
feature as a potential simplification tool, without adding an optimizer pass.

The current Phase140 compiler has ten hand-specialized exact list comparisons.
They avoided the runtime callback dispatch of the older generic comparator.
Bend's `~` parameters already offer a third option: a closed comparison function
is substituted at compilation, while the list and any explicit state remain
runtime arguments. The same source loop can therefore produce distinct
first-order implementations. This is ordinary static specialization, not a new
claim of recursive compiler improvement.

The source audit finds the mechanism in the pinned upstream guide and Base
`List.contains`, `List.filter` and folds, and in the selected compiler's template
checking/materialization path. Closed arguments must be checked without local
runtime variables. A captured runtime value must be passed as explicit state,
not hidden inside a template key. The language's template ordering rules apply.

The previous Phase7 binding-schema failure was broader: a runtime mode/shape
machine with a more complicated worklist grew source and slowed both operations.
Static callbacks do not remove its shape classification, frame allocation or
invalid-state combinations. This experiment tests the actual Phase140 callback
boundary, and cannot inherit success for a general AST walker.

## Cheap decision gates

1. Source-check one static list comparator and its explicit-state variant.
2. Compare all ten typed cases against the independent existing generic and
   hand-specialized implementations. Include mismatch, length, recursion and
   wraparound cases. Finite comparisons are not equivalence proofs.
3. Compile a small runtime-parameterized native workload through the existing
   Bend compiler. Inspect actual called code for callback dispatch and measure
   against hand-specialized code, with allocation/input construction outside
   the measured repeated comparison where possible.
4. Count replacement source, call-site type/policy arguments and necessary
   adapters. Charge template instance checking, generated code and build cost.
   Sharing source can leave machine size unchanged or increase it.
5. Only a measured favorable result justifies replacing complete traversals in
   production. A test-only generic helper earns no compiler deletion credit.

Potential follow-up: static policy plus explicit typed runtime state for a
measured repeated traversal. Reject a universal callback walker or new runtime
mode machine. To support a substantially smaller compiler, the method must
eventually replace whole algorithms/representations, not merely shorten loops.
