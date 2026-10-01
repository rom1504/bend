# P39-004 callback feasibility

Status: static inspection plus a retained checked-fixture refusal. Root acquired
both compiler refusals; no callback execution speed result is available yet.

The Phase37 list fixture is not higher order: its selected bench materializes a
generated list, calls first-order `keep_gt1`, `dbl`, then `suma`. The source comment
explains that generic map was replaced by first-order recursion for affine
checking. Its generic `apply`/`force` profile does not show callback traffic.
Known first-order component work is a separate optimization opportunity.

The closures fixture does contain captured `compose`/`chain` values. Its final
module SHA256 is `41545cf22a79379460f40877d3e0bf3927409f3adec842642041b336951407be`.
`compose` receives f/g through erased-type-prefixed arguments, calls f and tail
calls g. `chain` recursively captures a scalar offset and a preceding closure.
That fixture cannot by itself establish a materialized-list callback result.

Current `j_pure_signature` delegates live argument/result types to `j_pure_type`,
which accepts supported scalars and closed data, not function values. A direct
callback path therefore requires a new bounded proof fact; adding only emission
would be insufficient. The [design](../../design/phase39/callbacks.md) keeps this
eligibility gap and potential affine source-checking refusal explicit.

The first authored fixture materializes callback, input and result lists and
uses every function value once. Both checked Phase37 and pinned TypeScript
refused it because `callback.make` consumed predecessor `p` twice: once to
derive a dynamic capture and once in recursive construction. This is a fixture
quantity error, not a compiler conformance discrepancy. The retained v1 source
SHA256 is `fdd8ec2fda7f20a15c2c3d0186a8e26ea40393188700ce7c830625449364d1ec`;
raw failures are `selfhost/build/phase39/callback-baseline01` and
`callback-typescript01`.

The versioned `callback-fixture-v2.bend` marks that Nat parameter `+n`, following
the existing duplicable-Nat pattern. It preserves function-value affinity,
algorithm, scalar captures, all three materialized lists and the independent
U32 recurrence oracle. `callback-catalog-v2.py` records both v1 parent hashes;
the original files and failed acquisitions remain unchanged. Checked acquisition
of v2 is the next gate, before any direct-call ablation or speed claim.
