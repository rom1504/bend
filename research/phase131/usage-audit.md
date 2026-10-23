# Phase131: retain exact use facts for one immutable body

Status: bounded candidate checked, finite/real-body/full-QBE gates pass. Root
subsequently authorized a separate CPU5 correctness lane,3GiB maximum RSS and
16GiB available-memory floor. Native performance remains root-owned. The first
checked acquisition rejected a pattern binder order; `summary-v01.bend` and its
receipt remain negative evidence. `summary-v02.bend` changes only that order.

## Source and measured motivation

Parent is qualified Phase130 `mode-source01/compiler.bend`, SHA256
`995d6b4bf14963debb9a810de2ed941c3cd30a71fc34a156d96b1adbd1b06bdd`.
Its original `nq_uses`, `nq_min_uses` and `nw_uses` stay unchanged in the candidate.
They are the executable independent reference, not replaced with the new code.

The Phase129 Map active-context profile attributes10.97% to use-query contexts.
The event report records1,424,357 segment dispatches and8,116,922 `term_drop`
entries while `nq_uses` owns the active context. These are instrumented event
counts, not inclusive exclusive time or guaranteed removable overhead. The
current Phase130 compact Base change does not remeasure this exposure.

Two actual consumers repeatedly query an immutable body:

| Consumer | Body identity | Existing decision |
|---|---|---|
| `ns_unshared_terms` | One `nc_erase(book,dv(d))` supplied by its definition wrapper | Visit source terms; test maximum use≤1 for relevant variable IDs |
| `nh_terms` | One `nc_compact_definition(book,d,0)` supplied by its definition wrapper | Visit source terms; inspect type or mark wildcard when maximum use>1 |

The Map event report records13,041 and19,869 respective segment dispatches. Their
recursive calls pass the identical body argument. Each query currently walks
that body's tree afresh. We have not yet attributed every use-query event to
these consumers: `p113p_bindable`, demand checking and wrapper validation also
query usage. No gain from those unchanged callers is assumed.

## Exact semantics, including the non-obvious cases

For each U32 variable ID, a summary stores the pair `(minimum,maximum)` in0..2.
It is not an ordinary occurrence count:

- `Var` contributes exactly one to its ID and ignores any children.
- Exactly two-child `Mat` combines minimum with `min` and maximum with `max`.
- Other `Mat` arities use ordinary child sequencing, as the old implementation
  does. This includes malformed/internal forms; no stronger admission is assumed.
- `NWPattern` has minimum zero. Its maximum is the maximum of each row's
  `kid(row,0)` summary; row metadata and further children are ignored. Missing
  children retain `kid`'s existing `Absent` behavior.
- Every other form sequences all children with addition saturated at two.
- `KLambda` and `KLiteral` use the actual selected `p98_tag_eq`, `ix`, `ks` and
  `kid` helpers. There is no representation projection or ad-hoc tag adapter.

Entries are a sorted, unique sparse list with positive maximum; absent entries
mean `(0,0)`. IDs retain their full unsigned range, including4294967295. There
is no dense-ID/freshness bound or array-mask assumption. Merging uses the exact
safe `p131a_add`, `p131a_low` and `p131a_high` declarations from
`phase131/laws/production.bend`.

The proof agent's bounded arithmetic contracts are distinct from the full
summary theorem. Sortedness, uniqueness, sparse absence, concrete-tree traversal
and the correspondence of lookup to the old recursive query remain explicit
bridge obligations. Finite differential controls do not prove those universally.

## Reuse and invalidation boundary

Each public consumer wrapper constructs one local summary and passes it through
the existing decision traversal. Recursive helpers never reconstruct it. No
summary crosses a body rewrite, request, compiler generation or source identity.
There is consequently no global cache or hidden invalidation policy.

Only two original declarations change: `ns_unshared_terms` and `nh_terms`.
Everything downstream, including final independent verifiers, remains intact.
Annotation treatment, type queries, branch order, wildcard short circuit and
returned list order follow the original consumers. Empty worklists and an
already-hot wildcard avoid summary construction. An otherwise early-rejected
scan may still build an unused summary; this is a performance risk to measure.

## Candidate acquisition and cheapest falsifiers

Compose using the existing Phase131 assembler, with these modules in order:

