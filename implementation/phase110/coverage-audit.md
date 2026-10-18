# Phase110 source and independent workload coverage

The first expanded controls were frozen at **2026-10-18 19:05:48 UTC** from
baseline `7fc45f3e44498ad6d55cf7fd3784f2bd1035612e`, before candidate execution
or selection. This source audit and data preparation execute no compiler or
generated target. Root's separate receipts establish actual admission, semantics
and timing; preparation alone establishes none of those results.

## What is broader

The [manifest](../../selfhost/tools/performance/phase110/controls/manifest.json)
pins 29 new ownership graphs: 11 training and 18 held-out. Existing Phase109
thirteen-case reverse controls and separate discard/duplicate oracles retain
their exact bytes and hashes. They remain regressions, not fresh held-outs.

New graph dimensions include deep **String** traversal as well as deep lists,
65,536 and 65,537 elements, unique and held-root paths, interior held tails after
16,381 nodes, held opaque heads, two aliases to the same root, long String heads,
nulls and Unicode scalar boundaries, combining marks, and static roots/tails.
Static cases stay within the fixed 128-word arena; deep static input is not
silently claimed. Retained aliases are observed after dropping the worker result,
then independently dropped. Every repetition checks allocator release and
agrees with its first result/aliases; captured complete output must match the
independent frozen oracle separately.

Actual `front/lexer.bend` and `back/native/text.bend` bytes are snapshotted as
character-string and line-list datasets, each with unique/shared graphs.
Training uses lexer contents; held-out uses native-text contents. These inputs
are source-derived replay for physical profiling, **not an observed distribution
of compiler allocations or runtime hotness**. Equal dataset weighting is an
experimental objective, not a whole-compiler performance projection. The old
four-string deep list remains a useful ownership control but cannot alone
represent compiler workloads.

The independent reference uses ordinary Python sequence semantics and the
pre-existing FNV-1a64 observation contract. Reverse, discard and duplicate each
have 29 expected observations; actual Base tail/last and prospective append each
have 15 list observations. A digest and zero outstanding allocator words are
finite observations rather than an ownership proof.

## Four real source computations and their admission requirements

Exact declaration bodies, whole-source hashes and source lines are frozen under
[controls/sources](../../selfhost/tools/performance/phase110/controls/sources).
The imported Base fixture makes the first two actual declarations reachable;
it does not replace their bodies by equivalent host or renamed source code.
The original whole-source hash is authoritative for preceding annotations such
as `nt_append`'s `@unsafe`; body snapshots alone are not standalone checked units.

| Computation | Checked/live facts required | Owned operation shape and boundary |
| --- | --- | --- |
| Base `List.tail<&2,String>` (`base.bend:941`) | Erase quantity/type parameters; live arity 1; parameter and result `List<&2,String>`; Nil 0 live fields, Con 2, opaque String head. | Branch/Take; empty returns Nil; nonempty sinks head and returns tail. Existing operation subset fits, but a new authenticated one-argument entry is needed. It tests removal and surviving subgraphs without rebuild fusion. |
| Base `List.last.go<&2,String>` (`base.bend:948`) | Erase quantity/type parameters; live arity 2; parameters are **List and String**, result String; same constructor catalogue. | Empty returns accumulator; nonempty Take, sink prior accumulator, self-tail `(tail, head)`. Existing subset fits. The input/result ABI roles differ from reverse and must not be inferred from two-machine-word arity. |
| Compiler `nt_append<String>` (`text.bend:46`) | Erase `-A`; live arity 2; list result; authenticated `nt_reverse` dependency/signature plus ordinary call effects. | Exact source is `nt_reverse(A, nt_reverse(A,xs,Nil{}),ys)`. It requires ordered nested-call evaluation and owned ordinary-call transfers. Existing lowerer refuses it; the frozen `xs + ys` oracle must not be implemented as a C shortcut. |
| Base `String.drop` (`base.bend:2021`) | String plus Nat parameter; Nat `Zero`/`Succ` representation and erased unary live field; multi-scrutinee matches. | Self-tail drop differs from reversal, but current fixed catalogue permits only 0/2-field List/String constructors. Add authenticated unary/Nat representation before claiming admission; neither a raw U32 replacement nor name-specific lowering is justified. |

