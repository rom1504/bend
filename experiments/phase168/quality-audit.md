# Phase168 independent generated-code audit

This is an offline source/QBE/assembly comparison; no compiler, generated
program, or profiling job ran in this audit. The measured boundary comes from
Phase167 `observer-runtime02/report.json`: four alternating pairs of the actual
new `observer-baseline01` and `observer-build01` executables, exact `768\n` in all
eight observations, medians 0.441204748s and 0.655356054s. The observer prototype
is **1.48538× slower on this verifier computation**, despite its smaller build.
This is neither a whole compiler runtime ratio nor a full self-build result.

## A concrete missing capability

The retained QBE files are
`selfhost/build/phase167/{observer-baseline01,observer-build01}/emit/program.ssa`.
Their corresponding `machine/program.s` and executables are also retained.
Decode `_FID_` names as their underscore-separated decimal character codes.
Function declarations in these two files give:

| Emitted representation | Optimized baseline | Observer-first |
|---|---:|---:|
| Direct functions (`p113d`) |93|73|
| Closed region workers (`p112w`) |385|0|
| Scheduled functions (`p111`) |1,563|983|
| Main entry |1|1|
| QBE bytes |2,895,455|1,886,005|

All 20 baseline-only direct identities are exactly ten pairs named
`$p118borrow.read.<owner>` and `$p128borrow.owned.<owner>`:

`String.eq`, `String.order`, `String.is_empty`, `da`, `dx`, `index_hash`,
`p111v_at`, `p88_string_eq`, `p88_string_eq_go`, `p98_eq_finish`.

There are no observer-only direct identities. Thus source-derived scalar
readers and their retained owned fallbacks are an exact missing optimization
family, not a conjecture based only on file size.

The difference survives QBE's machine lowering:

* `index_hash`: baseline QBE line454 and assembly line444 call
  `p118_rt_borrow_scalar_safe`, then the reader and one root sink, or the owned
  fallback. Observer QBE line2001 and assembly line2149 retain
  `p125_rt_take2` inside the character loop and a direct `Char.to_u32` call.
* `p88_string_eq_go`: baseline QBE line910 uses the guard, reader, and root
  sinks. Observer line2227 retains three static `take2` call sites and a direct
  `Char.is_eq` call. These are static sites, not dynamic event counts.
* `da` and `dx`: the baseline uses guarded scalar readers; the observer retains
  variant-sensitive record takes and field sinks. For `da`, baseline QBE
  line2856 versus observer line1447 shows the contrast, including eleven static
  sink sites in the latter. `dk` remains the same ordinary accessor in both;
  this is not a claim that every KDef accessor lacks borrowing.
* The real repeated consumer `p111v_get`
  ([verify-segments.bend:3](../../selfhost/src/back/qbe/verify-segments.bend:3))
  has the same keep → `index_hash` → `index_find` call pattern in both
  artifacts (baseline QBE line4823, observer line4605). Some changed work is
  therefore below a substantially unchanged lookup boundary.

The source owners are
[index.bend:66](../../selfhost/src/core/index.bend:66),
[consuming-strings.bend:5](../../selfhost/src/core/consuming-strings.bend:5), and
[term.bend:294](../../selfhost/src/core/term.bend:294). Assembly scratch-frame
sizes differ, but frame reservation is not a measurement of stack traffic,
heap allocation, or total active stack; the reader itself can also use scratch.

## The implementation prerequisite is specific

Unchanged `p128bs_leaf`
([borrowed-regions.bend:8](../../selfhost/src/back/qbe/borrowed-regions.bend:8))
refuses every `P113DCall`, including nested branches. The observer's current
`index_hash` and `p88_string_eq_go` therefore cannot pass that test until the
small `Char` calls disappear. Reusing the bounded ordinary inliner before
scalar selection is a justified prerequisite; weakening the leaf requirement
would change the lifetime contract. `da`, `dx`, `p111v_at`, `String.is_empty`
and `p98_eq_finish` already have leaf ordinary bodies.

The inliner must retain the maintained hygiene, size, stack and insertion
guards, including `p113i_original_clean(original)` before adding a transformed
callee to the table
([inline.bend:339](../../selfhost/src/back/qbe/inline.bend:339),
[inline.bend:360](../../selfhost/src/back/qbe/inline.bend:360)). Already verified
general borrowed observer seeds should remain outside that ordinary inlining
table and transformation. Changing their retained-root boundary is a separate
optimization requiring its own justification.

