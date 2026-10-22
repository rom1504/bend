# Local verified table-call projection

This optional renderer extends the frozen `local/` modules without changing
them. Its sole parent override is `p113ah_private_chunks`. The original IR,
ordinary full verifier, function signatures and runtime remain unchanged.

At each private-function emission, `p126i_catalogue` traverses the verified
function list once. It invokes the existing exact `p126s_cells` recognizer and
retains only the function name and last table index for four-to-64-cell tables.
Per-call lookup visits that compact catalogue, not every program function.
The catalogue is internal to this emission; callers cannot supply one to the
public compiler entry.

Within the local renderer, an exact one-result, one-argument call to such a
function becomes the existing unsigned full-64-bit clamp and one immutable
eight-byte table load. The standalone table function and data remain emitted
by `p113ah_function`; its exact decision body contains no operand buffer or
table calls, so the new local-selection predicate does not intercept it.
All other calls use the unchanged `p113e_call_emit`. Counter exhaustion also
uses that fallback. Both default and in-range paths read the argument before
assigning the destination, including when both use the same local.

The template reserves three labels from the shared emitter counter. Its local
temporaries use `%p126_inline_<counter>_...`, separate from source `%v_` locals,
float temporaries, loop snapshots and generic `%t_` temporaries. It advances
the counter by three and preserves the error/terminal state. Results remain
full Terms; local float facts for every written result are killed exactly as
for the original call. No cross-call float ABI or new result inference exists.

`dispatch.bend` is the exact local dispatch with its function names/context
changed and the call emitter replaced. Branch-local fact transfer, Boolean
diamonds, scalar width handling, float primitives and full-word two-phase loop
backedges remain delegated to the same helpers. No-array functions containing
a recognized table call may now use this renderer even without float buffers.
Array functions retain the previous function-level fallback.

Load `model`, `emit`, `dispatch`, `entry`, then optional `controls` on the clean
local-plus-selector source. Export `p126i_controls` for 12 finite analysis/text
checks. They are not native tests of fabricated IR. The ordinary checked source
controls remain the frozen selector `cases-v02.json` (including indices 2^32
and 2^40), and `specialization/transfer/ordinary-cases.json` plus its independently
frozen 2000-iteration routing benchmark. Root owns all target executions.

Required gates: checked source; finite controls; original ordinary outputs;
emitted call removal with table globals retained; rotating matched timing.
For functions/calls with no admitted table, emitted bytes should remain exact
local11 output. Potential costs are an added catalogue traversal, larger callers
and extra branches; no performance result is claimed by this source preparation.