`List.tail` is an O(1) worker whose dropped head may itself be long. Timing it on
a long list does not turn it into an O(n) list walk. `List.last.go` actually walks
the list and releases earlier heads/accumulators. Neither has the reverse
Take/Build/Tail fusion shape, so no fusion gain should be assumed. Both widen
semantic coverage without claiming general non-tail calls or tree support.

Source-only authority remains mature checked erasure:
`back/native/erase.bend:nc_erase_app` removes arguments from checked telescopes;
`nc_erase_annotated` retains live constructor fields; `nc_erase_mat` records live
field count as match id `count + 1`; `back/native/request.bend:nr_walk` stores
`NativeErasedBody` and live arity. Phase109's lowerer checks that match field count
against the explicit constructor catalogue and verifies ownership before Nx
construction. A captured tag named `NativeErasedBody` is not authentication.
Bind every new selected entry to source, checked graph, erasure and ABI roles.

## Runtime preparation and search discipline

[prepare.py](../../selfhost/tools/performance/phase110/controls/prepare.py)
authenticates all frozen inputs and renders graph initializers. It extends the
Phase109 harness with repeated String patterns and explicit tail/last/append
entry shapes. C performs graph setup/observation only; no Bend worker algorithm
is translated into the harness. Initial prepared directories are
`selfhost/build/phase110/controls-{reverse,tail,last}01`.

The [bounded policy search](../../selfhost/tools/performance/phase110/controls/policy-search.json)
predeclares twelve choices: fused/tagged/specialized/pair crossed with
QBE/Clang-O2/GCC-O2 on a common cached GCC runtime. Rank all candidates against
the **same unchanged fused-QBE denominator**. Also report matched-backend ratios
for attribution, but comparing ratios with different denominators must not
select a slower backend. Report the QBE winner separately from the absolute
twelve-choice winner. Unavailable choices remain explicit in the search record.

Training and held-out timed lists are fixed before measurement. Selection uses
equal-workload geometric means of median paired alternating rounds, with a
3% minimum improvement and consistent direction; inconclusive results retain
the incumbent. Held-outs are read after freezing a winner, without tuning or
repairing it afterward. Record build/validation/search cost, acquisition/cache
distinctions, code size and allocator behavior. A faster kernel is not evidence
of faster research or full-compiler speed.

## Next coverage increments

1. Authenticate and execute tail/last with the complete expanded ownership
   matrix; retain source/type/arity errors as rejected attempts.
2. Implement generic direct-call ownership transfer and checked dependency
   closure for unchanged `nt_append`. Compare full append work and all retained
   aliases, including empty left/right lists. Preserve its two traversals as
   source semantics rather than attributing them to frontend overhead.
3. Generalize checked constructor descriptors, then admit Nat/unary matching for
   `String.drop` and `List.drop`. Add independent zero/in-range/past-end counters
   and sharing between input and count graphs where legal. `take` additionally
   needs a non-tail return continuation and is a separate gate.
4. Choose a measured scanner or tree consumer only after ordinary calls and
   descriptors work. `f_scan_word` additionally requires Char predicates,
   `FScanned` products, counters and lazy choices; a tree walk needs richer ADT
   layouts and traversal continuations. Preserve these concrete refusals rather
   than treating another reverse fixture as their substitute.

## Ordinary-call extension frozen before its implementation

At **19:10:55 UTC**, a separate
[call manifest](../../selfhost/tools/performance/phase110/controls/calls/manifest.json)
freezes exact annotated compiler `nt_reverse`/`nt_append` declarations and twelve
fresh append graphs. Six training/six held-out cases add independently owned
arguments that physically share a root or suffix, aliases into both arguments,
static suffixes, 65,536-node shared roots and an odd 65,537-node tail split.
The runtime harness obtains those extra claims through production `keep`, updates
the input when a root keep returns a new handle, and asserts an interior sealed
child retains its handle. The worker body is never implemented by C or Python.

The minimal general extension has one operation:
`Call(dest, callee, owning_arguments)`. A callee catalogue binds its source
identity, authenticated checked-erased body, live signature and machine symbol;
every target must be present in the verified emitted library or a separately
declared import with matching ownership effects. Function names select bodies,
not special algorithms. Matching machine U64 widths alone is insufficient to
prove List/String/result roles; source-bound checked signatures supply that fact.

