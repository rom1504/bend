# Phase66 conformance and independent review

This phase moves the reference from `018751270e800bc222a93dad7f257083ee53a5f7`
to `059266225b77c8ca256ac6b25ee5c21449bab151`. The inventory and recipes below
are measurements of scope and executable plans. They do not establish a passing
compiler until their actual reports close.

## Inventory and comparison axes

The data-only [inventory producer](../../selfhost/tools/performance/phase66/controls/inventory-delta.py)
hashes both immutable reference trees. Its [complete inventory](../../selfhost/tools/performance/phase66/controls/inventory01/delta.json)
contains 1,513 old gate fixtures and 1,587 new fixtures: 83 added, 38 modified,
9 deleted, and 1,466 byte-identical. Eleven modifications change only the
embedded oracle. Imported support files are separate inputs, not independent
gate fixtures.

| Namespace | Added | Modified | Deleted |
|---|---:|---:|---:|
| check | 17 | 0 | 0 |
| compile | 7 | 0 | 0 |
| comptime | 1 | 0 | 0 |
| flatten | 5 | 9 | 0 |
| halt | 0 | 1 | 0 |
| import | 2 | 0 | 0 |
| io | 28 | 21 | 4 |
| parse | 2 | 0 | 0 |
| printer | 0 | 2 | 5 |
| proof | 10 | 0 | 0 |
| reg | 9 | 1 | 0 |
| run | 2 | 3 | 0 |
| stats | 0 | 1 | 0 |

The maintained JS eligibility rule selects 1,170 new fixtures: 1,071 classified
as pure, 39 foreign, 36 network, and 24 scheduler cases. These are static scope
categories; eligibility does not imply runtime availability or a passing result.
Network, Bun-specific provider, timeout, and hardware limitations must remain
visible in execution reports. The ordinary checker and declaration-trust verdict
are distinct from upstream's Lean proof kernel. GPU and Lean execution are not
claimed by this migration.

The first [25-source screen](../../selfhost/tools/performance/phase66/controls/inventory01/screen25-rationale.json)
covers namespace/member collisions, Array writes, flatten diagnostics, dependent
checking, rewrites, proof arrays, boxed words, deep marshalling, tail application,
foreign constructor identities, and effect refusal. It requests 50 parse/check
observations and 23 eligible JS observations per compiler/reference pairing.

The full comparison uses the old compiler with the old 1,513 fixtures, the new
TypeScript reference with all 1,587 fixtures, and the migrated Bend compiler on
those same 1,587 fixtures. Report parse and check separately: a negative parse
observation is not successful type checking. Compare formerly passing common
fixtures explicitly, separating new coverage, intentional changed oracles,
pre-existing gaps, runtime exclusions, crashes, and timeouts. The familiar small
96/34/18/2 suites are useful controls, not substitutes for this full inventory.

## Reproducible staging

[prepare-conformance-v3.py](../../selfhost/tools/performance/phase66/controls/prepare-conformance-v3.py)
clones the exact frozen attempt's tools, runtime, and source manifest into a fresh
Phase66 directory, then copies its qualified API unchanged. Each recipe binds
the compiler image, reference revision, Base bytes, Node binary, and every
copied input. Changing the private harness inventory pin does not re-label the
compiler image's lineage. The new TypeScript adapter's declaration display uses
the actual upstream `name_key`; trust propagation still uses internal keys.

Parse/check use one persistent worker. JS requests use isolated workers because
the persistent adapter intentionally supports only parse/check. Each command is
serial CPU3 with a 1 GiB Node heap, an RSS guard, a deadline, and retained outputs.
Exit 1 can mean a completed conformance mismatch and must be interpreted from
the report, never converted into either a blanket pass or a missing result.
The initial copied-file identities precede intentional harness edits; the
recorded `harnessManifestAfter` and `adapterDisplayChange` describe current bytes.

