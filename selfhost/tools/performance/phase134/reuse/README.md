# Phase134 isolated owner-lowering reuse probe

Status: isolated checked prototype; not integrated or native-qualified.
Parent is the exact qualified Phase131 source recorded in
`implementation/phase131/final/candidate.json`. No production declaration is
overridden. The checked source03 composes `owner-v02.bend`, `controls-v02.bend`
and `request-v01.bend` with Phase134's composer and an empty override list.
Source04 adds audit controls only and independently checks all 29 controls.

The prototype retains actual `P111Code` for an owner and decides whether to use
it **before invoking `p111_entry`** on the next revision. A hit does not run that
owner's generic segment lowering, liveness construction, continuation creation,
typed entry worker construction or their transient allocation. It is not a cache
of rendered QBE, and it does not discover hits after running those operations.

It deliberately still pays for `nc_compact_definition`, its body scan, entry
query results and exact key comparison. In the intended prepared-book boundary,
`NativeStaticBody` already supplies the compact body; unprepared inputs can pay
substantial additional work. No common preparation, source checking, private
candidate construction, final verifier, binding, rendering or machine build is
removed. This is a measured seam to investigate, not a full incremental compiler.

## Minimal contract

`p134ur_run(book, names, bangs, fresh, prior)` returns:

- The same `P111Book` product as `p111_compile_defs(..., [])`.
- An ordered list of typed owner-cache slots.
- Hits, actual owner lowerings, eligibility refusals, fresh-counter misses and
  other key misses.

`p134ur_batch` runs two revisions with one fixed compiler implementation and
retains the first revision's slots for the second. Cache lookup advances one slot
per requested owner. Reordering safely misses; no repeated whole-book comparison
or linear cache search is hidden in each owner lookup. Entries retain compact
input bodies and lowered code, not the entire previous book.

The cache is in-process and typed; it is not a public serialized artifact API.
Producer/runtime/policy identity is fixed by the process. The prototype has no
cross-producer compatibility claim. The complete cached set is not yet bounded
by a byte budget; use only bounded experiments and charge retained memory.

## Why this small cross-book reuse can be sound

The current `p111_entry` makes contextual entry decisions before generic
lowering. The key records their complete results: owner name, exact compact body,
input fresh counter, bang flag, native/foreign classification, effective arity,
live type arity, mapped name and typed worker parameter kinds. These preserve
eta selection, factory/body entry construction and entry calling conventions.
Source metadata within the compact term is compared too.

Most bodies are conservatively refused. `p134ur_closed` admits a fixed grammar
whose generic lowering does not inspect arbitrary definitions: scalar/variable
nodes, lambdas, applications without any global Ref, lets, explicit NOp/NCall/
NApply nodes, wrappers and erased nodes. It recursively rejects constructors,
matches, static-pool words, globals and unknown forms. In particular:

- `Ref` can trigger native provenance and contextual helper admission.
- `Ctr`/`NCtr` can request native constructor provenance through value kinds.
- `Mat`/`NMatch` can request constructor layouts and field facts.
- `NStatic` can embed prepared static-pool decisions.

None of those dependencies is guessed from a syntactic Ref-only call graph.
Unknown bodies run the original `p111_entry`; errors retain their original
ordering and results.

An admitted App has no Ref or Mat anywhere in its body. The existing native-call
and result-kind paths therefore reach their book-independent fallback; beta
substitution only introduces the same admitted bodies and entry variables.
Explicit NCall embeds its target name and jumps without looking up that callee.
All constructor identities remain outside this initial grammar. These arguments
are a source audit for the exact fixed producer, not a formal whole-backend proof.

Relevant parent declarations: `p111_entry`, `p111_extend`, `p111_lower`,
`p112_liveness_*`, `p112s_live_fallback`, `p112s_liveness_fallback`,
`p113n_original_value_kind`, `nd_native_call`, and `p113_callee_kind`.

The global fresh counter is intentionally **not rebased**. A hit requires its
exact old value, so continuation names and binder allocation remain identical.
If an earlier edit changes the amount of fresh allocation, later owners miss
even when otherwise unchanged. This exposes a remaining scalability barrier
instead of silently returning stale names. A stable owner-local naming proposal
is a separate change.

## Controls and evidence requirements

The 29 data-level controls compare independently fresh lowering against cached
lowering, including exact rendered segment/table metadata plus fresh/error state.
They cover cold/no-op, real scalar body edit, owner ordering, fresh-counter
movement, bang change, contextual refusal, missing owner, empty input and
explicit forbidden nodes. A deliberately forged stale body key must disagree
with the fresh-output oracle. This mutation demonstrates the comparison catches
stale output; it is not a production cache feature.

