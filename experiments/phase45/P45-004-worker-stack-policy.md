# P45-004: worker stack policy

Status: the capped-public-call precursor is deferred after static review, before
implementation or measurement. Root selected a real continuation IR instead.

## Rejected precursor

The proposed experiment would admit otherwise proved contextual functions denied
by `j_instance_cycle`, execute their private workers with a per-root depth budget
such as 32, and call the original public `G` function at exhaustion. Erased null
arguments would be restored ahead of the already demanded live arguments.

Two holes prevent treating that as a stack-safe fallback:

1. `G[original]` can already contain the selected contextual wrapper. Contextual
   workers deliberately leave `regionProof` null. A fallback at depth 32 can
   therefore enter the same public wrapper with the same arguments, immediately
   reach the same exhausted budget, and call itself again without source progress.
   For example, a scalar root A calls an erased helper B, which calls A after
   decrementing its input. Falling back at A's entry repeats A's entry before
   executing that decrement. Other public roots own separate lexical counters;
   their counters do not establish a common native-stack bound either.
2. Calling `callOwned`/`force` beneath existing native frames does not unwind
   those frames. Public trampoline use alone does not prove bounded stack across
   optimized reentry. The existing hybrid tree path falls back to a dedicated
   iterative `$stack` body, not to a potentially optimized public `G` function.

There is a separate admission concern: `j_instance_cycle` returns true for an
actual cycle, exhausted fuel, and malformed/missing edge metadata. Relaxing every
true result would admit more than known cyclic graphs. Invalid or incomplete
graph analysis must continue to refuse optimization.

The representation premise itself is plausible: contextual instance books have
no `JSFlatContext`; their owned constructors retain ordinary tagged/native values
and dense native tuples. Exact instance metadata gives the erased prefix length
in `fact.da` and original public arity in `fact.dx`; source aliases have prefix
zero. Restoring that ABI does not solve reentry or stack accounting.

No capped-public-call implementation is promoted. A shared generic-only execution
mode or a dedicated iterative fallback would need a new proof across every
private entry boundary, making this a poor shortcut to the required backend.

## Chosen continuation IR

The lowering agent is implementing a first-order worker IR with explicit
assignments, calls, branches and returns, followed by a program-counter loop.
A non-tail private call saves its return location and live register frame; its
return resumes the caller before subsequent arithmetic or construction. A tail
private call transfers to the target without retaining a native JavaScript frame.
All admitted instance members share the dispatcher, including renamed mutual
cycles. Ordinary arithmetic and constructor work remain straight-line code
inside blocks rather than an interpreter step for every expression.

This replaces native recursion on private graph edges, rather than raising a
recursion threshold. The estimated implementation is several hundred lines
(initial target approximately 500–650); actual size and compile cost must be
reported after integration. The complete JPure/instance/representation proof and
public host/dependency guards remain required. Unsupported higher-order or
partial-call forms retain the original backend. This is still a private backend
under guarded entry, not a relaxed public ABI or universal effect analysis.

## Independent falsifiers

The [worker-composition fixture](../../selfhost/tools/performance/phase45/fixtures/worker-composition.bend)
and [expectations](../../selfhost/tools/performance/phase45/fixtures/worker-composition.md)
are authored separately from the lowering/printer. They exercise non-tail mutual
recursion followed by noncommutative arithmetic, recursive constructor results,
tail cycles, shadowed bindings and deep inputs. Small cases use pinned TypeScript
and the prior compiler; deep cases have iterative independent oracles and retain
any baseline stack failure explicitly. Mutation/guard refusal, errors and reentry
still need existing boundary controls. Activation must be measured separately
from matching final values.

Root owns all compilation, controls and timing. No experiment result is claimed
by this policy decision or by the unexecuted fixtures.

## Reviewed SCC partition

The subsequent printer partitions the worker call graph into strongly connected
components. This supersedes the initial single-dispatcher implementation above.
Every direct private call is an explicit worker-IR instruction; the graph walk
includes both branches and all following instructions. Exact transitive closure
uses three 32-bit words for at most 96 functions and exactly one pivot per
function. Invalid targets, invalid functions and larger graphs refuse this
backend. Missing or incomplete analysis never establishes an acyclic edge.

Calls within a recursive component retain explicit return PCs and register
frames. Calls between components use ordinary positional JavaScript calls.
Those edges form a directed acyclic graph, so their native call depth is bounded
by the number of components, independently of recursive input depth. A singleton
with a self-call still uses the machine; a singleton without one uses scalar
JavaScript locals. This bound concerns admitted private graph edges, not arbitrary
host callbacks or deliberate public reentry.

Static review verified that function entry IDs and generated continuation IDs
remain disjoint, argument expressions retain their order and caller scope, and
non-tail machine calls allocate a distinct child vector before restoring the
saved parent. The selected partition experiment retains allocating tail
transfers; the separately tested vector-reuse ablation is not implied here.
Terminal tuple/Char cases whose established condition is already constant true
may select their first branch, retaining preceding input work and selected field
reads. These are architecture and correctness findings; runtime qualification
and speed evidence belong to the experiment receipts and final report.