First-level leaf readers alone do not recover the whole ten-pair family.
`p128br_seed` and its consumer retry establish source-authorized borrowed calls
for enclosing observers
([borrowed-regions.bend:285](../../selfhost/src/back/qbe/borrowed-regions.bend:285),
[borrowed-regions.bend:707](../../selfhost/src/back/qbe/borrowed-regions.bend:707)).
The helper must actually be emitted in the same worker bundle; the schema alone
is not authority. `p128br_arguments` requires each borrowed descendant's origin
to remain under a held root
([borrowed-regions.bend:204](../../selfhost/src/back/qbe/borrowed-regions.bend:204)).

Accordingly, an experiment containing both bounded inlining and scalar-summary
composition measures that combined treatment. It must report which helpers
actually return, and cannot attribute its whole effect to borrowing alone.

## What this does not establish

The ten missing pairs are the strongest concrete first repair; no physical
profile here attributes the 48.5% runtime excess to them. The missing 385 region
workers, changed inlining decisions, cold constructor facts, and scheduled
fallback population remain competing explanations. In particular, baseline
`index_find` is larger than the observer's body and inlines some wrapper work;
fewer bytes are not evidence of less executed work.

The observer uses `p167plain_segments`, which calls `p111q_segment` individually
([demand-plain.bend:6](../../selfhost/tests/phase167/demand-plain.bend:6)); it
intentionally bypasses the registry builder. A cheap subsequent region ablation
would hold the *same verified final program and live/cold tables* fixed and
change only this emission path to the maintained registry-backed
`p111q_segment_chunks`. That needs no new semantic admission strategy and tests
the surviving generic boundaries. It must preserve actual full headers and the
existing direct-import/forwarder obligations; rebuilding different direct
functions at the same time would confound the comparison. Earlier Phase167
live/plain-live results are informative but do not substitute for this pair:
their final direct population differs from the proposed scalar treatment.

## Source-review obligations for the additive variant

The checked request must remain the only entry providing source permission,
actual constructors and prepared source bodies. Cached plans are tied to that
same book; neither a matching name nor a projected signature proves semantic
equivalence. Triple bundles must retain the original owned implementation,
guard and root disposal. Dependencies must precede consumers, and replacement
must not leave duplicate public owners or remove a needed owned fallback.

Early closed seed checking with actual constructor layouts is useful, but it
does not replace the final verifier using actual demanded IDs. Retain
`p167v_original`, the all-private requirement and
`p118b_verify_functions(functions, actualOriginal)` on the final emitted
population. The borrowed projection checker establishes structural/ABI
contracts, while the source observer analysis and held-origin rules establish
the lifetime justification. Finite controls are neither arbitrary-IR safety
proofs nor BendTT proofs of the compiler.

## Concrete module review

Reviewed the initial implementation and final 207-line
[early-scalars.bend](../../selfhost/tests/phase168/early-scalars.bend). Mode0
omits ordinary inlining; mode1 uses the protected bounded inliner. Both external
entry points reject modes greater than1, and the mode is explicitly carried to
the single selection point. No concrete semantic blocker was found in this
source inspection. Normal checked acquisition is still required; this review
is not a target result.

* `p168_prepared` classifies plans against the actual prepared book with an
  empty ordinary worker list. General observers are synthesized once; scalar
  plans without an owned body are retained for later rather than inventing one.
* `p168_seed_verified` preserves the exact-source substitution selection and
  closed seed check. `p168_inline` skips all general seed identities and keeps
  them out of its table. `p168_inline_next` retains the original-clean guard.
* `p168_scalars` passes cached plans to unchanged `p128bs_eligible/find`. Added
  triples are independently checked with real constructors before prefixing
  them to the old list. The replaced original owner is removed by the actual
  added signatures; the owned implementation remains in its renamed triple.
  The initial scalar plan has no helper dependencies and the owned fallback is
  leaf, so this closed-prefix check is meaningful rather than a fabricated
  dependency catalogue. A legitimate fallback needing an unavailable literal
  function ID may conservatively refuse here.
