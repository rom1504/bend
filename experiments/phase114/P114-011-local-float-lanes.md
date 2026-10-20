# P114-011: retain exact float results through local copies

Pre-target hypothesis: operand-buffer removal leaves repeated representation
round trips. In the qualified ray `isect5`, both selected and scalar-operands
assembly have 49 GPR/XMM moves; the latter reduces its frame from 2072 to 24 bytes.
This bounded experiment tests reuse of an already computed floating result,
without changing any private/public signature or full-word result.

Parent is the checked `scalar-operands-source02` and API02. The isolated overlay
changes only `p114so_stmts`. Exact pure operation groups and whole-function buffer
admission remain the parent's. A local fact maps an N111Local name to the emitted
`s` temporary produced by operation23 or26..29. A subsequent F32 arithmetic or
comparison operand may use that exact lane. Operation23 still interprets its
input as U32 bits and never reuses a cached float operand. Every result retains
the original word cast/zero-extension for generic users.

The only additional propagation rule is the exact statement
`N111Set{destination,N111U64{},N111Local{source}}`. Emit the original copy unchanged.
Read the source fact, invalidate an old destination fact, then alias destination
to the same lane if one exists. Recognized operation operands similarly use the
old facts before their result destination is invalidated/rebound. Comparisons
produce no float fact. Keep at most16 most-recent facts. Every other statement,
branch, call, transfer or failed group selection clears the facts. There are no
memory facts, joins, signature inference, general propagation or N_W32-based
representation claims. Original ownership operations/verifiers remain intact.

The retained `s` result and the old `s→w→U64→w→s` path have identical low32 bits;
there is no removed numeric operation, reassociation, contraction or changed
rounding point. Independent review must check NaN/signed-zero preservation,
source/destination aliasing, exact-copy invalidation, shared temporary-counter
freshness and barriers before targets run.

Falsifier: ordinary arithmetic/copy-chain source must produce positive reuse,
retain the exact ordered floating operation sequence and complete output, and
leave unsupported sqrt/call/branch paths unchanged. An ordinary local rebinding
case must use the updated value. If actual lowering has no matching chains, do
not run a timing campaign. After structural and ordinary-source gates, root may
repeat the same bounded ray/local-pair screen, with local-pair as a potential
no-change control. A source check or lower instruction count alone is not a
runtime win or promotion. The selected compiler/runtime remain frozen.

Status: source preparation only; no target execution or result claimed here.
