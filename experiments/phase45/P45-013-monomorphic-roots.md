# P45-013: ordinary monomorphic worker roots

The private worker graph can handle ordinary first-order functions without an
erased argument. This experiment removes that historical admission restriction
while retaining the complete graph, host, representation and public-dependency
guards. Primitive and literal leaves remain ordinary public definitions. It is
an eligibility change, not a workload recognizer or a relaxation of those guards.

## A real fallback failure, and the correction

Candidate13 passed the fixture's 54 small value checks and six worker-activation
checks, then failed the first genuine public-mutation boundary. In
`selfhost/build/phase45/monomorphic-controls13/report.json`, installing a getter on
`G.cedar` produced:

| Role | Result | Getter events |
| --- | --- | --- |
| Baseline11 | `1133` | `G, G` |
| Candidate13 | Function descriptor with arity `1` | `G` |

This was a compiler bug, not a failed test expectation. `cedar` has two declared
arguments, but its source value starts with a matcher. The ordinary public
descriptor therefore accepts one argument before constructing the next function.
The widened worker root incorrectly exposed a two-argument descriptor. On guard
refusal, the existing generic fallback consumes only consecutive leading lambdas;
it reached the matcher and returned it without applying the already-read slots.
The public partial-application and demand boundary was also changed.

The isolated13b correction requires
`j_lambda_count(dv(d)) == da(d)` for public worker-root admission. This existing
counter skips annotations and counts the same consecutive lambda prefix consumed
by ordinary closure lowering and the generic fallback. Public matcher-prefix
definitions remain ordinary, while their bodies can still participate in a
proved private graph behind a fully saturated lambda-prefix root such as `bench`.
The guard applies to every contextual root: the same saturation obligation exists
for the earlier erased-argument admission path.

The failed source and report are preserved. The one-predicate patch and its
before/after identities are in
`selfhost/build/phase45/alias-prefix-patch13b/receipt.json`; the patch is
`alias-prefix.patch` beside that receipt. Independent static review passed.
Candidate13b then passed the complete v2 control at
`selfhost/build/phase45/monomorphic-controls13b/report.json`: 54 small oracle
observations, six activation checks, ten public mutation boundaries, and one
supplemental ABI observation bundle. The consumed failed13 receipt remains
unchanged. Earlier candidate13 timing does not measure the corrected13b image;
the final combined candidate must establish its own runtime result.

## Independent controls

The renamed [fixture](../../selfhost/tools/performance/phase45/fixtures/monomorphic-workers.bend)
uses mutually recursive scalar functions with non-tail arithmetic, mutually tail
recursive functions, and an unoptimized literal leaf. Expected U32 results come
from an independent iterative oracle. No timing claim follows from these controls.

The consumed [v1 controller](../../selfhost/tools/performance/phase45/monomorphic-workers-controls.mjs)
is retained. The separately reviewed
[v2 controller](../../selfhost/tools/performance/phase45/monomorphic-workers-controls-v2.mjs)
adds public descriptor observations (`cedar.arity == 1`, `bench.arity == 2`),
staged application, absence of helper demand before the second `bench` argument,
raw ungranted `.code` execution, and the actual oversaturation error. It compares
baseline11 and13b values, descriptor metadata and getter traces. Diagnostic
activation counters must remain unchanged on these fallback paths. Existing ten
live mutations cover the public global, code, environment, bound arguments,
arity, and `.call` hooks; these do not claim arbitrary hostile-preimport support.

This failure reinforces a reusable rule: a private worker may have a convenient
full positional ABI, but a public wrapper must preserve the source's actual
saturation boundary and the timing of each intermediate function construction.
