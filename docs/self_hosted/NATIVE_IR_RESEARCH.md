# Native IR research prototype

Phase106 implements a small native IR in Bend with two consumers: generated C
compiled by Clang, and structured transport consumed by a pinned Rust/Cranelift
adapter. The graph, verifier, constant folder and text emission stay in Bend.
It is an opt-in research tool; the installed native compiler remains candidate04.

Read the [design](../../design/phase106/native-ir-research-loop.md),
[results](../../implementation/phase106/README.md), and
[exact replay commands](../../selfhost/tools/performance/phase106/README.md).
The [IR contract](../../selfhost/tools/performance/phase106/ir/README.md)
states supported operations and ownership/tail-call limitations.

The useful result is a development/release tradeoff. Small Cranelift objects
compile 10–17 times faster; emission and linking narrow that advantage. Fresh
one-shot build/check target-cost estimates are about half those of C O2 across
the tested families. Repeated execution can reverse the advantage. These are
component-clock results on constructed IR, not a new full-compiler speed claim.

Use the fast semantic screen to change a supported IR transformation or consumer,
then the small repeated matrix to measure construction/runtime tradeoffs. Freeze
training inputs and retain held-outs. Run expensive independent proofs when the
actual proved package changes, or at a justified integration gate; authenticate
and reuse unchanged accepted proof evidence. Scalar helper laws do not certify
memory, the recursive optimizer or machine code.

The best-supported next experiment is bounded inlining of small pure helpers in
the Bend IR. Current Cranelift output retains calls that Clang removes. A common
pass could improve both backends without duplicating semantic optimization logic.
Production integration still needs general checked-term lowering, the real value
and ownership ABI, effects, guaranteed tail transfer and task/GPU semantics.
No device hardware is needed for this measured CPU experiment, and no GPU result
or automatic backend promotion follows from it.