The first old full frontend attempt stopped before any probe: the resource
supervisor deliberately clears `BEND_*`, and the first factory had placed the
environment outside that supervisor. Its recipe and failed output remain
unchanged. The explicit v2 successor sets the environment inside the guarded
command and also publishes conventional API/Base paths with identical bytes.
The corrected recipe is staged at
`selfhost/build/phase66/conformance-old-full02/recipe.json`, using the qualified
Phase65 State10 B1. It closed with all 3,026 observations and stable inputs:
1,016 positive parse passes, 497 negative parse observations, and 1,509 exact
check passes out of 1,513 checks. There were no crashes, timeouts, or unsupported
observations. The four check mismatches are `io/cid_unknown`,
`io/effect_ctr_name`, `io/main_foreign`, and `reg/array_open_element`; each has a
later compile/IO-layout rejection oracle but is accepted by the ordinary checker.
These are phase-triage items, not established type-checker gaps. Exact old
TypeScript full comparison subsequently closed with **3,026/3,026 identical
normalized observations**, including the actual results behind all 497 negative
parse labels. Both compilers have the same four later-stage check mismatches.
The [exact join](evidence/conformance-old-paired.json) preserves both closed reports
and their compiler, harness, Base, and reference identities.
Applicable JS execution remains a separate gate.

[compare-conformance.py](../../selfhost/tools/performance/phase66/controls/compare-conformance.py)
summarizes only closed, stable reports with exact unique requested-row coverage.
It keeps missing reports pending and distinguishes exact status changes from
type acceptance and declaration-trust refusals. A closed observation containing
mismatches does not become a passing conformance claim.

The maintained typed adapter's historical `js` lane selects the legacy backend.
For the full primary-JS comparison, v3 makes the ordinary driver's `direct`
selection explicit in a private adapter copy. Legacy JS and native source
controls remain separate. It also corrects the reference wrapper's new upstream
declaration-trust rule: an ADT's own kind and parameter type must be traversed
alongside constructor types. `check/unsafe_kind` and `check/unsafe_kind_def` are
focused witnesses; Bend already included this dependency through `dt(d)`.
The new selected B1 and new TypeScript full frontend runs each completed 3,174
observations. [Complete normalized comparison](evidence/conformance-front-paired03.json)
finds **3,174/3,174 identical results**, including rejection text, declaration
verdicts, type acceptance, and proof-trust fields. Both have 1,082 positive parse
passes, 505 observed negative parses, 1,583 check passes, and the same four
type-accepted fixtures whose rejection belongs to a later backend/runtime stage.
There are no crashes, timeouts, or unsupported observations in this frontend
census. Across the 3,008 observations shared by the old and new inventories,
no previously passing row loses its pass status. The 31 changed complete results
are upstream-aligned diagnostic/declaration changes, not new discrepancies.

The final04 image has exactly the same selected API, raw checked API, assembled
Bend source, Base, 99 roots, and direct runtime as the tested03 image. The
[explicit reuse audit](evidence/conformance-final04-frontend-reuse.json) rehashes
all 313 frozen files, proves the only changes are the newly qualified Base
annotation hash and one Foreign Array expression in two legacy runtime files,
and binds a fresh passing strict36 validation. Persistent parse/check never
requests annotation products or executes those runtime files. This narrow audit
reuses the frontend observations only; it makes no backend or performance claim.

Fresh final04 primary-direct-JS and new TypeScript recipes each request 1,170
observations; those results remain pending. The direct recipe includes all 25
surviving IDs from the historical direct26 selection. Its remaining printer
fixture was deleted upstream and is explicitly excluded rather than counted as
a pass. Fixture, independent judge, driver, API, and selection identities are
pinned in `selfhost/build/phase66/direct-census-subset-plan.json`.

## First complete primary JavaScript comparison

The selected04 Node campaign closed all 1,170 probes with stable inputs. Its
results are evidence for the unchanged JavaScript closure in selected05; they
are not a declaration that all applicable programs conform.

| Independent fixture judgment | TypeScript | Bend |
|---|---:|---:|
| Pass | 990 | 984 |
| Failure | 6 | 61 |
| Unprintable main, not applicable | 123 | 123 |
| Unavailable Bun provider | 51 | 0 |
| Ten-second probe timeout | 0 | 2 |

The two adapters classify unavailable `bun:ffi` differently: the reference
reports unsupported, while Bend reports a runtime error. Those same 51 provider
limitations account for 51 Bend failures; they are not 51 independently
established code-generation defects. Five further failures are shared platform
effects: three libc error-message differences and two providers requiring
`Bun.spawnSync`. Bend passes the separate NaN fixture whose TypeScript result
disagrees with the golden value.