* `p168_retry` publishes only summaries tied to successfully produced worker
  bundles. One unchanged consumer retry uses that stable helper population;
  it does not assume newly retried consumers are already available as helpers.
  Existing topological owner order is preserved by `p128br_apply`.
* Final demand construction and `p167ob_lowered` retain actual generic/static
  obligations and the final borrowed projection check. No protected verifier,
  source permission rule, recursion rule, or runtime ownership primitive is
  weakened.

The general observer representation is chosen before raw candidate admission.
The scalar replacements are selected **after** `p113d_passes` and do not rerun
that admission; this variant primarily restores execution quality. Cached plans
avoid repeating their initial classification, but eligibility/lowering checks
still perform real work. “Analysis happens only once” would be too broad.

## First completed Phase168 artifacts: restoration exposes ordering

Offline comparison of `selfhost/build/phase168/baseline01` and `inline01`
confirms identical request method, API01, source, Base, prepared carrier and
binding identities in their emission receipts. Both build receipts are complete;
runtime observations were still pending when this comparison was made.

| Quantity | Baseline01 | Inline01 |
|---|---:|---:|
| Complete source-to-executable screen |31.455195s|31.014306s|
| Backend plus rendering |21.469983s|21.275096s|
| Direct functions |93|93|
| Region workers |385|0|
| Scheduled functions |1,563|983|
| Total functions |2,042|1,077|
| QBE bytes |2,895,455|2,435,905|

These are single build observations. The earlier approximately25% construction
saving is largely absent in this treatment; the current1.4% difference is not
evidence of a repeatable improvement. The prototype materializes emitted text
inside its lower/verify interval, so only backend **plus** rendering is a fair
stage comparison. Both rows use authenticated prepared Base in a fresh hosted
compiler process, not a native full compiler self-build.

All ten previously missing reader/fallback pairs are restored. The final direct
identity sets match exactly;78 of93 individual QBE direct function definitions
are byte-identical after removing inter-function whitespace. All eleven reader
bodies, including the already present general `String.cmp` reader, match the
baseline. Machine assembly confirms that `index_hash`, `p88_string_eq_go`, `da`
and `p111v_get` now have the same relevant call boundaries as the baseline.
For example inline assembly line152 has the index-hash guard/reader/fallback
calls, replacing the old candidate's per-character owned take path.

However, the remaining15 direct bodies reveal a **concrete ordering hazard**:
ordinary consumers inline the old scalar owner before that owner is replaced
by a borrowed adapter. Replacing the function later cannot repair copies
already embedded in its callers. This is semantics-preserving but defeats part
of the intended optimization:

| Direct owner | Baseline QBE body bytes | Inline QBE body bytes | Concrete changed boundary |
|---|---:|---:|---|
| `p111v_signature` |31,337|95,505|16 `String.eq` calls become16 `String.cmp` calls plus16 `take2` and sink sites|
| `p111v_comparison` |6,975|50,920|10 `String.eq` calls become10 `String.cmp` calls plus owned extraction/disposal|
| `p111v_operator` |6,884|46,435|9 `String.eq` calls disappear into ordinary comparison/extraction code|
| `p111v_counted_call` |21,726|82,673|7 `String.eq` calls disappear, with additional literal/buffer/lookup wrapper inlining|

These are static call-site counts, not executed counts or attributed time. They
show why “the helper set now matches” is insufficient to conclude that runtime
quality is recovered. The inliner also expands some other small wrappers, so
the table is not an equality-only treatment.

A narrow next falsifier, if runtime warrants it, is to keep semantic scalar-plan
owners out of the early inline table while still preparing their own leaf
fallbacks with eligible tiny callees. That preserves calls until the later
scalar replacement supplies the new implementation. The protection set must
come from source plans, not special-cased owner names. This is a proposed
alternative, not a tested result or permission to alter the leaf/lifetime rules.

## Region-control review

[region-control.bend](../../selfhost/tests/phase168/region-control.bend) keeps
the same `p168_request_mode` lowering and the same `p167ob_final` gate; only its
successful emitter changes to `p167live_chunks`. Both paths compute actual IDs
from the same final program, use the same `p167live_eligible` predicate and
construct the same live/static/constructor tables. The differing segment path
is exactly `p167plain_segments` versus maintained `p111q_segment_chunks`, the
latter entering `p112c_segment_chunks` and registry construction. Modes greater
than1 are refused. No source-level semantic blocker was found.