The credit transition consumes one claim for **each argument occurrence**, checks
that the destination does not overwrite a live owner, and creates one claim for
the returned owned Term. Passing one binding twice requires a prior keep. The
callee consumes its argument claims on all normal exits. A declared fail-stop
does not return; it must not manufacture a valid ownership continuation.

Nested source calls evaluate argument expressions in explicit left-to-right
order and preserve every owner needed by later arguments or the continuation.
An ordinary call is an effect barrier: invalidate borrowed/discriminant facts
and require no pending scratch transfer across it. The returned owner may feed a
constructor, another call or Return. Returning a different function's call is
not a self-tail move; the generic Nx direct call provides its ABI transition.

For the actual append body, the expected source-connected operations are:

```text
Build Nil -> empty
Call reverse(xs, empty) -> reversed
Call reverse(reversed, ys) -> result
Return result
```

`ys` remains live across the first call. Each temporary receives exactly one
subsequent consumer. The two reverse traversals follow the real source; no
append-name recognition or host concatenation lowering is permitted. The
existing fixed List/String descriptors suffice. Generalizing arbitrary ADT
catalogues, Nat/unary constructors, indirect calls and scheduler effects is a
separate extension with its own evidence.

At **19:12:44 UTC**, the supplemental
[source-shape manifest](../../selfhost/tools/performance/phase110/controls/calls/shapes-manifest.json)
freezes identity, call-inside-constructor, nested argument calls with sharing,
dead-input sink and one binding used twice. Dynamic/partial calls are expected
refusals. Missing/duplicate callees, wrong arity/roles, absent emitted targets,
zero-credit arguments and live destination overwrite are declared mutation
gates. They remain expectations until root executes the corresponding checks.

## Independent audit of private runtime IR and physical aliasing

The next source-only inspection covered `runtime-ir/{lower,library}.bend` and
`runtime-ir/adapter.inc.c`, the complete reconstruction model/reference, and existing
operation/worker controls. It found no concrete semantic defect in the inspected
fast-path template. That is an inspection result, not target qualification.
Six limitations distinguish the experiment's evidence:

1. **The law's cells are separately accounted.** Its full-result equality
   preserves arbitrary external root counts for each abstract cell, but it
   excludes two records denoting one physical refcount cell. An incoming `other`
   may legally be the remaining String tail, or contain a second edge to the
   retained String. Those DAGs require runtime evidence beyond the current law.
   Identical nontrivial first/second children are generally ill-typed in the
   fixed List<String>/String catalogue; a fabricated malformed graph would not
   be a valid counterexample to source admission.
2. **A static object can have a heap redirect.** Sealing a static String inside
   a dynamic constructor allocates an RFC cell. Its top-level location is then
   dynamic while the decoded object is still static. The inspected classifier
   correctly requires decoded `ir_src >= HEAP_OFF` after seeing count one.
   The new sealed-static-parent control distinguishes this from ordinary raw
   static roots and requires the original static contents to remain unchanged.
3. **Last-owner redirects are a separate allocator transition.** Count one
   permits object-shell reuse but requires freeing its separate RFC cell.
   A subsequent seal may immediately allocate that same class0 cell. The
   template loads both children before freeing the redirect, then seals both
   rebuilt fields. Explicit last-owner and class0-empty/handoff controls make
   these ordering and allocator obligations observable.
4. **Template equality proves correspondence to a generator, not its memory
   correctness.** Private verification recomputes the entire machine graph
   from verified owned operations and compares canonical serialization; public
   Nx still rejects arbitrary memory. A wrong but consistently regenerated
   heap template would pass that equality. Source authentication, exact runtime
   layout, valid owned inputs and the actual memory transition remain separate
   premises tested by the C/IR differential controls.
5. **The fast path is explicitly single-threaded and layout-bound.** An aligned
   64-bit RFC read is justified only without concurrent mutation; the atomic
   view profile preserves the existing helper for attribution. The exact heap
   threshold, class0 allocator offsets, count bits and single active context
   are material assumptions. Cached heap pointers remain stable under the
   inspected `corpus_grow`, which extends the same base address. No GPU,
   concurrent-reference-count or arbitrary-runtime compatibility follows.
6. **The worker clock is a small fraction of evaluation cost.** The complete
   first search records 247.683 s wall, 241.375 s summed child-process wall and
   6.734 s worker clocks—2.79% of process time. The remaining time includes
   graph setup, alias creation, observations, release, context management and
   process startup. Without per-stage clocks it cannot all be labeled graph
   construction, and worker speedup does not establish faster research loops.

