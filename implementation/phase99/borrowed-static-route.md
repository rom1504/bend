# All-trivial observer route hypothesis

Source04 extends source03 by allowing the existing owning adapter when every
schema root is trivial to dispose. Its guard is `(ANY shared) || (ALL trivial)`.
No helper name, constructor name or source spelling selects this route. Schema
admission, certificates, workers, adapters, runtime and canonical modules are
unchanged. This is a prepared candidate; no compiler or program was executed
by its author, and correctness/performance qualification remains with the root.

In the completed source03 own-C
(`0c84b47d9c787289f0159c7c47074ecb58b50fe6a16785836488760350feffac`),
`term_triv(t)` means `term_tag(t) <= TAG_PAK || t == TERM_HOLE ||
term_loc(t) < HEAP_OFF`. The ordinary `term_sink` immediately returns for those
values. Static String nodes and their children are immutable image values;
`term_peek` reads their direct location. Empty roots use packed nullary values.
Thus the owning adapter's disposal is constant-time for this newly admitted
case, including large static graphs. It cannot add a second dynamic destruction
traversal there. The existing any-shared alternative is left byte-exact.

`term_triv` alone is not a type or lifetime certificate: it also recognizes
scalars, captureless closures and the hole sentinel. Existing checked root
schemas and observer admission still provide shape and permission checks.
Only schema root positions enter the conjunction; scalar argument bit patterns
must never affect it. Admitted schemas still require one or two roots. The
true identity for an empty internal fold does not admit zero-root functions.

Two unique dynamic roots, or a static root paired with a unique dynamic root,
still take the original owning path. An RFC wrapper at count one is likewise
nontrivial and keeps that fallback. A shared dynamic root continues to activate
the existing route regardless of the other root. Packed/static nullary roots
are safe because their already checked schema controls any field access.

The exact derivative is
[`borrowed-calls-source04/compiler.bend`](../../selfhost/build/phase99/borrowed-calls-source04/compiler.bend),
SHA-256 `c19e926eb7d8d41309c9ed8aa18960c484f3b17681507b57da5418ccfedd31ec`,
1,762,973 bytes. It adds 9 lines/540 bytes to source03, or 132 lines/8,877 bytes
to Phase98. Its [recipe](../../selfhost/build/phase99/borrowed-calls-source04/changes.json)
replays every source03 edit from exact Phase98, adds the new helper and guard,
and checks complete inverse replay. Source03 and its methods remain untouched.

Reproduce into a fresh output directory with
`python3 selfhost/tools/performance/phase99/borrowed-calls/prepare-static-v1.py --out selfhost/build/phase99/borrowed-calls-static-replay01`.
The previous `prepare-v3.py` intentionally still reproduces source03; its old
README output-path example is not the recipe for this new source04.

Three [source-bound laws](../../selfhost/tools/performance/phase99/borrowed-calls/static-laws.template.bend)
constrain the actual emitted conjunction, ignored scalar slot and true fold
identity. Their extraction keeps exact helper bodies and removes only leading
unsafe annotations; three semantic helper mutations challenge the laws.
Safe admission and independent proof checking have not run. These are guard
text contracts, not a proof of `term_triv`, native lifetime or C semantics.
Four [finite API cases](../../selfhost/tools/performance/phase99/borrowed-calls/static-api-cases.json)
exercise the same selection boundaries and preserve the old shared disjunction.
They can be appended to the existing 18 predicate cases without modifying pins.

The fastest qualification order is checked API/source admission, those four
cases and the existing small09 corpus, then a static/static variant of the
already useful equality micro with runtime repetition count and full output.
Inspect generated C to confirm the new clause, direct borrowed calls and exact
fallback after removing the guard. A generated-program control should exercise
static/static equal and unequal strings, static/empty, shared/static,
unique/static and two-unique pairs with exact final roots/output. Runtime branch
counters or an isolated C predicate truth table distinguish representation
from source-level ownership; affine syntax alone does not prove the branch.

The expected truth table for two roots is:

| Root A | Root B | Route |
| --- | --- | --- |
| static/packed | static/packed | new borrowed route |
| shared dynamic | any valid root | existing borrowed route |
| any valid root | shared dynamic | existing borrowed route |
| unique dynamic | static/packed | original owning path |
| static/packed | unique dynamic | original owning path |
| unique dynamic | unique dynamic | original owning path |

Keep broad observer admission, permission and representation checks unchanged.
Only a measured gain in the intended compiler work justifies full-image
integration; a static micro gain alone does not establish that result.
