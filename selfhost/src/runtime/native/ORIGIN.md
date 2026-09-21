Runtime and foreign effects originate from HigherOrderCO/Bend commit
6018e28ecc67cf1fffc0c20c64b11023474c2df8, bend2/comp.ts and bend2/effs.
Apache-2.0; see LICENSE. Runtime template interpolations have been expanded.
The compiler is implemented separately in Bend.

The host IO scheduler has one local adaptation: synchronous effect streams
requeue their activation after a 4 ms time slice, only at a completed effect
boundary, and check nonblocking helper completions on each event-loop turn.
This prevents slower boxed-code execution from delaying unrelated File effects
behind a TCP sender until socket backpressure eventually yields. Parked effects,
activation ownership, Emit/Halt behavior, device execution, and effect handlers
retain their original protocols. This time slice does not interrupt pure
computation or a blocking syscall.
