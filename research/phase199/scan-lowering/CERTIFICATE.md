# Admission and fallback certificate

This is an executable bounded recognizer, not a proof in the BendTT kernel.
Its host acquisition checks the Bend source; separate emitted-program controls
must establish that the ordinary call lowering realizes the intended ABI.

The hook is reached only by `x185_array_version`, after the existing mode-2
array-origin scan has selected the guarded optimized worker. It retains the
original `p117v_` scalar worker, metadata setup, runtime guard and fallback
argument sequence. It admits exactly four explicit parameters and two results,
with the sole used array origin at parameter three. These are signature/IR
conditions, independent of user function names and workload constants.

The existing normalization stages are reproduced in `pipeline.bend`; the new
selector acts after copy/scalar preparation, before all ordinary allocation
and physical call emission. Non-admitted shapes rejoin the same ordinary path.
`x199s_enabled=false` selects the original array emitter directly.

The selector checks the complete two-level countdown shape: U64 fuel equals
zero, returning the original owner and full-width carry; otherwise fuel is
unequal to zero. Both guards, the zero result and the second guard's failure arm
remain exactly as supplied. It changes only the positive branch after proving
all its statements, including the sole terminal backedge. Acceptance requires
at most 64 scalar statements. The hosted Boolean conjunction is eager, so
this acceptance budget is not an early traversal cutoff; the existing array
version already bounds its source body to 1024 structural units. No unknown
expression or effect is admitted.

Semantic tokens track initial fuel, index, owner, carry, and authenticated
metadata base/mask. They additionally represent exact fuel minus one; low32
index and carry; low32 index plus one; masked index; four-byte displacement;
cell pointer; loaded U32; low32 sum; and XOR of that sum with low32 unmasked
index. U32 casts admit only a finite explicitly canonical set; 64-bit XOR
requires both operands already canonical. The mask is at most 2^31-1 by the
unchanged array metadata factory, so masked full index equals masked low32
index. Operand commutation is admitted only for the explicitly symmetric ops.

Assignments cannot overwrite parameters or authenticated base/mask. Copies
update the environment, so overwriting a temporary cannot retain its stale
meaning. Exactly one U32 load from the certified cell must precede exactly one
U32 store of the certified XOR to the same cell, both at displacement zero.
Every other memory operation, call, branch, alloca, unknown op or terminal
refuses. The final backedge must pass fuel-minus-one, incremented U32 index,
original owner and the pre-XOR sum in that order. Therefore the only replaced
observable behavior is the full sequential array recurrence.

The helper receives existing metadata and the original fuel/index/carry. It
returns the final carry; the generated function still returns the original
owner first. The helper's independent contract covers exact sequential U32
updates, finite full64 fuel, capacities one/two via scalar fallback, larger
power-of-two rings via four-cell scans, and wrap/tails. No final index is an
observable result in the admitted signature. Call liveness, source/destination
aliasing, frame alignment and return placement are delegated to the existing
ordinary typed call machinery and tested on generated objects, not inferred
from this certificate alone.
