# Phase167 prototype: independent source review

Read-only review of `selfhost/tests/phase167/demand-{model,lower,verify,emit,controls}.bend`
before target qualification. No compiler or generated target executed in this
lane. No concrete fatal demand/ABI/stack defect was found in this bounded review;
that is not a correctness certificate.

## Boundaries that are implemented soundly at source level

* Scheduler identities come from `nc_ref_name` and `p113d_public`, not prefix
  decoding. Positive-arity factories and workers have separate catalogue entries;
  zero-arity entries coincide. Conflicting declarations refuse.
* Demand visits every current `N111Value` position, including scalar instructions,
  nested branches, call arguments, returns and direct `Again` values. Direct-call
  target names need no scheduler entry: final ordered direct verification requires
  their actual direct dependencies. Unknown scheduled IDs refuse. Each complete
  newly produced generic family is marked present before its queued demands are
  processed, so local continuation identities need not be in the source catalogue.
* Fallback owners use the actual original `p111_entry` family and bang marking.
  Admitted factories copy the original eta branch, whose additional native,
  foreign and bang exclusions already follow from `p164a_allowed`. Their real
  continuations remain. Global fresh state advances from actual generated code.
* Every demanded direct entry is an actual adapter with exact shape, source arity,
  actual header and final worker obligation. All final workers are private;
  changing that flag does not grant direct-to-scheduler permission. The unchanged
  final `p113e_functions` checks every body and dependency in order with the actual
  retained headers/constructor IDs. Runtime calls retain its whitelist. Ordinary
  recursive cycles refuse; admitted tail recursion uses `P113DAgain`. Generic
  non-tail recursion remains on the original scheduler.
* Emission derives numerical IDs from the same final scheduled segment list used
  by validation. Genuine generic bodies, actual header uniqueness/ABI limits,
  constructor schema and static image are independently checked. The source-bound
  adapter obligations replace only the original verifier's inability to recognize
  those fixed direct-call adapters; no fictitious body certificate is substituted.

Sources: [lower](../../selfhost/tests/phase167/demand-lower.bend),
[final boundary](../../selfhost/tests/phase167/demand-verify.bend),
[`p111_entry`](../../selfhost/src/back/qbe/lower.bend:619),
[`p113e_functions`](../../selfhost/src/back/qbe/verify-direct.bend:188),
[`p111q_ids`](../../selfhost/src/back/qbe/emit.bend:239).

## Material limitations for interpreting a timing

1. **All admitted direct workers remain.** `p167l_functions` privateizes the whole
   admitted list; every retained worker seeds scheduler demands. This is scheduler
   representation pruning, not whole-program direct reachability pruning or
   elimination of all candidate construction. `p113pl_candidates`, SCC cleanup,
   admission, shared static preparation and constructor catalogues still run.
2. **Optimization policy changes too.** The prototype omits late borrowed/product
   composition and live/array optimizations. Contrary to the initial design claim,
   its inherited emitter still builds the generic region registry (see the
   artifact census below). Mode1 adds
   bounded inlining and request-derived cold analysis. A construction win is not
   attributable solely to demand generation, and it does not establish generated
   compiler/runtime preservation. Prior Phase163/164 regression evidence applies.
3. **Rendering boundaries differ.** Candidate `p167e_plan` materializes chunks;
   baseline `p134e_plan` leaves rendering for its cursor. Therefore compare total
   backend+render, not `lowerVerifySeconds` alone in `request.mjs`. Full native
   source needs bounded streaming before an acquisition can respect memory limits.
4. **Cold mode is actually enabled.** Initial review stopped at the base/static
   table builder and incorrectly suspected missing capability8. This was resolved:
   [`p111q_data_chunks`](../../selfhost/src/back/qbe/emit.bend:57) invokes
   `p118c_tables` before rendering, enabling the source-authorized cold flags.
   No correction to the prototype is needed for that point.
5. **The fixed-shape check shares its generator.** `p164a_shape` compares against
   `p164a_body`; the independently written fixture tests the zero-arity shape.
   Actual positive-arity and factory execution controls are still necessary to
   catch a shared argument-load/arity implementation mistake. Final structural
   validity does not prove semantic equivalence to the checked source.

## Cheapest missing controls / census

The30 finite controls exercise final-boundary refusal well. They do not by
themselves exercise demand discovery and generation. A small positive-arity
function used both saturated and partially applied should force the same source
owner's worker and factory, consume its closure twice, and preserve complete
observable output. A mixed non-tail-recursive caller plus direct helper checks
scheduler return and deep-stack behavior. Include a genuine IO request if the
claimed route includes IO. Nested `N111FuncId` discovery can also be tested as
cheap structural controls, without executing malformed programs.

Current `request.mjs` records only total emitted functions and loses
`P167Lowered.stats`. Offline QBE comparison can independently count final direct,
scheduled and omitted identity sets, but cannot recover rejected candidate fate
or which generic bodies were never constructed. On a subsequent frozen method,
carry the already computed stats through a Bend result wrapper, preserving the
same admission/final verifier path; do not lower twice merely to obtain counters.
Report `[sourceNames,directFunctions,fallbackFamilies,admittedFactories,adapters,
finalSegments,queuedUniqueIdentities]` with their exact definitions. Pair those
with emitted-symbol set differences; neither alone is a dynamic-work census.

