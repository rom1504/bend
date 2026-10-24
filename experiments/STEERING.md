# Current research checkpoint: Phase137 borrowed query composition

[Report](../implementation/phase137/README.md) ·
[Selection](../implementation/phase137/candidate.json) ·
[Metrics](../implementation/phase137/metrics.json) ·
[Next opportunities](../implementation/phase137/remaining-opportunities.md).

Qualified source `2620d59a…e4ecf38`, preferred actual N3 at
`selfhost/build/phase111/p137-n3/program`. Keep qualified Phase134 N2 as a fallback;
installed CLI unchanged. Fifty finite controls pass, Q2/Q3 reproduce106,285,793
bytes, both N2/N3 pass focused19, N3 passes ordinary45. All45 historical runtime
wrappers are byte-identical to the previously measured products; no fresh broad
runtime ratio. Do not silently relabel N3 as N2.

Same frozen Phase131 source, full cold source-to-executable373.511→346.391s
(7.26% less, one fresh serial pair). Prepared Base/runtime and machine tools are
identical; semantic/object results are not reused. OS page caches stay warm.
Separate same-source self-request350.187→325.880s (6.94% less), with identical
QBE. Small native requests are approximately neutral; fresh upstream screen
1.4070→1.3957× request time. Request+machine-child sum0.6824× upstream has different
runtime-build policies and is not request parity. Full-source upstream timing
is not established by the three-source screen.

The checked compiler widens shallow readers to16 fields and preserves complete
scalar query boundaries before early inlining. Three actual queries compose
those observers. Existing runtime/verifier/proof bytes remain intact; no second
preparation pass. Kernel gains31.23%/64.88% transfer to the large compiler at a
smaller percentage. Compiler source+177 lines (0.30%); full fixed-source QBE only
1.10% smaller. No60s build,1MB IR or recursive research acceleration is claimed.

Important tradeoff:148 extra static calls to still-owning getters may offset
some gains; this is not measured dynamic overhead. Unchanged compiler A built
by the new generator is approximately neutral/slightly better on three requests.
Next test narrower consumer preservation against original/unfused sources, and
capture the actual BookCache-reader refusal before altering helper-depth limits.
For larger gains, remove early scans with exact reusable ownership/prior facts;
existing indexes differ in precedence/payload. Retain all failed experiments.

35 serial guarded jobs took41.06min; peak2.04GiB in independent API checking,
about1GB during full native work. Three bounded audit/source agents ran no target
campaigns. Keep one root-owned CPU3 measurement lane and the16GiB available floor.
No PR comments were posted.

# Previous investigation: Phase136 cold native compilation

[Report](../implementation/phase136/README.md) ·
[Metrics](../implementation/phase136/metrics.json) ·
[Stage decision](phase136/P136-001-cold-stages.md) ·
[Query decision](phase136/P136-002-query-work.md).

Qualified Phase134 N2, fixed full Phase131 source: cold source-to-executable
375.923s,1.018GB peak, exact107MB independent QBE. Separate diagnostic stage
request354.331s: parsing44.745s, checking53.149s, erasure30.326s, raw lowering
59.411s, optimization/verification77.734s, rendering64.760s. Frontend152.111s
excludes Base and includes more than checking. Dedicated ownership-check0.144s
is distinct from runtime ownership work throughout. Separate machine replay
QBE8.727s/assembly4.874s/link0.266s; do not add nested/overlapped clocks.

Fresh exact-object profile:11,569 samples, zero loss,99.68% thread CPU coverage.
Physical drop/fade29.74%; active nc_ctor_owned/lookup/f_find18.16%, with overlapping
drop/fade intersections9.21%. Actual kept-row projections transfer nine KDef
fields then sink eight; loops are already local. Reuse Phase131's unqualified
wider-record plus scalar-consumer positive ceiling on these actual paths before
another IR rewrite. Preserve ownership/shape/fallback and final verifier gates.
Then eliminate raw scans with exact prior/constructor facts; existing scope
indexes are not automatically equivalent in order or payload.

Fourteen query controls, three complete plan/product bridges and twelve native
small output gates pass. Diagnostic source/check failures remain visible.
No production source change, fresh broad45 ratio, upstream comparison or native
promotion. Phase134 remains qualified. Cold60s needs6.3× from this baseline;
individual5–15% hypotheses overlap and do not establish that goal. Warm earlier
semantic-unit reuse remains the second track; do not repeat late-cache hit claims.

# Previous investigation: Phase135 full compiler incremental rebuild

[Report](../implementation/phase135/README.md) ·
[Metrics](../implementation/phase135/metrics.json) ·
[Decision](phase135/P135-001-incremental-rebuild.md).

Actual native compiler A→B now uses compiler-announced complete QBE bundles,
reuses56/66 machine groups without a whole-text discovery scan, and matches both
independent107MB products. Cached and independently cold B loaded ELF/headers are
exact.18 compiler-output and6 ordinary gates pass; three-case request time is
0.99305× monolithic, essentially flat. This is experimental, not a new qualified
N1/N2 or installed selection.

Do not overstate the speed result. Same-executable late semantic cache B takes
374.922s versus ordinary364.183s once despite1387/1507hits. A-only backend replay
takes15.979s versus cold grouped38.906s, but conventional monolithic construction
still takes14.699s guarded versus cached replay16.064s. Whole-loop acceleration
is unproven. Most of the old work remains and new bookkeeping has real cost.

Native B stages: frontend175.080s (46.3%), initial lowering62.179s (16.4%),
optimization/verification68.360s (18.1%), render/backpressure72.677s (19.2%).
These are wall intervals with ownership cleanup and shared-CPU machine work, not
exclusive source self-times.62.7% precedes the existing optimization cache.
Next split frontend checking/annotation/erasure and test early reusable prepared
definitions with exact consumed dependencies. Keep independent checking and final
verification. The isolated ownership summary is correct but has mixed hosted
results and misses earlier calls; it is unselected.

