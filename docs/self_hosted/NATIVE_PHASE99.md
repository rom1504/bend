# Phase99 native borrowed-call profile

Status: optimization discovery in progress; Phase98 remains the installed default.
The [report](../../implementation/phase99/README.md) separates completed experiments
from release qualification. The [Phase98 guide](NATIVE_PHASE98.md) describes the
unchanged native request interface, supported imports/providers and runtime limits.

The compiler remains written in Bend. Upstream compiles its source to C to obtain
native B1; B1 compiles that same source to C to obtain native B2. Clang builds each
C image. Compiler requests execute those native binaries. Python authenticates
and transports files; it does not implement compiler passes.

## Change and constraints

Read-only observers can call another already certified observer without converting
borrowed cursors back into owning arguments. An internal registry records the
callee's admitted schema and private worker. Admission requires matching root
types, argument count, live-root ancestry and scalar results. Residual calls
carry their private-worker dependency. Ordinary owning compilation remains the
fallback for unsupported calls, escaping children and uncertified helpers.

The outer adapter keeps the original roots alive and releases them after the
borrowed call returns. Moving a cursor does not move its owning root. This is a
restricted interprocedural extension of the existing observer analysis, not a
general borrow checker or a change to reference counting.

The redirect accepts either an existing shared root or **all schema roots being
trivial to release**. The latter includes immutable static strings, whose sharing
does not set the runtime reference-count bit. Only root argument positions count;
scalar arguments do not. With no shared root, mixed static/unique-dynamic inputs
and two unique dynamic inputs keep the owning path. Runtime `term_sink` immediately
returns for trivial terms; the new alternative adds no cleanup traversal.

Both changes retain the existing schema authority and checked provider boundary.
The source04 checkpoint does not add generic KTerm projection, mutable-array borrowing, allocation in
borrowed workers, effects during traversal or escaping borrowed children. Scalar
narrowing, array permissions and runtime atomic protocols are unchanged. The
separate scalar-width experiments were rejected after their execution timings
failed to improve.

## Exact source and evidence

The source04 checkpoint is 1,762,973 bytes and 38,922 physical lines, SHA256
`c19e926eb7d8d41309c9ed8aa18960c484f3b17681507b57da5418ccfedd31ec`.
That is 132 lines and 8,877 bytes above Phase98. The canonical 134 modules and
installed JavaScript release are separate and unchanged.

The discovery successor `274b65b5…` adds 175 lines and 9,462 bytes to source04.
It admits bounded plain aggregate schemas, keeps applied fields opaque, and
allows certified scalar calls on fields below a live parent root. It also
expands small closed saturated selectors into direct branches when their actual
arguments include literal lambdas. Nonliteral arguments retain their ordered
evaluation; unsupported shapes keep ordinary calls. A single interval traversal
replaces 64 repeated freshness scans. These are general shape/type rules, not
compiler-helper-name substitutions.

The small native probes demonstrate borrowed tag reads and branch allocation
removal. Whole-compiler measurements and release qualification remain separate.
The experimental native image is acquired by executing the checked Bend compiler
through a JavaScript host to emit C, then building that C with Clang. Its compiler
requests are native; this acquisition shortcut is not a qualified B1/B2 chain.

Six source-bound laws have independent BendTT/Lean checks: three preserve
residual argument order/failure information, and three constrain the emitted
all-trivial predicate. Six safely admitted mutated helpers fail those laws.
These local statements do not prove native lifetime safety, the complete
analysis, generated C or whole-compiler correctness. Native executions, complete
output comparisons, self-reproduction and code inspection remain separate gates.

See the [design](../../design/phase99/native-scalar-and-borrowing.md),
[static-route audit](../../implementation/phase99/borrowed-static-route.md),
[law assessment](../../implementation/phase99/law-usefulness.md) and
[release procedure](../../implementation/phase99/release-plan.md).

## Fast iteration

Start with the exact-source checked testing API and small native controls in
`selfhost/tools/performance/phase99/borrowed-call-tests/`. Those establish code
shape and complete output before paying for a full native image. Compare the
10-million-call static and shared-dynamic equality micros in balanced order;
shorter runs approach the guard's timing resolution. They are mechanism probes,
not representative compilation benchmarks.

For a passing candidate, run the six-source native screen, then a same-source
full-self comparison and B1/B2 reproduction. Reserve broad conformance, the 45
original programs and public release qualification for a measured winner. Reuse
unchanged generated C as artifact continuity; if C changes, measure the original
program's execution before claiming performance preservation. Commands, exact
recipes and failures are retained with the Phase99 report.