## Independent static census of the first matched products

Baseline `verifier-baseline03/emit/report.json` and candidate
`verifier-raw01/emit/report.json` bind identical source/Base/checked API/method
inputs. Both complete IR files were rehashed against their receipts. Source is
39,333 bytes, SHA256 `ff6b4083aa2f3e034f3b4f8e43dfb25d93a4f524685934e0ee13845278033ef3`.
Reproducible offline method: [`tools/static-census.py`](tools/static-census.py);
complete counts and named identity sets:
[`verifier-raw-static-census.json`](verifier-raw-static-census.json).

| Emitted representation | Optimized baseline | Raw demand |
|---|---:|---:|
| All functions |2,042|1,437|
| Scheduled `p111` functions |1,563|1,223|
| Of these, generated `$p111.k.*` continuations |1,332|1,088|
| Of these, source/zero-argument entry or factory identities |117|51|
| Of these, named `$direct.*` scheduled workers |114|84|
| Region `p112w` workers |385|157|
| Native `p113d` functions |93|56|
| Native function text bytes |481,329|154,350|
| Scheduled function text bytes |2,039,740|1,659,307|
| Total QBE bytes, including tables |2,895,455|2,063,363|

All135 named candidate scheduled identities are a subset of the baseline's231:
66 entry/factory identities and30 named scheduled workers disappear. Generated
continuations fall by244 in count, but fresh numbering changes with traversal;
the1,419 removed and1,079 added exact scheduled symbols must **not** be described
as that many eliminated/introduced semantic computations. The census records
this limitation explicitly.

All56 raw direct worker identities are present in the baseline;21 bodies are
byte-exact and35 differ. The37 baseline-only direct workers include borrowed
readers/owned adapters and later specialization. This is evidence of a different
optimization population, not proof that37 unnecessary duplicate computations
were removed. Static emitted text is not runtime work, and neither output reveals
the number of rejected candidates constructed during compilation.

**Material correction discovered from the output:**157 raw `p112w` functions
contradict the initial “no region registry” claim. The exact active call chain is:

```
p167e_indexed
  -> p111q_segment_chunks                 emit.bend:245
  -> p112c_segment_chunks                 closed-regions.bend:533
  -> p112c_emit_indexed
  -> p112c_index_with                     closed-regions.bend:490
```

Thus the first measured prototype demand-prunes scheduled representations and
omits late direct optimization, **while still performing region discovery on
the retained segments**. Its smaller registry population is real. It has not
measured eliminating that machinery altogether. Preserve these artifacts and
method identities. A loop that explicitly calls `p111q_segment` without this
wrapper is a separate no-registry ablation, requiring its own output/runtime gate.
That route may lose useful generic-to-generic ordinary calls and make execution
slower even while compiling faster.

## Single-generic counterarchitecture and the observed barrier

Source review of `demand-single.bend` found no additional admission/FID/stack
blocker. It calls shared preparation and `p167l_functions` with an empty direct
list. Consequently no source owner qualifies for an adapter: each demanded
identity obtains its genuine original `p111_entry` family, and the adapter map
remains empty. Both mode0 plain emission and mode1 inherited-registry emission
still pass the actual generic/static final checks. This isolates omission of
private candidate production, admission and private optimization. It does not
preserve direct/borrowed code quality by construction.

The completed inspect01 receipt gives a sharper result than symbol inference:
117 source names,56 admitted direct functions,49 complete fallback families,
**zero demanded admitted factories**,38 adapters,1,223 scheduled segments and
1,175 unique queued identities. Thus further pruning of admitted factories has
no remaining benefit in this workload. The49 fallback families include
`p111v_body`, `p111v_stmt`, `p111v_assign`, `p111v_decl`, `p111v_intersection`,
`p111v_put`, `index_set` and `p131i_insert`. They are real verifier and persistent
state computations, not arbitrary wrappers that may safely disappear.

The parent's completed contrast01 screens report prepared-Base full builds of
31.75s baseline,24.29s demand+live,23.05s plain+live and22.53s plain. All produce
the independent768 result. The corresponding two-pair runtime observations are
0.442s,1.145s,1.160s and1.347s. These are promising construction reductions but
**fail the generated-code-quality gate**. The cost of eliminating the last region
recovery step is small here; the large execution deficit survives restoring
live transport. This does not causally attribute the entire regression to one
missing pass, but it rejects promoting this combination or calling it a faster
self-hosted generation.

The hard barrier to10× is now concrete: the shortcut saves backend construction
by removing machinery needed to execute hot verifier families efficiently.
Frontend checking also survives unchanged. A new self-hosted generation would
have to run those families faster; these products run this representative
computation roughly2.6–3.0× slower. Complete-output correctness alone cannot
establish the desired generational speedup.