Full pipeline peak1.248GB; normal temporary unit text is bounded by18.15MB for
this workload. Qualification deliberately retains all B text for replay. The
107MB serialization and whole semantic IR are still produced; no1MB total IR,
ten-second edit or recursive-research speedup is established. Keep Phase134 as
the qualified tool and retain the framed backend boundary for further work.

# Latest qualified execution: Phase134 bounded emission

[Report](../implementation/phase134/README.md) ·
[Qualified capsule](../implementation/phase134/final/README.md) ·
[Plan](../design/phase134/README.md) ·
[Guide](../docs/self_hosted/incremental-native-development.md).

Final source `a0001924…fa19fb57` has exact Q1=Q2 reproduction, focused19 on both
native generations, ordinary45 on N2 and all45 native benchmark products exactly
matching the prior measured products.59 finite controls and source checking pass.
Output cursors plus no-copy newline writes reduce sampled full-source peak RSS
2.918→1.009GB (65.43%). Whole structured IR remains live. Same-boundary verifier
reuse preserves the independent final verifier and existing proof bodies.

Controlled small-request screens: N1 0.98166× parent, N2 1.00255× parent;
N2 remains1.41377× upstream. This is no established compiler speed gain.
One full-source observation is4.76% longer and overlaps correctness work; retain
the caveat and per-case regressions. Source grows550lines (0.95%), ELF0.119%.
Keep Phase131 available; no installed selection or universal speed promotion.

A bounded host pipe avoids the full textual QBE file while retaining assembly.
Private inline/range results are genuinely reused across edits in a separate
Bend prototype. Hosted Lexer saves26.7% backend time in both orders; Map's
apparent gain reverses and balances to neutral despite34/34hits. Native session
Lexer B improves21.32%, completeA+B9.08%; Map6.12%/2.62% in two balanced pairs.
All16sessionproducts and5refusals pass. Compare warm against cache-reset in the
same experimental image, not adoption against a cache-free compiler. The image
is separate from qualified core; its acquisition costs~413guardedseconds.
No persistent frontend, owner-local binding, integrated incremental objects,
10-second full edit,1MBtotalIR or recursive-acceleration result is established.

Next prioritize earlier candidate preparation and real compiler edit locality
using native evidence. Generic-owner caching only reused cheap primitives and
was rejected. Preserve complete callee/absence/order dependencies, fixed producer
identity, independent final checks and fresh-output oracles. Keep expensive native
qualification at integration milestones; do not expand caches by hit counts alone.

# Latest research: Phase133 Zig-informed compiler architecture

[Research](../research/phase133/README.md) ·
[Zig incremental evidence](../research/phase133/zig-incremental.md) ·
[Bend source audit](../research/phase133/bend-opportunities.md).

No compiler or qualification change. Official Zig0.17.0 source shows fact-specific
semantic dependencies, persistent compilation state, compact indexed storage and
short-lived per-function AIR/MIR. Source-reported MIR expansion20–50× motivates
bounded queues; it does not establish tiny total IR or a hard memory ceiling.
Published millisecond local edits use a warm process and native incremental linking.

Our existing census bounds the largest QBE function at171,719bytes versus107MB
whole text; the largest attributed owner group is2.13MB. This supports bounded
rendered output, not1MB whole compiler RSS. QBE1.3 itself emits and frees each
function, so changing backend is unnecessary to test bounded Bend emission.

Next: a sealed verified owner unit before numeric/static binding, bounded
rendering, then interned identifiers and semantic-query reuse for that same unit.
Preserve consumed reducible bodies, ownership/layout/admission and absence facts;
keep independent final verification. Compact physical storage must be measured,
not inferred from an Array-of-boxed-records type. Keep Phase101's packed-String
regressions as a reason to scope representation changes to compiler IR/output.

The selected QBE image also calls C-template lookup merely to classify primitive
operations; a shared semantic primitive catalogue is a concrete small falsifier.
Its2.13MB attributed owner is not a guaranteed removable-size or speed gain.

Cold1.5–3× and warm10–100× are ambitious conditional research targets, not measured
Bend gains. Subsecond edits also require bounding global checking, verification
and linking. Do not implement a new backend/linker or broad cache before the
first actual lowering-unit hit proves useful. Phase131 remains qualified below.

# Latest investigation: Phase132 incremental native development

[Report](../implementation/phase132/README.md) ·
[Go research](../research/phase132/go-build-reuse.md) ·
[Development guide](../docs/self_hosted/incremental-native-development.md).

Qualified selection remains Phase131 below. A census of its107.06MB QBE finds
2.29M instructions and63,239functions. Reversible private/local name compaction
reduces text46.27% while preserving allocated machine computation and exports.
One machine-build pair saves only~0.65s; direct compact Bend emission is untested.

A real one-declaration emitter edit passes independent source checking, then costs
368.98s for complete native emission.55/65 object units are reused; machine-build
wall falls19.85→5.98s against a fresh partitioned reference with exact allocated
sections/ELF metadata. Nine full-QBE and six ordinary program-output gates pass.
The~21s host partition scan plus unchanged frontend makes this a reuse experiment,
not an end-to-end acceleration.476function bodies and two data declarations
change, exposing nonlocal binding/literal-layout churn.

The measured request gains~1.90GB RSS late, before output appears; the entire
107MB becomes visible in the final~2s. This supports packed/streamed verified
emission, not a claim that disk writing or one exclusively measured phase takes
the several-minute request. Compiler child peak2.90GB; allocated ELF code10.82MB.

Next investigate reusable named lowering units before numeric/static binding,
with stable owner/literal identities and Go-style separate semantic-interface
and object content fingerprints. Preserve consumed body/layout/admission and
negative dependencies, exact producer/runtime/policy identity and independent
verification.10s is an ambitious warm-edit target, not cold-build evidence.
No production cache,1MB full IR, new qualification or recursive acceleration is
claimed. Preserve Phase131; no additional backend is warranted by this work.

# Latest qualified experiment: Phase131 laws and complete borrowed computations

