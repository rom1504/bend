# Exact Nat successor-destructuring projection

Frozen `manifest01.json` selects `model.bend`, `controls.bend`, the parent source
and the unchanged qualified runtime. Override only `p111q_stmt`; export
`p126nt_controls` for16 analysis-only rows. Use `cases.json` with the existing
ordinary emitter/functional harness for13 independently expected output lines.
No target/compiler run was performed by this prototype's author. `prepare.py`
only computes the independent oracle, hashes artifacts and checks the exact
fallback declaration copy.

The existing canonical Nat lowering `p113nm_take` already emits predecessor
arithmetic in admitted direct workers. Generic scheduler/H continuation paths
can still carry the original helper; this experiment applies its exact
semantics **after** original graph verification, across those emission paths.
It adds no ownership optimization and leaves structured verification unchanged.

In `runtime-verified01/runtime.c:4408`, `p111_rt_special_take` checks arity,
then the Succ case writes `out[0] = term - 1` and returns `count`. Only the exact
U64-result helper call with Ptr state=`state`, constant U32 kind4, U64 term,
Ptr local output other than state, and constant U32 count1 is projected.
The original independent verifier checks buffer capacity, argument types and
the special-arity contract first (`p111v_contract`, parent source:40402).
Constants discharge the eliminated arity check. No unknown helper, dynamic
kind/count, high-word constant, wrong signature or other special case is added.

The replacement is three instructions in this order:

1. Compute full-width unsigned `term - 1` into a fresh temporary.
2. Store that value to the original output pointer at offset zero.
3. Assign1 to the original call-result local.

This preserves the original scalar input snapshot when the result local also
names the input, preserves the output write and call result, and never narrows
Nat to U32. Buffer provenance need not be strengthened: unlike stack
transport, this writes the same one word as the checked original helper.
Continuation-renamed scratch buffers are therefore supported. Nothing touches
keep/sink, tagged heap constructors, RFC state or Array destructuring.

Fresh temporaries use the already-reserved `p114t_<site>_nat_pred` namespace.
The original `p114t_namespace` gate rejects user/IR collisions; existing
`p114t_expanded` reserves one global emission site before emitting the three
instructions. Nested branches use that same monotonic counter. Near-overflow
site IDs retain the exact prior emitter. The prior emitter also handles every
refusal and nonordinary code state unchanged.

Finite controls check precise instruction order/full-width constants, input
result alias admission, renamed buffers and refusals. Synthetic high-bit and
invalid-signature calls remain analysis-only; they are never runtime probes.
The ordinary source instead constructs valid Nat values through2^48−1,
matches through IO to exercise generic emission, observes retained inputs,
and independently sums predecessors through4096 ordinary steps. Expected
results come from Python integer arithmetic, not compiler-generated output.

Correctness/output success alone does not show the optimization fired. Inspect
the actual selected H/generic QBE, require the helper call to disappear, then
compare the same frozen benchmark and unrelated ordinary controls. No claimed
timing gain or native-chain qualification accompanies this source prototype.