This is a valid source-level registry attribution control, provided each pair
uses the same scalar mode and source/API inputs. Its extra generated region
workers and changed scheduled bodies are the intended treatment. It does not
isolate a single region, and it does not repair the stale inlined scalar copies
above. Actual generated-output and runtime gates remain necessary.

### Important limit: registry recovery is not full continuation recovery

The registry-only path does **not** use the maintained `p134e_registered`
context or its `p124r_public` continuation chain. In particular, it does not
construct the direct/legacy callable view used by call-and-resume composition.
A neutral registry-only runtime result therefore cannot reject that broader
capability. Registry worker counts also depend on the retained segment set;
matching the baseline worker count is not an independent correctness objective.

The smallest separate continuation-emission control is, after the unchanged
successful `p167ob_final`, to collect
`p134e_prepare(original,nodes,functions,False{},p167live_eligible(program))`
using `p134e_collect_cursor`. This retains the exact final bodies, IDs and
tables, disables arrays, and restores the maintained `p114h/g/r` renderer
([stream-emission.bend:23](../../selfhost/src/back/qbe/stream-emission.bend:23),
[stream-emission.bend:67](../../selfhost/src/back/qbe/stream-emission.bend:67)).

There is a further explicit limitation: all demand-final workers are private.
`p124r_complete` and `p124r_public` require the signature's public bit to be1
([helper-resume.bend:21](../../selfhost/src/back/qbe/helper-resume.bend:21),
[helper-resume.bend:155](../../selfhost/src/back/qbe/helper-resume.bend:155)).
Merely passing these private functions to `p134e_prepare` does not make them
available as direct callable replacements. A separate renderer-only callable
view can be derived from independently authenticated actual adapter owners,
with exact bodies/order retained and an extra borrowed/direct check against
actual original headers. It must not publicize arbitrary private readers,
owned fallbacks or products, change the independent private-final gate, or
invent a verification certificate. That is a distinct treatment with extra
verification cost, not a claim that the old registry-only control tested it.

## Selective alternative source review

The89-line
[early-scalars-selective.bend](../../selfhost/tests/phase168/early-scalars-selective.bend)
overrides only experimental `p168_closed`. Mode0 is unchanged; mode1 uses a
plan-derived selection. Every cached scalar/retry owner and every existing
general seed stays out of the inline table. Only unchanged, clean leaf helpers
are inserted under the original table budgets. Only eligible nonleaf scalar
owners are transformed, and the result is kept only when it establishes the
unchanged leaf contract. Non-target consumers remain exact. No concrete source
blocker was found.

The policy is deliberately conservative: a useful tiny helper may itself be
in the retry set and therefore excluded. That can prevent leaf preparation;
inspect actual restored helpers rather than weakening the exclusion for a
recognized source name. No whole-program recursion or lifetime rule changes.

The separate [selective-controls.bend](../../selfhost/tests/phase168/selective-controls.bend)
adds four pure policy checks: a leaf helper changes only its selected consumer;
a blocked helper is not inlined; a seed helper is not inserted; and an unknown
helper leaves the original function intact. Negative cases compare all fields
of complete function lists. The positive case also requires the unchanged
independent direct verifier to accept the resulting list. These controls were
written offline; their checked execution belongs to the root's target lane.

## Adapter-derived renderer view review

Reviewed the66-line
[adapter-view.bend](../../selfhost/tests/phase168/adapter-view.bend) without
executing targets. No concrete semantic blocker was found. Both renderer modes
use the same selective producer (`p168_request_mode(1,request)`); mode0 keeps
private metadata and mode1 changes only renderer-callability flags.

The normal entry first runs the unchanged `p167ob_final` on the actual private
program and adapter map. Only then can `p168v_functions` mark a function whose
map entry has the exact adapter kind, owner name, reference shape, matching
arity, zero metadata field and one result. Actual source/header/body obligations
have already been established by that private final gate. The renderer copy
preserves every function body, parameter list, result count and list position.

Both modes then run maintained `p118b_verify_functions` against the real
original program. In mode1 this additionally checks public ABI obligations:
matching real header arity, one result, no incoming continuation values and
zero flags. Borrowed-body and dependency checks remain enabled. No synthetic
header or success certificate is supplied. A reader, owned fallback or product
without an authenticated adapter entry stays private.