[Report](../implementation/phase131/README.md) ·
[Final capsule](../implementation/phase131/final/README.md) ·
[Native timings](../implementation/phase131/native-results.md) ·
[Program timings](../implementation/phase131/program-runtime.md) ·
[Guide](../docs/self_hosted/analysis-and-proof-boundaries.md).

Final source `1bc5930e…728f9` is native-qualified through Q2=Q3 reproduction
(107,059,385 bytes), focused19 on N2/N3 and ordinary45 on N3. Q1 was emitted by
the qualified Phase130 N1 and differs as expected. The unchanged Phase128 runtime,
explicit compact prepared Base and independent final verifier remain required.
Installed selection is unchanged; the final capsule is the explicit research
candidate. FAST is a separately qualified fallback, not the final source.

Final N2 request time falls20.92% versus Phase130 N1: same-block upstream ratio
1.82482→1.44305×. A separate fixed-source N1/N2 block shows10.64% less request
time from improved generated compiler code; N2/upstream1.42683×. Do not pool
blocks. Ready-executable child sums0.71498× upstream use different prepared-Base/
cached-runtime workflows and do not establish request parity.

The actual N2 reproduces all45 measured wrappers exactly. All405 generated-runtime
observations pass: fresh baseline/upstream1.66679×, final/upstream1.66268×,
final/baseline0.99754×. This is approximately flat; positive log deficit0.767276,
40/44 above1.1× and21 above2×. A five-round follow-up retains a1.56% BST32
regression. Historical1.65258× is not this block's denominator.

Selected improvements: reused min/max use facts with proved first-order algorithms,
one-path index insertion and closed reads/catalogues, immutable constructor
exposure, general selector admission, borrowed shallow records and scalar product
results composed through actual emitted helper workers. Source+824 physical/
636 code lines. Fifty-seven distinct laws are independently accepted, with exact
source bridges and mutation controls; full KTerm/native correctness is not proved.

Retain negative evidence: safe closure summary2.564× slower before recovery;
eligible-but-unused borrowed plans; late closure/preparation duplication; field
masks removing110 machine instructions without runtime gain. Private string
identity is inconclusive; owning identity has a20% extracted-query gain and a
separate whole-image ceiling. Generic closed-factory evaluation is checked only
as a data prototype; it could simplify419 literal expansions but needs an
aggregate work/result budget. Neither prototype is in the qualified source.

Use refreshed final-N2 profiles to choose the next complete query boundary.
The full self-build context now identifies `nc_ctor_owned`7.48%, `lookup`5.43%
and `f_find`5.20%; a checked-book ownership summary is a concrete next hypothesis.
Proved scalar bucket fusion plus wider borrowed layouts removes50.65%/61.95%
of time on one-entry/collision-stress extractions, but remains unqualified and
is not a whole-compiler gain. Preserve that composition for follow-up.
Prefer one general, source-justified work-elimination rule over a new backend or
universal IR. Same-source executable gains demonstrate self-optimization, not
recursive acceleration of research. Full source emissions take~382–491 guarded
seconds and~2.9GB RSS; cheap proxies precede another complete qualification.

The user's subsequent [native-first and incremental-development proposal](../design/phase132/incremental-native-development.md)
is saved for the next investigation: census actual QBE, test compact internal
symbols and stable artifacts, then one correctly invalidated reuse experiment.
No incremental compiler or backend migration was implemented in Phase131.

# Previous qualified experiment: Phase130 compact prepared Base

[Report](../implementation/phase130/README.md) ·
[Candidate](../implementation/phase130/candidate.json) ·
[Native timings](../implementation/phase130/native-results.json) ·
[Guide](../docs/self_hosted/prepared-base-transport.md).

Native source-to-QBE request time falls11.68% in the same three-case block:
Phase128N1/upstream2.0412× → Phase130N1/upstream1.8028×. A separate qualified
N1/N2 block measures1.7949×/1.7924× upstream. Request+machine-build child sums
are~0.88× upstream under the existing prepared-Base/cached-runtime policy; do
not call that request parity. Both scalar-order source rewrites were slower and
are excluded. Whole compiler source grows114 lines (0.20%), including67 controls.

The qualified source is995d6b4b…; hosted→N1→N2 reproduces102,432,076 QBE bytes.
Focused19 passes on both images, ordinary45 onN2. All45 ordinary QBE products,
.text and allocated machine sections matchPhase128 exactly; only nonallocated
symbol strings differ. Historical runtime wrappers were not retimed;1.6526×
remains their last measured Phase128 score. Installed CLI selection is unchanged.

**Select the compact carrier explicitly** from the candidate receipt with the
Phase130 native-request/timing recipes. Old Phase125 qualification recipes keep
using decimal Base and do not automatically obtain the transport gain. The host
must authenticate the complete carrier/producer/Base identity; the stamp alone
is not permission. Original reconstruction/verification and runtime ABI remain.

Full hosted acquisition cost872.50s and peaked near6GiB; native self-emission
cost399.32 guarded seconds/2.81GB. Prefer the qualified native producer for a
future byte-preserving acquisition after independent source checks, retaining
reproduction/semantic gates; codegen changes may require an extra generation.
Use small exact proxies before another image. Next investigate remaining
materialization and repeated name/use queries; complete scalar projection must
reuse the existing traversal/ownership contract rather than another source
rewrite. No recursive acceleration is claimed. See Phase130 cost/evidence.

# Research foundation: Phase129 Bend capability audit and fresh N1 profiles

[Research](../research/phase129/README.md) ·
[Ranked next experiments](../research/phase129/qbe-opportunities.md) ·
[Measurements](../implementation/phase129/README.md).

That audit left compiler and installed selections unchanged; Phase128 was the
qualified performance frontier at that point. The audit distinguishes mathematical proofs from
forward `law` signatures, structural checks, unsafe/model boundaries and native
qualification. QBE remains deliberately sequential; ordinary RFC loads rely on
that premise. Latest upstream has a newer equality-adequacy theorem, but the
active language/kernel pin was not changed.

