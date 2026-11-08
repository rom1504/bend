Runtime and foreign effects originate from HigherOrderCO/Bend commit
6018e28ecc67cf1fffc0c20c64b11023474c2df8, bend2/comp.ts and bend2/effs.
Apache-2.0; see LICENSE. Runtime template interpolations have been expanded.
The compiler is implemented separately in Bend.

The host IO scheduler has a local adaptation: synchronous effect streams
requeue their activation after a 4 ms time slice, only at a completed effect
boundary, and check nonblocking helper completions on each event-loop turn.
This prevents slower boxed-code execution from delaying unrelated File effects
behind a TCP sender until socket backpressure eventually yields. Parked effects,
activation ownership, Emit/Halt behavior, device execution, and effect handlers
retain their original protocols. This time slice does not interrupt pure
computation or a blocking syscall.

Phase182 ports the Base-facing runtime behavior from upstream
9a4223d577ba56a0cb53d1fd952d2b481c38930f while retaining the local heap, effect
and scheduler ABI: argv[0] and RTS option separation, quiet Exit, invalid Unicode
scalar replacement at UTF-8 output, and F32 text termination. The args/open/read/
write providers add byte argv/path, line reads and positioned writes, preserving
the existing result ownership protocol. Updated runtime bytes need a newly
generated checked runtime template and explicit asset binding; the retained
historical template and qualification receipts do not qualify these changes.
