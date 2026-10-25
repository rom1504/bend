# The next reuse boundary: carry change evidence with immutable products

This is a bounded source investigation, not another measured optimization. The
important remaining distinction is between reusing a result and avoiding the
work needed to rediscover that the result is reusable. Phase140 does the former
well; it still performs several complete walks to establish the latter.

The next architectural experiment should make a successful producer return its
immutable products **and an exact change summary**. Downstream consumers should
use that summary within the same private session. Adding another independently
keyed cache would repeat much of the work identified below.

## Evidence and limits

The completed `selfhost/build/phase140/full-batch01/report.json` records actual
N1b, before the source17 metadata change and the source18 typed-comparator
experiment. The first warm compiler edit has these stage wall intervals:

| Stage | Cold seed | Warm inline-policy edit |
| --- | ---: | ---: |
| Frontend | 134.031 s | 53.058 s |
| Raw preparation/lowering | 70.679 s | 15.497 s |
| Optimization/verification | 93.104 s | 45.100 s |
| Registry | 15.390 s | 11.948 s |
| Rendering/close | 49.689 s | 8.044 s |
| Total native stages | 362.893 s | 133.647 s |

The warm request reused 3,924/3,964 annotations, 3,702/3,742 erased and raw owner
products, 49,012/49,013 raw verifier judgments at each boundary, all 1,515 direct
judgments, and 66,802/66,974 rendered pieces. These are different denominators.
The report separately records transport cost and does not establish independent
product equality for every warm edit. It is not a native qualification receipt.

These intervals are upper bounds on the categories discussed below, not their
exclusive costs. Ownership cleanup, lookups and other work occur inside them.
No percentage gain is assigned to a particular traversal without measurement.
The newer source18 comparator experiment is not credited with a result here.

## 1. Rebuilding the checked/annotated book around almost unchanged owners

The active [frontend](../../selfhost/tools/performance/phase140/session/frontend-v02.bend)
still calls ownership/entry gates and constructs `book_context_world` before
entering the [owner bridge](../../selfhost/tools/performance/phase140/owner/bridge-v04.bend).
In that bridge:

- `p140of_context` recomputes annotation stops and `reach_book`.
- `p140oa_walk` visits every selected owner even on a hit. `p140oa_record`
  reconstructs the definitions and entry-list spines; `p140oa_done` reverses them.
- `p140of_annotated` runs `jl_checked_error`. The existing implementation builds
  an index through `book_cached(defs,0)` and traverses the reachable definitions.
- `p140of_merge` calls `nc_context_index`, `nc_context_defs`, `norm_max_book`, and
  `book_cached`. The latter builds a complete `index_build(book)`; it does not
  merely wrap a retained index.
- `p140oe_walk` reconstructs the reachable ordering, visited index and erased
  fact list even when `body`, `arity` and `refs` are all reused. `nr_prepared`
  subsequently invokes `ns_attach_book`, `nc_paths_of` and `kr_filter`.

The source definitions are in the pinned Phase137 compiler at `book_cached`
(line 6614), `jl_checked_error` (17646), `nc_context_defs` (35881),
`nc_context_index` (35900), and `nr_prepared` (36302). These traversals are real
even if annotation and erasure miss counts approach zero.

**Useful boundary:** a checked revision should retain its ordered owner table,
name index, annotated products, erased reference lists and per-owner maximum
fresh identifier. A producer-created change set could patch those structures;
an aggregate maximum structure must handle removal of the previous maximum,
not only take `max(old,new)`. Preserve ordered lookup/duplicate precedence and
the exact reachable ordering required by downstream lowering.

**What cannot simply disappear:** global freshening, changed declaration types,
checker world and seen state, ownership errors, entry eligibility and the open
Array check still need their current meaning and error priority. An unchanged
source spelling or owner name is not evidence that its checked product survived
global renumbering. Start by avoiding assembly/index reconstruction; independently
validate any later incremental replacement of semantic checks.

## 2. Rediscovering changed bodies at successive stages

The [owner analysis](../../selfhost/tools/performance/phase140/owner/reverse-v04.bend)
now uses a retained reverse graph, but `p140oq_analyze` still scans ordered
headers and calls `p140o_delta` for exact complete owner comparisons. The raw
bridge invokes this again on the prepared book. `p140or_fact_changes` then
walks every reachable name and compares both `ns_body` products. These are
distinct source and derived-fact dependencies; one cannot delete the latter
just because the source owner appears unchanged.

After that work, [raw lowering](../../selfhost/tools/performance/phase140/owner/raw-v01.bend)
still routes every hit through `p140og_record`: it recreates the entry segment,
marks segment flags and reverses/appends the complete segment list. Private
candidate hits similarly rebuild the flattened candidate list.

The same rediscovery continues downstream:

- `p140v_context`, `p140v_raw_walk`, and `p140v_direct_walk` compare the global
  ordered context and bodies at both verifier boundaries.
