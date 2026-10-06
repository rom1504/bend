# Independent Phase54 review

This is a static source review. No compiler, generated program, benchmark,
installation or bootstrap stage was executed by the reviewer. Target execution
and promotion remain root-owned. The installed Phase53 image is the starting
reference; a new direct compiler image or fixed point is not yet established.

## Shared helpers

The extraction passes static review. Comparing the six preserved source files in
`selfhost/build/phase54/helper-separation01/before` with their current remainders
and the four new modules gives the same 278 `def`/`law` blocks: no altered body,
missing declaration, added declaration or duplicate in this set.

- `back/common/{literals,queries,native-facts}.bend` contains checked-term
  inspection, type/context/substitution and constructor queries, binary32
  classification and checked Base declaration ownership facts.
- `back/js/shared-text.bend` retains JavaScript quoting, numeric expression
  spelling and `.js` foreign-source selection.

The ownership predicates inspect definition kinds and native flags; they are not
a complete native-operation or constructor-layout proof. Literal readers accept
particular syntax; their callers still supply provenance. JavaScript evaluation
order, numeric match lowering, native templates, representations, runtime guards
and ABI emission remain target-specific. Keeping the old names during an exact
extraction avoids combining organization with a semantic migration. Future C,
LLVM or assembly emitters can reuse suitable facts without inheriting JS policy.

Reviewed new module hashes:

| Module | SHA256 |
| --- | --- |
| common/literals.bend | `1a5360db5a467683dc0446d1f409ea34da21886649f2cddd518b6ab14cba00c5` |
| common/queries.bend | `135f8750079d08f6779dca3753f3bbda325d50f595b8f9c99a61db1331cc3a09` |
| common/native-facts.bend | `395c314326c89f150d536d8a225b92f86291aff3da811d48456f0f5468c52f1f` |
| js/shared-text.bend | `26f2b4b0e8656296bfa0d0b157bd36618fa3ce8a1c538cc53a59c2a425b481b9` |

## Graph invariants and remaining scale limits

The previous `direct/calls.bend` computes a transitive closure per definition,
then tests both reachability directions across all rows. Replacing that graph
algorithm is justified independently of increasing acceptance limits. The
proposed iterative SCC decomposition and reverse propagation from unknown-tail
seeds must preserve these facts:

1. Source scanning uses the exact emitted Nat/Word rows, live saturation and
   erased-argument rules. Constructing a closure is not executing its tail.
2. A node may require bounce forcing precisely when it can reach an unknown
   closure tail; a named cycle alone is not a bounce seed.
3. Component members retain selected-definition order. Every member agrees on
   the leader and dense program-counter numbering, including singleton nodes.
4. Missing targets and exhausted budgets reject the whole analysis. Traversal
   accounting includes duplicate edges, pending DFS frames and reverse edges;
   empty queues at a budget boundary must still complete.
5. The selected annotated definitions remain overlaid on the original typed
   context before analysis and emission.

The graph rewrite alone does not establish compiler-scale emission. There is a
second 512-definition limit in `direct/reach.bend`, whose first operation is call
analysis before exact emitted pruning. Reachability also has an edge budget and
a 2,097,152-character per-definition metadata scan limit. Moreover,
`jd_definition_loop` emits the complete SCC switch separately for each entry:
a large component can still duplicate quadratic body text. Reachability emits
each visited definition before the final emitter repeats the work. These are
separate limits/costs, not solved by a linear SCC algorithm or a larger number.

## Direct compiler-image migration

There is an existing migration path, not a requirement to recreate the legacy
`G` protocol. `typed-driver.mjs:loadApiForIdentity` validates term/span/load ABI
versions and returns `module.default` directly when `module.G` is absent. That
path already serves the named-field upstream bootstrap API. The positional
`compiler-abi.mjs` adapter is selected only for legacy self-emitted modules.

`KTerm`/`KDef` expose String, U32, Bool and List fields, including source ranges;
they do not contain a Nat field. Direct named constructors therefore appear
compatible with the existing host's first-order records without conversion.
This is a source observation, not yet a qualified compiler image. The direct
host's Nat-type scan, recursive marshalling bounds, whole-type IO filtering,
arity raising, partial calls and export selection still need checking on the
actual compiler API inventory. No-G presence alone proves none of those facts.

