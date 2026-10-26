# Optional product failure must not poison boxed admission

There is a specific missing capability worth testing: the mature C backend
withdraws failed optional product signatures and selectively retries ordinary
workers; the direct QBE admission path does not currently do that. This is a
bounded reuse of an existing semantic policy, not a new IR or an assumption that
every missing worker is caused by products.

## Observations

The compact verifier's V02→V03 source ablation restores actual direct workers
for lookup/get/value and improves the complete native verifier slice by11.06%
against its old-record baseline. V03 makes absence a genuine second constructor
while retaining four-field present rows. V02's single-constructor result is a
product-signature lead; the executed candidate trace now confirms the exact
failure/dependency chain. See [verifier.md](verifier.md).

The selected source has these relevant boundaries:

- `nq_signature_tele` advertises a product route from finite type shapes before
  knowing whether its body can be lowered (integrated source33712).
- `p113pl_call` selects an advertised `NQSig` when arguments fit (45367).
  The ordinary boxed candidate receives that same signature environment.
- `p113p_transfer` refuses a boxed value when the destination requires a known
  product shape, with `product result shape mismatch` (45111). This refusal is
  correct; accepting unchecked opaque-to-product conversion is not a fix.
- `p113d_passes` discards failed candidates and only admits dependencies already
  ready (44146 onward). A caller of an unavailable advertised route consequently
  remains unavailable, even if a boxed version could have compiled.
- `p128raw_plan_finish` performs SCC candidate preparation and dependency closure,
  but does not withdraw unavailable product signatures and retry boxed lowering
  (55903).

By contrast, the existing C route explicitly documents this problem at33014:
`nf_ready_signatures` removes unready `NQSig` aliases while retaining constructor
shape facts; `nf_removed_signatures` names those withdrawn routes; `nf_retry`
rebuilds affected ordinary candidates and retains admitted workers. These
helpers already exist in the selected compiler. Their retry policy is stronger
prior art than a new speculative admission architecture.

## Hot-path evidence constrains the opportunity

Static inventory of the exact qualified Phase143 QBE, joined to its authenticated
Phase144 profile, is retained in
`selfhost/build/phase144/product-hot-census01/report.json`. The reproducer is
`verifier/product-hot-census-v02.py`; v01's source-location bookkeeping failed on
separate law/definition blocks and is preserved. No target was executed.

| Owner | Profile samples | Boxed direct worker | Product worker |
| --- | ---: | --- | --- |
| `nc_ctor_owned` |594|yes|no|
| `String.append` |543|yes|no|
| `p111v_get` |446|yes|no|
| `f_find` |442|yes|no|
| `p131i_insert` |376|no|no|
| `p111q_memory` |131|yes|yes|
| `p113k_get` |109|yes|yes|
| `index_leaf` |76|no|no|
| `p111v_put` |73|no|no|
| `p111v_step` |59|no|no|
| `p111v_decl` |50|no|no|
| `index_join` |40|no|no|
| `p111v_body` |25|no|no|

The sample denominator is10,083. These are active-owner observations, not call
counts or guaranteed savings; the current integrated candidate also changes
some consumers. Several largest computations already have direct workers, so
this fix cannot recover an absent worker for them.

`p131i_insert`, `index_leaf`, `index_join` and `p111v_put` return the sum `KDef`.
Their own result cannot explain rejection as a single finite product. Transitive
dependencies may still matter, but ordinary non-tail recursive construction is
another plausible cause. The index investigator separately observed canonical
tree consumption and a saved continuation around a ready Boolean helper; that
is not evidence of product failure. The candidate trace must separate these.

## Additive falsifier prepared for root execution

The141-line `verifier/product-retry-v01.bend` changes no existing declaration.
`product-retry-source01` retains the complete integrated source as a byte-exact
prefix. The diagnostic prepares the same constructor catalogue/static book,
generates the same generic/raw candidates once, and records initial admission.
It then:

1. Derives actual admitted names from the existing QBE worker list.
2. Uses the C helpers to withdraw only unready product signatures, retaining
   constructor shape metadata.
3. Retains every initial worker unchanged and in its original order.
4. Retries eligible, still-unready ordinary definitions whose source references
   mention withdrawn routes, using `p113pl_boxed_candidate` itself.
5. Applies the original `p113d_passes` with the retained ready index and32-round
   limit. It does **not** synthesize another SCC catalogue, whose fresh names
   could otherwise collide with the original catalogue.
6. Runs the normal subsequent optimizer, independent verifier and observer/
   emission pipeline in the separate experimental emitter.

The full independent verifier remains the admission gate. Neither retry
construction nor a positive finite counter is a proof of end-to-end semantic
equivalence. This prototype also intentionally does not match the C retry's
exact implementation in every detail: it uses QBE candidates, does not require
the old candidate's error to be empty, and preserves QBE's own dependency and
stack rules. Any retry failure remains a refusal.

`product-retry-census-v01.mjs` compares the complete recorded original lowering
with an independent call to the unchanged integrated entry. It checks retained
worker order/bodies, original static program and the original raw reservoir;
records every original error, missing dependency, withdrawn alias and attempted
retry; and runs `p113e_verify` independently on both before/after programs.
Complete graph snapshots preserve successful and rejected candidates.

Four frozen source fixtures exercise the distinction:

- A small list-head function returning a product containing a number and String.
- The126KB native verifier fixture with original KDef state, including real
  `p131i_insert`, lookup and verifier functions.
- The single-constructor four-field verifier variant.
- The genuine-absence sum variant that already restores direct admission.

