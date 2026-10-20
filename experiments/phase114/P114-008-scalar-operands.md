# P114-008: remove private scalar ABI buffers before emission

Hypothesis, before implementation: exact pure floating primitive calls still
carry the runtime scratch-buffer ABI after their calls are expanded. Final ray
`isect5` has 34 unconditional writes to its two main scratch words and 49
XMM/GPR moves; local-pair's array fast path also writes then reloads temporary
results. These are actual surviving machine instructions, not dynamic cost
measurements. The measured final screen remains 8.255x upstream for active ray
and 7.706x for local-pair. This experiment tests the smallest first category:
remove input scratch traffic for already expanded pure F32 operations.

An isolated overlay on frozen `final-source01` changes only complete private
function rendering. It examines already verified structured IR; it does not
rewrite QBE text, alter the original IR, runtime, ABI, verifier, ownership,
source acceptance, optimization thresholds or selected public/recursive hooks.

Admission is per local buffer over the ENTIRE function. Its origin must be the
implicit private scratch allocation or an explicit local N111Alloca. Every use
must be either that allocation or an exact contiguous sequence of U64 stores at
0 (and 8 for binary), followed by p111_rt_op(state,id,buffer,count). Only existing
pure expansions 23/1 and 26..35/2 qualify. All other pointer/value uses, aliases,
escapes, unsupported calls, malformed adjacency and destination collisions refuse
that buffer. Nested branches are included in the audit. A function with no
admitted buffer takes the exact prior rendering path.

At admitted sites, emit the same low32 extraction, F32 operation/compare and
zero-extended U64 result directly from the stored operand values. Cast both
operands before assigning the result. Unsupported/fallback operations retain
all their original stores. Do not introduce FP reassociation or approximate math.
The first bounded implementation may retain untouched branch rendering; whole-
function audit is still required because a branch can observe earlier stores.

Falsifier: checked ordinary arithmetic/comparison, output-bit and unsupported
sqrt witnesses must retain complete output; structural evidence must show the
admitted input stores disappeared while fallback buffer stores remain. Then
repeat the same active-ray/local-pair screen. Local-pair is a no-change control
for this first float-only prototype, not a claimed beneficiary. Broad/native
qualification belongs to root and follows only if the small screen improves.

This is optional after the qualified final checkpoint. No result, speedup or
promotion is claimed by the source preparation. Typed FP chains and guarded
array result promotion are later hypotheses, not part of this first experiment.