The [supplemental audit](../../selfhost/tools/performance/phase110/controls/audit/manifest.json)
freezes seven concrete graphs across six families at **19:20:34 UTC**, with two
release orders each. They use complete short values, not hashes. Three graphs
are training controls; four graphs/eight observations are fresh held-outs for
this new candidate boundary. Earlier held-out workloads are reused regressions.
The baseline C pair helper and IR probe consume exactly the same prepared
graphs. Probe emission shares the actual classifier/rebuild generator; the
probe's scratch transfer is test-only and is not timed source-worker machinery.

## Faster follow-up measurement without changing the original experiment

[fast-loop-v2.json](../../selfhost/tools/performance/phase110/controls/audit/fast-loop-v2.json)
freezes a new schedule for direct-constructor/private-IR candidates. It leaves
search01, its twelve choices and all completed observations unchanged. Per-case
repetitions are `clamp(ceil(0.005 / median baseline seconds per repetition)),1,100`
using only the frozen search01 fused-QBE rows. For the same seven training
workloads this yields **6, 3, 6, 1, 7, 1, 3**, with unchanged contents, ownership,
weights and three alternating rounds. The two source-list workers already take
about 5.6/6.8 ms per traversal, so their previous ten repetitions repeated large
setup and observation costs unnecessarily for a short screen.

Linear scaling of existing process observations predicts about 32.9 s instead
of 241.4 s for the same candidate count; this is an optimistic estimate because
it also scales fixed overhead. It is not an observed speedup. New source/build,
validation and complete campaign costs remain separately chargeable. A faster
new worker may need longer confirmation; close or sub-millisecond results stay
inconclusive instead of being silently given more favorable samples.

Do not cache or share String heads across fixture repetitions: that changes the
physical graph and can move a unique path to shared ownership. Add setup,
observation, release and context clocks only in a new harness version. Keep the
old ten-workload held-out geometric mean intact, including
`list-long-head-shared`: despite long String heads, that reverse worker traverses
only four list cells, so its very short timing ratio can be noisy. Flag it and
provide a separate diagnostic aggregate if useful, without replacing the frozen
ten-case denominator or treating those reused workloads as fresh held-outs.

## Actual-source call shapes and generic continuation witness

The [call-shape execution manifest](../../selfhost/tools/performance/phase110/controls/call-shapes/manifest.json)
freezes a direct six-export harness at **19:32:02 UTC**. It retains the five
previously frozen source shapes and two source refusals, then adds the explicit
synthetic `p110_reverse_via_call` witness. Its nonempty branch takes a node,
builds its head onto the accumulator, and ordinarily calls the actual compiler
`nt_reverse` on the remaining tail. Thus its complete meaning is reverse plus
accumulator while its owned sequence is Take/Build/Call/Return, broadening the
continuation shape beyond self-tail fusion without any name-based optimization.

The JSON catalogue lists eight exact source identities, live arities/roles,
cross-function dependencies and six exported machine symbols. Python/JS may
select captured facts using that data; generic call lowering remains in Bend.
The 28 C harness cases invoke those generated exports directly and observe full
short Unicode sequences, aliases after result release and zero live heap words.
Empty/unique/shared/static inputs and physical overlaps between arguments are
included. Eighteen cases are training and ten held-out. No IO-wrapper execution
or hand-written C implementation substitutes for the actual worker calls.

## Inline Take2 follow-up

The [take audit manifest](../../selfhost/tools/performance/phase110/controls/audit/take-manifest.json)
freezes twelve graphs/twenty-four observations at **19:35:14 UTC**. The inspected
general template loads both children before releasing the last-owner redirect
and class1 shell; shared and static cases fall back before mutation. New
controls separately exercise raw, redirect-count-one, shared, static and
heap-wrapped static parents, plus a List whose opaque String head also appears
inside its tail list. Both child-drop orders preserve surviving owners.

Class1 tests construct ordinary one-character padding roots until the actual
free list is empty or its word length is exactly 32,766. Taking the two-word
parent must respectively leave one two-word hot shell or hand the full 32,768
words to cold storage. Only allocator metadata reads are used in preparation;
no free-list or heap state is fabricated. These are operator correspondence
checks, separate from the actual Base tail/last source executions and from any
abstract ownership law. Root's target receipts determine their actual status.