Fresh current-N1 evidence: 55 exact-QBE observations, 40 loss-free sampled
captures on three short requests. Every request executes 1,087,899 decimal-parser
entry segments. Decimal active contexts are 38.84% closures / 10.47% lexer /
8.74% Map; usage-query contexts are 10.97% Map. All 218 sampled unresolved libc
PCs authenticate as register copy called by `p111_set_regs`; copy plus exclusive
helper leaves expose 9–13%. Requested register clearing remains zero. Physical,
context and counter views overlap; diagnostic overhead stays explicit. No new
upstream ratio or full-source profile is inferred.

Next compare compact/static prepared-Base materialization against a complete
borrowed scalar-query ceiling. Test one reusable use-summary with a small safe
theorem/bridge. Preserve existing QBE and independent verification; postpone a
universal IR, multicore/GPU ABI or large proof project until a bounded experiment
establishes value. Conditional gains and 1×/10×/100× ambition scopes are in the
ranked plan, not measured performance claims.

# Previous qualified experiment: Phase128 borrowed queries and shared preparation

[Report](../implementation/phase128/README.md) ·
[Candidate](../implementation/phase128/candidate.json) ·
[Native timings](../implementation/phase128/native-results.json) ·
[Program timings](../implementation/phase128/program-results.json) ·
[Guide](../docs/self_hosted/borrowed-native-queries.md) ·
[Research](../research/compilers_architecture_and_techniques/phase128-fast-compilers.md).

Final source02 is native-qualified: hosted → N1 → N2 reproduces exactly
102,187,679 bytes of QBE, focused19 passes on both images, and N2 passes ordinary45.
The final checked API passes 100 finite predicates and an independent field-ABI
fixture passes 545 checks. Installed selections and previous qualified images
remain unchanged. The final admission receipt is **native-admission03.json**;
the earlier receipt's documentation-pin drift is preserved and explained.

Fresh paired native request time is **21.16% less than qualified Phase126**,
2.55439× → 2.01378× upstream. A separate qualified-generation block gives
N1/N2 1.93696× / 1.91912× upstream; do not pool blocks. Request plus machine-build
child-stage sums reach approximately 0.95–0.99× upstream under the established
prepared-Base/cached-native-runtime policy. That is not source-to-QBE parity.

Actual N2-produced historical45 wrappers pass all 405 timed observations.
The 44-point generated-runtime ratio improves 1.73444× → 1.65258× upstream
(4.72% less time); positive log deficit 0.808172 → 0.759829. Forty cases still
exceed 1.1× and 21 exceed 2×. Fixed-batch time falls 6.52%, positive excess 10.27%.
Largest observed regression is 1.34%; morning improves 21.39%, tree 10.96%.

Selected capabilities: scalar borrowed observers, verified borrowed helper
calls and nested layouts, exact thin-wrapper restoration, guarded late field
loads, one observer scan, indexed reachability and shared raw request preparation.
The Phase127 live-bank repair is now propagated through self-hosting. Broad
gains belong to this composition; the compiler-name kernel's 4.04× speedup is
not a compiler-wide result. Source grows 1,619 lines (+2.93%), including controls.

Negative evidence: late-flat-only skipping was inconclusive and excluded;
nested-reader admission alone missed its hot caller; constructor-provenance
indexing has precedence hazards and low measured short-request exposure.
Shared preparation preserves complete QBE on Map/RLE/tree. Static instruction
counts grow in field readers because correct fallbacks remain.

Next: profile this qualified image, then test repeated AST usage queries or
checked-Base decoding in a bounded compiler workload. Old decimal-decoder and
`nq_uses` percentages are stale exposures, not new gain estimates. Preserve one
serial target lane, independent verification, ownership and fallback contracts.
No backend rewrite, global cache, installed promotion or recursive-acceleration
claim is justified by this result.

# Previous diagnostic: Phase127 reusable native profiler and cost recovery

[Report](../implementation/phase127/README.md) ·
[Profiler guide](../docs/self_hosted/PROFILING.md) ·
[Full-scale opportunities](../implementation/phase127/full-scale-opportunities.md) ·
[Design](../design/phase127/general-native-profiler.md).

General sequential Linux/x86-64 profiling now combines unchanged-ELF samples,
authenticated selected physical callers, active Bend contexts, conditional
lowered owners, sixteen event counters and ordered CPU windows. Unknowns and
instrumentation overhead stay explicit. Ordinary Mandelbrot/tree transfer,
independent ABI controls and80 offline tests pass. No installed selection change.

A missing `p126_rt_nat_divmod` live-bank admission globally disabled transport
in Phase126. A checked producer repair compiles unchanged source32 with only
one QBE capability-field difference and byte-identical10.10MB machine text.
Contemporaneous three-request medians improve11.37% geometrically; one full-source
request494.0→444.8s improves9.95%. Other15 counters match exactly per FID;
requested register clearing falls to zero. This is a causal same-source image,
**not repaired-source N1/N2 qualification**. Existing Phase126/125 images remain.

Full-source uninstrumented sampling puts40.03% in term_drop/span_fade. Context
profiles and source/machine inspection point to owning string comparison,
linear name/declaration search, constructor-provenance rescans and borrowed
observer product transport. The archived scalar-result observer V2 passed
bounded checks but has no demonstrated compiler-level admission or isolated
gain; do not relabel it as an established performance rejection. Short requests
also retain fixed Base decoding and Map-specific repeated native lowering.

An exact five-function name-search extraction now passes both QBE and upstream
C outputs. QBE takes1.496s versus0.102s for upstream (14.65× on this shared-name
proxy only);66.53million drop entries accompany just63,613 allocations and187
dispatches. Accepted samples put54.20% in destruction/reclamation. Upstream C
already emits borrowed peeks where QBE emits owning takes. This is a cheap,
concrete optimization workload, not a new whole-compiler ratio. The initial
2–3ms samples overrun and are excluded;8–13ms QBE repeats pass.

Next: qualify the admission repair; skip guaranteed-unused late preparation
with exact-QBE equivalence; test borrowed scalar equality versus indexed lookup
in a small real compiler computation before another full image. Keep effects,
sharing, nonowning-result and transport admission obligations. No new upstream
ratio,44-point program-runtime score, optimizer rewrite or recursive-acceleration
claim follows from these profiles.