Root-only jobs are in
`selfhost/build/phase144/product-retry-source01/jobs.json`, guarded at3GiB RSS,
16GiB available-memory floor and CPU3. The root's
`phase111/p144-product-retry-api01/report.json` independently checks the additive
source. The first census stops before retry analysis: the small fixture used a
forbidden local-binder match. `admission-fixture-v02.bend` moves that match into
a parameter helper; the original fixture and exact parser refusal are pinned
by `product-retry-fixtures02/cases.json`. Its one-job rerun reuses the checked
API and leaves all other fixtures unchanged.

## Executed admission census

The root's `selfhost/build/phase144/product-retry-census02/report.json` is
complete with `allCandidatesVerified=true`. All four before states equal their
independently computed original lowering; initial worker order/bodies, static
program and raw candidates are retained exactly. Both direct programs pass the
unchanged independent verifier. This verifies the bounded admission experiment;
it does not qualify emitted machine code or measure generated runtime.

| Source | Initial candidates / ready | Withdrawn aliases | Retried ordinary definitions | Newly ready |
| --- | ---: | ---: | ---: | ---: |
| Product head witness |8/3|4|2|2|
| Original KDef verifier |120/51|40|16|0|
| Compact single-product verifier |118/46|52|28|5|
| Compact sum verifier |107/47|40|16|0|

The witness recovers `p144probe_head` and its scalar consumer
`p144probe_value`. The single-product verifier recovers boxed workers for
`p144vt_bucket`, `p144vt_find`, `p144v_get`, `p144v_capacity` and `p144v_target`.
This succeeds without changing that source's datatype. Its original
`$product.p144vt_absent` and `$product.p144vt_bucket` both report
`product result shape mismatch`; callers had selected those unavailable aliases.
Thus product-signature poisoning is an observed capability gap, not merely an
inference from the two datatype spellings.

However, the original compiler-derived verifier gains **zero** workers. Its
`p131i_insert` reports `product non-tail self call` and lacks
`p131i_original_set`, `index_leaf` and `index_join`. `index_leaf` depends on
unready `index_remove`, which depends on `index_remove_step`; `p111v_put` depends
on unready `index_set`. Their own sum result did not cause optional-product
failure. Retrying more such candidates does not address those constraints.

The compact retry's `p144v_value` is still unready at this initial boundary:
it now depends only on `String.eq`, which depends on `String.order`, then
`String.cmp`. This is also true of the sum variant's initial candidate, despite
the sum variant ultimately producing a direct value worker through later
observer closure. Stage-local admission counts therefore are not final machine
worker counts.

The one-shot hosted costs do not support a compilation speedup claim. Original
raw versus original-plus-retry calls were run in that order, with different JIT/
GC state; the latter also retains a diagnostic trace. Their observed pairs are
0.192/0.086s,10.105/8.507s,6.135/6.161s and5.356/5.671s. They expose potential
cost but are not paired independent request benchmarks. The separate native
slice result is reported below; no whole-compiler improvement is established.

## Remaining composition issue and cheapest next test

The first prototype deliberately leaves `P128RawLowering.raw` byte-identical.
That is conservative for original candidate retention, but `p128raw_close`
later uses this reservoir to reconsider callers after adding verified observer
workers. It still sees the compact caller's old product-bound references, not
the newly relowered boxed candidate. Thus the prototype can understate the
benefit of composing product fallback with late reader admission.

The smallest follow-up is to retain original raw candidates first and append
the successfully constructed retry candidates for that later closure. The
existing `p113d_pass_function` skips names already ready, so original ready
workers remain preferred and no duplicate function need be published. It must
be separately checked for complete emitted code, fallback ordering and the
unchanged final verifier; no new SCC synthesis is required. This has **not**
been implemented or tested in this census, and is not a performance claim.

The root subsequently executed that matched complete compact single-product
verifier experiment, with unchanged source, runtime and independent checksum2048.
`product-retry-native-times01/report.json` records three alternating pairs:
baseline median2.668860s, retry2.468382s, ratio0.924883 (**7.51% less runtime**).
The adaptive timer extended beyond its first pair because both executions were
under3s. Every ordinary build execution and timed output matches the oracle.
This is a representation-robustness result on a full real verifier slice;
it is not a speedup of the original compiler.

The emitted QBE grows1,990,113→2,062,761bytes. Complete checked hosted emission
takes33.3015→33.4403s in the one ordered diagnostic pair; this does not establish
a reliable compilation-cost difference. The original-slice zero-worker result
still argues against production retry or a full compiler campaign now. Retain
the capability and its actual negative transfer evidence for future compact
representations, instead of making every compilation pay for unsuccessful
fallback discovery.

## Decision and cost gates

The first decisive result is whether V02 acquires the same direct lookup/get/
value capability as V03 **without changing its datatype**, with the exact
initial failure trace explaining why. The second is whether original compiler
functions acquire useful workers, rather than only the constructed example.
The existing native fixture then permits matched machine and runtime comparison
without rebuilding the whole compiler.

Do not broadly relower all rejected candidates by default. Reference discovery,
signature filtering, ready-index reconstruction, retained candidates and cleanup
are real costs. The empty-withdrawn case already returns unchanged; an empty
attempt list and a dense failed-route set deserve additional cost scrutiny.
If compiler-hot functions remain blocked by recursion or transport, keep this
as a representation-robustness fix and do not sell it as a large compiler-speed
opportunity. Existing ready functions must retain their products and performance.

If the witness and transfer pass, the smallest integration point is immediately
after initial dependency closure, while the exact immutable prepared book and
signature table are still available. Keep a single bounded retry wave and the
independent final verifier. A later dependency worklist would need demonstrated
cost justification; it is not part of this experiment.
