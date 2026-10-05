# Array write shape: experiment and implementation

The clean public-call experiment in
`selfhost/build/phase47/array-public-timing01/report.json` separates the modest
initial compiler result from the earlier batch-level backing-view opportunity.
The following medians are microseconds per public `bench` call:

| Saved module variant | Median µs |
| --- | ---: |
| Installed worker23 | 90.854 |
| Checked array01 | 84.207 |
| Array01 with ordered write statements | 63.809 |
| Array01 with invariant backing alias | 86.680 |
| Both statement write and invariant alias | 63.986 |
| Array01 with unsafe host-guard bypass | 73.694 |

Ordered statements give approximately **1.32×** over array01 in this screen.
The invariant-alias change does not help, and combining it adds no improvement
over statements alone. Removing the guard explains part of the remaining cost,
but the bypass is an explicitly unsafe diagnostic and is not a proposed release
change. These derivatives are saved-JavaScript experiments, not checked compiler
implementations or broad performance claims.

The separate activation controller confirms the public local-fold entry uses
the raw branch, including zero iterations; missed activation does not explain
this result. Preserve the original four-way batch experiment: its different
wrapper/amortization context does not predict this public-call ratio directly.

The [design](../../design/phase47/array-write-statements.md) implements the useful
operation rule in `j_array_view_statement` and `j_array_view_store_values`.
Existing private vector-field and return emitters call it. It evaluates arguments
once in order, performs the store with its original Number/length operations,
then delivers the same array to the existing result destination. Unflagged and
unsupported expression contexts keep their prior expression spelling.

This is a concrete application of the [LLVM](../../research/compilers_architecture_and_techniques/llvm.md)
and [Go](../../research/compilers_architecture_and_techniques/go.md) survey lesson:
explicit ordered operations can expose useful optimization without adding a
general analysis framework. There is no store elimination or movement here.

Source-array02 freezes this write-only change independently of later admission
normalization. Static delimiter/whitespace checks and independent source review
pass. The root-owned checked build and unchanged 24 independent value oracles
plus 39 boundary controls also pass. Maintained canary timing remains a separate
qualification result; the diagnostic ratio is not a checked-compiler speed claim.
No installed-release or production-speed claim is made by this report yet.
