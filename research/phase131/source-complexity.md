# Phase131 compiler source and preparation-cost audit

The reproducible inventory is
`selfhost/build/phase131/native-source-audit01/report.json`, produced by
[`source-audit.py`](../../selfhost/tools/performance/phase131/native/source-audit.py).
It hashes the actual composed `compiler.bend` files. External proof experiments,
benchmarks, Python/JS harnesses and research documents are not compiler lines.
Composition is not checking, admission, or native qualification; those statuses
remain in their own receipts.

## Source size

“Code lines” means nonblank lines excluding full-line `#` comments. Physical
lines include both. Unique names combine a forward `law` signature and its
definition; declaration-head counts keep them separate. A `law` head is not
necessarily a proved theorem. These quantities measure source size, not a
numerical count of semantic concepts.

| Frozen source | Bytes | Physical lines | Code lines | Unique declaration names | Changed existing names |
|---|---:|---:|---:|---:|---:|
| Phase130 `mode-source01` |2,613,588|57,018|41,219|6,443|—|
| `combined-fast-source02` |2,628,217|57,431|41,536|6,488|5|
| `combined-first-order-source01` |2,629,035|57,442|41,539|6,488|6|
| `combined-codegen-source01` |2,640,826|57,641|41,698|6,507|16|
| `combined-regions-source01` |2,650,402|57,842|41,855|6,529|18|

FAST adds413 physical lines (0.72%) and317 code lines. Most new code is retained
control/reference machinery. The following is an auditable lexical dependency
classification of **new declarations relative to Phase130**, rather than a proof
of runtime reachability:

| Candidate | Production-connected helpers/types | Their code lines | Control/reference helpers | Their code lines | Unconnected additions | Existing-code delta |
|---|---:|---:|---:|---:|---:|---:|
| FAST |16|111|29|221|0|−15|
| First-order + missing |16|114|29|218|0|−12|
| Codegen |30|190|33|280|1 /9 lines|0|
| Regions composition |46|298|39|328|1 /9 lines|+1|

For example, FAST's net317 code lines are96 production-connected lines plus221
control/reference lines. These controls really are inside the selected source;
they are included in its total, not external test files added to an unrelated
repository-wide count. The raw JSON lists every classified name and module pin.

The five FAST replacements are `ns_unshared_terms`, `nh_terms`, `index_set`,
`index_find`, and `lookup`. First-order+missing adds the `missing` replacement and
replaces the summary merge/max/min implementation without adding unique names.
Codegen additionally changes bounded selector admission and the observer helper
schema/call/scan path. Regions adds `p128bl_node` and `p128br_reference` changes
with shallow owned-layout/virtual-product compatibility. The rejected regions07
module is not present in this inventory.

One concrete unused addition is `p131p_scalar_helpers` in
[`late-workers-v03.bend`](../../selfhost/tools/performance/phase131/projection/late-workers-v03.bend):
nine code lines, with no lexical incoming reference from any other declaration.
Do not generalize that finding to helpers named “original”: `p131i_original_set`
is a production fallback and must remain. Controls could eventually be composed
into a separately checked test overlay, but that would require exact source/body
binding and new qualification; this audit does not remove them.

## Actual native product growth

| Product | Phase130 | FAST N1 acquisition | Change |
|---|---:|---:|---:|
| Full compiler QBE bytes |102,432,076|104,618,546|+2.13%|
| Full compiler QBE physical lines |2,521,280|2,556,660|+1.40%|
| N1 ELF bytes |16,586,488|16,771,824|+1.12%|

These are complete pinned files, not one selected function. The FAST image was
acquired through qualified Phase130 N0; its own self-reproduction/qualification
is a separate gate. Full first-order/codegen/regions compiler images were not
available at this audit. A2,414-line `merge_loop` versus a605-line old helper
cannot substitute for a comparison of the whole old helper family, much less
the whole compiler image. The same three ordinary request products are
byte-identical in the retained small hosted comparisons.