The renderer uses unchanged `p134e_prepare` with actual original/static nodes,
arrays disabled and `p167live_eligible` evaluated on the original semantic
program. Thus the treatment can exercise public direct-call/continuation
composition while holding the lowering and verified bodies fixed. It adds a
real second verification traversal to both modes, which belongs in build cost.

`p168v_callable` and `p168v_prepare` alone are internal helpers, not arbitrary-IR
authorization interfaces: their provenance comes from the gated normal entry.
This source review does not replace complete output checks, finite semantics,
or a whole-compiler qualification. The separate selective controls' first
source snapshot failed because three local list bindings needed explicit type
annotations; the root preserved that failure and corrected those annotations
before its next acquisition. The auditor did not edit the frozen snapshot or
run those controls.

## Callable view: the missing registry import boundary is now concrete

The completed `view-census.json` compares the actual private/callable renderers:
all93 direct bodies are identical, both have124 region workers and983 scheduled
functions, and the only static call-count change is62 additional `reg_get`
sites in the replacement public adapters. Thus adding public metadata did not
eliminate resume transitions in this pair. Static counts still do not attribute
runtime; the full output and paired runtime receipts are separate evidence.

`baseline02/emit/program.ssa` is byte-identical to `baseline01`. Against
`callable01`, both have the same93 direct identities but only64 individual
direct QBE bodies match. Remaining differences include lookup-wrapper inlining,
branch/ownership cleanup and some consumer composition. For example baseline
`index_find` calls the inner equality loop and embeds some child-list handling,
while the candidate keeps ordinary equality/child-list wrapper calls. This
remains a separate possible cost from scheduled continuations.

Two initially plausible confounders are excluded by the **actual** artifacts:
both have185 constructor-hot bytes, all1, and both `p111_program` tables have
capability field11 equal to5. Mode2's `p117p_tables` would set this field to3,
then live transport ORs4 to produce7. These outputs therefore do not establish
a mode2/array advantage for the baseline. The maintained renderer has that
capability, but assuming it was enabled for this workload would be incorrect.

The registry boundary explains why the callable metadata alone did so little:

1. `p134e_prepare` runs `p112c_index_with(segments,index)` before
   `p134e_registered` creates the direct-callable view.
2. `p112c_index_with` starts with empty ready/symbol maps
   ([closed-regions.bend:490](../../selfhost/src/back/qbe/closed-regions.bend:490)).
   Region private-call verification recognizes only its own registered
   `P112RegionSymbol` entries. An actual demand adapter calling a `p113d` symbol
   does not seed that population.
3. Later public flags cannot recover omitted region workers or the generic
   callers that would have composed with them. The late continuation planner
   has additional closed-frame, size and arity requirements; it is not a
   substitute for every local registry fusion.

There is a concrete consumer difference, beyond aggregate function counts.
Baseline QBE line61410, `$direct.p111v_put`, fuses two `atom` calls and an
`index_hash` call into ordinary `p112w` calls, followed by the scheduled
`index_set` jump. Callable QBE line23032 instead writes a six-value continuation
frame and jumps to the first `atom`; its remaining work lives in continuations.
Baseline `$direct.p111v_stmt` also has four local `p112w` calls to `p111v_type`
that the candidate lacks. These examples identify missing composition; they do
not quantify how often the paths execute or their fraction of the runtime gap.

The bounded reuse path is the seven helpers from Phase164
[hybrid-imports-only.bend](../../selfhost/tests/phase164/hybrid-imports-only.bend):
eligibility, insert, imports, candidates, registry, forward and forward-if.
After the unchanged private gate and authenticated public-copy check, eligibility
must bind actual segment arity/result/incoming/flags to the checked public
signature. Seed these real imports **before** registry discovery, preserve the
full fusion index, exclude only imported owners from generic candidate creation,
and emit one actual `p112w → p113d` forwarder for every seeded rank0 entry.
Those real functions justify ready/symbol entries; a ready bit without its
forwarder would be unsound. The existing independent region private-call
verifier and rank-based discovery remain unchanged. This is a proposed bounded
bridge at the time of this audit, not an established improvement.

## Import-before-discovery module review

