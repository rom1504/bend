# P185-003: Inline authenticated cold constructor cache hits

Status: source candidate; source checking, machine controls and measurement
pending. No promotion is implied by this implementation.

The admitted physical profiles attribute 9.21% of QBE map128 samples and
18.11% of tree-bitonic samples to constructor helpers. Removing those helper
costs entirely would bound speedups at approximately 1.10x and 1.22x. This
candidate retains allocation and field stores, so those bounds are not an
expected result. Caller register allocation and helper call disruption may
also change. The corresponding raytrace constructor share is zero.

Our C output and QBE output perform the same logical constructor allocations.
The hypothesis is that exposing the runtime's short allocator-cache-hit path
to the target compiler avoids helper overhead and improves surrounding code.
This is not constructor-cell reuse or an allocation-count reduction.

`selfhost/src/back/qbe/cold-constructors.bend` adds a shared structured late
expansion. It admits only an already verified `p111_rt_ctor` call with exact
state identity, symbolic constructor ID, known stack scratch, U64 result, and
literal arity 1 through 4. Constructor IDs retain the same numeric identity
and arity. A new explicit metadata marker records the descriptor's cold/hot
bit; absent or hot metadata refuses expansion. An arbitrary constructor name
is never evidence of coldness.

The selected serial CPU runtime is ABI 11102: state heap pointer offset 0,
allocator pointer offset 8, 32 allocator classes, eight-byte allocator slots,
and cache lengths at slot 32 plus class. Classes are 0, 1, 2, 2 for arities
1, 2, 3, 4. The expansion checks emitted descriptor version 11102, size 192,
and sequential/cold-publication capability bits 1 and 8 before state access.
The existing runtime bind remains the authority for the single active
descriptor and the selected source/runtime binding remains unchanged.

On a nonempty cache, the expansion exactly pops `heap[head]`, decrements the
cache length by the class's word capacity, copies all original field words,
and packs the unchanged constructor tag, ID, and allocated location. Field
words are snapshotted before any mutation. Hot constructors, empty caches,
unsupported arguments and failed descriptor guards use the original helper
path. No retain, sink, seal, allocator refill, free, or runtime source changes
are introduced. The verified original namespace already excludes generated
`p114t_` locals; each site reserves a unique number.

The QBE emitter walks this expansion once, including its original slow
calls, to avoid recursive expansion. Direct x86 can consume the same
`P114TExpansion` through its independent experiment switch. Generic and
private QBE functions share the existing statement emitter.

Focused controls are in `selfhost/tests/phase185/cold-ctor-controls.bend`,
`cold-ctor-oracle.c`, and `cold-ctor-inputs.bend`. The first checks admission,
metadata refusal, unchanged rejected rendering, field snapshots, original
fallbacks, and constructor-ID boundaries. The independent machine oracle
compares all heap and allocator words, checks exact slow arguments, all four
widths, capability variants, null-state guard failures, hot fallback, and
consecutive allocation sites. It stubs slow helpers only inside this oracle;
real runtime qualification is a separate gate. The ordinary source fixture
holds shared children and outer aliases across all constructor widths.

Cheap falsification: source check or oracle failure rejects the candidate;
absent cache-hit expansion in representative machine code invalidates the
mechanism; a rotated baseline comparison with no map/tree improvement does
not support promotion. Broader exact-output and runtime qualification remain
required before any selected image changes.
