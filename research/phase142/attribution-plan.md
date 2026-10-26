# Phase142: attribute the warm floor before changing its boundary

2026-10-26, repository `e093c3b`. Read-only investigation followed by an authorized
host observer implementation; no target execution by this investigator. The
coordinator owns execution. This is a measurement plan, not a speed result.

The cheapest first experiment is **retain the actual small A/B request products
in a checked hosted API, and replay individual existing Bend operations**. A new
native compiler image is unnecessary for this attribution screen. Native timing
is still needed before turning hosted observations into a native gain claim.

## What the retained evidence establishes

The final Phase140 warm native stages were frontend30.966s, raw13.306s,
backend40.079s, registry9.902s and render/close6.777s. These are nested pipeline
boundaries, not removable costs. In particular,40.079s is not the final verifier.

The retained diagnostic capture
[`profile01/report.json`](../../selfhost/build/phase140/profile01/report.json)
ran the older Phase140 N1d image. Its approximate warm window contains4,550
physical samples, with11.27% in borrowed `p88_string_eq_go`,4.81% in borrowed
`String.cmp`,24.33% in reclamation and13.03% in ownership/product helpers.
The full capture has zero reported loss,99.41% main-thread CPU coverage and
95.88% resolved symbols. The warm window still has4.15% unresolved samples.

These are useful leads, not attribution to a particular equality caller.
The window is derived from CPU sample ordinals and conservative wall bounds,
not timestamped phase events. Reclamation and equality can serve many stages.
Do not add their percentages to a raw-comparison speedup estimate or ascribe
reclamation exclusively to structural equality. The old capture also predates
the Phase141 comparator consolidation.

The existing hosted verifier screen is already cheap. In
[`verify-screen01`](../../selfhost/build/phase140/verify-screen01/report.json),
preparing real independent A/B raw programs cost2.82+1.75s for Lexer and
4.24+4.76s for Map. Median warm whole first-verifier observations were0.0768s
and0.1407s, versus0.2854s and0.7527s fresh. Those are historical ordered hosted
observations. They establish a useful experimental scale, not the native floor.

## Ready observer and exact source

[`attribution.mjs`](../../selfhost/tools/performance/phase142/attribution.mjs)
uses the original frozen Lexer and Map fixtures from Phase134 reference03,
Phase137's selected Base/carrier, and unchanged Phase141 source:

- Source SHA256: `f5bfca6d1fe9b378955d6c89ba5ec2428ec1627d7d008eb0c15eac1b51c8a06a`.
- Checked API: `selfhost/build/phase111/p142-baseline-api02/report.json`.
- API SHA256: `f755a65577f760099bab7082a48ba2ecb69b4e0c52b55e4e8f716109e435d2ec`.
- API acquisition already completed in14.80s; no native acquisition was needed.

Run under the coordinator's existing single measurement lane and resource
guard, with a fresh output,180s deadline,3GiB process allowance and16GiB available
memory floor:

```sh
selfhost/.bootstrap/bun-1.4.3/bun \
  selfhost/tools/performance/phase142/attribution.mjs \
  selfhost/build/phase111/p142-baseline-api02/report.json \
  selfhost/build/phase142/attribution01 \
  lexer coverage-map-churn-128
```

For the smallest iteration, pass only `lexer`. The20–180s range is a budget,
not a measured duration for this new observer. It reuses existing checked
functions and pins every input; it does not implement a second compiler.

The real edits are Lexer `U32.shln(x,13n)`→12n in `prng`, and Map
`U32.mul(i,31)`→29 in `p37.map.update`. A's logical source path remains fixed for
B. Absolute parser hints include the prepared Base origin. The observer checks
complete A output against the frozen product; complete warm B against the old
fresh pipeline; both frontend requests structurally; and that B actually changes
QBE. Input/API/carrier hashes are rechecked at completion. Cold means empty
candidate state in a warm host process, not a cold executable or cold OS cache.

## Boundaries and interpretation

The initial A and warm B run four disjoint timed calls:

1. `p140f_named`: parser/checker/ownership/annotation/erasure/frontend assembly.
2. `p111_runtime_admission`: the original request admission.
3. `p140or_lower`: static preparation, owner reuse and raw lowering.
4. `p140b_session`: first verification, optimization, second verification,
   late observer/borrowed closure and the independent final gate.

Output rendering, independent fresh oracle work and three rounds of subsequent
component replays are recorded separately. The initial stage total excludes
registry/rendering and is explicitly named `totalBeforeRegistrySeconds`.

The replay inputs are actual returned products and successful caches. Each
operation remains the checked Bend implementation:

| Replay | Exact root | Included work / limitation |
|---|---|---|
| Ordered raw global context | `p140v_context` | Raw headers and constructor equality; no body equality. |
| All first-verifier admission context | `p140v_reuse` | Previous row plus ordered direct headers. Nested, do not add both. |
| Raw segment equality | `p140v_segment` per actual pair | Complete header/body equality, plus host dispatch per segment. Diagnostic aggregate, not an exclusive in-compiler timer. |
| Raw admission | `p140v_raw_walk` | Comparator, list walk and original verification for misses. Metadata supplied outside interval. |
| Direct admission | `p140v_direct_walk` | Direct body equality/miss verification plus ordered ready-index rebuilding. |
| Complete first verifier | `p140v_check` | Context, metadata, raw/static/direct checks. Encloses several prior rows. |
| Final independent gate | `p126bp_complete` | Replays all current final checks on the actual final accepted functions; excludes late closure preparation. |

The final gate is accessible without instrumenting the closure machinery.
The actual output is `P134Planned{P134Admitted{assembled}}`, so replay:

```text
p126bp_complete(assembled.original.original,
                assembled.certificate,
                assembled.original.functions)
```

Its output must equal the original emitted plan. This includes
`p118b_verify_functions`, `p113a_verify_after` and `p114t_verify_done` through the
unchanged original function. It is a hosted replay cost, not an exclusive native
sample attribution. This is the important missing measurement; timing
`p140le_verified` alone would include observer preparation and closure too.

The frontend replays use the actual retained owner context, annotation products,
and final request. They separate `jl_checked_error`, `nc_context_index`,
`nc_context_defs`, `norm_max_book`, `book_cached`, `nc_paths_of` and `kr_filter`.
Each result must match the actual corresponding product. The annotation list
is reconstructed from retained entries outside timed intervals. This tests the
specific remaining whole-book/index work rather than attributing all frontend
cost to cache misses. `ns_attach_book`/constructor-table assembly is not yet
isolated and must remain an explicit unmeasured remainder.

Orders reverse on alternate replay rounds. Report every observation and medians;
three observations do not supply a confidence interval. Replays overlap each
other and the original stage, and must never be summed into total request time.
JIT, allocation, GC, held references and ownership behavior differ between the
hosted API and native image. Static segment counts are not dynamic node visits.

## Small follow-up hooks only if the replay justifies them

For the producer-witness experiment, diagnostic counts should be returned once
per request: segment pairs considered, exact raw body comparator invocations,
body nodes actually visited, witnessed admissions, old-comparator agreement,
miss verifications and final gate invocations. Count visits inside the comparator
when investigating its cost; do not substitute total IR size or the number of
cache hits. Preserve the original short-circuit order. No per-node logging.

Use the real old comparator as the diagnostic oracle. New witnessed admission
must imply old complete segment equality under the same successful-revision
context. Keep the independent final gate unchanged. Disable diagnostic duplicate
comparisons/counters for the clean timing candidate. Collect a same-source
instrumentation-overhead observation; instrumentation is not a speed result.

The first falsifier is straightforward: if raw body comparison is a small part
of hosted admission and native samples do not implicate it, do not expect this
seam alone to remove the40s backend floor. If the independent final gate dominates,
owner-witness admission cannot evade that floor without a separately justified
verification design. If book/index assembly dominates, focus on retained checked
views rather than another raw cache.

## Native confirmation without another image build

The existing native `phase140-batch` entry supports small repeated source jobs
in both Phase140 and Phase141 images. `run-batch-v02.py` can preload the already
built sampler; no machine-code rebuild is needed. Create a small plan with a
cold seed followed by real edited warm requests and independent expected QBE.
Use the exact candidate image and the source-compatible plan, not old full-source
products with new timestamps. Its output path must currently be under Phase140:

```sh
python3 selfhost/tools/performance/phase140/session/run-batch-v02.py \
  --image EXACT_QUALIFIED_OR_EXPERIMENTAL_IMAGE \
  --plan PINNED_SMALL_TWO_REVISION_PLAN.json \
  --out selfhost/build/phase140/p142-small-samples01 \
  --seconds 120 \
  --sampler-receipt selfhost/build/phase140/sampler01/report.json \
  --period-us 8000
python3 selfhost/tools/profiler/analyze.py \
  --samples selfhost/build/phase140/p142-small-samples01/samples.txt \
  --binary EXACT_SAME_IMAGE \
  --output selfhost/build/phase140/p142-small-samples01/analysis.json
```

This is a command template until the image and independent small-job plan are
pinned. Do not execute the full compiler solely for early attribution. Collect
at least500 accepted samples for quantitative fractions, preserving unknowns,
loss and process-lifetime coverage. Fast jobs may require several real requests;
never turn repeated no-ops into the headline warm-edit workload. Keep clean
request timings separate from sampling; no absolute CPU attribution without a
matched clean CPU denominator and qualified coverage.