## Typed entry certificate boundary

The [admission controls](../../selfhost/tools/performance/phase110/controls/admission/manifest.json)
freeze fourteen reachable source entries and twelve adversarial recipes at
**19:43:55 UTC**. Canonical String and List<String> identities and mixed-role
signatures have positive entry expectations. List<U32>, Nat, U32, a user
datatype with the same constructor arities, a type alias, erased dependent
parameters, a function parameter and a function result have negative narrow
certificate expectations. All of those are intended valid language sources;
an additional reachable String-returned-as-List source is a source-check
failure, kept separate from certificate refusals.

The independent oracle distinguishes a concrete entry signature from a fully
certified closed library. The concrete reverse wrapper has List<String>
parameters and result, but its unchanged generic compiler `nt_reverse`
dependency has an erased type parameter. A host List<String> assertion about
its two erased owning words cannot replace checked specialization. The first
certificate grammar must refuse that generic dependency. Conversely, source
arity must stop telescope traversal before a function-valued result; treating
that result as one more input would misclassify a closure as a data worker.

Descriptor recipes independently change constructor identity, element role,
type arity and recursive binder reference. Exact Base name strings and matching
field counts alone do not prove the concrete runtime representation. Original
typed source authentication, canonical type structure and the corresponding
Base constructor provenance must all agree before erased facts may use the
specialized ABI. Frozen expected verdicts are not observed checker results.

Source inspection of the ordinary-call pass confirms left-to-right nested
argument staging, separate ownership-credit and closed-callee checks, and
whole-library Nx verification. It does not add source role checking by itself:
the old caller-owned catalogue supplies arities and symbols, and all owning
words share a U64 machine representation. The new typed-entry boundary is
therefore necessary for broadening beyond the previously authenticated fixed
source contract. Inspection of the generalized private runtime templates found
no new discrepancy in the child-load-before-free order, last-owner/static
classification, or class1 allocator transition; concrete graph probes remain
the separate physical correspondence check.

## Historical disk cleanup proposal

The [cleanup proposal](cleanup-candidates01.json) authenticates three retained
Phase107–109 evidence archives and each proposed local file against its exact
archive member. It proposes 12,000 non-executable historical output files:
150.18 MiB content and 183.89 MiB allocated blocks at inspection. Generated
graphs/C/objects/assembly account for 128.18 MiB allocated; optional archived
receipts and other text account for 55.71 MiB. All executable files, source and
capture directories, toolchains, production runtime snapshots and current
Phase110 outputs are preserved. The large unarchived compiler C files are
excluded. This is a proposal only; no deletion was performed by the auditor,
and root must recheck each file immediately before any removal. Historical
direct paths removed under this proposal require restoration from the retained
capsule before reuse.

## Loop timing instrumentation

The separately versioned [loop-accounting harness](../../selfhost/tools/performance/phase110/controls/loop-accounting/manifest.json)
was prepared at **19:48:05 UTC** from the exact frozen `train01/harness.c`.
Original fixture bytes, expected observations and ABI header are copied
unchanged to `selfhost/build/phase110/loop-accounting01`. Every original line
except the extended stderr format remains an ordered subsequence, and the
worker call and its original two clock statements remain a contiguous exact
substring. All scratch, alias-after-result-release, repeated-result and zero
live-word checks remain in place. This changes only instrumentation, not the
completed policy search or workload lifecycle.

The new integer-nanosecond phase ledger separates context open, graph/alias
setup, worker envelope, pending check, observation, result/alias drops,
live-accounting/context-close, and loop checks/stdout bookkeeping. Both the
harness and the independent saved-output checker require exact reconciliation
of phase sums to first/last partition marks, then to separate outer marks plus
an explicit residual. Independently recorded process wall time may be supplied
to expose startup, selection, final formatting/flushing and teardown costs.
The original workerSeconds remains the narrower worker clock; the enclosing
phase includes clock/accounting overhead and must not replace it for ranking.
No instrumentation target was executed during preparation.

## Consumed-wrapper spare controls

The [wrapper-spare audit](../../selfhost/tools/performance/phase110/controls/audit/spare-manifest.json)
freezes seven graphs/fourteen complete-value observations at **19:50:55 UTC**.
It independently checks raw dynamic and raw static external fields, including
both at the class0 32,767-word handoff boundary. Candidate-only assertions require
the output field to own the consumed parent redirect itself, with count one
and the correct decoded target, while class0 HOT/LEN/COLD remain unchanged.
The retained String head is scalar, so its unchanged seal cannot allocate and
obscure that invariant. A static external constructor still requires a wrapper.