Export roots need an explicit check: `stage0-library.mjs` supplies a restricted
`book.order` to upstream `js_lib`, while the ordinary direct library roots every
eligible non-Base definition and exports eligible selected definitions. A
restricted compiler facade must preserve its intended roots instead of silently
rooting every helper in the compiler source. Full-image export differences and
any additional marshalling must be recorded separately.

Concrete migration steps, in increasing scope:

1. Emit a small explicit API set: ABI versions, a path helper, KTerm construction
   and access, cached book lookup, and a real loader/diagnostic operation. Use
   the ordinary loader's no-G branch. Check exact results, source spans, erased
   parameters, shared children and long List spines. Inspect wrappers for
   unexpected Nat conversion. Frozen host input and two sequential phase calls
   expose accidental mutation or copying assumptions.
2. Match the complete checked bootstrap export inventory, not only functions
   reached from a user program. Keep original ownership/template/foreign/IO
   eligibility rules and record exact missing or unsupported exports. Exercise
   load, check, diagnostics, specialization, legacy JS, direct JS and native
   source emission through that image.
3. Introduce an explicit direct compiler-image format/runtime identity in a
   separate bounded probe. Bind the checked producer, frozen source, Base,
   driver, direct runtime and output. Preserve the current legacy image path.
4. After compiler-sized acceptance and execution succeed, let the direct image
   check and emit the same frozen source. Compare another checked self-emission
   with the chosen seed under the same roots and options. Only that later gate
   can establish a new direct fixed point; stage0 checking or user-program
   benchmark equality cannot substitute for it.

The private compiler-image specialization pipeline is a separate migration.
Its generated-source transforms match legacy `G`/`fn`/`build` forms, its purity
proofs are tied to those forms, and its package/proof binds the legacy runtime.
Use a separately qualified direct image path rather than feeding direct text
through those transforms. Explicit `backend:'js'` in worker/session inspection
selects the requested *output* backend; it is not the image representation tag.

## Maintained routing

The two new `--legacy-js` arguments in `conformance/selfhost.mjs` and
`conformance/verify-seed.mjs` pass static review. Their resource flags, source,
selected compiler, Base/runtime, provenance and stage equality checks remain
unchanged. The host-only spy controller checks actual spawn expressions and
negative selector cases without launching children. This repairs an implicit
default assumption; it does not qualify a fixed point or change public defaults.

## SCC source checkpoint

Static PASS for `direct/calls.bend` SHA256
`797993d96b6eab3a273f979146d0032fa573e56d1178bbe5f3715dfd08417c87`.
All 25 scanner/row-builder definitions compare byte-exact with the frozen
Phase53 source. The new implementation validates named rows and targets once,
uses explicit enter/exit worklists for finishing order, partitions reversed
edges, and propagates unknown-tail seeds backwards. Component construction scans
original rows in reverse and conses members, restoring original source order and
dense IDs independently of DFS order. Each component list is stored once.

The final two-site use of tail-recursive `List.reverse.go` instead of
`List.append` reverses private adjacency traversal order; it does not change
component membership, canonical member order or bounce reachability. All query
consumers use the retained accessors; no other source file directly reads the
old per-name metadata representation. The new two indexes under `$JD.Calls.dc`
match `index_first`/`index_child` access.

The 512-vertex cap is unchanged, but acceptance is not entirely unchanged: the
old 65,536 queued-edge budget per reachability walk becomes a 4,194,304 total
input-edge budget. Some dense/duplicate-edge inputs formerly refused can now
pass. This resource-policy difference needs explicit reporting and boundary
controls. Once input validation bounds vertices and edges, the later traversals
expand each vertex once per pass; pending duplicate work is bounded by those
validated edges rather than a new unbounded source expansion.

The graph controller's initially missing `oracle` function brace was reported
and corrected before the reported baseline consumption. Its small-graph oracle
uses independent per-vertex reachability; larger sparse shapes use closed-form
facts. Those controls qualify graph facts only, not source scanning, generated
program behavior or compiler-scale self-emission.

## Additional probe/tool review

