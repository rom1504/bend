# Constructor-query allocation slice

Status: source proposals and both controller versions passed independent static
review. Root integrated owner01 in checked-lookup01 and ran controls02 successfully.
This owner made no live source edits or target runs. Throughput measurement and
promotion remain separate from the focused controls below.

The Phase57 reach profile's `missing`/`kt` weights motivated this general query
change. It is separate from Phase55's completed typed `jd_raise` optimization.
All payloads are in `selfhost/tools/performance/phase58/lookup/`:

- `queries-baseline.bend` pins current common queries (`fb9fa891…`).
- `empty01.patch` / `queries-empty01.bend` avoid intermediate absent values.
- `owner01.patch` / `queries-owner01.bend` includes empty01 plus owned arm lookup.
- `identity01.json`, `catalog01.json`, `controls01.mjs`, and two renamed fixtures
  retain proposal/source/controller inputs; no ignored raw is their sole copy.

Global constructor search formerly called `lookup(dc(d),name)` on every owner.
Each empty or unmatched list manufactured a missing KDef and two absent KTerms.
`j_find_ctor_children` continues to the next owner on empty/unmatched children
without a return-value allocation. First matching child still goes through
`j_found_ctor`: even a matching non-Ctr record is returned, and matching Absent
skips the entire owner as before. A BookCache child still invokes index_lookup
and stops the local list on miss. Only the final whole-book miss constructs the
ordinary fresh missing value. No state, index, sentinel or public ABI is added.

Owned arm lookup normalizes the same old input domain once. Only original All
plus normalized ADT uses existing `j_layout_ctor`; wrong telescope/domain,
missing owner or missing owned constructor retains global search. Actual checked
books have globally unique constructor names, so the owner and old first global
match are the same record. Type specialization and arm telescope construction
remain unchanged. This is the same uniqueness contract used by Phase55 arity;
unchecked duplicate-owner books are not owner-route qualification inputs.
Global search itself retains their exact first-match behavior.

The controller accepts:

```sh
node --stack-size=4096 --max-old-space-size=1024 \
  selfhost/tools/performance/phase58/lookup/controls01.mjs \
  BASELINE_CHECKED_ATTEMPT CANDIDATE_CHECKED_ATTEMPT \
  selfhost/build/phase58/lookup-controls01
```

Root runs serially under CPU3/process-tree supervision (suggested first limit
90 s wall, 1 GiB JS heap, 2 GiB tree RSS). It verifies both checked attempts,
allowed frozen common-query source hashes, copies ordinary host tools into fresh
private projects, and creates explicit diagnostic derivatives of named B1 APIs.
Acorn-selected `missing` and `kt` function bodies increment private diagnostic
counters; appended probes expose existing query functions. Exact edits, suffix
hashes, Node parser source and input/copy/derived identities are recorded.
Production APIs and their checked sidecars remain untouched.

Synthetic global-query witnesses cover empty book, 512 empty owners then hit or
miss, 512 nonempty unmatched child lists, duplicate owners/children, matching
Absent, non-Ctr first match, and cached child hit/stop-on-miss. Expected missing
counts are 512→0 for successful long searches and 513→1 for a whole-book miss.
Cached rows may still construct an indexed absent result; no zero-allocation
claim applies to that compatibility branch.

A fresh renamed source exercises Nat literals/recursion, U32 literal/default
rows, a normal ADT and an erased dependent constructor field. Actual accepted
ABI2 completion supplies the checked book; actual annotate_selected trees supply
matcher telescope inputs. Complete arm-type results and source inputs compare
across images. Unknown owner, wrong telescope, owned-constructor miss and absent
telescope probe the original global fallback. Both ordinary emitted libraries
must return source oracle120. A renamed duplicate-constructor source must fail
with the same diagnostic in both images. Whole emitted bytes are recorded, not
required equal when root combines independently qualified output-shape changes.

Counts are not benchmarks or a proof that all missing records in Phase57 belong
to this path. After these controls, root should qualify focused maintained suites
and actual reach/final-emission costs before promotion. Duplicate malformed
source rejection is distinct from an unchecked synthetic duplicate-owner graph;
it does not authorize a shortcut for arbitrary inconsistent books.

## Controls02 admission successor

