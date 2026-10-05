# Carry private-array layout into existing scalar trees

The checked array04 compiler gives a raw private layout to an eligible public
scalar root. Existing scalar-tree lowering can instead embed that root's checked
helper graph as local functions, so the outer tree never reaches the optimized
public entry. The editdist module demonstrates this: its positive-depth batch
calls local handle-based `$R_pair`, while depth zero calls public `pair`.
This is a composition gap between two existing lowerings.

Reuse the exact complete typed scalar-tree plan at `j_tree_done`, including its
checked zero branch, checked recursive child arguments and combiner, and complete
guarded helper set. The shared array audit must cover both executable branch
terms. Add the root only to the allowed-call lookup when auditing recursive terms;
its original shape/active-chain proof remains responsible for the two child
transfers. Do not add an unchecked source body to the executable helper set.
Keep the same scalar public signature, internal Array.new requirement, native
ownership/telescope proof, supported executable-node set, and bounded audit.
Unknown/residual/container/opaque cases retain the old path.

After complete admission, emit a second lexical closure using the existing
private book marker, helper normalizer, and `j_tree_body`. All private helpers in
this closure use raw backing arrays. Normalize checked zero/successor terms while
preserving the root's self Apps for the existing frame-stack emitter. Keep the
old handle helper declarations and old tree body unchanged.

The extra exact Succ-entry branch runs after the existing argument-slot reads:
fresh array host guard, the existing scalar/predecessor checks, existing depth
bound, then the complete original dependency guard. On success, invoke the raw
closure with the captured scalar slots. Put `/* private raw array tree */` at this
statement boundary for independent activation instrumentation. On refusal, execute
the entire old selection and fallback, including its original checks. Keep the
public Zero matcher and descriptor ABI unchanged. Do not alter runtime guards,
inherit an outer region permission, or open a new proof scope.

The frame algorithm, left/right argument order, allocation demand, aliases,
Number conversions, and length reads remain the same. This is a representation
choice shared across an already-proved graph, not a new recursion optimization.
The extra closure duplicates helpers; measure emitted size and compiler cost as
well as runtime. Bound source integration to about 70 lines and reuse the existing
body emitter rather than copy it.

Before performance measurement, replay array04 controls and a renamed independent
binary tree. Require activation on positive depths, unchanged zero behavior,
independent leaf/tree oracles, noncommutative child mixing, distinct array records
per leaf, helper transfer, public composite refusal, and host/source mutation
fallback. Preserve the completed array04 corpus as the measured parent. The
counter-only saved-output experiment establishes the old path; it supplies no
runtime performance claim. See the implementation diagnosis in
[implementation/phase47/nested-array-entry.md](../../implementation/phase47/nested-array-entry.md).
