# P45-011: typed private Number-Nat representation

Status: checked worker11, eight maintained suites, independent Nat controls and
deep worker controls pass. The isolated worker10b→11 screen measures 1.694× Map
and 1.725× records gains; these two points remain 2.953× and 2.543× TypeScript
time. This is a development checkpoint, not full-corpus or release qualification.

The public selfhost runtime represents Nat with BigInt. Pinned TypeScript uses
Number internally, but its typed library exports also return BigInt Nats,
including Nat fields in public data. Our valid immediate Nat domain is 0 through
2^48−1, not arbitrary integers.
Current Map and record workers repeatedly test/decrement counters and carry Nat
inside freshly owned tuples and records. A Number countdown alone is insufficient:
the representation must compose through the complete proved private graph.

A whole-worker-IR pass validates every value and native boundary, then rewrites
all internal Nats together. Typed Nat literals, projections, constructor layouts,
match layouts and native/primitive operation identifiers supply semantic facts;
we do not recover types by editing generated JavaScript text. Unknown boundaries
retain the original BigInt graph. The pass is linear in the finite lowered IR and
adds no source recognizer or independent source-level optimizer.

The first mode supports checked successor and addition, saturating subtraction,
comparison, exact divmod (including divisor zero), U32 conversions and Nat shift
counts. Other existing U32/F32 operations and known non-Nat native boundaries keep
their behavior. Multiplication and exponentiation are outside this first whitelist.
Sum/successor intermediates are below 2^49 and exact in binary64. Division obtains the exact integer remainder `r=a%b`, then computes `(a-r)/b`;
the numerator is exactly divisible and the integer quotient fits 48 bits.
This avoids an approximate floor quotient and adds no Math dependency. Overflow uses the existing
`bad` error path and exact message.

The public entry proof is unchanged: positive arity, original scalar input tests,
complete purity and layout proof, exact-entry permission, dependency descriptors,
and host identities. Nat inputs remain BigInt and bounded before Number conversion
inside the existing host-identity guard. A Nat result converts back to BigInt after the
private computation. String and other scalar results remain unchanged. Public
object/closure results and container inputs stay excluded, so internal Nat fields
cannot escape into an unconverted public ABI. Generic fallback is selected before
execution, never by restarting partially executed work. The rejected nullary07
admission is not included.

Validation must cover Nat inputs/results above U32, constructed 2^32, max/overflow,
zero and large divisors, remainder identities, shift counts 0/31/32/max, nested
record/tuple fields, recursive errors/reentry and mutated public/host boundaries.
The compact literal parser still rejects 4294967296n: use Nat.add or public inputs
for large values. Compare valid typed Nat inputs and BigInt results exactly across
all three compilers; compare selfhost mutation/error details against the predecessor.
TypeScript's overflow string remains distinct from selfhost's Error object.
Counter derivatives prove
activation independently of timing. Representative Map/record screens and profiles
then decide whether to keep the change; BigInt has not been proved the only cause.

The isolated pass is in `selfhost/src/back/js/ir/worker-nat.bend`. It performs one
eligibility traversal and one structural rewrite; component analysis still uses
the unchanged call edges. `JWEmission` carries the selected representation to the
existing public wrapper. The ordinary printer retains BigInt `JWNat` output for
refused graphs. No public runtime representation or runtime fragment changed.

This experiment also replaces proved Nat native descriptor calls with private
arithmetic helpers. A measured gain would combine representation and native-call
elimination; it would not alone prove how much BigInt arithmetic cost. An optional
BigInt-direct ablation can separate those causes after the general pass is useful.

## Executed checkpoint

The selected API is
`319d06fd039a2ed51881ad824d5371c29ad3b41d332f4bb4906e256ce7c65bf2`.
The repaired BigInt control, worker10b, is
`5ada9ab4b60b1f4a7b82a90436e5682bc596cb7eab340fbe8e96215ba7e6a443`.
Both use the unchanged runtime and pinned upstream
`018751270e800bc222a93dad7f257083ee53a5f7`.

`number-nat-controls11-v2/report.json` passes 215 oracle cases across all three
roles and all 16 public fixture roots, five overflow cases across all three,
28 exact selfhost boundary comparisons and 73 untimed activation observations.
The complete candidate AST contains one `public_counter` assignment; it retains
generic entry and BigInt fields. Number/BigInt host replacements, descriptor
mutation, real source overflow, Error-hook reentry and subsequent replay pass.
The compact-literal refusal fixture is recorded but **not executed by this
controller**; that separate frontend check remains outside these totals.

Eight maintained suites pass. The independent composition fixture additionally
passes 135 small oracle cases across three roles, five public-data cases, five
descriptor refusals and two diagnostic unwind/reentry cases. Five separate deep
roots each pass 4,096 and 50,000 recursion steps with two seeds at the default
984 KiB stack setting. These are scoped backend controls, not a new conformance
count for the language.

The causal screen `runtime-worker11-vs10b/report.json` passes all 18 fresh role
samples in 15.377 seconds. Three rounds per role rotate order; each uses at least
350 ms warmup and a 150 ms sample target on CPU 3 with Node 24.18.0, a 1 GiB heap
and 2 GiB process-tree RSS limit. Timings exclude compilation and instrumentation.

| Point | TypeScript ms | Worker10b ms | Worker11 ms | 10b / 11 | 11 / TypeScript |
| --- | ---: | ---: | ---: | ---: | ---: |
| Map churn 128 | 0.793806 | 3.969341 | 2.343764 | **1.69358×** | **2.95256×** |
| Record aggregation 256 | 1.268730 | 5.565618 | 3.225962 | **1.72526×** | **2.54267×** |

Candidate within-sample drift is +19.96% to +21.69% for Map and +8.30% to +8.80%
for records. The gain survives fresh predecessor execution, but three short
rounds do not establish steady-state, full-corpus or universal speed. This change
combines Number representation with removal of proved native descriptor calls;
it does not isolate the cost of BigInt alone.

Two failed attempts remain visible. The first isolation removed the shared
`$workerBudget` declaration from worker10; its Map execution failed before any
measured case. Worker10b restores precisely `let $workerBudget=32;`, and the valid
causal comparison uses 10b. Separately, the first Nat controller incorrectly
expected Number results from the TypeScript library and stopped at `0n !== 0`
before completing any oracle. Inspection of the emitted typed wrappers established
the BigInt ABI. The preserved v2 controller requires the original exact oracles
and shared BigInt inputs; it does not coerce unexpected outputs into passing.

The [checkpoint report](../../implementation/phase45/native-representation.md)
records the source isolation, worker09/10b/11 progression, field-layout uncertainty,
profiles and remaining validation limits. Raw attempt paths in this record are
relative to `selfhost/build/phase45/`; their hashes and consumed inputs remain in
the receipts rather than being presented as committed public artifacts.
