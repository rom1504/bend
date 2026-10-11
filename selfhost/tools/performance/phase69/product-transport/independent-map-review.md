# Independent review of the saved-C Map scheduler island

Source inspection only: reviewed `map-island.py`, its original derivative and
corrected `map-island-v2.py`/`map-product-island23-prep02/program.c`. No compiler
or target executed by this reviewer. Root records all actual outcomes.

## V1 blocker and V2 correction

The first generic wrapper entered `WL_OPEN` before preserving its incoming
arguments. On the host that macro expands to a fresh `WL_BANK`, shadowing the
incoming `r0..r5` parameters. Jumping to the private entry then passed
uninitialized arguments. V2 saves all three input words to locals before
`WL_OPEN` and restores them immediately before the private jump. The failed V1
attempt must remain separate from any valid timing.

## Width and continuation review

The private entry receives the original three boxed words and returns two
words. Its metadata has arity 3 and RESW 0 because it is an ordinary entry, not
a continuation. The reconstruct continuation has one captured Char and two
incoming result words: arity 3, RESW 2. The boxing continuation has no captured
parameters and two result words: arity 2, RESW 2. Flags identify all three as
fork-free, with no newly introduced bang site.

In sequential mode the recursive call pushes the saved Char and continuation
FID. Return pops the FID; reconstruct pops the remaining saved word before
reading it. The generic adapter pushes only its box FID, so that continuation
needs no extra capture pop. Both result registers are saved to local names
before each new `WL_OPEN`.

In task mode `rem = 1` counts one returning computation, even when it supplies
two result words. Reconstruction uses result index 1 after its saved Char;
boxing uses index 0. Existing `FID_EXIT` resumes these continuations with
`arity - returned_width` captured words, which is respectively one and zero.
Task allocation/free sizes agree with those arities. `WL_RESW`, `WL_SAVE` and
`WL_TAKE` increase to two coherently; the existing six-word register bank is
already sufficient.

The leaf and reconstruct paths call already-admitted product workers with
exactly their emitted field order. Their output buffers are consumed once.
Original String destructuring, field ownership and mismatch fail-stop paths
remain. Every external generic entry still receives a boxed Tuple result;
only the private recursive region bypasses the shell. Original device bodies
remain reachable on device, while the new host-only entries have no device
callers. This is a host diagnostic, not a qualified device implementation.

After the register correction, no further concrete blocker was found for the
saved-C discriminator. Correct runtime output, one/four-thread controls and
balanced timing still belong to root's execution lane.

## Requirements for a general compiler rule

Do not infer a multiword recursive result contract from its declared type
alone. Every admitted returning path must produce the same proved constructor
shape, including all recursive SCC members. Keep ordinary parameters boxed so
the rule does not introduce earlier tag checks on unused malformed arguments.
Unknown result shapes, mismatched constructor returns, foreign/dynamic/bang
boundaries and failed product-worker admission need the original boxed route.

Precomputing product admission before scheduler lowering must retain its
existing fixed-point behavior: a caller cannot keep a private target whose
callee later fails admission. Continuation metadata must derive from the same
field layout as its emitted stack/task accesses. Shared and static fields move
under the ordinary ownership environment; removing the outer product shell
does not authorize removing field keeps or drops. Test a recursive product
producer unrelated to Map, mixed boxed/private callers and raw mismatch/error
order before considering the rule general.