Seven fixtures pass TypeScript and expose a Bend gap in this first campaign:
`check/meet_at_run_time` and `check/meet_uses_in_arms` reject the runtime `Min`
term; `reg/arity_wall`, `reg/wide_record_drop`, and `reg/wide_record_stale` refuse
bounded tail-call analysis; `reg/const_shared_layout` and
`reg/show_shared_layout` exceed the whole-probe ten-second deadline. The latter
does not identify which compilation or execution stage exhausted the deadline.
All seven remain explicit pending focused correction and fresh validation.

The data-only comparison is
`selfhost/build/phase66/conformance-primary-js04.json`; the full provenance and
frontend/direct-subset join is
`selfhost/build/phase66/conformance-lanes05.json`. The join deliberately has no
global conformance-pass flag. The 123 unprintable-main exemptions come from the
unchanged fixture judge, not a new exception introduced for this campaign.

The separately reviewed Bun replay selects the union of missing-FFI runtime
rows plus those exact five platform failures. It copies retained emitted
modules, invokes neither compiler, and applies the same independent fixture
judge. Both roles must have checked runtime provenance. Graphics/device rows
remain explicit deferrals; missing artifacts, failed output, and timeouts cannot
be counted as passes. Its result supplements the immutable Node campaign.

The first focused Bun run has now closed: 56 selected fixture IDs, 55 paired
executions, and 110 program actions. **54 fixtures pass both original goldens**.
`io/process_run` has the same output mismatch in both compilers for inherited
pipe and descendant-output behavior. `gfx/app_linear` remains explicitly
deferred under the conservative graphics policy. There is no candidate-only
failure in this supplemental run. Its raw receipt is
`selfhost/build/phase66/bun-replay01/report.json`; the original Node counts above
remain unchanged.

## Selected07 follow-up

All seven candidate-only gaps pass a fresh complete 1,170-probe Node campaign
after the focused fixes: **991 pass, 56 platform failures, 123 not applicable,
and no crashes or timeouts**. Every one of the reference's 990 passing fixtures
now passes Bend; Bend also passes the NaN fixture. There are 1,118 completely
identical normalized observations. The remaining 52 observation differences are
the 51 unavailable-FFI classifications and that NaN improvement.

The fixes have different causes. Runtime quantity meet is erased to `null`,
matching the actual TypeScript output. Wide-record call analysis now counts
fields within its existing scan bound instead of rejecting every record wider
than 64 fields; it preserves the original body-scan budget and still refuses an
incomplete analysis. Printability now carries successful visited types across
sibling fields and constructors, avoiding exponential rechecking of shared sum
types. Cyclic types with an invalid later field still reject. The first
printability build failed on local-match syntax; its report remains intact, and
the corrected parameter helper was rebuilt and checked before this campaign.

Frontend reuse is supported by an exact executable dependency audit, not by
claiming the compiler image stayed identical. Between selected05 and selected07,
the generated runtime, all 99 API wrappers, and all **1,403 functions reachable
from 51 conservative frontend API roots** are byte-identical. The 13 changed or
new backend functions are unreachable from the persistent parse/check path.
Combined with the earlier exact host/native-only transitions and fresh strict36,
this preserves the full 3,174-observation frontend evidence. The proof is
`selfhost/build/phase66/conformance-final07-frontend-reuse.json`.

The [compact conformance summary](evidence/conformance-final07.json) records
the final lane join, `selfhost/build/phase66/conformance-lanes07.json`
(SHA-256 `e1a91ac309ac69f8d5c3ac6261ad9265edb8bf013e635cbc5e228d602727db06`).
It verifies the selected image, all completed lane inputs, the 25 surviving
historical direct cases, and the supplemental runtime evidence. Independent
source reviews preceded the data-only join; it reports no unexplained
candidate-only gaps while retaining every unsuccessful primary observation.

