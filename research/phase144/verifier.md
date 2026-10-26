# Phase144: compact raw-verifier state

Source-only experiment, 2026-10-26. Selected input is Phase143 source
`a51a4a6d0a32e118ca75eac96fb4e64bae0fcf951b09ee859c2632f65550bd4e`.
The original production and independent final verifiers remain unchanged.

## Observation and hypothesis

`p111v_put` stores a nine-field `KDef` for four used fields: exact name, kind,
width and capacity. Two nested Absent terms, an empty constructor list and two
flags contribute no raw-verifier information. Assignment reprojects a schema
record into another such record. A nonterminal branch join traverses one live
map, looks up the other and reconstructs every surviving row; unequal capacities
become zero. This is a complete construction/query/join/reclamation problem,
not just a lookup benchmark.

`p111v_get`'s previous 4.08% context share comes from the Phase142 executable
profile collected in Phase143. It is not the new Phase143 residual profile and
does not establish the candidate's maximum or expected speedup.

The first falsifier retains names, hashing, kinds and all verifier decisions,
but stores four-field typed records in a private canonical Patricia tree.
This tests representation cost without introducing source-local interning or
mutable arrays. The private tree uses the existing one-descent insertion
principle, exact bucket names, remove-all-old-duplicates then prepend semantics,
and original left-before-right intersection traversal.

## Exact scope and cost

The prototype consists of a roughly 90-line typed table and a mechanically
extracted 370-line raw-verifier clone. The extraction script pins the selected
source and records the substitutions. Only the private table and entry access
change; every original decision and diagnostic string is retained. The old
declarations are independent references, not aliases to the new implementation.

This deliberately duplicates a verifier for a bounded experiment. It is not an
acceptable production architecture by itself. Adoption requires actual gain,
an explicit retirement/shared-definition plan, independent review, and unchanged
final verification. The typed raw verifier does not cover P113 direct functions,
later array/product contracts or the complete compiler correctness boundary.

The compact tree is built privately from empty by typed insertion. It does not
claim to reproduce arbitrary malformed/legacy `KDef` maps or zero-mask nodes.
All metadata names remain collision-checked; there is no hash-only admission.

## Required falsifiers

1. Independently check the additive Bend modules; no overrides.
2. Run finite controls with independent expected errors. Compare complete schemas
   and live maps after a data-only reconstruction to the original representation.
   Include a real hash collision, duplicate names, reserved names, width/allocation
   changes, undefined values, dynamic capacities, error precedence and terminal
   path behavior. Never execute deliberately invalid IR.
3. Run the complete raw verifier on real Lexer, Map and closure plans, including
   global tables, all schemas, all branches and returned errors. Preserve ordered
   calls and source/IR/API identities. Hosted measurements are only a discriminator:
   JS garbage collection does not faithfully measure native reclamation.
4. If promising, extract complete real per-function slices and measure native
   construction, verification, joins and teardown with independent error output.
   Include preparation/metadata costs rather than timing only repeated lookups.

First-version methods are under
[`selfhost/tools/performance/phase144/verifier/`](../../selfhost/tools/performance/phase144/verifier/).
The original V01 private table failed source checking because the removal
function captured an affine list tail in both conditional callbacks. V02 marks
that tail shareable. The rejected source and check receipt are retained.

The root subsequently independently checked `prototypes-source03` (SHA
`f74b34c50ce3b5e9065f4a0b77601fb7770debd56a8929c0d14c1ff8b29d1c86`).
`verifier-controls01/report.json` passes all44 independent expected-error
controls and full-state comparisons. `verifier-screen01/report.json` passes
complete original/private raw verification for all three real programs.
Hosted candidate/original median ratios are approximately1.105 for Lexer,
0.917 for Map and0.914 for closures. This is mixed evidence, not a general gain.

The next native falsifier is source-prepared under
`selfhost/build/phase144/verifier-{lexer,map}-native01/`. Exact dependency closure
reduces source to126/121KB for Lexer and549/543KB for Map (old/new), avoiding
another full compiler source/image acquisition. Each repetition constructs all
265/666 actual metadata headers and constructor tables, then validates eight
complete branch-rich real bodies, including schema, flow, joins and temporary
state reclamation. The expected checksum is2048 for256 repetitions.

Unselected bodies in the metadata catalogue are empty because only their exact
headers are consumed when validating the selected functions. This catalogue is
not presented as a complete executable source program. Actual immutable IR is
serialized as constants, so its input storage may become static; both variants
share that representation. Native timing therefore remains a temporary-state
discriminator, not a whole-compiler memory-lifetime or speed claim. Native source
checking, machine acquisition and measurement were root-owned jobs.
There is no new theorem, production verifier replacement or promotion.

## Native result and an admission confound

The Lexer native slice passed ordinary output and three alternating timing
pairs. Original/candidate medians are2.668716688/2.617976431 seconds, a ratio of
0.980987020 (1.90% less time). This is a weak result and does not justify
adopting457 additional verifier lines. The Map native plan remains unrun.
See `selfhost/build/phase144/verifier-lexer-times01/report.json`.