The additive direct compiler adapter preserves method identity and named graph
identity; its transport cases cover shared children, frozen inputs, a 20,000-node
list and cached-book handoff. The emission prototype initially skipped the
ordinary TODO, specialization and emission-ownership stages. The owner was
asked to retain those unchanged stages before reachability even when the exact
source's type-check proof is inherited. The correction passes static review at
emitter SHA256 `2d58298a1e10f3689faf879d40d1f04043b7b81ad38c37a1ac8aad3cf1510230`:
the inherited lane now runs TODO checking and specialization, and both lanes
check emission ownership before typed reach/layout. The fresh ABI2 checker
already returns its completed book. Tool/config/helper identities are rehashed.
An inherited lane continues to say that it did not perform a fresh self-check.
This approves the restricted transport experiment, not the full API or a fixed
point.

Two initial qualification-tool defects were reported: native inspection passed
an API filename where an API object is required, and the byte comparator treated
archive-backed published modules as loose files. Candidate module rows also
need an explicit join to checked source/emission-output identities. Consumed
failed versions must remain intact; a corrected successor must retain exact
module comparison without normalization or changed-case exceptions.

The corrected comparator v2 passes static review: the maintained bundle reader
handles archived baselines, and each compared candidate module is joined to its
checked source/output receipt, including exact reconstruction of the retained
generic-row observer. Native inspection now receives the API object loaded from
each frozen role. The scale-source generator correctly distinguishes its exact
declared function counts from selected graph vertices; its identity-chain oracle
is independent of compiler execution.

Graph boundary controller v2, SHA256
`4904d4e9b351b5e62f9053b582b1c81e21666b51de3b06794a78be8f395375f9`,
also passes static review. It preserves the original 14 cases and adds ten
explicit bounded-entry cases for zero/exact/one-short vertex or edge budgets,
raw duplicate edges and missing targets. It retains input-mutation checks,
independent reachability facts, membership assertions and final identity checks.

## Graph02 definition-budget checkpoint

After root authorized the larger production bound, the narrow graph02 delta
passes static review against the preserved `scalable-graph02/*.before` files.
One pure `jd_definition_budget()` returns 4096 and is used in exactly three
places: source-row collection, graph validation and exact emitted reachability.
Only these expressions and comments change. The source-tail limit remains 8192
per definition, the total graph-edge limit remains 4,194,304, exact reach remains
bounded by 65,536 queued names, and each emitted definition remains bounded by
2,097,152 characters. SCC text duplication and host/API gates are unaffected.

- `calls.bend`: `3b8129d1976a2016a7aef5a9e3cdd175fe7f5f9d5aec5ab220a427b37e1f0255`
- `reach.bend`: `3f0780000d1003e5fcc28243b210f39259c2b0716e2a975c0130ebcdbf3e0a1b`

This approves an explicit resource-bound change; it does not establish that
every 4096-definition source fits the other bounds, or qualify a direct compiler
image, throughput result or self-emitted fixed point.

## Ordinary-driver probe and diagnostic progress

The bootstrap ordinary-driver probe passes static review at SHA256
`a535abf241ab5f64605837b20ef2b7446f9109725ddf6374346c3329152ccd78`.
Both roles use byte-identical private driver/runtime copies with separate Base
caches, and call ordinary `loadApi`, `inspect` and `execute` without supplying
an API override. The direct role requires the no-G export contract and exact
method identity. The comparison retains all eight observations and exact emitted
JS/C hashes; only verified input paths become their content hashes. Every fixture,
including rejected sources and execution inputs, is rehashed at completion.
This checks ordinary-driver compatibility; it does not establish a compiler
fixed point. C output is compared but is not executed by this probe.

The progress-only emitter v2 also passes static review. Its pinned predecessor's
API pipeline is unchanged; synchronous JSONL records surround existing steps.
The report correctly labels its elapsed times as including diagnostic IO.

Scale-source generator v2, SHA256
`08d11c160c8680c75242a14346e5aae20417bbe35bea8cd72d2cfea9722b9111`,
corrects the preserved v1 fixture failure by adding `import Base` after its two
comments. Declared function counts, identity-chain edges, oracle 37 and fresh
output checks remain unchanged. The missing import was a fixture error, not a
compiler scale refusal.