# Latest experiment: Phase126 representation composition and native checkpoint

[Report](../implementation/phase126/README.md) ·
[Candidate](../implementation/phase126/candidate.json) ·
[Native results](../implementation/phase126/native-results.md) ·
[Regressions](../implementation/phase126/broad-regression-audit.md) ·
[Design](../design/phase126/persistent-private-values.md) ·
[Reproduce](../selfhost/tools/performance/phase126/README.md).

Source32 is native-qualified: exact99,526,466-byte hosted→N1→N2 QBE,
focused19 on both images and original45 correctness on N2. Installed selections
remain unchanged. Checked API,98 finite predicates and9 ordinary programs/152
output lines pass. Original45 timing passes405 observations.

Matched44-point runtime ratio1.90357→1.75263×upstream (7.93% less), fixed-batch
sum13.90% less, positive log deficit0.902235→0.814547, positive excess20.25% less.
Forty cases still exceed1.1×;21 exceed2× (previous24). Equal-family ratio1.84688×.
Ray runtime80.52% less, active rays55–56% less, numeric recurrence~28% less,
records16.3% less. **Not parity:** morning regresses15.29%, tree-bitonic11–12%;
closures64 grows4→5ms. Preserve all these observations and the independent oracles.

Selected capabilities: local F32 values, verified finite scalar tables and inline
reads, safe conditional recursive preparation, flat borrowed products, allocation-
free Nat.divmod product transport, exact two-function tail-cycle loops. Typed
private ABI, local tree-shell reuse and source33 optimizer composition are excluded.
The tree-shell attempt removes37.92% of Node allocation calls but regresses runtime.

**Cost warning for research priorities:** hosted two-request cost+8.75%; native
N1/N2 requests+22.82%/+21.99% against a fresh Phase125 repeat. Native request ratios
2.578×/2.558× upstream; ready stage sums1.231×/1.222× with explicit prepared-Base and
cached-runtime policy. Source+2066 lines (+3.88%), full-compiler QBE+6.96%. Native
qualification26.27 active guarded minutes, peak5.502GiB. A storage refusal was
preserved and resumed without repeating completed work; exact duplicate snapshots
reclaimed430,489,600 bytes. This does not demonstrate recursive acceleration.

Next priorities: first ablate the tree predecessor/layout and morning call-graph
regressions, and skip known-ready late flat candidates to recover duplicated
preparation without changing emitted QBE. Then test carrying a verified flat
helper result through its outer Map continuation. Require unrelated transfer,
independent correctness and real runtime wins. Do not infer hotness from refusal
counts or allocator-call reductions. Keep one serial guarded target lane and
preserve qualified Phase125 as the cheaper iteration alternative.

# Previous experiment: Phase125 owned composition and native consolidation

[Report](../implementation/phase125/README.md) ·
[Native results](../implementation/phase125/native-results.md) ·
[Design](../design/phase125/owned-composition.md) ·
[Candidate](../implementation/phase125/candidate.json) ·
[Reproduce](../selfhost/tools/performance/phase125/README.md).

Phase125 source06 adds checked owned-prefix append, primitive representation
identities and post-verification sized runtime calls. Original45 passes405
observations: same-run44-point ratio1.92031→1.89221× upstream (1.46% less).
Positive log-slowdown0.908321→0.895002;40 cases still exceed1.1× and24 exceed2×.
Final independent map/append transfer241→163ms (32.37% less), excluded from the
historical score. Diagnostic transfer constructors/takes770→514. Raw-owner-only,
RFC1 and result-ABI-only attempts preserve negative/neutral evidence. No parity claim.

**New qualified native checkpoint:** hosted→N1→N2 reproduces93049182 QBE bytes;
both images pass focused19 and N2 passes45 one-shot programs. Qualified source,
API/runtime/images and exact selected compressed source are pinned. Installed
JS/native selections remain unchanged. No ELF fixed point, N2→N3, GPU/parallel
or recursive-acceleration claim. Prior Phase118 assets remain intact.

Hosted two-request compiler cost0.99143×Phase124, approximately neutral. Native
N1/N2 requests2.13489×/2.11464× upstream; ready stage sums1.02516×/1.01421× with
prepared Base/cached runtime versus upstream full C/Clang builds. A fresh Phase118
repeat shows no demonstrated throughput gain after block drift. Qualification
cost22.55min, peak5.159GiB under6GiB; full-compiler QBE grows8.41% across118→125.
Compiler source+283lines including controls; additive runtime65lines.

Next: preserve private producer destinations across local resumes, requiring
transfer and measured elimination of construction/ownership rediscovery. If the
bounded prototype cannot demonstrate wider value, prioritize persistent typed
F32 calls/backedges: ray contributes26.6% of positive excess runtime. Matched
constructor witnesses/virtual products are another general capability; current
verifier facts do not justify removing dynamic take-shape checks. See
[remaining opportunities](../implementation/phase125/remaining-opportunities.md).
Stop repeating broad campaigns for one-percent helper adjustments. Keep one
controlled target lane, immutable evidence, exact fallbacks and the resource
rules below. Do not revive generic cell credits or change benchmark weights.

# Previous experiment: Phase124 complete helpers and local resume

[Report](../implementation/phase124/README.md) ·
[Design](../design/phase124/local-ready-resume.md) ·
[Candidate](../implementation/phase124/candidate.json) ·
[Reproduce](../selfhost/tools/performance/phase124/README.md).

Phase124 ready-only source02 extends Phase123 with a verified callable-catalogue
view and explicit local helper/resume node. Existing successful selections and
runtime/ownership gates remain unchanged. Original45 passes405 observations:
same-run44-point runtime2.00033→1.92014×upstream (4.01% less), family-weighted1.97879×.
Positive log-slowdown0.94870→0.90847 (4.24% less); fixed-batch medians5.03% less.
Forty points still exceed1.1× and24 exceed2×. Largest regression1.29%.

