# Register transport opportunity

Runtime04 remains selected and unchanged. The coordinator's core-lexer profile
reported about 659 million cleared register words versus 51 million copied words.
This suggests an opportunity, but neither unconditional removal nor deriving a
prior dirty prefix from the present `next`/`rn` fields is justified by the current
generic IR contract.

`work_loop` sets `state.next=P111_STOP` immediately before invoking every segment.
Direct jumps and closure application set `rn=0`. Consequently an ordinary
`p111_set_regs` call normally observes STOP/0: the current function identifier is
not available for the proposed `fid_arity(state.next)` bound. Positive `rn` can
describe prior returned words, but it is not a universal current-bank bound;
built-in `WL_OPEN` resets it, including the sequential EXIT/TAKE path.

The current clear also has observable semantics outside the generated language
subset. The generic verifier bounds `reg_get` by declared entry arity or incoming
width, but does not relate every actual return width to its pending continuation.
It admits bounded raw state memory operations and does not require every
register getter to occur before a terminal transfer. Such a graph can observe
inactive zero words or write beyond a proposed dirty prefix. The verifier alone
therefore does not prove that stale words are unobservable.

The retained built-ins do not introduce an initializedness obstacle if their
current operations stay unchanged: ENTER reads one task word and loads the
declared input prefix; IO_EMIT reads and returns one word; CLO_APPLY reads two
words and fills captures plus the argument; EXIT saves the logical bank and only
delivers `rn` results. INIT/READ/WRITE/SAVE/TAKE use the same logical width, and
the dispatcher fully initializes state once. Scheduler and root-delivery loops
read result arrays only within their recorded count. These facts do not remove
the generic graph observations above.

Two bounded follow-ups are viable:

1. Add an exact valid-prefix graph contract: reject raw state access and late
   register getters; authenticate each entry prelude; connect returns to all
   reachable continuation incoming widths; retain closure/task/builtin width
   checks. A no-clear runtime must be bound to that strengthened compiler/graph
   receipt, rather than treated as equivalent for all currently verified IR.
2. Preserve zero semantics with an explicit conservative dirty-prefix field.
   Initialize it with state, update it after every scalar transfer, and reset it
   conservatively after every built-in whole-bank write. A transfer of `count`
   words clears only `[count,old_dirty)` when `old_dirty>count`, then records
   `count`. The field needs an explicit ABI/version or private-state contract;
   it must not be guessed from STOP/rn or a reentrancy-sensitive global. Every
   permitted direct bank writer must update it, or source admission must exclude
   such writers. Conservative full-width fallback remains valid when provenance
   is unknown.

Useful gates include widening then narrowing prefixes with sentinels, repeated
same-width transfers, multiple-result continuation returns, closure application,
IO_EMIT, root EXIT/SAVE and task-continuation EXIT/TAKE. Negative controls should
include an inactive raw read, a direct high-slot store, a late getter and a return
shorter than the continuation's declared incoming width. These distinguish a
proved transport contract from a workload-specific observation. No runtime
variant, compiler or native target was created or executed for this audit.