## What the projection closure recomputes

The actual codegen composition uses
[`candidate-v02.bend`](../../selfhost/tools/performance/phase131/projection/candidate-v02.bend)
and `late-workers-v03.bend`. Source tracing gives a more specific explanation
than “it prepares everything twice”:

1. Initial preparation still constructs the raw candidate catalogue once in
   `p128raw_prepared`; `p128raw_plan_finish` performs the initial readiness closure.
2. The observer scan retains its plans and actual worker bundle. Product
   wrappers are now eligible for helper summaries alongside scalar wrappers.
3. When a product helper and a nonempty retry list exist, `p131p_closed` performs
   a readiness closure over the **retained raw catalogue** before retrying scalar
   observers. It rebuilds the merged signature index and visits already-ready
   candidates, whose bodies are skipped by `p113d_ready`. Waiting candidates may
   need additional dependency rounds, bounded by the existing32-round fuel.
4. Retries use the closed worker set, then the final independent verifier runs.
   This branch does not call another `p128raw_close` afterward.

The baseline already performs late readiness closure for flat workers, normally
after observer retry. The new branch changes its condition and ordering; it can
force closure in product-helper cases that previously skipped it. It is not
automatically an extra closure for every request, and it does **not** reintroduce
`p113pl_inspect_request`, source lowering, or Base materialization. Signature-index
reconstruction and candidate visits are concrete work; their total time is not
established by source inspection.

Likewise, `p128br_summaries` is called from the diagnostic
`p128br_diagnose_lowered`, not the selected raw request entry. Counting its
independent scan as a new production-request cost would be incorrect.

Other repeated work worth measuring, distinguished from new regressions:

- `p128raw_prepared` already evaluates `nc_bangs_names(book,names)` separately for
  the ordinary compilation and raw-candidate preparation arguments. This is an
  existing baseline duplication, not introduced by projection. The observer
  candidate selection later asks for these facts again.
- Product wrapper/result-parameter checks occur when seeding a helper and again
  at a call. The wrapper is immutable metadata; argument ownership checks remain
  call-specific. Preserving a verified-wrapper fact might remove the static
  portion, but direct/untrusted helper construction and fallback obligations
  must remain covered.
- `p128br_check_added` verifies added workers, and final verification checks the
  integrated result. These are different admission scopes. They cannot simply
  be removed as duplicate work.

No cache, skipped verifier or compiler change was introduced by this audit.

## Available request-cost evidence

The retained CPU5 hosted comparisons have one ordered parent→candidate pair per
case, within a single API process. They include the checked API's request body
(including Base reconstruction), but exclude API import, input-file reads and
writing emitted chunks. They do not isolate closure stages or provide native
compiler performance estimates:

| Diagnostic comparison | Lexer ratio | Closures ratio | Map ratio |
|---|---:|---:|---:|
| First-order+missing / FAST |1.0427|0.7624|0.9682|
| Codegen / first-order+missing |1.0185|0.8863|1.0607|

Reports are `combined-first-order-request01/report.json` and
`combined-codegen-request01/report.json`. All six products in each comparison
match the frozen complete-QBE oracles;16 real Base bodies also agree. The fixed
order, single repetition, host JIT and concurrent investigations prevent a firm
profitability conclusion. In particular, the Map1.0607 ratio does not identify
the raw closure as its cause.

The controlled native FAST block is separate: request time falls6.11%
geometrically, driven by17.58% lower Map time; lexer/closures changes are small.
It cannot be transferred to the codegen candidate without measuring that image.

The cheapest stage attribution, if root chooses it, is a bounded derivative of
the existing checked API probe that separately observes observer scan, readiness
closure, retry and final verification. It should retain the same raw catalogue,
actual stage inputs and full final QBE oracle, and report diagnostic overhead.
First inspect catalogue size, newly admitted workers and retry activation; a
zero-activation case falsifies a closure-based explanation cheaply. No new
profile or target execution was performed here.