Other cases supply an existing external redirect at count one or two, or a
shared parent with an external alias. Those are ineligible for wrapper donation:
the existing other word stays unchanged and the parent wrapper is freed
normally, or the shared parent wrapper remains attached to its original target.
Both result-drop orders observe all survivors and external aliases before the
zero-live-word gate. Four observations are training and ten are new supplemental
held-outs. The semantic oracle also applies to the existing production helper;
the spare-specific allocator/identity assertions apply only when explicitly
enabled for the candidate probe. No execution was used to derive either.

## Independent admission trust review

The [source-pinned trust review](../../selfhost/tools/performance/phase110/controls/admission/trust-review.json)
separates structural admission from authenticated provenance. `nxe_entry` checks
canonical roles/descriptors plus source/fact name and arity, then retains both
records. It does not establish that an arbitrary erased body was derived from
that typed source. Same-name/same-arity body substitution and a forged declared
source arity illustrate why the caller must authenticate both products of one
checked request. A serialized certificate or a `native=true` field cannot
replace that boundary. Exact Base bytes also supply the U32/Word/native-scalar
provenance beyond the String/List/Char descriptors explicitly traversed here.

The initial `nxe_plan` adapter creates `p86_plan` itself and compares its seed's
Base FSource name, path and complete text with trusted asset values. However,
`f_seed_matches` does not authenticate the seed's book, ready state or prepared
world: those still require the mature factory. The current fixed-contract
native frontend also remains separate from this prototype and delegates
runtime Base/cache byte authentication to its launcher. The IR agent's then-pending
live factory therefore compares read Base bytes with compiled exact assets and
constructs preparation internally, without accepting a raw seed from callers.
That new factory was pending at this initial review; the subsequent review
below covers its implemented boundary.

`admission/check.mjs` currently checks fourteen entry expectations and nine
explicit malformed-data cases. It does not execute the twelve recipes in the
original oracle as a set, evaluate `closedLibraryAccepted`, or check the
separate ill-typed source. Its completion flag must consequently remain an
entry-probe result. Additional transport hardening should explicitly require
the expected capture kind and successful type/status fields, alongside the
existing exact product/source/Base hashes. The frozen new recipes distinguish
malformations the structural helper should reject from substitutions that the
authenticated factory must make impossible.

The [closure source controls](../../selfhost/tools/performance/phase110/controls/admission/closure-manifest.json)
were frozen at **19:55:50 UTC**. Four positive roots exercise separate List and
String dependency chains, mixed-role constructor arguments containing calls,
and a diamond that discards one owning result. Two roots have valid canonical
entry telescopes but must fail complete closure admission: one reaches generic
`nt_reverse`, the other a private Char identity. Every reached private callee
must receive its own role certificate from the same request, even when it is
not exported. Requested roots define the admitted closure; the source's IO
observer must remain outside it. Missing/duplicate dependency facts, exported
symbol collisions and a bounded-traversal refusal are separately declared.
No target or compiler was executed for this review or the new controls.

## Fresh final-selection held-outs

The [new final corpus](../../selfhost/tools/performance/phase110/controls/final-heldout/manifest.json)
was frozen at **20:02:20 UTC** with eleven new `final-` graph names and two
repetitions per workload. Seven inputs cover Unicode scalar boundaries, NUL,
combining/supplementary characters, deep odd lengths and List/String unique,
root-shared, tail-shared and opaque-head-alias paths. Four use the exact full
parser and checker-kernel source texts as line-list/character-string payloads,
including unique/shared pairs. These source datasets differ from the earlier
lexer/native-text inputs; no hotness or workload-frequency claim is made.

Prepared `controls-final-heldout01/harness.c` and its ABI header are byte-identical
to frozen `train01`. Independent oracle code is also unchanged, and the original
preparation engine has only two path-depth adjustments for the new directory.
The 1.3 MB source case file encodes repeated patterns rather than expanded deep
arrays. The eleven independent observations were computed without candidate
execution. They form a separately reported equal-weight held-out aggregate
after root freezes its final selection; the original eighteen held-outs remain
explicitly reused regressions and all original names/oracles stay unchanged.