**Highest-information architecture after the single-generic contrast:** test
one canonical per-owner control graph with efficient ordinary execution and
explicit resumable frames for non-tail fallback, rather than producing both
scheduled and direct body populations or accepting permanently slow fallback.
Use the complete `p111v_assign → p111v_put → index_set/p131i_insert` state-update
path as the first transferable cluster, including old-root retention and the
actual verifier consumer. This is not another handwritten insertion zipper:
the compiler must derive branch/call/return/frame behavior from the ordinary
prepared source, for an unrelated recursive-tree cluster as well.

The test must include graph construction, stable numeric local identities,
final structural/ABI checks, frame lifetime and complete output. Preserve the
existing source-authorized borrowed/cold constructor operations on that graph,
so fast execution is obtained without reconstructing the old whole-program
candidate/registry pipeline. Calls outside the cluster remain explicit checked
imports or genuine scheduler bridges; do not admit ordinary unbounded C recursion.
Require both lower complete compile cost **and** runtime near the optimized
baseline before any full compiler acquisition. If single-generic+registry already
achieves both, it is the cheaper base and should win over a new graph. Otherwise
the decisive missing capability is efficient fallback execution, not a broader
omission whitelist. None of these pilot results yet supports a10× forecast.

## Observer-before-admission module review

Bounded source review of the157-line `demand-observers.bend` found no blocking
legality defect in its normal checked-plan entry. This is a review of the code,
not a claim that its target pilot passed.

* `p167ob_permission` establishes the maintained scalar/observer permission
  disjunction on the same checked request before calling `p118e_workers`.
  Candidate filtering uses the prepared book and excludes bangs/native/foreign
  definitions through unchanged `no_candidate_names`. Original typed observer
  schema, residual eligibility and root-retention checks are reused.
* Seed projection uses a private copy, an **empty function-ID map** and the real
  independently scanned constructor catalogue. This grants no fabricated public
  scheduler ABI: a seed requiring an unmaterialized identity fails. Closed
  dependency-ordered seeds are independently checked before they seed admission.
* Public markers are retained only on source-derived workers for the exact
  source/arity/one-result `p164a_allowed` selection. `p167l_functions` later
  privateizes the emitted list and derives genuine demanded entries. Selection
  does not equate a same-name function with a generic-body certificate.
* Final `p167v_original` checks the actual retained generic bodies, static image,
  headers and adapter obligations. Then `p118b_verify_functions` projects and
  checks **all actual final private workers** against the actual scheduled and
  constructor IDs. Missing targets, malformed borrow constructor/count arguments
  and dependency/ABI violations remain refusals. The original verifier is unchanged.

The structural projection checker is not a proof of source lifetime permission;
that authority comes from the internal same-request construction route. Treat
`p167ob_lowered`/`p167ob_emitted` as internal/debug helpers, not public APIs that
authenticate arbitrary host-supplied IR or source provenance. Existing checked
request transport must continue to call `p167ob_plan` and retain this boundary.

Conservative scope limits: one nonclosed seed can refuse the whole experimental
request; filtering a source name can remove optional raw product variants not
supplied by the seed, reducing admission coverage. This mode applies neither
the bounded inliner nor request-derived cold analysis; it emits plain generic
bodies with independently eligible live transport. Thus the pilot tests this
specific combination, not preservation of every mature optimization.

Useful focused controls are wrong/unknown borrow constructor, wrong field count,
missing final seed target, and actual shared/same-root preservation. Existing
producer and final-check machinery supplies their relevant refusal contracts;
this review ran none of those controls. The parent owns the complete-output and
compile/runtime quality gates.

### Completed observer pilot

The checked API and all35 controls now pass. Independent offline comparison of
`inspect01` with `observer-inspect01` confirms73 final direct workers versus56,
with no removed identities. The17 additions consist of the scalar comparison
reader plus **exactly the16 dependency-ready names predicted before the pilot**.
Fallback families49→37 and scheduled segments1,223→983 corroborate the intended
admission effect. Complete matched build time falls31.343044→23.350522s, but
four alternating execution pairs remain0.437725→0.649529s (1.48387× slower).
Every runtime output is exactly768 with empty stderr/exit zero.

The [obstruction report](admission-obstructions.md#completed-observer-experiment-the-predicted-cascade-occurred-exactly)
records full receipt paths, matched-input checks, the retained-baseline/runtime
distinction and all metric scopes. This is a successful mechanism falsifier and
a failed generated-code-quality gate. No promotion or full native qualification
follows; the10× cold-build goal is unmet.

### Final matched executable check

A subsequent bounded `observer-runtime02/report.json` run closes the earlier
retained-baseline distinction: it times the actual newly built
`observer-baseline01` and `observer-build01` ELFs in four alternating pairs.
Medians are0.441204748s and0.655356054s, ratio1.4853785. All eight outputs are
exactly768 with successful exit. The earlier runtime01 paragraph describes only
that preliminary screen. Both plain-demand and observer Map/IO semantic gates
also pass frozen value/count oracles (`map-oracle01`, `observer-map-oracle01`).
This does not change the failed runtime-quality gate or authorize promotion.
