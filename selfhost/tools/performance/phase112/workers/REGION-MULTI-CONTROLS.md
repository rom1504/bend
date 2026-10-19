# Independent multiple-call fusion controls

`region-multi-controls-v2.mjs API.mjs FRESH_OUTPUT` calls the checked Bend prototype
and writes paired generic/candidate QBE fixtures. Only the coordinator executes
this transport or generated programs. The input graphs are explicitly synthetic
N111 controls; they do not claim actual-source admission coverage.

The original method remains preserved after its first host-control failure: it
read `P112FusionBody.site`, but the exported field is `next`. Version2 fixes only
that field access; the compiler, fixtures and expected semantics are unchanged.

Required exports are `p112c_index`, `p112c_program_counts`,
`p112c_segment_chunks`, `p112c_plan_index`, `p112c_candidates`, `p112c_round`,
`p112f_index`, `p111_verify_program`, `p111q_ids`, `p111q_segment` and
`p111q_chunks`. The first admitted entry remains the same complete
`P112RegionEntry` used by region02.

Eight native pairs observe complete stdout:

| Fixture | Expected stdout | Check |
| --- | --- | --- |
| three-sequential-capture-permutations | `11224202` | Three calls, with captures reordered between each call |
| branch-yes-fresh-sites | `1112` | The first of two branches uses its own two sites |
| branch-no-fresh-sites | `2222` | The second branch uses two further distinct sites |
| alias-chain-result-first | `"α😀"` | Captured physical alias survives three calls and result-first release |
| alias-chain-alias-first | `"α😀"` | The same graph with alias-first release |
| exact-eight-site-budget | `8` | The exact eight-site limit admits a private caller |
| ninth-call-generic-fallthrough | `9` | Budget exhaustion keeps the remaining runtime transition |
| cyclic-continuation-budget-fallthrough | `21` | A finite counter-driven continuation cycle remains correct after bounded unfolding |

All expected files include a final newline. Each pair must use the same pinned
runtime, exit successfully and match stdout/stderr. Four refusal cases cover
non-tail self/mutual private recursion, generated-name collisions and late
transport-state observation. Two more controls distinguish the exact
128-statement continuation budget from 129 statements after an earlier site has
already fused.

Every positive graph is accepted by the original verifier. The transport checks
the exact site count and next counter, requires one distinct
`p112f_N_local_scratch` per site, independently constructs six immutable rounds,
and compares all previously admitted full entries after every round. It also
checks that calls beyond the expansion budget prevent private caller admission.

Independent source review found no concrete defect in the initial prototype:
each successful fusion advances the global counter before scanning the produced
list, the counter flows through both branch arms and their suffix, and every
copied continuation comes from its original validated definition. Existing
capture/argument snapshots and flat numeric namespaces preserve simultaneous
values and disjoint scratch storage. At most eight continuations, each with at
most 128 original statements, can be copied per public or private source body.
An unsupported or exhausted suffix retains runtime transport; returning paths
with such frames cannot enter the private planner. The once-filtered candidate
list preserves original metadata/hygiene checks, while all ranks use immutable
previous readiness and emit stored first-admission plans.

This source review depends on the mandatory original verifier, exact fusion and
region modules, and the selected CPU fail-stop runtime. It is not a formal proof
or a target qualification. Existing region02 admission receipts do not cover
the new final emission hook; a separate exact source/runtime receipt is needed.

`admit-region-multi02.py` supplies that separate source-only receipt using
`conjunction-region-multi02.json`. It pins all 36 dependency/implementation
modules and the final hook, including multi inventory02
`78371a044fe9fd0a94b0d761a921a61fb7c5734e1d11254660702d8741c95e7f`.
Nineteen source mutations must refuse, including changed site budgets, reused
site numbers across recursive expansion or branches, mutable readiness and
replanning frozen entries. The `p112c_` namespace is deliberately separate from
the existing word selector's `p112m_` namespace. Namespace inventory01 is
preserved but is not the input to this admission. Detected float, static and
word-selector overlays still require their own receipts for this same compiler.

```sh
python3 selfhost/tools/performance/phase112/workers/admit-region-multi02.py \
  --runtime-source selfhost/build/phase111/runtime-source04/runtime.c \
  --runtime-object selfhost/build/phase111/runtime-source04/runtime.o \
  --compiler COMPOSED/compiler.bend --out FRESH_ADMISSION
```

Preparing the controls, review and receipt method executed no target. Source
qualification and paired native observations remain coordinator work.