RLE22.82% less, three generate-and-lex inputs34.49–37.13% less, Unicode text3.59–3.87%
less. Lexer core QBE is unchanged: its input generator is inside the frozen timer.
Static96 new local regions include90 repeated library regions; selection counts
are not hotness or speed evidence. Native alias/depth list/tree controls and17
pure predicates pass. Hosted RLE/lexer compiler cost0.99532×parent, approximately
neutral. Compiler source+172lines; emitted QBE+0.605%. Qualified Phase118 and
installed selections stay unchanged; no native N1/N2 or recursive acceleration claim.

Separate scoped frame expansion passes its small checks but saves only1–2%; excluded.
One initial batch deadline is preserved; completed verified outputs were explicitly
recovered. Phase through20:44:11 used27.20min,16.96min guarded,19 jobs including2
failures, one broad emission/screen, no image build. Two bounded offline agents.

Next: eliminate complete intermediate computations. RLE still builds a temporary
lrepeat spine that lconcat consumes/reconstructs. Try a general checked
producer/consumer or destination interface, preserving effect order/aliases and
showing transfer beyond RLE. Do not revive generic cell credits, a named recognizer,
or another global scratch-name rule. A compiler-decoder analogue exists but lacks
measured admission/inclusive hotness. Qualify and measure it before claiming
compiler self-optimization. Keep the existing resource/evidence rules below.

# Previous experiment: Phase123 predicate origins and machine selection

[Report](../implementation/phase123/README.md) ·
[Design](../design/phase123/typed-private-computations.md) ·
[Reproduce](../selfhost/tools/performance/phase123/README.md) ·
[Candidate](../implementation/phase123/candidate.json).

Checked-hosted Phase123 source04 on Phase121 retains exact comparison origins
through Boolean/copy lowering and exposes masked array scales to QBE's address
matcher. Two Bend modules add95 source lines; runtime/ABI unchanged. Final amd64
builder additionally passes GNU assembler `-mbranches-within-32B-boundaries` after
a smaller loop caused a measured list regression. Same-QBE ablation fixes it;
this machine policy is pinned separately and is not silently installed.

Final original45 passes405 observations. Same-run44-point geometric ratio is
2.15074→2.00584×upstream (6.74% less), family-weighted2.05886×. New diagnostic
mean positive log-slowdown is1.01575→0.94810 (6.66% less); exp(L)2.76142→2.58079.
Programs above2× fall31→24, but40 still exceed1.1×. Fixed-batch medians fall3.67%.
Do not let four already-fast points cancel the remaining deficit in planning.
Gains concentrate in editdist and Mandelbrot lineages; local-pair and scalar-region
are derivatives, not extra independent algorithms. Longer editdist1.69× parent,
1.26×upstream. Hot loop65→44 instructions,9→4 stack operands; Mandelbrot mit122→99.

Compiler hosted three-case cost0.97485×parent (small screen); native N1/N2 cost
unmeasured. Qualified Phase118 and installed selections remain unchanged. Final
finite controls and81 ordinary output lines pass. No GPU/parallel or recursive
research acceleration claim. The ordinary-assembler negative results stay archived.
50.87min checkpoint includes27.74min guarded work,34 jobs, three failures8.40s;
one broad emission, two machine-policy screens, no full compiler acquisition.

RLE explicit-state ceilings give only10–14% and both flatten all state lanes.
Strict-subterm layout rule does not admit its nested aliases; excluded. The next
bounded experiment is ready-helper→local-resume: actual helpers are P113D complete
workers, while recursive-region admission consumes P112 readiness. Both callable
view and explicit resume node are needed; preserve exact ownership/arguments,
existing explicit stack and fallback. Prototype against independent heap-owned
walker and a compiler-hot analogue, then check compiler cost before a broad gate.
Do not revive generic cell credits or add a universal IR first.

# Previous diagnostic: Phase122 remaining gap to upstream

[Report](../implementation/phase122/README.md) ·
[Design](../design/phase122/remaining-gap-profiles.md) ·
[Reproduce](../selfhost/tools/performance/phase122/README.md).

Unchanged Phase121 products:90 clean observations,60 usable zero-loss captures,
33,274 samples and150 complete-output/count checks. Ten difficult cases are4.240×
upstream geometrically; this is not the full44-point2.144× score below. Mature C
is near1× on lexer/BST/scalar/editdist, faster on map/records; QBE remains2–4.5×
on those programs. Vintages/toolchains differ, so no backend-only attribution.

Private ready calls cannot resume inside the current recursive-table region;
finite nested Sigma states rebox; ownership consumption loses reusable storage.
BST take/ctor leaves are51.3%, control only0.5%. Editdist already avoids hot helpers,
but its inner loop has65 instructions/9 stack operands versus26/0 in both C
products: repeated predicate conversion is a concrete cheap test. Ray stays8.47×
QBE/3.41× mature C, requiring persistent typed numeric regions and possibly a
separate vector/specialization advance. Helper tuning alone cannot close these gaps.

Next: post-inline predicate canonicalization and RLE explicit-state ceilings,
then composable typed private calls/products if they transfer. Preserve exact
ownership, widths and explicit-stack safety. No large IR rewrite, policy search,
or another already-fast list/closure optimization before those tests. Generic
cell-credit reuse and expensive Phase120 fact analysis remain negative evidence.
Two serial guards cost6.34min; no builds or selection changes. Qualified Phase118
and installed compiler identities below remain authoritative.

# Latest experiment: Phase121 native construction elimination

[Report](../implementation/phase121/README.md) ·
[Design](../design/phase121/construction-elimination.md) ·
[Reproduce](../selfhost/tools/performance/phase121/README.md) ·
[Backend guide](../docs/self_hosted/native-fusion.md).

Checked-hosted source04 on qualified Phase118 reuses existing JS semantic
admission to eliminate private list pipelines and immediately applied scalar
closure chains. Native scalar lowering and verification remain shared; no new
runtime or public ABI. Phase120 numeric modules are not included.

