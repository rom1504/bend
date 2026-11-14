# Next composition: integer branch selection inside float functions

Design audit only, 2026-11-14. No compiler edits or target runs. The smallest
useful next slice is an adapter for an integer comparison immediately followed
by `X186FloatBranch`, reusing existing branch legality and compare emission.
Blanket dispatch of plain runs to `x190_stmts` is not yet safe.

## Actual witness and first scope

The closed-F32 diagnostic's actual worker is `$direct.p194.floop` (the closed
floop referred to in planning), in
[selected assembly](../../selfhost/build/phase194/diag-selected-emit02/f32-region-closed/program.s),
SHA256 `8a670e509c4b905780b74c4b9a2e506ee28ed35a92de56f1720792197cfaf4e8`.
It materializes `n == 0` using CMP/SETE/MOVZX, copies and tests the Boolean,
then branches. The nonzero arm repeats CMP/SETNE/MOVZX/copy/TEST for `n != 0`
before decrementing n and performing ADDSS/MULSS/SUBSS. The loop has no call on
this positive path. This is actual selected machine evidence, not a speed claim.

Contiguous plain-run handling alone misses these sites: the comparison is a
Plain node, but its consuming branch is a FloatBranch node. Start with that
two-node edge. Use `x190_branch_allowed` and `x190_branch_test`, then recurse
through the **original float child nodes**, retaining label, terminal and error
threading. Keep both comparisons initially; remove SETcc/Boolean TEST sequences.
Eliminating the redundant inner comparison can follow only with a float-node
adapter for the existing exact complementary-arm certificate and terminal
continuation rule. Do not reuse its returned fake placement rows as executable
arms, or carry flags across the F32 body.

Physical binary operand selection is already reached through
`x181_stmt → x181_scalar → x181_binary`. The gap is multi-row branch/predicate/
address composition, not all physical instruction selection.

## Conditions for safe reuse

Whole-function read/write/protected facts may come from post-identity
`x186_f_placement_rows`, including setup and parameters. FloatValues metadata
records both input reads and the destination write, preventing a Boolean read
by a float conversion/arithmetic node from being incorrectly declared private.
Unary nodes can conservatively count their duplicated operand twice. Compute
facts once, not per plain run; a later float use, result, call or Again must
invalidate a local complete-use claim. Float-node placement rows are fake
integer ADDs: never emit them, optimize their apparent arithmetic, or use them
as evidence of integer value relationships.

There are four practical obstacles:

1. **XMM-only copies.** Plain U64 copies are part of the existing canonical
   float region and can read or write XMM homes. Their GPR/frame homes may be
   stale. A run handed to integer selection must exclude every read **and
   write** with an XMM home, or keep the existing `x186_x_copy` path. Checking
   sources alone misses an XMM-only destination. Canonical low32 F32 bits do
   not authorize truncating arbitrary U64 copies. The current ordinary-operation
   cuts help establish these exclusions; keep them authoritative.
2. **Selected liveness.** Full `x190_stmts` also invokes address selection.
   Address fusion can delay base/index reads past their original arithmetic
   rows. The ordinary path's `x191_placement`/`x192_shared_placement` extends
   precisely those lifetimes. The float path currently allocates from original
   node metadata. Blind reuse could read a register since reused by an unrelated
   local, even though the address matcher rejects logical-name overwrites.
   Restrict the first adapter to branch/predicate selection with original scalar
   fallback. Address composition requires matching selected placement for each
   real plain run before the combined frame is allocated.
3. **Cuts and effects.** Do not join runs across FloatValues, FloatBranch,
   calls or loop edges; preserve current XMM cut/publication rules and floating
   operation order. Calls, SSE comparisons/conversions and integer instructions
   can affect flags. Only the existing tightly bounded CMP-to-branch/select
   connection may consume integer flags. Arithmetic rounding and MXCSR effects
   remain where they were.
4. **Structured control.** Generic `x190_if` expects ordinary statement arms.
   Float arms must retain their node emitter. Empty branches, terminal arms,
   reserved/setup/parameter names and whole-function repeated-name counts need
   the same existing certificates. Do not flatten float nodes to obtain a
   convenient branch body.

## Smallest falsifier and transfer decision

Use the actual closed floop, plus one tiny checked node fixture whose integer
predicate is also consumed by a following FloatValues conversion. Require the
closed worker to lose both SETcc/TEST sequences, while the extra-use fixture
retains its needed Boolean publication. Inspect actual final admission before
timing. Add one canonical U64 copy with an XMM-only source and destination and
one raw U64 observation with nonzero upper bits; these must preserve full words
and the existing copy emitter. Reuse existing rounding/NaN/status observations.

If address composition is later attempted, its first falsifier should force
GPR pressure with a base/index whose original last read precedes an unrelated
register-reusing definition and the eventual selected memory access. Original
metadata is not enough for that case.

Closed/mixed F32 diagnostic loop guards are concrete coverage. Numeric and ray
workers plausibly contain integer counters/guards in float-admitted functions,
but exact preselection/selected-owner inspection must establish those sites.
Do not widen the first experiment to floating comparison fusion, cross-call
XMM lifetimes, or new global SSA. Require a machine change, a bounded paired
runtime gain, and one ordinary-workload transfer before broader integration.