Static inspection of those exact ordinary-qualified binaries does show reduced
code size: QBE2,474,841→1,990,113bytes, object706,240→615,304bytes. Record
construction itself changes from the72-instruction original `p111v_put` body,
with two `atom` calls and a generic constructor call, to a48-instruction private
body using the four-field constructor helper. These are physical static code
counts, not dynamic call or allocation frequencies.

However, this is **not a code-generation-equivalent representation ablation**:

| Computation | Original emitted path | Compact emitted path |
| --- | --- | --- |
| Name hashing |33-instruction direct adapter, borrowed reader |Same33-instruction adapter/reader |
| Get row |31-instruction direct worker: hash then direct lookup |30-instruction scheduler entry: hash then runtime jump |
| Tree lookup |595-instruction direct worker |245-instruction scheduler body; three static runtime-jump sites |
| Validate value |353-instruction direct worker |437-instruction scheduler body; three runtime-jump sites |
| Statement/body dispatch |595/230-instruction scheduler bodies |Same595/230-instruction bodies |

The compact path removed unused record fields but retained full-string hashing,
collision comparison, trie traversal, repeated schema/live lookups and branch
reconstruction. It also lost ready direct workers for lookup and value checking.
The new absence helper itself *is* a ready direct worker returning a static
constant, so simply blaming that helper would be incorrect. No dynamic profile
has established which remaining category dominates this slice.

The strongest source-backed admission hypothesis is eager finite-product call
selection. Unlike the multi-constructor `KDef`, single-constructor `P144VEntry`
receives a product signature. `p113pl_call` chooses that signature before final
readiness; selection/recursive-call limitations can therefore reject a compact
result path that previously stayed boxed. This is a hypothesis requiring the
actual candidate error/dependency trace, not a demonstrated diagnosis yet.

Version03 makes absence a genuine second constructor, `P144VAbsent{}`, while
keeping all present rows four fields and preserving the exact absent getter
results. This avoids inventing an impossible constructor merely to manipulate
the optimizer. The existing direct paths return: actual V03 `p113d` workers
exist for private tree lookup, bucket lookup, get and value validation. The
private tree worker has141 machine instructions, get30, and value validation353
(the same count as the original). Put remains a48-instruction scheduler body;
body dispatch remains230 instructions. These counts include physical static
paths and are not dynamic instruction counts.

The root's independently acquired V03 native slice passes exact output2048
and three alternating timing pairs. Original/candidate medians are
2.718980787/2.418247639 seconds: ratio0.889394898, or **11.06% less slice time**.
Individual paired ratios are0.881919,0.906181,0.889395. This is stronger evidence
for compact verifier state, but not a whole-compiler gain or a claim that this
one slice represents every program. QBE grows from V02's1,990,113 to2,162,901
bytes while execution improves: smaller generated text did not predict the
better version. The original remains2,474,841bytes.

Receipts are `verifier-lexer-sum-times01/report.json` and
`verifier-sum-machine01/report.json`. The subsequently checked
`prototypes-source04`/`p144-prototypes-api04` also passes all44 independent
expected-error and complete-state controls in `verifier-sum-controls01`.
V02, its weak timing and exact binaries remain frozen. No production selection
changed and no full native compiler qualification is implied.

Static source/machine evidence is reproducible with
`verifier/inspect-native-v01.py`; its96 selected function bodies/disassemblies and
input identities are retained under `verifier-machine01`. Static cold/fallback
paths must not be interpreted as per-operation work or added into a savings
prediction.

## Does the admission problem explain other current hot paths?

The selected-current census prevents extrapolating from the new prototype.
`census-selected-v01.py` joins exact Phase143 source and qualified QBE to the
existing exact-object Phase144 native profile (10,083 samples). Its report is
`selfhost/build/phase144/verifier-selected-census01/report.json`.

| Selected owner | Samples | Actual boxed direct worker | Actual product worker |
| --- | ---: | --- | --- |
| `p111q_memory` |131 (1.30%)|yes|yes|
| `p113k_get` |109 (1.08%)|yes|yes|
| `p111v_step` |59|no|no|
| `p111v_decl` |50|no|no|
| `p111v_body` |25|no|no|
| `p112c_try` |29|no|no|
| `p112c_frame` |26|yes|no|
| `p112c_freeze` |10|no|no|
| `p134e_registered` |3|no|no|

`p113k_get` returns the finite product `P113KFact`; its input, rather than its
result, is `KDef`. Despite that relevant shape, its emitted product and boxed
workers both exist. The absence-of-ready-workers explanation is therefore
**false for these two measured hot examples**. Registry construction has little
direct owner weight in this particular profile. Owner samples include work in
physical helpers and must not be added to those helpers' sample fractions.