The [Bun transfer audit](evidence/bun-reuse-final07-v1.json) independently proves
that all 55 previously executed pairs retain identical emitted modules and
payloads, along with all 50 JavaScript runtime/provider files. It transfers the
54 paired passes and the one shared failure; it does not invent another 110
executions. The graphics deferral remains. The explicitly mixed Node/Bun union
therefore covers **1,045 golden-passing fixture IDs for Bend versus 1,044 for
TypeScript**. The remaining inventory comprises 123 unprintable-main exemptions,
one shared process fixture failure, and one graphics deferral. These are finite
fixture results, not full-language, mathematical-proof, native, or GPU claims.

## Source review findings

The TypeScript kernel delta changes namespace spelling, diagnostics, Array-write
syntax, flattening errors, and template memo representation. It does not add a
new core type-checking algorithm. Larger changes in `safe.ts` and `bendtt.lean`
must not be mistaken for new capabilities of our ordinary checker.

The isolated [checker display patch](../../selfhost/tools/performance/phase66/controls/checker-names-v1/candidate.patch)
wraps nine user-facing names with `name_key` in three existing files. It adds no
line, type, or branch and leaves raw lookup, family, and equality identities
unchanged. The frontend owner independently verified that removing the wrappers
recovers the original files exactly.

The first new checked B1 exposed two maintained harness omissions: its frozen
host did not copy the driver's `base-cache-graph.mjs` dependency, and the reference
adapter still printed internal colon names in declaration verdicts. The latter
caused four actual reference failures among the 36 focused checks. The same
display omission remained in Bend's `dr_lines`. The follow-up
[three-line patch](../../selfhost/tools/performance/phase66/controls/harness-closure-v1/candidate.patch)
adds the missing frozen dependency and applies `name_key` to both verdict text
renderers. It preserves raw unsafe-definition metadata and the trust algorithm.
Root applied these exact reviewed bytes; the failed prior validation remains
unchanged, and the Bend display correction requires a newly built API.

Independent review approved the frontend source candidate and its 54 name/display
plus 19 parser controls, including imported member collisions and UTF-16 source
slices. The marshalling review checked the shared LIFO work stack, ADT copying,
Array in-place updates, scalar/callback order, recursive converter registration,
and preserved fallback budgets against the actual new TypeScript implementation.

That review found one real migration defect before a target build: the first
host candidate retained eager missing-effect registration checks at module load.
New upstream intentionally reports a missing registration only when its request
executes; `io/effect_unregistered` must print `before` first. The host owner removed
the eager check and its dead helper in the preserved v2 candidate. Duplicate
registration remains checked by the runtime. Source review of v2 passed; runtime
controls are still required.

The four bootstrap factory successors were independently replayed byte for byte
from their frozen parents, including each counted edit and source hash. They use
a genuine checked B1 for the new TypeScript runtime, preserve all 99 requested
exports, require the new upstream and Base identities, and retain tiny split vs
unsplit output equality. They do not re-label an old equality-profile image as a
new compiler generation.

The native-source follow-up exposed two C boundary incompatibilities after the
actual Clang toolchain was supplied: current foreign sources use two-argument
`io_eff` registration and Corpus-based `term_peek`/`blk_loc` helpers. Independent
review approved the isolated 19-line host-only compatibility shim. It routes
memory access through the retained runtime's existing shared-cell/acquire logic;
the temporary `Env` allocator field is unused by those helpers. Immediate
two-argument registrations use `need=0`, while existing readiness/timer callers
retain their third argument. The replay method binds both actual failed emitted
C modules and changes only that insertion, preserving independent stdout goldens.
This source review is not a fresh-emission or general native-conformance result.

The adjacent blocking-effect review covers `Chan.send` result ownership,
TCP `Some`/`None` receives, TCP failure suffixes, UDP failure datagrams, and
zero-size UDP refusal. Closed and parked channel senders must receive their
original unsent value in `Fail`; the old drop operation must not run after that
transfer. Invalid byte lists must be checked before consuming them. The eight-file
candidate satisfies these source invariants and preserves the existing immediate
zero-size TCP refusal. Eleven new timed/try handlers and two UDP byte handlers
remain explicitly unavailable on the retained native scheduler; their named
refusal occurs only when an unregistered request executes. They are not counted
as native conformance passes or as gaps in the primary JavaScript backend.