These internal KTerm controls are not checked source-program conformance. Before
any integration claim, use real checked NR_Request/prepared inputs, run the
independent existing final verifier, and compare complete fresh QBE. Do not
describe synthetic controls as a compiler-source edit speedup.

`p134ur_inventory` counts eligible/refused compact bodies without lowering. It
is only a ceiling: matching entry facts and fresh counters further restrict
actual reuse. Run this census on actual prepared compiler-derived inputs before
investing in an acquisition or broad qualification.

Timing must include preparation/key scans/comparison, hit result ownership and
reclamation, not only the skipped `p111_entry` calls. Report cold first revision,
warm second revision, independent fresh second revision and combined cost. Stop
if eligibility is negligible or key/retention overhead consumes the saving.

## Initial evidence and limits

Receipts live under `selfhost/build/phase134/`; these are independently guarded
hosted checks, not native compiler benchmarks.
Compact tracked copies, including failed attempts, are preserved under
[`implementation/phase134/reuse/`](../../../../../implementation/phase134/reuse/README.md).

| Receipt | Observation |
|---|---|
| `reuse-api-check03/`, `../phase111/p134-reuse-api03/report.json` | Source03 independently checked: 14 API exports, 14.98 s outer wall, 2.244 GB process-tree peak. |
| `reuse-finite03/report.json` | All 21 initial controls pass, including deliberately stale-body mutation rejection by the fresh-output oracle. |
| `reuse-finite04/report.json` | All 29 controls pass, adding worker-kind/native/mapped/type key invalidation, explicit-call dependency and wrapped Ref controls. |
| `reuse-requests03/report.json` | Real checked Bend body edit 11→12; two owner-lowering hits and two lowerings; all 49,054 pure-concatenated QBE bytes equal independent fresh output. This older harness omits native IO chunk separators. |
| `reuse-census03/report.json` | Prepared frozen requests: lexer 14/45 eligible, closure workload 7/15, Map workload 17/72. This is eligibility, not dynamic cost share or a full self-compiler census. |
| `reuse-lexer05/report.json` | Real lexer `prng` edit 13n→12n. Old cold output exactly equals frozen 577,297-byte Phase131 native QBE; warm edited output exactly equals independently fresh edited output, including native chunk separators. |

The tiny real edit's ordered hosted observations were 0.3727 s initial request,
0.2008 s warm edited request and 0.1836 s independent fresh edited request. The
warm path did **not** beat fresh in this observation. JIT/order effects and the
small workload preclude a calibrated ratio claim. The cache demonstrably skips
work, but a complete-request speedup is not established; do not infer a speedup
from initial-versus-warm alone.

The lexer result is a stronger negative: **all 14 reused owners are native U32
primitives; all 31 ordinary owners are refused**. The corrected replay records
6.144 s warm versus 4.318 s fresh in a single ordered hosted observation. There
is no evidence for a useful end-to-end gain. Do not integrate this memo or expand
its machinery solely to improve hit counts. The missing capability is reuse of
contextual, expensive owner computations.

Retained negative attempts: `p134-reuse-api01` rejected invalid multi-scrutinee
fallback syntax, fixed in owner-v02. `reuse-finite02` exposed an incorrectly
constructed test NWord (digits belong in `name`, not `id`). Both paths produced
the same early lowering error, so byte-equivalence controls alone passed while
work counters and the mutation control failed. Controls-v02 repairs the fixture.
This is concrete evidence that cache tests need both independent output oracles
and explicit work/invalidation observations.

`check-v01`/`check-v02` joined chunks without `IO.print`'s extra newline per chunk.
Their cached/fresh comparisons remain valid for those pure bytes, but they do not
establish native transport identity. `check-v03` preserves the exact convention
and asserts the old cold lexer against the frozen native product. The resulting
471-byte separator discrepancy is fully resolved; no benchmark definition or
compiler behavior was changed to make it pass.

The active experiment adds 260 physical Bend lines (31 definitions, seven data
types), plus 113 lines of controls. Production source and installed selection
are untouched. The next step should first measure how much request time lies
in private-candidate/generic lowering versus later global transformations. A
small exact-input `p112s_term` cache would cover more owners, but the measured
entire static preparation/inventory stage is only 0.08–0.12 s here, so its upper
bound is under 3% of the lexer request. That low-value implementation was rejected.