- `p134u_one` checks the complete input, then `p134u_facts_valid` compares prior
  callee products including absence. `p134u_range_one` and both
  `p134v_commit` calls perform further comparisons. These original Phase134
  optimizer uses remain outside the source18 typed-comparator replacement.
- `p140gm_changed` compares all raw segments before patching the fusion index.
- `p140r_hit` compares every private/public product and its observed fusion
  facts while deciding whether to emit an existing frame reference.

Typed first-order comparators can make these walks cheaper. They do not change
their asymptotic amount of work, and should not be mistaken for the final
incremental architecture.

**Useful boundary:** return a private `RevisionDelta` with a product, containing
the previous-success revision, producer epoch, ordered owner/segment mapping,
changed body identities, and separately changed global facts. An immutable body
identity survives only when the producer actually retains the same result.
The source-to-erased producer also reports derived-fact changes; raw lowering
reports segment changes; transformations propagate or replace those identities.
An unchanged-body claim from a source edit alone is insufficient.

This is a trusted internal capability, not a caller-supplied hash or a deserialized
cache. Compare retained epoch/version tokens directly; do not expose raw-pointer
identity as a new Bend semantic rule. Failed requests must not publish revisions.
Cross-producer use, stale revisions, counter overflow and missing change evidence
must refuse reuse. A token establishes only the artifact it names, not all of its
semantic dependencies.

**Global facts still matter:** ordered headers/IDs, constructor catalogue and
layout aliases, static-node placement, effect/permission policy, fresh-number
inputs, prior ready-helper order, negative lookup facts, and emitted binding
tables. Only their own unchanged producer-issued identities could replace their
exact comparisons. Keep today's conservative dirty-ADT refusal until a narrower
dependency contract is independently established.

## 3. Whole-program consumers still impose a floor

`p140le_scanned` joins cached observer results back into `p128raw_br_scanned`.
The final `p126bp_complete` still calls the original projected function verifier,
array verification and namespace checks. This final independent gate remains
intact. Its isolated warm cost has not been measured; the entire 45.100-second
backend interval is not its cost.

Registry/header assembly, final ordered rendering traversal and transport remain
whole-program consumers as well. Native frame references save most text
generation, but the observed warm transport still materializes approximately
106 MB. Stable object reuse and linker work are separate costs, outside the
native-stage table above. A more compact frame-reference stream is not a faster
complete build unless the consumer actually avoids equivalent discovery/copy work.

**Useful boundary:** retain owner/segment units and ordered references until one
necessary materialization boundary. Let the independent verifier consume the
exact current view; do not reconstruct the same list for each optimizer,
registry and renderer. Incremental certification of the final gate is a separate
research project with a stronger correctness burden, not an implicit exemption
for cache hits.

## Smallest decisive experiment

1. Finish the current typed-comparator screen. Compare exact products and the
   complete warm request; retain any cold-cost regression. This tests whether
   higher-order dispatch, rather than traversal itself, dominates the current
   comparison tax.
2. Use the existing stage mechanism to isolate book merge/index/max construction,
   owner/derived-fact comparison, optimizer hit admission, and the final verifier.
   Instrument a bounded real request first. This supplies ceilings; do not run a
   new broad campaign merely to increase the number of counters.
3. Prototype **one** producer-to-consumer delta: raw owner reuse → raw verifier
   body admission. Mint unchanged segment identities only when the exact raw
   product and its global header/fresh/static context are retained. Keep the
   old whole-context gate and independent final verifier. Compare the admitted
   body set with the original exact comparator in a diagnostic dual run.
4. Falsifiers: old/new source edit, unchanged and changed dependency, insertion,
   reordered headers, alias/layout change, fresh-ID shift, pooled-literal change,
   previous failure followed by recovery, and a stale/cross-producer delta. A
   false hit rejects the design. Equal products with no complete-request saving
   reject this boundary as the next performance priority.
5. Only after that seam pays, let the registry and renderer consume the same
   change evidence instead of rediscovering it. Extend to the frontend persistent
   book if its measured construction floor remains substantial.

Use the existing 20–60-second controls and 60–180-second small integration gates.
Run a full native compiler edit only for a surviving candidate; reuse authenticated
unchanged output evidence. Price acquisition, failed attempts, memory retention,
transport and machine builds separately from the warm request.

## What a tenfold result would require

Relative to this same-candidate 362.893-second cold seed, tenfold native-stage
speed requires at most 36.289 seconds. From the observed 133.647-second warm
request, that requires removing another 97.358 seconds, or 72.85%. Neither the
53-second frontend nor the 45-second backend alone can supply that improvement.
Complete-build tenfold is stricter once transport and machine work are included;
the independent incumbent's full-B denominator must also be reported separately.

The plausible route therefore spans both early revision assembly and repeated
downstream traversal, while preserving a measured independent verification floor.
This is a direction to falsify, not a promised speedup. If the remaining floor
exceeds the budget, the honest next choice is to change that boundary with an
explicit correctness design or revise the target—not to add more caches and
report their hit rate as progress toward tenfold speed.
