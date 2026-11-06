# Native transfer audit and bounded successor

The first native Phase169 image is
`selfhost/build/phase169/native-n1/program`, source `df8d6475…`, built by the
qualified Phase152 compiler. Its complete canonical-source build succeeded in
197.355s according to the root's completed gate. The small verifier request did
not preserve the earlier hosted speed ratio. The following audit identifies
extra native work; it does not assign exclusive timing to any source function.

## What actual machine code does and does not show

`nm -S` and targeted `objdump` inspected both retained exact ELFs. New
`p168t_walk`, `p168_scalars`, `p167l_loop` and `p169s_seeded` use ordinary scheduled
entries, `p111_rt_jump`, keep/sink and constructor/take helpers. Their entry
frames reserve 2,120,4,152,2,056 and2,120 bytes respectively. Static reservations
are not stack traffic or dynamic frequency.

This is not, by itself, a new admission regression: baseline `p113pl_candidates`,
`p113d_passes`, `p144o_prepared` and `p134e_prepare` also lack true `p113d` workers.
The common `p128bs_eligible` and `no_emit` scheduled entry machine bodies retain
their221-byte and1,564-byte sizes in both images. These size observations do not
prove byte identity, but refute an explanation based only on a newly missing
direct entry for those same helpers. A46-byte `p112w` source-function closure
wrapper is not a direct implementation of its computation.

Two concrete algorithmic costs are clearer than that symbol-count hypothesis:

1. `p168j_eligible` hashes/looks up every segment name before rejecting its
   metadata. `p168j_candidates` does another import lookup before the same
   metadata refusal. The qualified full program has34,422 incoming continuations
   among56,649 segments; all34,422 categorically fail incoming==0. Candidate
   program counts can differ, so this is an observed baseline scale, not the
   new route's dynamic count.
2. `p128bs_eligible` is more than a cheap flag test: its eager conjunction ends
   with `nc_error(no_emit(...))`, constructing/checking a scalar body. The new
   route evaluates it in the initial observer scan, selective target selection,
   and scalar fallback materialization. Reusing `NO_Plan` alone does not reuse
   that work. Native scheduling/owned values make the extra visits potentially
   more expensive than the hosted comparison suggests; profiling must quantify
   this rather than treating hosted/native ratios as interchangeable.

## Private implementation and exact scope

`selfhost/tests/phase169/admission-work.bend` contains three private overrides:

- `p168j_eligible` performs the existing arity/result/incoming/flags conjunction
  first. Only an eligible header reaches the unchanged direct-entry conditions.
- `p168j_candidates` rejects those same headers before querying the import map.
  For surviving headers, import priority, body cleanliness, order and reverse
  accumulation are unchanged. The metadata conjunction is literally the first
  guard of maintained `p112c_candidate`; false therefore cannot hide a candidate.
- `p168_closed`, mode1 only, computes `P169ScalarPlan{plan,eligible}` against one
  immutable prepared book. The same exact predicate result feeds copied
  selection and scalar-scan routines. Actual `p128bs_find` still observes the
  post-inlining function list; summaries, added workers, errors and ordered
  retries follow the original branches. Mode0 keeps the original call policy.

The cache does **not** grant admission from a host Boolean or caller-supplied
fact. It is constructed internally by the actual eligibility predicate. The
predicate depends on book+plan, not the subsequently transformed functions.
Selection already evaluates it for every plan before scalar materialization;
building that finite cache earlier does not suppress an error check. No result
is reused after consumer retry creates a changed plan.

This removes one repeated eligibility pass, **three→two**, preserving the initial
observer scan. Sharing across that earlier boundary would require threading a
new product through substantially more preparation helpers; that is deferred.
The cache itself allocates a small list and its first builder is non-tail;
ordinary scheduled continuations preserve stack safety. An extra reverse pass
is not presumed cheaper. The whole-request gate must charge those costs.

Fourteen finite controls in `admission-controls.bend` cover literal header and
signature boundaries, surviving candidate order, an actual positive eligibility
predicate, a negative plan, full selection-index equality, and full ordered
retry-plan fields. Their scan fixture intentionally has no owning function, so
it does not exercise successful worker generation or its error branch. Existing
full-source exact-QBE comparison and real generated-program execution remain
necessary for those paths. No new universal proof is claimed.

The independent review from `c23_compiler_research` found no semantic blocker
and explicitly identified that finite-control boundary. First source checking
and performance results remain pending; no production promotion follows from
this source audit.

## Frozen preparation

- API source02: `selfhost/build/phase169/admission-api-source02/compiler.bend`,
  SHA256 `2fb61127018bc5731e8bf811c185fa43134e819b901920812173fb8d84a2b21e`.
  Existing API exports/controls remain; `p169q_controls` adds the14 rows.
- Native source01 with the separately measured publication policy:
  `selfhost/build/phase169/admission-native-source01/compiler.bend`, SHA256
  `2af1c1eee61f4aae633100e99baf254a2fa1e251a2f570bab3aa894bfb14cea4`.
- `tools/prepare-native-admission.py` preserves the API source02 recipe.
  `tools/prepare-native-admission-publication.py --publication` is its optional
  publication successor. The earlier recipe's pinned bytes stay unchanged.

An initial data-only extraction refused a third `p168_closed` declaration before
writing a candidate. The corrected producer keeps the historical selective hook
under an unused private name in a copied input; an exact inverse/derivation is
recorded. The existing extractor's duplicate/protected-declaration checks remain
unchanged. No consumed source, production file or executable was edited.

## Cheapest profile if transfer remains unclear

Use the maintained generic main-thread sampler from `build-sampler.py`, exact
N1 request/oracle through `freeze.py`, then `run.py --modes sample --rounds 1
--periods-us 32000` for a full request. This first step needs no diagnostic
runtime relink and yields decoded physical function costs. For the roughly5s
verifier, pool enough identical captures using the existing compare method to
exceed the sample floor; a single capture is descriptive only.

Do not reuse the old Phase147/161 stage spec: required lowering boundaries no
longer occur on this route. New N1 has retained assembly/object but no SSA;
the old controller's owner bindings cannot be inherited. If physical costs do
not resolve the question, separately bind fresh stage markers/FIDs from this
image before adding runtime dispatch/stage instrumentation. No new profiling
framework is needed.
