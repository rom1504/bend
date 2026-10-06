# Phase58 integration extension: share mutual-recursion dispatch

The new literal-choice lowering exposes more tail calls to the existing SCC
analysis. The reach01 candidate generates and validates its 77-root B2 image,
including all eight driver observations, and freshly type-checks its own source.
Its first lexer screen is promising: 3,291→1,531 ms for import/API/first request
and 2,221→755 ms for the sole later request. These are one-pair diagnostics.

However, the generated image grows to 8,671,962 bytes. The current emitter prints
the complete loop and switch for every entry into a mutual-recursion component.
A data-only census finds 133 exact loop groups across 437 named entries. One
34-member group copies the same 70,138-byte loop 34 times. Sharing identical loops
would remove about 4.87 MB from this image before final metadata accounting.

Keep every named entry function and its original maximum-width parameter list.
Each wrapper passes its constant entry PC and those arguments to one private
component dispatcher. The dispatcher retains the exact case-local binders,
parallel argument stores, PC updates and loop transitions. Single-function loops
remain unchanged. A private helper name must be impossible to collide with a
normal encoded source name. The component leader explicitly references every
member in emitter metadata, so final reachability and rebuilt call facts retain
the complete ordered component. Wrappers reference the leader.

First derive a diagnostic JavaScript image by grouping exact identical loop
bodies, preserving the runtime prefix, wrapper formals and original bodies via
an invertible edit list. Refuse unexpected `this`, `arguments`, `super` or
`new.target` dependencies. It is not a checked source image or release. Compare
its ordinary lexer output oracle and first/later timing with the exact parent
through the existing private-image experiment method. This isolates execution
shape; compiler output must remain unchanged in that fixed-source experiment.

If the execution tradeoff is acceptable, implement the same printer rule in
Bend, reuse existing component facts and avoid introducing another analysis.
The prepared change adds three small printer helpers. Qualify real emitted
self/mutual tail loops, variable arities, captures, evaluation order, non-tail
calls and component closure at default stack. Refresh the actual compiler image
and preserve exact B2→B3 reproduction. Final broader semantics and the full
45-point paired program measurements apply to the selected implementation.

Report generated code size, compiler-image generation time, request latency,
allocation and program execution separately. Sharing saves printed code and
JIT work, but the extra wrapper call may cost runtime; the diagnostic must test
that tradeoff before the source implementation is selected.
