# Late observer scan: dependency audit and optional experiment

Status: candidate 15 passed checked API acquisition and all 32 late finite
controls (`p140-native-api15` and `native-finite04` receipts). Exact real-request
comparisons and native timing are separate gates. This is not a qualified
compiler change or an established speedup.

The native experiment reported 35.266 seconds in the warm backend, versus
74.256 seconds for A, despite almost all inline/range and raw-verifier units
being reusable. That does not establish which remaining stage dominates.
The bounded experiment replaces only initial observer planning and worker
construction; it leaves retry planning, composition and final verification paid.

The actual selected compiler's `p128br_scan` constructs
`no_observer_plan(book,name,True)` for every candidate, then performs admission
and calls either `p118b_functions` or `p128bs_find`. The latter embeds a current
optimized owning fallback. A cache keyed solely by source owner or signature
would therefore be insufficient even when the observer analysis itself is
unchanged. The candidate preserves the exact first-name lookup behavior,
including absence and an ineligible first matching function.

The original request book is a distinct dependency epoch. Its `BookCache`
contains erased/static facts accessible through `ns_body`; `nc_source_body`
can read those instead of the visible declaration body. The post-static raw
cache's transformed book cannot authenticate these original inputs merely
because its output happens to match. The candidate maintains a separate book,
dependency graph, reverse index and all-declaration fact comparison.

An independent audit found a missing **global** dependency in version 1:
`nol_finish` appends `nol_scalar_specs(book,book)` to every successful schema.
An unrelated ADT's constructor type can unfold an edited alias. All source
headers and the selected owner's ordinary dependency closure may remain
unchanged, while the complete schema catalogue changes. Version 1 is retained
as rejected evidence. Version 2 constructs this catalogue once per request,
retains the previous result, and compares every ordered `NO_Spec`/`NO_Layout`
field before allowing any cache hit. Controls include the concrete unrelated
ADT/alias case as well as individual field mutations. That counterexample is
an internal metadata mutation, not a claim that it passes the source checker.

Version 3 strengthens the per-owner key further: every dependency edge
includes both the actual source declaration and its actual `ns_body` fact.
Changes to either input refresh the edge before the next revision; propagation
uses the retained old reverse graph. A hidden erased reference and a three-
revision reference-removal control cover this case. It no longer assumes that
erased references are a subset of source references.

The validity premise remains narrow: same compiler, privately published cache
state, and actual internally prepared request namespace/constructor metadata.
This is not an authenticated serialized worker cache. It must be retained only
after the complete request succeeds. The emission wrapper preserves previous
state on errors, and the surrounding session must still withhold publication
if output IO fails.

The independent source audit found no further blocker in version 3: unchanged
owners can use the prior outgoing dependency graph, while every changed owner
is already dirty; refreshing changed edges after closure supplies the next
revision's graph. This source audit does not replace the executable
controls or independent complete-output comparisons.

The optional implementation is
[`core-v03.bend`](../../../selfhost/tools/performance/phase140/late/core-v03.bend)
(152 lines) plus
[`emit-v01.bend`](../../../selfhost/tools/performance/phase140/late/emit-v01.bend)
(39 lines). It has no production override. The wrapper calls the original
`p128raw_br_scanned`, so retry, closure, original passes and
`p126bp_complete` remain in their existing order.

The planned screen compares the entire original `P128BROpen` against cold,
edited, unchanged and reverted cached results for actual Lexer and Map inputs.
It also compares complete fresh/cached QBE, the unchanged historical oracle,
and error/publication behavior. Dependency admission, catalogue preparation,
fallback comparison and cache retention must be included in cost. Only a
subsequent native full-compiler replay can establish how much of the remaining
35-second backend this removes.

One further opportunity is now concrete but unmeasured: the global scalar
catalogue is repeatedly constructed inside successful schemas. Threading one
immutable request-local catalogue into schema construction could remove that
work on cold requests and misses too. The present experiment only computes it
once for its cache key; original miss processing still performs the original
schema work. Do not count that future opportunity as an implemented gain.