The existing `profile-window.py` only accepts one cold plus one warm request,
and derives approximate ordinal bounds. It must not be used unchanged for
multi-job stage attribution. Exact native attribution would need bounded phase
markers or region counters, not relabeling a broad leaf sample. Generic runtime
owner/caller attribution can complement physical samples, but scheduler owner
state alone is not a causal caller for borrowed helpers or reclamation.

## Coordinator-run first screen: actual result and observer correction

While this investigation continued, the coordinator executed
[`attribution01`](../../selfhost/build/phase142/attribution01/report.json)
successfully in46.612s. Complete frozen-A/fresh-B QBE comparisons and frontend
structural comparisons passed for both fixtures. Median component replays:

| Hosted seconds | Lexer | Map128 |
|---|---:|---:|
| Actual warm pipeline before registry |2.5714|2.2130|
| Actual warm frontend |1.0055|0.6733|
| Raw admission replay |0.03442|0.07469|
| Complete first verifier replay |0.04060|0.09163|
| Independent final gate replay |0.36592|0.10466|
| Annotation eligibility replay |0.01199|0.07493|
| Maximum fresh scan replay |0.00735|0.01429|
| Book index replay |0.00273|0.00233|

The replay/whole-request scale suggests approximately1.3%/3.4% for raw admission,
1.6%/4.1% for the entire first verifier and14.2%/4.7% for the final gate. These
are ratios of ordered diagnostic observations, **not additive exclusive shares
or native speedup ceilings**. They make a large win from the first raw admission
alone less likely on these fixtures. The final gate matters more on Lexer; the
majority of Map's backend remains elsewhere.

One observer reporting bug is retained explicitly: v01 decoded three Bool
observations as tagged objects, whereas this checked JS ABI returns primitive
booleans. Consequently `contextEligible`, `directEligible` and
`equalSegmentPairs` were incorrectly false/zero. The actual checked admission
calls received the original booleans and reported264hits/1miss for Lexer and
665hits/1miss for Map; the pipeline and all correctness assertions passed.
The timing calls themselves still executed. Do not treat the erroneous fields
as compiler refusals or dynamic equality counts.

[`attribution-v02.mjs`](../../selfhost/tools/performance/phase142/attribution-v02.mjs)
fixes the ABI decoding and asserts equality-only counts match the admitted raw
hits when context reuse holds. The frozen v01 method/report remain unchanged.
Only a syntax check was performed by this investigator. Use v02 for future
collections rather than rewriting the historical receipt.

The native profile offers **no stronger causal first-verifier claim**. Its report
explicitly says neither caller-unwind nor active-owner sidecars were collected.
There are only tiny direct named comparator/verifier leaf counts; these do not
bound their inclusive costs because borrowed comparisons, runtime helpers and
continuations run elsewhere. This is insufficient evidence to override the
small hosted signal.

The next useful exports are `p140pl_load`, `p140cb_owner_cut`, `p140cb_check`,
`p140cp_admit`, `p140dr_report_data`, `driver_emit_owned`, `j_compile_error`,
`book_context_world`, and `p140of_context`. They allow an exact warm frontend
replay in original order:

1. Parser resume plus completion/global freshening.
2. Owner-cut lookup and complete checker bridge.
3. Report, ownership eligibility, entry eligibility and context creation.
4. Owner change analysis, annotation/erasure reuse and remaining assembly.

Replay `p140cp_admit` separately on the actual current event book/checkpoint to
measure its full `norm_max_book`, exact checked-prefix comparison and exact
remaining-header comparison. Its accepted suffix still runs `dg_check_events`;
the small fixtures skip only3 and2 declaration events. That is a specific reason
not to assume checker hits mean near-zero checking. The owner adapter still
runs `p140oq_analyze`, reachability, annotation admissions and erasure traversal.
Their work is absent from the tiny index/book replays. Until the next subdivision,
"the frontend floor is checking" and "the frontend floor is owner comparison"
remain competing hypotheses.

The coordinator subsequently requested that subdivision in the corrected observer.
`attribution-v02.mjs` now includes it and requires the additional exports above
from `selfhost/build/phase111/p142-baseline-api03/report.json`. It replays the
original call order three times against A's actual successful cache, compares
the complete resulting plan and parser/checker/owner state to warm B, and records
the accepted remaining checker-event count. `p140cp_admit` is explicitly labeled
as nested in the checker bridge. Use a fresh `attribution02` output with API03;
the extended script has only been syntax-checked by this investigator at writing.