Original45 passes405 output/count checks. Same-run44-point geometric runtime
improves2.98762→2.14395× pinned upstream (28.24% less); frozen-family score2.200×.
The gain is concentrated: four programs from two families change,41 emit exact
parent QBE, and40/44 timed points remain over1.1× upstream. Summed fixed-batch
medians fall only6.48%. Do not equate the geometric gain with broadly achieved
parity. List cases improve20–21×; longer closure confirmation improves84.3×
parent and47.7× upstream. Neutral map-digest fusion is excluded.

Three standalone controls match240 output lines; nine literal acceptance/refusal
expectations match checked admission and emitted activation. Selected scalar
workers contain no calls/allocations. The checked erased-lambda adapter changes
only an analysis view and reruns original full checks. Finite metadata-forgery
controls, parallel/GPU behavior and native N1/N2 remain unqualified here.

Complete hosted three-case request cost is+1.41%, admitted-entry+0.04%; compiler
source grows258 lines (0.49%). These are not native compiler speed measurements.
The42.69min snapshot includes20.63min guarded work and three failures totaling16.85s.
One broad campaign; no full image rebuild. Experimental candidate and all rejected
attempts are pinned; qualified Phase118 and installed selections remain intact.

Next: measure a compiler-hot or remaining slow workload's producer/consumer
ceiling, then preserve the semantic description before representation lowering.
Active ray, RLE, evening-program and tree-bitonic remain large deficits. Repair
Phase120 analysis cost before combining its numeric gains. A shared description
is promising; another broad IR rewrite or general search framework is not yet
justified. No recursive research acceleration has been demonstrated.

# Previous experiment: Phase120 numeric regions and signed words

[Report](../implementation/phase120/README.md) ·
[Design](../design/phase120/runtime-specialization-and-parity.md) ·
[Reproduce](../selfhost/tools/performance/phase120/README.md).

The experimental checked-hosted producer passes405 original45 observations.
Same-run equal-point runtime improves2.98283→2.87077× pinned upstream C,
3.76% less time;44 timed points and the zero-work sentinel remain unchanged.
Scalar runtime falls30.14%, active ray21.69%, ordinary Mandelbrot10.00%.
Related inputs transfer; most other families are unchanged. Three rounds are a
screen, not a claim that no small regression exists. Native N1/N2 and installed
selections remain Phase118/earlier, respectively.

Exact low32/sign provenance recovers SAR; explicit word rendering preserves
zero extension. Existing operand/float-lane ablations are distinguished from new
bounded arithmetic regions. CtorId metadata admission and reserving the unchanged
1024-node budget for arithmetic leaves remove both hot intersection calls.
No new public/private ABI, runtime, SIMD pass or workload-name selection.
Retained combined01 adds17.95% hosted prepared-request cost on four sources.
Combined03 reduces local word analysis59% but gives no whole-cost win (20.56%
over parent in a separate paired screen), so it remains unselected. Its45+6
exact-QBE bridge and failed attempts are preserved.

A Boolean width rewrite triggered correct-but-slow fallback; its corrected
variant was neutral. Both are excluded. Check accepted transformation activation
as well as final outputs. Word analysis costs2.368s versus0.519s verification
on one prepared Mandelbrot graph; repeated fact-list maintenance is the main
new cost. This cycle adds1199 active Bend lines including controls; no simplicity
or native compiler-speed improvement is claimed. See the final report for paired
hosted cost, resource accounting and remaining qualification.

Next: remove intermediate container construction across a measured producer/
consumer region, with unrelated transfer. Reduce analysis cost using exact-output
fast loops before full image acquisition. Existing numeric improvements do not
meet the proposed two-family2× architecture signal or establish recursive research
acceleration. Preserve the qualified Phase118 source/runtime below.

# Latest diagnostic: Phase119 profile refresh

[Report](../implementation/phase119/README.md) ·
[Numeric audit](../implementation/phase119/numeric-audit.md) ·
[Reproduce](../selfhost/tools/performance/phase119/README.md).

No compiler/runtime/default change. Six matched current-QBE/mature-C/upstream-C
cases plus the exact Phase114/118 N1 lexer request pass102 output observations;
44 zero-loss captures yield27,493 physical samples. All current QBE libc samples
are copying, with no sampled fill. Compiler destruction/reclamation is28.1%.
Ray intersection/nearest remains72.1%; list destination-fill/take2/extend1 is59.5%.
Core numeric assembly is unchanged despite ownership wins. IR/QBE already support
sar; general signed-word identity recovery is missing. Upstream's larger ray
region also exposes SIMD, a separate capability rather than an automatic fusion gain.

Next smallest experiment: exact signed-word recognition with independent boundary
controls and unrelated transfer. Larger opportunities: typed private numeric
regions, then eliminate intermediate containers. Do not revive dead-scalar cleanup,
assume all runtime checks are removable, or infer inclusive analysis cost from
destructor leaves. Existing policy search and a new broad survey are lower value.
The six-case4.103× diagnostic ratio is not the original45 score3.009×. Ordinary
compiler request1.89s versus2.68s is a two-observation check, not the N1/N2/upstream
screen. Three serial guards take5.22min; no rebuild or selection change.

# Current compiler frontier: Phase118 ownership and live transport

[Report](../implementation/phase118/README.md) ·
[Native results](../implementation/phase118/native-results.md) ·
[Design](../design/phase118/ownership-and-construction.md) ·
[Remaining opportunities](../implementation/phase118/remaining-opportunities.md) ·
[Reproduction](../selfhost/tools/performance/phase118/README.md).

Bend source projects mature destination construction and borrowed-observer plans
into direct QBE, retains cold-constructor facts, proves live-prefix transport and
uses exact sized/primitive helpers. No workload-name selection. Allocation-only
construction is selected; cell reuse, destination cursor, scalar-only observers
and dead-scalar cleanup are excluded after small/neutral/negative results.