The absent verifier workers remain useful trace candidates, but missing emitted
workers alone do not establish failed product specialization. For example,
`p111v_put` calls the recursive persistent-index update; that path can fail direct
admission for genuine non-tail recursive transport independently of finite
product layout. The exact candidate errors/dependencies must distinguish these
cases before implementing a general fallback.

If the V03 discriminator and candidate trace establish the specific product
failure, a narrow general fix would retain boxed alternatives when an advertised
product return cannot be implemented. Preserve the current semantic lowering,
topological dependency checks, stack guarantees and independent final verifier.
Do not simply permit opaque-to-product transfer or rerun every compiler analysis.
First identify the invalid signature and only its affected callers; cost the
extra preparation and ensure previously ready product workers stay available.
A broad relowering campaign is not supported by the current hot-path census.

## Integration without copying the verifier

Adding a four-field `KLocalFact` constructor to the shared `KDef` datatype is
possible, but it is not a private three-function edit. The selected source has
29 declaration owners directly matching `KDef`, `KIndexLeaf` or `KIndexNode`.
They include nine projection accessors, canonical and legacy index operations,
five name/kind predicates, and exact snapshot equality. In particular:

- `p140p_variant`, `p140eq_def` and `p140vm_index` deliberately distinguish
  physical constructors. Their wildcard refusals would make two new facts fail
  equality unless explicitly extended. Comparing only projected fields would
  weaken existing snapshot identity, so is not an acceptable shortcut.
- `index_find`, `index_tip`, `index_insert` and `p131i_insert` accept the same
  datatype for tree nodes and payload records. A new record used as a tree
  must have a defined legacy interpretation, even if intended production uses
  place it only inside canonical leaf buckets.
- `dn`/`dk`/`da`/`dx` must preserve the four projected fields; the remaining
  accessors must preserve the exact old `Absent`/empty/false values. The five
  direct name/kind predicates must agree with those accessors, including
  unexpected kinds, rather than assuming every new fact is named `local`.
- Source-connected proofs involving the actual `KDef` declaration or these
  functions need a fresh bridge review. Existing exact-source receipts cannot
  automatically cover a changed core datatype.

The V03 experiment also replaces the generic index with a private canonical
trie, removing its legacy-shape paths. A compact `KDef` row alone therefore
cannot inherit the observed11.06% gain. It would be a separate experiment with
potential wider code-generation consequences.

The cleaner eventual integration is to **replace the local schema/live state
in place**, keeping the existing verifier decisions and diagnostics. Use a
private sum entry plus canonical table, split a local scan from global
`P111VScan`, and update the shared P111/P113 local-flow consumers together.
Keep global function/constructor identities in existing `N111Ids`/`KDef` maps.
That avoids adding a second370-line verifier algorithm and avoids changing the
compiler's universal record. The estimated source budget is approximately90
new table lines plus coordinated type and accessor edits, not a promise about
final checked size. It requires a new complete slice: V03 also compacts global
metadata, so its exact gain cannot be attributed solely to local state.

For this cycle the qualified compiler should remain unchanged. Before paying
for that integration, measure the raw verifier's complete contribution to the
current request. If the affected work is fraction `f`, this slice's11.06% saving
suggests at most roughly `0.1106*f` request-time reduction under the strong
assumption that the slice transfers. A2% total saving would require about18%
of request time in the affected work; neither that fraction nor transfer has
been established here. Missing direct-worker profitability is the broader
demonstrated architectural lesson, while a general admission fix still needs
the exact rejection/dependency trace.

## Larger opportunity if this pays

Intern local names once per function and use compact typed entries or indexed
scalar schema/live arrays throughout flow. Preserve exact diagnostic names and
the original schema-before-flow/first-error order. Count initial conversion,
branch cloning/intersection and teardown. Array scalar-lane lowering in the
whole mixed compiler must be inspected; an `Array<U32>` source type alone does
not guarantee four-byte cells or tuple-free reads in this runtime.

The cheapest scalar-ID experiment would resolve *one existing complete function*
into an ID-bearing verifier view, preserve the original names in a diagnostic
table, and compare original/ID results on the same finite error suite and real
body. Charge the entire conversion, metadata preparation, branch-state cloning
and teardown. A lookup-only or preconverted-only speedup is insufficient.
If this fails with one verification, carry IDs from the actual lowering producer
through multiple passes before expecting amortization; do not add a late string
interning pass whose cost merely replaces the removed hashes.

For eventual producer-owned IDs, `NC_Binding` already carries a scalar source ID,
but generated scratch names, inline renaming and branch-local definitions create
additional namespaces. IDs need exact per-function freshness and transfer rules;
parameter shadowing, duplicate declarations, width changes, capacity joins and
diagnostic first-error ordering must remain unchanged. Global function/constructor
identities are separate from local slots. A final independent verifier must not
trust an externally forged or stale name→ID correspondence.

The shared P111/P113 local-state interface is a sensible later consolidation
boundary. The V03 result confirms that changing IR datatypes without preserving
optimization admission can hide useful representation gains. It justifies a
targeted follow-up, not a large local-ID implementation or a whole-compiler
speed claim.