1. `selfhost/tools/performance/phase131/laws/production.bend`
2. `selfhost/tools/performance/phase131/usage/summary-v02.bend`
3. `selfhost/tools/performance/phase131/usage/consumers-v01.bend`
4. `selfhost/tools/performance/phase131/usage/controls-v01.bend`

Use `--overrides ns_unshared_terms nh_terms`. Export `p131u_controls`,
`p131u_build`, `p131u_agrees_all`, `p131u_unshared` and `p131u_hot` for the
checked host discriminator. `p131u_controls` has22 cases. `p131u_agrees_all`
compares both bounds for every independently enumerated syntactic ID plus
explicit absent/boundary IDs, and checks sortedness/count range.

The source-only extracted native fixture is prepared by:

```sh
python3 -B selfhost/tools/performance/phase131/usage/prepare-fixture-v2.py \
  --out selfhost/build/phase131/usage-proxy02
```

It copies25 exact selected declarations, including both original query walkers,
the NWPattern helper and actual term/borrowed-tag representation helpers. It
produces original/summary variants differing only in `p131k_query`; the candidate
rebuilds the summary on every iteration, so preparation is included. Three
64-ID families cover ordinary single uses, two-arm choices and word-pattern
rows. A small independent integer oracle fixes expected outputs. This synthetic
proxy establishes only that repeated queries can amortize preparation.

Prefer checking the actual consumers and emitted QBE before spending time
improving the proxy. A complete Map request, lexer and an unrelated closure/tree
request must retain byte-identical QBE. Pair same-process API cost; then use the
qualified native producer only if total cost improves meaningfully. No full
image acquisition is justified by a synthetic speedup alone.

## Cost risks and stop conditions

Sparse sorted merging is deliberately small, not asymptotically optimal. Large
descending-ID sequences can copy many list prefixes; lookup is linear in the
number of stored IDs. It also computes minimum facts that these first two
consumers do not need. Branches create summaries before discarding paths, and
eager preparation can lose against a scan that makes no usage queries.

Reject or narrow the candidate if preparation/retained entries outweigh removed
tree walks, actual consumer cost rises, or emitted QBE changes. A cheap next
ablation is maximum-only summaries or a demand-triggered first construction,
not a large persistent cache. A joint min/max walk for `p113p_bindable` is a
separate alternative with a smaller reuse opportunity; do not mix its result
with this experiment.

## Bounded executed evidence

The whole candidate API03 checks11 exports in14.83 guarded seconds, with
2,148,519,936 bytes peak RSS. API02 had stopped at the2GiB cap, before any semantic
failure. The separate22-control gate passes in1.65s with152MB peak RSS.

`selfhost/build/phase131/usage-request01/report.json` records16 real checked
Base-body min/max comparisons and12 complete QBE emissions: parent and candidate,
two alternating rounds each, on lexer, closures and Map. All twelve match the
frozen qualified native QBE byte for byte. The guard takes80.95s, peak953MB.

These same executions provide an exploratory CPU5 cost discriminator:

| Request | Parent seconds, two observations | Candidate seconds | Ratio of means |
|---|---|---|---:|
| lexer |9.006,7.154|9.276,6.988|1.0065|
| closures |1.299,1.310|1.277,1.286|0.9823|
| Map |9.978,10.976|9.155,9.991|0.9137|

The equal-case geometric ratio is0.9667. Two observations, JIT warmup and possible
concurrent root work do not establish a stable native/compiler-wide speedup.
The consistent Map result is sufficient reason for a controlled native proxy;
the lexer result is neutral, not evidence of a useful gain.

Proxy02 original/summary checked APIs pass both22 controls and the independent
three-line oracle (`1400980480`, `1400980480`, `2124477184`). The source variants
have14,581/14,592 bytes; only `p131k_query` differs. Hosted execution including
summary preparation takes0.331/1.340/1.646s for the old three families versus
0.048/0.055/0.045s for summaries. These deliberately repeated64-ID inputs show
amortization potential, not actual native request performance.

Negative proxy evidence is retained: proxy01 had incorrect IO-do syntax;
proxy02 fixes only the wrapper. Two ordinary `--check-only` attempts refuse the
compiler's declared unsafe helpers by policy. They are not type/ownership
failures. The existing checked bootstrap API route then successfully validates
both complete proxy books, preserving its unchanged checker and hole gates.