Reviewed the118-line
[adapter-imports.bend](../../selfhost/tests/phase168/adapter-imports.bend).
No concrete source or obvious affine-capture blocker was found. Its sole
override is experimental `p168v_prepare`; the original private final gate is
still reached through the unchanged normal entry. Both modes now construct
the same authenticated public view and repeat the maintained public ABI and
borrowed-body check. Consequently **this module's mode0 is the stock renderer
with public view**, corresponding to the prior callable treatment, not the
prior adapter-view mode0 private treatment.

The renamed Phase164 selection helpers bind each imported worker to an actual
zero-incoming, zero-flag, one-result header with matching public arity. The
rank0 entries are present before the unchanged `p112c_passes`; only those
owners are omitted from registry candidate construction, while all actual
segments and the complete fusion index remain available. Discovery starts
subsequent ranks at1. The producer never supplies a fake generic body or an
invented successful region plan.

`p168j_forwards` emits a real ordinary-call `p112w` forwarder for each rank0
entry from the same final direct-function list. Eligibility guaranteed its
matching arity/result; direct namespace and dependency checks already rejected
missing or duplicate workers. Imported owners are excluded from later
candidate discovery, preventing a second definition, and rank1-and-later
workers do not receive prefix forwarders. Ordinary forwarders appear before
the standard cursor's definitions, which QBE supports. The unchanged registry
private-call verifier checks their registered symbol/arity contract when
composing callers.

Both modes preserve function bodies, actual IDs, static nodes, constructor/live
tables and arrays-off policy. The seeded path adds real forwarder text and
changes registry composition, so emitted-code equality is not expected.
This review establishes a concrete guarded implementation boundary; it does
not claim semantic proof, representative runtime improvement, a faster native
self-hosted generation, or promotion. The root owns all checked acquisition,
full-output and paired runtime evidence.

## Completed import experiment: quality recovered on the verifier workload

Independently read all12 observations in
`selfhost/build/phase168/runtime-imports01/report.json`: four alternating rounds
of baseline, stock-public renderer and seeded-import renderer. Every observation
completed with exit0, exact `768\n` and empty stderr.

| Executable | Median seconds | Relative to baseline |
|---|---:|---:|
| Optimized baseline02 |0.438888606|1.00000×|
| Stock public-view registry |0.612518671|1.39561×|
| Import-seeded registry |0.423049469|0.96391×|

The seeded treatment uses30.93% less time than the stock-public control and
3.61% less than this baseline in the bounded paired screen. The same-API05
complete source-to-executable observations are31.557995s for `baseline03` and
27.758682s for `imports01` (12.04% less); their method/API/source/Base/carrier
pins match. Those build figures are single observations, not repeated medians.
The runtime baseline was the **baseline02 executable**. Baseline03 emits exactly
the same QBE, but its executable was not timed by runtime-imports01.

[imports-census.json](../../implementation/phase168/imports-census.json)
confirms93 unchanged direct bodies. Region functions grow124→160 solely because
of the36 real imported forwarders: **no additional derived region-worker
population appeared**. The observed recovery comes from making those workers
available to local composition, not from the hypothesized growth of a further
region-worker cascade. Static jump sites fall716→421; this does not measure
dynamic jump frequency or assign a time cost per jump.

The predicted code transfer survives machine construction. In stock01 assembly
line24872, `$direct.p111v_put` has only a keep and scheduler-jump call in its
first body. Imports01 assembly line26206 has two actual calls to `p112w.atom`,
one to `p112w.index_hash`, constructor work, then the remaining `index_set` jump.
The imported index-hash forwarder at assembly line3 makes the real ordinary
call to its verified `p113d` implementation. Imports01 `p111v_stmt` likewise
contains the four local `p111v_type` calls missing from the stock rendering.
These are actual assembly call boundaries, rather than conclusions inferred
from a smaller IR file.

This controlled result supports the architectural lesson: semantic callability
must reach the registry **before** local composition, with real code backing
its contracts. Late flags and a matching direct-helper inventory were
insufficient. It establishes a successful joint build/runtime screen for this
real verifier computation, not representative speed for all programs, native
whole-self-compilation economics, broad conformance, compiler correctness proof,
promotion, or the10× goal. The root's independent lookup transfer is a separate
gate; this audit did not execute it or any target.
