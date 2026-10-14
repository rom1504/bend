# Replace repeated whole-program membership scans

Prepared offline; no compiler checking, target execution or speed measurement.
This is separate from the two-field definition header experiment. Do not combine
them before either has an independent result.

The latest exploratory 180-second capture places shared equality and `has_name`
in the 30–60-second window, `nb_contains` in 60–90 seconds, then almost entirely
String append in 120–180 seconds. Its outer qualification failed after a canonical
source edit during capture, so these are diagnostic leads, not clean phase clocks.
The final-output builder is the stronger immediate explanation of the 600-second
deadline. Indexed membership cannot remove that later append work.

## Exact call paths and the smallest candidate

The native entry calls, in order:

1. `p86_plan_checked` → `driver_report_data(original)`.
2. `p86_plan_context` → `reach_book(context,["main"],stops)` → annotation.
3. `p86_plan_annotated` → `jl_checked_error` → `nr_prepare_annotated`.
4. `nr_prepare_annotated` → `nr_walk`, followed later by native emission.

`core/reach.bend:84` checks `has_name(seen,name)` for **every pending dependency**.
The list grows with the reachable program, and line81 scans that live-name list
again for every input definition. If V names are reached, E dependency items are
popped and B definitions are filtered, membership alone can perform O(E·V+B·V)
String comparisons. The number of compared characters and ownership cost are
additional factors. These are algorithmic bounds from the actual code, not counts
measured from the failed profile.

The independent [`reach-indexed.bend`](reach-indexed.bend) candidate adds one
private checked-entry helper. It retains the existing dependency traversal,
lookup, parent-constructor resolution, stop behavior and input-book filtering
order. Only membership is carried in the existing compressed persistent trie.
`p90_live_has` tests a dedicated marker kind, so an empty name cannot be confused
with the empty-name `missing()` result. Existing exact-name collision buckets
remain responsible for full 32-bit hash collisions. No unchecked integer-ID or
probabilistic membership substitute is introduced.

The private native entry changes just:

```bend
annotate_selected(context, reach_book(context, ["main"], stops), stops)
# to
annotate_selected(context, p90_reach_book(context, ["main"], stops), stops)
```

The legacy public `reach_book`, `kr_visit`, `has_name`, lookup functions and JS
Data ABI remain unchanged. The candidate has 63 physical Bend lines including
law declarations/comments, seven functions, no new datatype and no new algorithm
family: it reuses the current exact index. A frozen compiler derivative adds64
physical lines, with the one private call replacement. Hash construction still
walks each query String once; index paths are bounded by the 32-bit key width,
with linear work within a complete-hash collision bucket. There is no worst-case
constant-time claim.

## Why full products and chronology are preserved

At each call to `kr_visit`, let S be membership in its `seen` list. The indexed
loop's invariant is that its trie contains exactly S:

* A pending name already in S skips the same item and retains the same remainder.
* A new name is marked before the identical `kr_resolve` call.
* An absent result contributes no additional name or dependencies.
* A resolved definition marks `dn(d)` and prepends exactly the original
  `kr_dependencies(d,stops,todo)` output. The list may contain duplicates in the
  legacy loop; their membership is unchanged by a set.
* Filtering walks the original book once, retaining each original complete
  definition exactly when its name is in S. This preserves input order and even
  repeated entries. No definitions are reconstructed by the candidate filter.

This differs materially from replacing `f_find` with a final-definition map.
`f_find` returns the first matching list event. `f_context_declared` stores mapped
headers with bodies removed and aliases/namespaces applied; those are not equal
to local raw declarations. `f_decl_local` therefore cannot return an existing
scope-index hit directly. Any parser fast lookup needs a **separate raw-event
index**, updated exactly when `Con{d,book}` changes, with laws and imports covered.
That is a larger source-state and transport change, so it is not this experiment.

Native checked-entry admission matters: hashing forces a whole String, unlike a
legacy early mismatch. The proposed call sees names produced by parsing/checking
Bend source, not arbitrary malformed JS values. It does not grant the indexed
implementation to the existing public raw API or change its failure demand order.

## Controls and root-run protocol

`prepare-reach.py` ran offline and produced `reach01/manifest.json` plus
`legacy.bend`, `indexed.bend` and `compiler-reach.bend`. It copies actual current
core term/index/reach definitions and uses the same consuming native equality in
both standalone controls. The host script only assembles source and literal test
data; the proposed compiler optimization is entirely Bend.

Twenty complete-result cases cover empty/missing roots, chains, diamonds, cycles,
duplicate edges/roots, stopped bodies whose types must remain reachable, direct
and inherited constructor roots, ordinary-name precedence, duplicate-event lookup,
empty names, Unicode and an actual FNV collision: `costarring` and `liquid` both
hash to **1582148253**. Expected selected row indices are written explicitly in
the fixture generator. Full terms, flags, constructor lists and retained complete
books must match, not only selected names or hashes.

Use the existing guarded `phase88/component.mjs` independently on:

```text
selfhost/tools/performance/phase90/observation/reach01/legacy.bend
selfhost/tools/performance/phase90/observation/reach01/indexed.bend
```

After both check, compile each C output with the same Clang flags and run C with
`--threads 1 --gpu off` plus both JS outputs, all under separate serial guards.
Then:

```sh
python3 -B selfhost/tools/performance/phase90/observation/compare-reach.py \
  selfhost/tools/performance/phase90/observation/reach01/manifest.json \
  OLD_JS_STDOUT OLD_NATIVE_STDOUT NEW_JS_STDOUT NEW_NATIVE_STDOUT \
  NEW_REPORT.json
```

Require four byte-identical outputs and all20 explicitly expected whole products.
The standalone execution is a correctness gate, not a compiler speed benchmark.
Then compare a private native image against the same image without this change,
with the late output-builder fix held identical. Test a completed general source
and full-self request; do not claim total gains from unfinished prefix windows.

Preparation/build costs belong inside total measurements. An index can lose on
small graphs: it allocates marker definitions and persistent nodes. A threshold
should be added only if paired measurements justify it, not guessed now. Any
full-source failure, changed C, changed diagnostics or material small-case loss
stops promotion. A 20-case source correctness suite does not replace full native
compiler cache/live and broad exact-C gates.

## Follow-on opportunities, kept separate

`back/native/request.bend:10 nr_walk` repeats growing-list membership using
`nb_contains(done,name)`. It can thread the same private index while preserving
the exact ordered `done` list and `facts` list; no field needs to change in
`NR_Closure` or `NR_Request`. Its result product and erased bodies must be compared
in full. `back/native/book.bend:290 nc_live_names` has the same pattern, but some
calls are already avoided by retained request products. Measure actual remaining
calls before changing both.

`driver/report.bend:91 dr_own_names` also scans a growing list while deduplicating
all user declarations. A companion set can retain identical first-occurrence
order and native-skip behavior. The report has separate safety closure rules:
an early unsafe result must never label every visited name unsafe/safe. Phase84
report-only shortcuts yielded only0.5–2.2% on their small program screens, so this
is a compiler-sized scaling hypothesis rather than a reprise of those savings.

`constructor_exists` scans all prior definitions and their constructor lists,
including during Base-prefix admission. An exact constructor-owner index can
help but has broader world-version and duplicate-diagnostic obligations. Small
`has_name` uses (removed constructor cases, short cycle guards, fixed stop lists)
should remain lists until measured otherwise. A blanket global replacement would
add index construction repeatedly and erase the intended asymptotic benefit.