Root's controlled native usage screen is now complete:
`selfhost/build/phase131/usage-timing01/timing/report.json` records five
alternating pairs with exact ordinary outputs. Median process wall time falls
2.579477→0.094107s, ratio0.036483 (27.41× faster). Both exceed the20ms timing
floor. This is the deliberately repeated-query proxy, not a27× compiler gain;
the measured exploratory whole-request mean remains only3.3% lower. Both native
programs were emitted by qualified Phase130 N1 using compact Base, built with
the same runtime and aligned assembler policy. A failed unrelated identity
extraction did not cause either successful usage acquisition to be repeated.

## Proof-connected algorithm candidate

The proof agent supplied source-connected safe absent, merge and lookup
algorithms, with ten independently checked bounded/aligned-key laws. The
generic KTerm traversal and complete disjoint-key merge theorem remain outside
that proof scope. `laws-safe-summary01/report.json` records exact proved-source
substitution and unchanged traversal bodies. It removes three mutually recursive
dispatch helpers and uses two small deferred branch dispatchers; this is a
candidate whose performance must be measured, not an automatic consequence of
proving it.

`usage-safe-source01` checks all11 API exports in14.53s with2.15GB peak RSS.
The22 finite controls pass. `usage-safe-request01/report.json` adds16 real Base
bodies and six full emissions from current/safe summaries on the same three
requests, all byte-identical to frozen QBE. These are correctness gates;
single-order diagnostic timings do not establish a speed change.

`usage-safe-proxy02` copies the entire proved module in declaration order while
preserving the prior proxy's workload and oracle. The first extraction appended
the safe chooser after its caller and correctly failed the filled-definition
gate; that attempt is retained. The repaired complete proxy checks successfully.
`usage-safe-jobs01/jobs.json` acquires only its new binary, then compares it
against the already qualified0.094s current-summary executable. No baseline
rebuild or full compiler acquisition is needed for this discriminator.

That screen rejects automatic adoption: safe callbacks take0.241731s versus
0.094279s for the fast helper-recursive summary, **2.564× slower**. They still
beat the original repeated walkers substantially, but proof-connected source
alone is not a performance result. Both safe and fast artifacts remain intact.

Independent static inspection identifies a concrete cost boundary. Fast maximum
and minimum queries each forward to a local tail-SCC worker. The safe versions
become137-line scheduler functions with a two-value closure and a32-byte
continuation capture; their chooser performs generic application. Safe merging
also grows314→605 QBE lines, with additional constructor/reconstruction sites.
These static counts do not attribute the entire runtime regression to closures.

Two disjoint next candidates were prepared and checked without a full compiler
rebuild:

1. **General selector lowering.** The existing closed-selector analysis omitted
   scalar literal leaves. A two-declaration override plus one helper admits
   canonical scalar leaves in a bounded, checked callee. V02 rejects unsupported
   source shapes before compaction, avoiding expansion of a huge String literal.
   It passes19 finite controls and independently emits the **unchanged safe proxy**.
   Max/min now have107-line local workers, explicit loop backedges and no closure,
   application or generic-jump calls. Merge is unchanged. V01/V02 emit the same
   644,797 QBE bytes; this is a structural result pending native timing. The root
   has a build-only/timing plan reusing the old safe binary and an ordinary
   eight-line text/shared-capture transfer gate. No failure-runtime probes ran.
2. **First-order safe algorithms.** Exact proof-agent source replaces callbacks
   with pending comparison state and scalar current heads. It preserves the
   remaining summary traversal. The extracted complete source checks;22 controls
   and three independent output checks pass. Four lookup and two merge equivalence
   laws connect these algorithms to the previous safe implementations without
   sorted/aligned-input preconditions; the full summary theorem remains separate.
   Root's plan emits only this new proxy and reuses the fast-summary binary.

The new source/proof experiments retain separate identities and costs. Neither
has been folded into the selected native compiler merely because it type-checks
or proves an equation. Their purpose is to test whether proof-friendly source
and efficient lowering can be made to cooperate without weakening either.

The useful abstraction, if this wins, is a body-scoped semantic summary whose
legality is independent of QBE text. It removes repeated ownership-sensitive
interpretation without changing generated-program behavior. Whether it actually
makes research cheaper is an end-to-end measurement, not implied by the design.

## Measured proof/performance reconciliation and integration

