# P39-004 callback feasibility

Status: **negative experiment; no production promotion**. The corrected fixture
checked with both compilers and the prototype passed its semantic controls, but
direct callback invocation lost overall against the unchanged compiler output.

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
the original files and failed acquisitions remain unchanged. Both v2 acquisitions
passed. The new source hash is
`435646e46362366a6ca9c286bbc4e082f83c35c69537a9efd58421cef52d4bd5`.

## What the generated code actually contains

`callback.offset` is already a flattened two-argument `fn`. Each callback value
is its partial application, with the changing U32 offset in `bound[0]`; there
is no arbitrary heap environment tree in this fixture. The generic map applies
that partial value through a bounce, combines bound/current arguments, invokes
the same code and forces the numeric result.

The saved-output ablation compared three Bend variants:

- **Original:** exact unchanged Phase37 output.
- **Scoped generic:** one manually proved scalar entry, exact saturation and
  complete descriptor/host guards for the seven source definitions; callback
  application stays generic.
- **Direct, unfused:** the same entry, with only the known callback application
  invoking its existing code using captured offset plus current element.

All callback, input and result lists remain materialized. Captures remain
dynamic. No constructor representation, traversal, reduction or arithmetic
algorithm is replaced. The scoped variants are explicitly **uncertified
prototypes**: their exact-source reasoning does not extend production JPure to
function-valued fields or arbitrary closure environments.

`callback-controls01` passed **14 oracle groups, 38 boundary groups and one
injected-error witness**. These include independent U32 sums, complete small
lists, nonzero direct entry counts, dependency mutations after successful calls,
live host hooks, raw/staged/overapplied entry, retained/changed captures,
multiple public callback identities, getter/reentry and early/late callback
errors. Complete private list observation uses a separately labeled diagnostic
scalar proof entry. An injected private failure tests proof suspension and
cleanup; it is not claimed as a source-legal error in this closed arithmetic
callback graph.

## Clean comparison and decision

The three-round screen completed in **20.586 seconds**. Each role uses the
same source inputs and checks the frozen oracle; 350 ms warmup and 150 ms target
are excluded from compile acquisition. Counter modules are never timed.
Cells are median milliseconds per call (observed minimum–maximum).

| Input | Original Phase37 | Scoped generic | Direct, unfused | Pinned TS |
| --- | ---: | ---: | ---: | ---: |
| 64, seed 17 | 0.3034 (0.3005–0.3118) | 0.3460 (0.3442–0.3481) | 0.3323 (0.3233–0.3350) | 0.0070 (0.0068–0.0076) |
| 256, seed 1234567 | 1.4851 (1.2315–1.5600) | 1.7768 (1.7586–2.0060) | 1.6898 (1.6415–1.9026) | 0.0297 (0.0296–0.0305) |

Direct invocation is about **4.1%/5.1% faster than its scoped-generic comparator**,
yet **9.5%/13.8% slower than original** by median. All direct-versus-original
rounds lose and their observed ranges are disjoint; original 256 has substantial
between-round variation, which is retained rather than hidden by the median.
The small direct-versus-scope difference at 256 has overlapping ranges. This
diagnostic fixture does not measure typical Bend program speed.

The new proof boundary does not pay for itself here. Its cost is not isolated
to one fixed outer guard: adding the first `exactCode` wrapper sets the runtime's
module-wide `hasExactCodes`, so remaining generic calls also take the WeakSet
membership path in `invokeExact`. The prototype additionally checks proof
coverage at each direct callback site. Those are concrete code differences, but
their individual time contributions were not separately measured.

Do **not** widen JPure or add a closure representation to pursue this result.
The useful next hypothesis is elimination of dispatch across a whole eligible
component, where one admission amortizes several operations per element.
Another bounded experiment could keep the existing public entry and attach a
local known-callback fact only within an already admitted component; that needs
a real source proof, and this result supplies no speed estimate for it. Fusion
is a distinct later experiment with direct-unfused as its comparator. The
current first-order list benchmark remains a component opportunity, not evidence
that callback specialization should improve it.

## Reproduction and retained identities

Raw directories under `selfhost/build/phase39/` are `callback-baseline02`,
`callback-typescript02`, `callback-derived01`, `callback-controls01` and
`callback-screen01`. Restore ignored raw evidence from the phase capsule once
published. The checked original module is
`66e7246d2cafda2c999981c869bfbcb7c755f127b5396dd4d7605f3a916efce4`;
the pinned TypeScript module is
`cf27497561f61e2a8fab1659e7479ebac598295dccbfc26b3213d17244c67f1b`.

```sh
node selfhost/tools/performance/phase39/callback-derive.mjs BASELINE.mjs TS.mjs \
  selfhost/tools/performance/phase39/callback-catalog-v2.json NEW_DERIVED
node selfhost/tools/performance/phase39/callback-controls.mjs NEW_DERIVED NEW_CONTROLS
python3 selfhost/tools/performance/phase35/compare.py NEW_DERIVED/compare.json NEW_RUN \
  --node NODE24_ABSOLUTE --cpu 3 --budget 60
```

Root supervises derivation/controls; the comparison owns its shared execution
lock and is run without another owner of that lock. No callback production
source was changed, and no conformance expansion or regression is claimed.
