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

The useful abstraction, if this wins, is a body-scoped semantic summary whose
legality is independent of QBE text. It removes repeated ownership-sensitive
interpretation without changing generated-program behavior. Whether it actually
makes research cheaper is an end-to-end measurement, not implied by the design.
