# Phase131: identity resolution and the actual hot index work

This source investigation starts from qualified Phase130 source
`selfhost/build/phase130/mode-source01/compiler.bend` at repository HEAD
`9f7ab43`. It uses the immutable Phase129 context/counter reports, whose absolute
shares are **not** fresh Phase130 CPU percentages: compact prepared-Base decoding
has since changed the denominator. Initial investigation was source-only;
the later bounded correctness executions are recorded below.

## Reject the first, low-ceiling catalogue proposal

The backend already has numeric source-local IDs, a first-match exact-name
Patricia `BookCache`, and a prepared native-body fact index. Resolving owner
names once is sensible in principle, but the short-request counters do not
justify a new catalogue framework as the main optimization:

| Direct-entry counter | Lexer | Map churn | Closures |
| --- | ---: | ---: | ---: |
| `p113pl_candidates` | 46 | 73 | 16 |
| `nq_signatures` | 46 | 73 | 16 |
| `lookup` | 89,854 | 76,512 | 32,275 |
| `p111v_get` | 221,196 | 175,379 | 12,942 |
| `ns_body` | 1,669 | 5,197 | 288 |
| `nd_arity` | 1,287 | 4,527 | 174 |

These are observed direct segment entries, not complete inclusive counts:
inlined calls need not appear. Still, constructing a per-owner row merely to
remove a few queries for each of 45/72 real definitions cannot explain the
large identity overhead. The existing 1.08–1.25× forecast for a larger identity
change remains an unverified prior, not a promise for this small proposal.

Concrete duplication exists in `p128raw_prepared`: it computes
`nc_bangs_names(book,names)` twice, and direct preparation separately requests
the same definition, body, arity and kinds. It is a small cleanup candidate.
Do not turn it into a general cache without measuring total preparation cost.

Any future catalogue must preserve more than string equality. `lookup` stops
at a `BookCache` sentinel; `index_build` builds the tail first and replaces with
the head, preserving first-definition wins. Native signature generation emits
extra product/constructor aliases, so simply zipping owner rows with signature
rows is incorrect. Full KDef payloads, duplicate ordering, exact Unicode names,
constructor provenance and diagnostics must survive.

## More useful observation: every update walks its trie twice

Selected `index_set` first calls `index_tip(tree,hash)`, then computes the lowest
differing bit, then calls `index_insert` from the root. Both walks follow the
same Patricia search path. Every concrete node already stores a representative
hash and split bit sufficient to decide whether insertion belongs above it.

The bounded candidate performs a standard one-pass Patricia insertion. This
removes a category of repeated work across frontend names, verifier locals,
function identities and optimizer facts, rather than adding another catalogue
that itself requires construction. It changes no IR shape or naming scheme.

Phase129 active context fractions were:

| Context | Lexer | Map churn | Closures |
| --- | ---: | ---: | ---: |
| `index_tip` | 1.15% | 0.96% | 0.35% |
| `index_insert` | 3.48% | 1.76% | 1.08% |
| `index_set` | 1.14% | 0.67% | 0.10% |
| `p111v_get` | 3.80% | 0.98% | 0.29% |

The explicit removable traversal is real; these figures do **not** establish a
speedup ceiling because helper/scheduler transport changes context attribution.
Conversely, one cannot claim a large compiler gain by adding all index contexts:
lookup and exact collision comparison are still required. Per-node mask work
and calling-convention cost could make the candidate neutral or slower.

## Legality and falsification

See [the candidate and integration instructions](../../selfhost/tools/performance/phase131/identity/README.md).
The invariant is stronger than “stored hash is a representative”: canonical
nodes require shared lower bits, monotone nonzero power-of-two split masks and
correct child placement. Existing join/insert constructors maintain it, and
pinned prepared-Base decoding reconstructs the same trees. The private routing
stamp alone is not a cryptographic authentication mechanism. Legacy
KDef/zero-mask forms retain the old algorithm. Arbitrary malformed concrete
nodes are outside this internal invariant and are not claimed equivalent.

The key discriminator is exact whole-tree differential equality, including
collision bucket order and rich replacement payloads, followed by byte-identical
whole-request QBE. Tests should exercise zero/highest-bit hashes, collisions,
duplicates, missing names and mixed legacy/concrete trees. Independent verifier
entry points and acceptance checks remain untouched.

Only after the cheap semantic screen passes should a native compiler image be
acquired. Compare complete lexer/Map/closure requests with the same prepared
Base and hardware policy; preserve a negative result if traversal reduction
does not reduce time. No large self-hosting campaign is justified solely by
this source argument.

## What remains more ambitious

If name hashing still dominates after this bounded test, the meaningful larger
change is to carry an already verified local/function descriptor through a
whole immutable verifier/optimization computation. It must remove repeated
hashing **and** exact lookup, not merely rename the lookup API. Building that
descriptor repeatedly or looking it up again by the same String defeats the
purpose. Changing the final IR and its verifier just to test this hypothesis is
premature; first identify repeated identical queries within a real computation
and measure a source-level ceiling. A separate Phase131 lane is investigating
reuse of usage summaries, so this lane does not duplicate that work.

## Initial results

The candidate diagnostic compiler checked successfully. The coordinating lane
ran 336 exact original/candidate tree comparisons and 11,088 lookups with an
independent latest-payload oracle, all passing (`identity-controls01`). The
subsequent authorized CPU6 check ran both checked APIs on the frozen lexer,
closures and Map requests twice in alternating order. All 12 complete QBE
outputs were byte-identical to the qualified native oracles
(`identity-request-check01`). The 95.26-second bounded guard peaked at 906 MB
process-tree RSS. These are correctness results, not native throughput gains.

The ordinary native proxy is prepared: unchanged extracted compiler KDef/index
definitions, 256 actual declaration names, two construction/update passes plus
all queries and reclamation per repetition. Native proxy and full-request
measurements are owned by the coordinating lane.

The experiment is ordinary algorithmic optimization. It is not evidence of
recursive self-improvement or a new universal identity architecture.