The timed float-source01 passes405 original45 observations;44 timed ratios improve
4.31651→3.00893× pinned upstream C,30.29% less runtime. Hosted prepared-request cost
on8 sources increases12.50%; entry cost18.66%. Do not equate code quality with
compiler/research-loop speed. The original timed source/API remains pinned;
traversal-repaired safe03 is a distinct native producer with an exact-byte bridge.

Safe03 N1/N2 reproduce85,831,654 raw QBE bytes, both pass focused19 (16 executions,
3 expected refusals), and N2 passes45 one-shot programs. Full qualification costs
21.43min, peak5.385GiB. Earlier589.6s/259.2s host-stack failures remain evidence.
The captured older nc_pack_foreign scan now uses an exact worklist. nt_choose
source recursion alone is not evidence of host recursion: inspect its trampoline.

Fresh native3-source screen: N1/N2 requests2.09187×/2.10976× upstream; configured
request+machine build1.01626×/1.02441×. Fresh Phase114 requests2.87824×/2.89711× and
ready1.35829×/1.36700×. Direct native median reductions25.70%/25.55% requests and
24.70%/24.58% ready. Both screens pass27 observations. Native prepared Base/cached
runtime versus upstream source Base/full C/Clang are explicit workflow differences.
This is neither full45 compiler throughput nor native-produced batch45 timing.

Native source a1aac003bbcac3731cc47b3c00dcc7e27f9323842fd26cb60417c2115e85ff10;
runtime runtime-extend01 SHA1b740d48e0db4504b214e0c909d0b5f28cd49064850e9be69fdb20a53a6c55fe.
Source51,056→52,411lines (+2.65%); timed broad QBE grows0.94%. Installed Phase102
native and Phase90 JS selections remain unchanged. No ELF fixed point, N2-to-N3,
GPU/parallel qualification or recursive research acceleration claim.

Next highest-value generated-code experiment: typed private call regions with
representation preserved across calls, compared against ABI-only changes and
upstream hot instructions. Ray-only parity would leave the aggregate2.600×;
require transfer to integer/Boolean/array programs. Old float-lane changes gave
12.77% active-ray /4.17% raytrace, not2×. Dead scalar cleanup shrank IR but grew the
hot loop97→99 instructions and regressed8.05%; do not repeat text-size claims.

Compiler-cost audit identifies eager observer admission, duplicate prepared-book
bang analysis, and discarded C residual text. Test the smallest exact-output
change first. eligible-staged is isolated and excluded: exact QBE on3 sources but whole
compiler cost1.00045× (neutral); see P118-005. No global cache is justified.
Use authenticated artifact reuse for runtime-only experiments and retain failures.

# Historical native development checkpoint: Phase114 source02

[Report](../implementation/phase114/README.md) ·
[Native results](../implementation/phase114/native-results.md) ·
[Selection](../implementation/phase114/selection.json).

Source02 N1/N2 self-reproduce74,220,801QBE bytes. Both pass focused19 and N2 passes
original45 one-shot outputs. The prior hosted source01 runtime aggregate is5.386×
upstream; do not relabel it as native-produced full45 timing. Source02 changes six
namespace traversals to loops after the first full acquisition hit a host stack
exception. Final qualification took22.07min/3.820GiB; enough disk is required.

Three-source native request ratios: N1 2.82490× /N2 2.82713× upstream;
request+machine-build sums1.35522×/1.35687×. The prepared-Base direct-QBE/cached-runtime
policy differs from upstream source-Base→C/Clang. Do not compare these clocks with
compiled-program runtime. Installed production selection remains unchanged.
Float/table/scalar-operand extensions are still separate experiments; read the
Phase114 report before repeating them. Phase112/113 remain historical checkpoints.

# Supporting evidence and production identities

[Phase116](../implementation/phase116/README.md): eight matched diagnostic programs,
QBE6.649×upstream C versus mature selfhost C1.089×;120 clean observations,48 native
captures and16 V8 profiles. This subset does not replace broad45. C already has
useful coherent scalar-array, observer and constructor plans. Tree scan is cold;
warp ownership/constructor paths are hot. Compiler profiles show related ownership
costs, but transfer to the compiler still needs measurement.

[Phase115](../implementation/phase115/README.md): four-policy reuse cuts emission
30.3%, but current policy remains best for runtime. Existing alternatives have
little diversity. Small negative-decision retention saves4.15% full warm emission;
it remains separate from the qualified native source. Do not launch large policy
search without new opportunities or demonstrated complete-loop amortization.

[Phase105](../implementation/phase105/README.md) remains authoritative for production
B1/B2 versus upstream: prepared45 0.499×/0.517×, live-Base2.384×/2.231×, full-source
prepared2.602×/2.965×. The installed native CLI/package is the Phase102 selection;
the Phase90 JS release remains separate. Read [comparison definitions](../docs/self_hosted/NATIVE_COMPILER_COMPARISON.md)
and [direct-QBE guide](../docs/self_hosted/direct-qbe.md) before quoting metrics.

# Resource, evidence and communication rules

One root-owned serial CPU3 target lane; use existing process-tree guards,2GiB for
ordinary experiments and a16GiB available floor. Larger qualified image campaigns
have an explicit6GiB gate after measured growth, retaining the16GiB floor. No unsafe/failure-runtime probes; do not resume Phase113
custom failure reproductions. Ordinary valid source controls and frozen benchmarks
are the iteration loop. Agents can perform disjoint offline audits; account for
cost rather than using them reflexively. Keep rejected attempts and independent
oracles. Never overwrite a frozen artifact, including hardlinked paths.

Disk is tight. Phase117 retained every exact artifact while deduplicating bytes;
its evidence capsule is10.9MB compressed. No full image build until disk and
measured benefit justify it.54 guards used19.82min total; non-target research time
and billing/quota are distinct. No PR comments unless explicitly requested.

The longer-term recursive-research question remains open. Use
[Phase104 design](../design/phase104/recursive-improvement.md) and
[research](../research/compilers_architecture_and_techniques/recursive-self-improvement.md).
Repeated self-reproduction is not recursive improvement;1×/10×/100× labels are
research scope, never measured speedup factors. See the ledger for older frontiers.