## Live closed-entry admission follow-up

The [second trust review](../../selfhost/tools/performance/phase110/controls/admission/trust-review-v2.json)
pins the implemented live factory and closure sources at **20:09:29 UTC**.
The CLI accepts no prepared seed, typed/erased book or serialized certificate.
It reads the configured Base file, compares all bytes with the compiled literal,
constructs `p86_prepare` and `p86_plan` internally, and certifies every reached
root/private callee from that same checked request. Generic and private Char
dependencies remain explicit refusals. Reserved private/runtime namespaces now
prevent export collisions. The raw structural helpers remain internal plumbing.

The review found that general-image preparation could inherit a stored/spare
source-admission receipt pinned to the old composed compiler bytes. Preparation
now refuses those profiles; baseline and compact-general composition remain
supported. The earlier externally seeded `nxe_plan` is explicitly unintegrated
and absent from prepared images. Root's existing `closure-check03` receipt
records four positive roots, two private-dependency refusals, nine malformed-data
refusals and a combined nine-definition/four-export library. That receipt emits
workers but does not execute the new native entry workers.

The [native closure semantic corpus](../../selfhost/tools/performance/phase110/controls/admission/native-semantics/manifest.json)
was frozen at **20:07:51 UTC**. Eighteen short graphs yield thirty-six complete
value observations across the four roots and both release orders. Empty,
unique, shared, static and physically overlapping mixed/diamond inputs check
Unicode values, aliases, scratch lifetime and final zero dynamic words. A
separate valid source requests an entry unreachable from main and must refuse
because its checked request lacks the erased fact. Preparation ran no compiler
or target; root owns actual native semantic qualification.

## Final follow-up selection tooling

The separate [selection and heldout tools](../../selfhost/tools/performance/phase110/controls/audit/FINAL-SELECTION.md)
recompute the declared decision from the full existing training matrix.
They require at least 3% aggregate improvement plus an improvement in every
round against the backend incumbent, then apply the same rule across backends
with QBE retained when inconclusive. Existing search winner fields do not
override that rule. A separately frozen protocol version can add candidates
before the next training run; fresh heldouts never enter the decision.

The command planner resolves each selected worker's own origin runtime.o,
preserves exact worker/object/report pins, and keeps its newly recorded runtime
object hash distinct from historical path-only link evidence. Its explicit run
mode relinks the unchanged fresh harness, checks complete values and records
the fixed three-round/two-repetition heldout evaluation. All per-case regressions
are reported; heldout acceptance cannot rerank the frozen winners. These new
tools were source-prepared only and leave the active search/relink scripts intact.

## Delayed-load physical-overlap bridge

Two [fresh unique-parent controls](../../selfhost/tools/performance/phase110/controls/audit/unique-overlap-manifest.json)
were frozen at **20:14:41 UTC** for four observations. Both retain a String
child that also appears inside the external List input. One parent is a raw
unique dynamic constructor; the other is a count-one redirect to it. Only the
child has an external alias, so both reach the unique reconstruction path.
The previous `retained-in-other` case keeps a parent alias and therefore takes
the shared fallback. Results and aliases are checked in both release orders.

Independent source review found that delayed old-field loads remain valid
under the stated allocator and stored-field premises: reserve/free/seal touches
disjoint class0 wrapper storage or free-list metadata while the class1 parent
shell stays live. Both original fields are loaded before either shell write.
The full physical ownership bridge remains separate from abstract laws with
independently accounted child cells. These supplemental controls were prepared,
not executed, by this agent.

## Actual Base non-tail ordinary call

The [String.append corpus](../../selfhost/tools/performance/phase110/controls/admission/string-append/manifest.json)
was frozen at **20:16:21 UTC**. Its source imports and calls the actual Base
implementation, with no copied algorithm. The expected closed entry has two
String parameters, a String result and only its own recursive dependency.
Ten graphs/twenty observations cover empty, Unicode, unique, shared, static,
same-root and physical-suffix inputs. The independent finite-array oracle is
concatenation; the C harness only constructs and observes graphs.

The initial recursion bound is 1,024 first-input cells, with shared depth
512/513 controls. Both result-first and aliases-first release orders require
survivor values, empty pending scratch and zero dynamic words. Native admission,
emission and execution are parent-owned follow-ups; these prepared controls do
not establish arbitrary stack depth or compiler hotness.