Root preserved `lookup-controls01` as an image-admission refusal: the checked
fields/lookup pilot attempts had `config.strictExact:false` because the build
configuration omitted that flag. Those receipts are unchanged. The successor
`controls02.mjs` records that flag, verifies the genuine checked attempt, and
independently pins `validation-001/report.json` plus its referenced
`validation-001/selected/paired.json`. Validation must complete/pass, bind the
exact attempt/API, and report selectedComplete with zero exact differences and
discrepancies. All 36 paired rows must independently pass both verdicts and exact
plus semantic comparison; no rows/missing/discrepancies are omitted.

Paired `complete:false` means full-suite completion was not attempted, while
selectedComplete is true; both fields remain visible. This does not rewrite the
configuration to strict-exact or claim full conformance. Every original query,
counter, source and negative assertion remains unchanged. Exact command:

```sh
node --stack-size=4096 --max-old-space-size=1024 \
  selfhost/tools/performance/phase58/lookup/controls02.mjs \
  selfhost/build/phase58/checked-fields01 \
  selfhost/build/phase58/checked-lookup01 \
  selfhost/build/phase58/lookup-controls02
```

Syntax and final successor review passed. Root executed controls02 successfully;
controls01 and its earlier admission refusal remain unchanged.

## Focused result: controls02 PASS

Root’s [raw report](../../selfhost/build/phase58/lookup-controls02/report.json)
completed/pass in 23.8 s under its external supervisor. Baseline is checked-fields01
API `ef4692ccc61dd7324b371f08b22c6f406418e99973a95769f378e2807c3eba97`;
candidate is checked-lookup01 API
`1e1b093952b48cb3799041724a203ce2b5595417a8b6aeb2517972c6b9ad7be3`.
The candidate common query SHA is `e62d1b36…`, the reviewed owner01 variant.
Both pilots retain strictExact:false; independent selected36 paired evidence
passes with zero differences/discrepancies, not full-suite completion.

| Diagnostic observation | Baseline | Candidate |
| --- | ---: | ---: |
| Arm-type comparison rows per role | 139 | 139 |
| `missing()` calls across those rows | 4,248 | 3 |
| `kt()` calls across those rows | 8,968 | 478 |
| `missing()` calls across the 135 actual matcher rows | 2,391 | 0 |
| Successful search after 512 empty owners: missing calls | 512 | 0 |
| Successful search after 512 nonempty child misses | 512 | 0 |
| Whole-book miss after 512 empty owners | 513 | 1 |
| Cached child miss then later-owner hit | 1 | 1 |

The 139 rows comprise 135 actual checked/annotated matcher queries and four
explicit fallback probes per image. Complete arm-type digests compare equal and
inputs remain unchanged. All three remaining missing calls occur in the explicit
unknown-owner/owned-constructor-miss fallback probes; the 135 actual matcher rows
have none. Global first-owner/first-child duplicate semantics,
matching-Absent owner skipping, non-Ctr first match and cached stop behavior all
pass. The cached compatibility branch intentionally retains its missing record.

Both independently emitted renamed libraries return the source oracle120; their
bytes happen to match (`b2ab9901…`). The renamed duplicate-constructor source
refuses at parse with identical diagnostics. These controls establish query
result/fallback and source behavior on this stated scope. `missing`/`kt` counts
are hook invocations, not bytes allocated, all allocations, GC savings or a
whole-source speed ratio. The source-forward owner assumption remains checked
global constructor uniqueness; malformed duplicate-owner graphs only qualify
global lookup semantics. Root’s separate lexer latency pilot is reported below.

## Lexer pilot: flat, no throughput gain established

Root’s [lookup-latency-pilot01](../../selfhost/build/phase58/lookup-latency-pilot01/report.json)
passes with the same emitted output. B1
import+first request is 1,860.44→1,839.63 ms; the sole later request is
1,174.79→1,181.70 ms. This is one process/sample per variant and mixed startup
plus request scope: the result is essentially flat, not a demonstrated gain.
The allocation mechanism’s intended throughput target remains large own-source
constructor queries, especially reach/final emission where Phase57 sampled
substantial missing-record construction. Fresh B2 own-source evidence and broad
qualification remain necessary before a retention decision.
