The root's `context-wide-machine02` completes six builds and 24 independent
ownership observations: baseline/threaded/context, QBE/Clang, unique/shared
String inputs, and both result/retained-alias release orders. The oracle observes
the eighth input as the result, all retained aliases, and zero pending/live
ownership. This is the explicitly synthetic eight-owner fixture, not an actual
source workload or a timing result. The [offline receipt](machine09-wide/report.json)
pins all six executables and their disassembly; inspection executes no targets.

The public `nx_wide(ctx,p0,...,p7)` ABI has nine machine arguments in every
product. QBE threaded additionally exercises the declared eleven-argument
private ABI. Its public wrapper supplies six register arguments and five stack
arguments. `nx_ctx110_wide` reads five incoming stack slots at frame offsets
16,24,32,40,48, copies them to five outgoing slots and calls
`nx_ctx110_wide_leaf`. The leaf consumes seven owners and returns the eighth
from the fifth incoming stack slot. This directly exercises argument placement
and ordinary-call forwarding across the register boundary. Baseline/context
QBE use the nine-argument private convention.

Clang's optimized machine code has a narrower private ABI than the C source,
despite `-fno-inline -fno-optimize-sibling-calls`. Whole-translation-unit argument
elimination removes both unused heap/allocator pointers from the threaded
fixture and hoists the untouched eighth result back to the public wrapper.
The wrapper retains the ninth public argument and returns it after the private
call. Private root and leaf therefore forward `ctx` plus the seven consumed
owners: eight arguments, comprising six registers and two stack slots. Both
ordinary private calls remain present. Clang qualifies the full public
nine-argument ownership behavior and an eight-argument internal call, but this
fixture does **not** qualify an eleven-argument Clang machine call. No further
variant or weakened qualification claim was introduced.

In both backends, baseline root and leaf each retain both checked getter
callsites. The two experimental modes retain exactly the pair in the public
wrapper and none in either private function. The context loads themselves are
dead in this sink-only fixture and may be eliminated; their actual use is
covered by the separate String.append/reverse/nt_append machine gate. Full
pointer-order rejection remains covered by the exact machine controls.

The first wide launch was refused by the outer disk guard before execution.
The successful second launch followed authenticated lossless cleanup; neither
that guard refusal nor this synthetic gate changes the frozen policy selection.