Both alternatives now have controlled native results. The selector-only compiler
change emits the **unchanged** callback-safe source and reduces its median from
0.245831 to0.099911s (ratio0.406423,59.36% less). Its independent ordinary
text/shared-capture transfer gate passes. The first-order safe algorithms run in
0.096660s against0.094172s for the fast unsafe summary (ratio1.026426), recovering
nearly all of the callback regression while connecting the actual implementation
to independently checked all-input equivalence laws. These are separate paired
blocks; do not combine their medians into a precise ranking. Evidence is in
`selector-jobs01/timing/report.json` and
`usage-first-order-jobs01/timing/report.json`.

The source-level first-order alternative is selected for the next algorithm-only
composition. `combined-first-order-source01` preserves the FAST identity changes,
substitutes the exact safe summary and exposes the existing `missing()` sentinel
as its literal constructor expression. The latter has a separate mixed hit/miss
native discriminator (ratio0.901899); it introduces no mutable pool or cache.
Compared with FAST, the combined source adds818 bytes and11 physical lines.
`combined-first-order-bridge01/report.json` authenticates11 actual compiler
declarations against the accepted proof snapshots, removing only namespace
qualifiers. This proves neither generic KTerm traversal nor backend correctness.

The complete algorithm source checks in15.70 guarded seconds (2.19GB peak).
All22 usage controls,16 sampled real Base bodies and six FAST/new complete QBE
emissions pass; all three request products match independent frozen QBE bytes.
The single ordered CPU5 pair is a correctness/cost screen, not native timing:
lexer8.586→8.953s, closures1.807→1.377s, Map10.483→10.150s. JIT order and concurrent
root work preclude claiming these differences as compiler gains.

`combined-codegen-source01` is a distinct candidate adding frozen selector V02
and projection-source06's raw-stage retry. It excludes selector V03 and the
rejected late duplicate-preparation path. It checks in15.72s (2.24GB), passes69
finite controls and the same source/proof bridge. Three request QBE products
remain exactly frozen, so they do not exercise the new codegen paths. The
one-pair hosted cost ratio is0.98565 geometrically, with Map1.06072, lexer1.01855
and closures0.88631; this is not evidence that analysis overhead is free.
Dedicated ordinary selector/projection transfer sources are therefore emitted
separately before native qualification. All original final verifiers remain.

The reusable summary remains local to an immutable body; there is no cross-request
cache or invalidation mechanism. Its unresolved scale tradeoff is building facts
for every body ID even when callers query only a subset, and computing lower
bounds although these two consumers need only upper bounds. The safe first-order
merge carries current heads explicitly to avoid callbacks/reconstruction; its
larger individual generated worker must be compared with the entire displaced
helper family, not with one function. Whole-compiler execution and native
self-reproduction remain separate root-owned gates.

The final ambitious candidate is `combined-literals-source01`, SHA
`1bc5930edcf80cda6c3572645df3c846fa631a83c2b936f20c83b05e0a6728f9`.
It adds the shallow-layout/virtual-reader composition and replays literal
constructor exposure on the **current** source bodies. It does not restore old
whole definitions. Its exact419 replacements preserve all91 original verifier
declarations and all11 proof-connected declarations byte for byte against its
direct parent. `combined-literals-bridge01` independently authenticates the latter.

The actual final API checks20 exports. All98 finite predicates pass. Six paired
FAST/final emissions and16 real Base-body min/max comparisons pass; all three
complete QBE outputs still match their frozen originals. The one-order CPU5
request ratio is0.95914 geometrically, with lexer1.03821, closures0.83485 and
Map1.01800. This remains an exploratory cost screen, not native compiler evidence.
Its42.11 guarded seconds include both compilers and output checking.

Four actual-final transfer emissions independently pass source lowering and the
unchanged final verifier: scalar selectors, String projection, list projection
and the actual compiler `nq_uses` computation. Acquisition costs36.44 guarded
seconds/594MB peak. Root-only plans at `combined-literals-ordinary01/jobs.json`
and `combined-literals-transfer-jobs01/jobs.json` now require seven aligned
native builds with independent exact ordinary-output oracles. Their completion
and the full self-hosting chain are separate gates; this note does not preclaim
either. The separate final admission method replays the original module
composition followed by the exact recorded literal patch, rather than treating
the derived source as a plain overlay or weakening the frozen native qualifier.
