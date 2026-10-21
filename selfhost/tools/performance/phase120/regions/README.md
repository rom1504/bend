# Phase120 bounded numeric regions

This optional experiment starts from the exact Phase118 safe03 selection. It
keeps the public/private integer ABI and generic U64 values. The hypothesis is
that exposing a residual numeric leaf call and retaining local F32 values inside
its branches can remove conversions and call boundaries that an ABI-only change
would retain. There is no measured performance claim in this source package.

`operands01.json`, `lanes01.json`, and `regions02.json` are separate exact source
recipes. They respectively restore the qualified Phase114 operand-buffer
elimination, add its sequential float-lane facts, and add this region mechanism.
The older `regions01.json` and `modules01.json` remain preserved: its API checked,
but self-review found that the new Bin path bypassed the existing word-width
pair emitter. Version 2 preserves that emitter and invalidates its destination
fact. The issue was code quality, not a demonstrated semantic mismatch.

The lowering hook is `p114s_inline`. It calls the exact safe03 original inliner,
then builds one immutable table of numeric leaves and copies selected calls.
It leaves `p114s_ranges` to the independent signed-word experiment. The actual
entry chain is `p113a_lower_request -> p113d_lower_request -> p114s_lower_request`;
`p114s_commit` independently verifies all rewritten workers before committing.
Both failed admission and failed verification retain the original functions.
The original generic program and final array/private verifiers remain unchanged.

A leaf has at most 512 structured nodes,32 parameters,8 results and 8 KiB of
allocas. It contains only numeric local Set/Bin instructions, private scratch
allocations/stores, exact runtime numeric operations 23–36, existing fail 4, If
and Result. It has no private call, backedge, ownership helper, heap/state access,
foreign effect or scratch escape. The existing complete-return predicate must
hold. The original checked-source factory and verifier still establish typed
signatures and operation-buffer initialization; this reflected syntax predicate
is not an independent source/ownership certificate.

Each caller has at most 4096 nodes before the pass. At most 4 sites and 1024 added
nodes are copied; the existing 16 KiB stack guard remains. The table is fixed for
the pass, so copied regions cannot grow transitively or introduce recursion.
The table/function catalogue loops are direct self-tail traversals. Per-body
analysis is bounded by these intended admissions; full-compiler request cost
and hosted stack behavior still require qualification.

Inlining reuses mature `p113j_inline`: fresh parameter bindings, exact instruction
order, fresh scratch allocations, all returned words snapshotted before caller
destinations change, and the same branch structure. `p120nr_` local names are
reserved in each caller before rewriting. Scratch addresses never escape the
admitted leaf; the only helper which reads them performs the unchanged numeric
operation. Each ordinary lowered primitive stores its arguments immediately
before its helper call. Fresh buffers prevent overwriting a caller's live
scratch, including when the caller loops. The helper/function ABI, allocations
of user values, and ownership operations are not changed.

The renderer reuses Phase114's facts: a known local names an immutable QBE `s`
temporary produced by an exact F32 operation; all original U64 materializations
remain. Exact U64 copies transfer that fact. Set/Bin/alloca definitions invalidate
only their destination, and the selected adjacent word-width pair remains intact.
Each If arm receives the same dominating incoming facts; no new arm fact escapes
the join. Calls, memory operations, transfers and unsupported groups retain the
old reset path. No memory/parameter fact, N_W32 type guess, reassociation, FMA,
speculative arm evaluation or additional floating operation is introduced.

Root owns all executions. `controls.mjs CHECKED_API FRESH_REPORT` requires the
exports in `modules02.json` and checks 20 reflected admission/expansion cases.
`ordinary-controls01.json` has the Phase118 functional manifest schema and a
literal complete-output oracle for branches, aliases/rebinding, signed zero,
rounding, NaN comparison and preserved sqrt. `numeric-controls01.json` adds the
unchanged Phase118 numeric controls. These ordinary programs may already be
inlined by the parent; count the actual copied calls and lane routes before
claiming they exercised the new pass. Structural controls never execute malformed
native programs.

The first falsifier is absent real residual-call coverage. If there is coverage,
compare complete outputs, private calls, float casts, stack/register traffic,
code size, and clean paired runtime against both preceding ablations. A smaller
QBE file or a successful source check alone does not establish benefit. This
prototype does not supply vectorization or typed function signatures and must
not be presented as the complete native-region architecture.
