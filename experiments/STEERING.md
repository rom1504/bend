# Latest decision — Phase183 first-class assembly installed

[Report](../implementation/phase183/README.md) · [Evidence](../implementation/phase183/evidence/index.json) ·
[Maintained assembly guide](../docs/self_hosted/ASSEMBLY.md).

The current selector now includes native assembly N2 alongside unchanged JS/C/QBE
images on upstream2.0.40 (`9a4223d`). Maintained x86 source profile1,416,804B;
shared ABI11102 runtime, AMD64 SysV, one mutator/GPU off. Actual N1/N2/S3 emit
identical111,074,856B assembly; objects match and ELF differences are confined
to nonallocated `.strtab`. N2 passes64 current cases (no unsupported), runtime10
and14 installed public controls including old C/JS routes. Source checking is
not a BendTT/backend proof. No unrestricted foreign/parallel/GPU claim.

Build/request/bootstrap/qualification/benchmark/profiler/release tools now carry
real x86 target, generation, source, runtime and assembly identities. The profiler
checks37,045 actual ELF FIDs; the199-sample integration capture is below 500 and
remains unusable for quantitative hotspot attribution. All prior source profiles
and selected JS/C/QBE binaries are preserved. Use fresh paths; equal historical
assembly/object files are hardlinked and must never be rewritten in place.

Performance is a major remaining deficit. Same-source prepared-Base assembly
self-emission119.661→234.689s for QBE-built N0 versus assembly-built N1 (1.96×);
complete builds128.527→244.027s. Single observations, not cold full-profile ratios.
Fresh fast-five/three-role/three-round screening passes every output but finds
assembly63.06×/89.20×/42.70× upstream C on local-pair/local-fold/scalar8192,
about 25–50× QBE. These kernels are not the full45 score. Zero-work is excluded;
a fourth kernel has a low-resolution upstream batch, so NO aggregate is admitted.
The20s first attempt timed out; the unchanged300s campaign completes in 119.885s.

Next investigate sharing the measured missing late QBE tag/borrow/constructor
expansions as structured native lowering, then inspect actual machine code.
Do not infer that first-class assembly support makes it competitive with QBE,
replace QBE's selection, or launch a whole new backend to hide this gap.
Nineteen guarded jobs1194.427s; three preserved harness/deadline failures, no
semantic counterexample. Total agent effort/billing is not guard wall time.

## Prior decision — Phase182 upstream2.0.40 installed

[Migration report](../implementation/phase182/README.md) ·
[Compatibility boundaries](../docs/self_hosted/upstream-2.0.40.md) ·
[Workflow](../docs/self_hosted/workflow.md).

The selected compiler now targets upstream `9a4223d577ba56a0cb53d1fd952d2b481c38930f`.
Snapshot08 (3,179,190 bytes) is the canonical source. Actual native N1/N2/Q3 and
JS B2/B3 reproduce complete products; QBE64, JS18, JS→C18, public C16/current10,
public-command, native session and independent kernel controls pass. Full JS
self-emission requires the recorded pinned-Bun stack allowance; ordinary finite
JS/C qualification used its default. Native builds took about183s per generation,
not a balanced speed comparison. No fresh broad runtime ratio, unrestricted
foreign/GPU/parallel qualification or assembly promotion is claimed.

Retain exact source/runtime identities and acquire fresh benchmark products before
comparing performance. The earlier assembly and frontend hypotheses below remain
research directions, not implicit capabilities of this migration.

## Prior decision — Phase181 assembly backend self-reproduces; retain as experimental

[Report](../implementation/phase181/README.md) · [Metrics](../implementation/phase181/metrics.json) ·
[Backend guide](../docs/self_hosted/x86-backend.md) ·
[Project handoff](../docs/self_hosted/projects/x86-backend/STATUS.md).

The Bend-written AMD64 SysV backend consumes the verified native program and
emits assembly without a QBE machine stage. Eight modules/1,192 lines; existing
runtime, assembler and linker retained. Production manifest/assets/installation
unchanged. Source check,17 machine functions,10 hygiene observations, nine
QBE/literal source comparisons and three smoke cases on each native generation pass.

The complete experimental x86 entry closure (1,415,281 bytes, not the full
production multi-target profile) builds through X0(QBE-built)→X1→X2. Assembly
and object files are identical; all loaded ELF sections match. Only the
non-loaded symbol-table object path differs. This is bounded reproduction,
not broad target qualification or a theorem.

Generated execution is slower: same-source compiler self-emission108.510→217.811s
(2.007×), total assembly builds117.811→226.417s. Paired real parser/checker
8.310→17.1355s (2.062×). Do not compare the smaller experimental entry build
with historical175–180s production source builds and claim a speedup.

Machine inspection identifies missing late QBE tag extraction, guarded borrowed
field loads and specialized take/constructor calls, beyond ordinary register
allocation. Next test existing structured `p112a_expand` before frame placement,
then `p128bf` guarded fields with original fallback obligations. Prefer a cheap
checker transfer gate before another full native acquisition. Defer direct ELF
objects and promotion; assembler removal cannot fix2× generated execution.

## Prior decision — Phase180 compact App overlay rejected

[Report](../implementation/phase180/README.md) · [Metrics](../implementation/phase180/metrics.json) ·
[Authoritative project handoff](../docs/self_hosted/projects/compact-frontend/STATUS.md).

Canonical KApply removes two child-list allocations from `app`, whose linked
body shrinks33→13 instructions. The complete medium frontend is neutral:
12.2465→12.1540s (0.76%, B/C/C/B), below the prespecified5% expansion gate and
smaller than sample variation. Whole-process14.8286→14.7093s. Both versions
retain direct workers; compatibility `ks` reboxes children and substitution's
machine body grows1122→1300 instructions. Static sites do not attribute time.

669 application and70 complete frontend observations pass, as do independent
source acceptance and native output digests. No mathematical proof, broad
backend qualification, full cold-build speedup or generated-user-runtime claim.
Do not expand the partial migration without a new measured owner/consumer
contract to retire. Fifteen guarded jobs299.223s; five source failures8.105s;
exact evidence and bounded source deltas retained. Production/installed source
frontiers below remain unchanged. The project is closed rather than left pending.

# Current complete-build measurement — Phase179 bendc/QBE comparison

[Report](../implementation/phase179/README.md) · [Metrics](../implementation/phase179/metrics.json).

Actual checked own-source-to-executable medians: historical bendc/C68.784s,
our Phase177 N1/QBE175.662s,2.554×. Two builds each, B/O/O/B, CPU3, fresh
program artifacts, reusable runtime objects; filesystem caches not flushed.
Our prepared Base is reused while bendc checks Base live. Different own sources
(1.174MB versus3.175MB), language revisions and output abstractions prevent an
equal-work or universal compiler-throughput interpretation.

The old~9s bendc result excluded Clang. Its actual checked CLI now measures
8.493s through source/check/emission and60.264s Clang/link medians. Our separate
same-image/source emission takes150.921s (17.77× the different bendc workload);
serial machine replay13.937s, including8.097s QBE. The large compiler-execution
gap remains. Serial diagnostic sum164.858s is not a paired improvement against
the streaming build. Do not subtract overlapped clocks or claim an ARM result.

Both C products equal the independent seed; both complete QBE products equal
the Phase175-generated oracle; repeated assembly/object agree. Rebuilt bendc
re-emits its exact checked seed; our new N2 passes frozen QBE and stdout checks
on nt-reverse. Bounded executable checks, no broad requalification/promotion.
Nine sealed guards/673.412s, no failed jobs. No compiler or installed change.
Phase178 remains the source frontier; installed Phase171 and reference images
remain explicitly available. Investigate complete work rather than interpreting
source size or different textual IR size as a causal speed ratio.

# Current source frontier — Phase178 cleanup; product refactor rejected

[Report](../implementation/phase178/README.md) · [Metrics](../implementation/phase178/metrics.json).

Maintained source removes eight unreachable parser/resolution definitions and
four forward signatures: 130 fewer physical lines, 68,369 remaining,
3,167,327B, SHA256
`8fd5043cd47361474ab9da6713687a2fd0825d8a7f0885192e5f70f67d7994db`.
All five executable entry closures and every surviving declaration normalize
identically to Phase177. All 112 protections and survivor order are unchanged.
Independent final source acceptance passes; 565 parser observations pass on the
initial deletion snapshot, with final orphan removals covered by source/closure
audits. This is cleanup, not a new cold-build/runtime score or image promotion.

An erased-body/ordered-reference product removes three consumer scans but adds
result/continuation contracts. 1,474 complete-value observations pass. Native
medium frontend is neutral: 12.234→12.2215s, B/C/C/B, variation larger than gain;
small extracted ELF grows 29,112B. Do not integrate or broaden this product.
Annotation/layout fusion was not implemented; it requires substantially broader
consumer retirement. A per-node summary is not automatically cheaper than a walk.

Installed Phase171, fully reproduced research Phase175 N2 and Phase177 N1 remain
unchanged. Shared source-only checking is now `tools/build/check-source.mjs`;
it does not emit JS or prove unsafe assumptions. Finite laws, upstream source
checking, backend validation and BendTT proof remain distinct.

# Previous frontier — Phase177 frontend integrated; qualified reference retained

[Report](../implementation/phase177/README.md) · [Metrics](../implementation/phase177/metrics.json) ·
[Reproduce](../implementation/phase177/reproduce.md).

Selected checked Bend changes carry the exact local declaration through parser
continuations and keep substitution/beta rebuilding inside one direct owner.
Frozen full-source frontend 56.186→54.0595s (3.78% less, B/C/C/B); complete cold
build 178.7954→176.8633s (1.08% less, one candidate-first pair). Same original
Phase170 source, prepared Base/runtime/toolchain/CPU3. QBE/assembly/object exact;
no new upstream ratio. Do not extrapolate this modest result to the 100s goal.

Maintained canonical source is 3,174,925B, SHA256
`1a359a4c94c8293fec12b8722793a5beafae1896dc2a8307bf5359a7f367532f`.
Three replacements, 27 additions, 260 source lines, 112 protected declarations.
Independent source acceptance, 264 substitution/565 parser complete controls,
14 combined parse/request cases, native64 and 45 exact timed QBE products pass.
The Phase177 N1 image uses its separate `image-binding.json`; it has no new N2
chain or JS/C qualification. Installed Phase171 and qualified Phase175 N2 remain
explicitly available and unchanged. Source integration is not installation.

Nine candidate forms were screened; materialization, freshening, reachability
and filtering alternatives remain unselected. The accepted medium profile shows
39% parse, 25% checking, 34% later annotation/layout/erasure. Ownership and String
comparison span stages; 43% of samples lack valid lexical ancestry. Do not turn
physical samples into removable cost ceilings. Avoid converting every walker.
Next shared-mechanism discriminator: source-bound String identity before owning
adapter alias guards, preserving both sinks, as already researched in Phase131.
A larger architecture needs measured elimination of a complete category of work.

# Previous research frontier — Phase176 calibrated experiments

[Report](../implementation/phase176/README.md) · [Metrics](../implementation/phase176/metrics.json) ·
[Runner](../selfhost/tests/phase176/README.md).

The same four-comparison frontend batch takes76.504s serially,38.890s with two
workers and28.170s with four distinct physical cores (2.72× throughput). These are
software screens under one aggregate guard; final timing remains isolated.
Smaller real compiler inputs recover known broad positive/neutral outcomes, but
do not predict gain magnitude or automatically authorize promotion.

A source-level explicit-frame traversal is5.00% slower while still using generic
scheduler functions. A separate single-owner loop gains a private worker and
reduces complete native workload time22.47%. Real parse/load falls3.44%/3.83% on
two smaller compiler inputs and2.86% on the frozen full source (23.2385→22.5730s).
57 complete-value controls per variant and14 complete parser comparisons pass.
These are experimental components: no new whole-frontend/cold-build score,
maintained source change, installed promotion or full-image qualification.

Next prioritize a larger measured semantic cost and test actual private-worker
admission before image acquisition. Preserve the rejected frame version. Avoid
manually converting every traversal or adding another global pass from one kernel.
The qualified source/image frontier remains Phase175 below; installed Phase171
is unchanged. Exact QBE duplicate storage aliases are immutable.

# Qualified frontend frontier — Phase175 integrated; Phase171 installed

[Report](../implementation/phase175/README.md) · [Metrics](../implementation/phase175/metrics.json) ·
[Reproduce](../implementation/phase175/reproduce.md).

The maintained parser and reporting modules now contain the two measured
Phase175 improvements. Canonical QBE source is 3,163,584 bytes, SHA256
`a0e953a84de73aa22403dde7ec2144540197633857a0f7b5b9784f9e66f5ad04`.
Three definitions change; ten helper definitions and nine forward signatures
add 98 source lines. These signatures are not mathematical proofs. All 112
protected declarations and all five entry-profile transformations remain intact.

Fresh fixed-source complete build: installed Phase171 185.550s → Phase175
178.937s, 3.56% less, one candidate-first pair. Same original Phase170 source/path,
prepared Base, CPU3, runtime/toolchain, streamed exact-output check and no retained
IR; no filesystem-cache flush or confidence interval. QBE/assembly/object are
identical. Do not compare this fresh pair to older 180s or 188s observations as
though they share a contemporaneous baseline. No new upstream parity result.

The extracted complete frontend improves 62.854→56.219s (10.56% less) across two
balanced pairs. These are component timings, not a separate cold-build score.
The full native N1/N2/Q3 reproduce QBE; N1/N2 assembly, object and every loaded
ELF byte match (one nonloaded filename byte differs). Native64 passes; all45
timed QBE products remain exact; six JS and six C products match their qualified
references. Those public screens are partial, and exact products carry prior
runtime evidence rather than a fresh runtime benchmark.

Use `selfhost/build/phase175/full-native-n2/program` with its `report.json` as an
explicit native N2 research compiler. **Installed/default selectors remain the
Phase171 release below.** Source integration is not installed promotion.

Keep the neutral precedence, field-quantity reuse and extra publication deferral
experiments out of the maintained compiler. The new bounded parser/frontend loop
is useful for source changes; a frontend gain alone cannot establish the 100s
goal. Prioritize measured complete costs, including the still-dominant work after
the frontend. No new runtime, verifier weakening or PR comment.

## Installed release — Phase171 published in Phase174


[Report](../implementation/phase174/README.md) ·
[Metrics](../implementation/phase174/metrics.json) ·
[Reproduce](../implementation/phase174/reproduce.md) ·
[Current selector](../selfhost/manifests/current.json).

Phase175 used the installed Phase171 compiler as its reference. That publication
integrated six maintained modules: 16 replacements, 28 additions,
112 protected declarations unchanged. Its canonical source is 3,161,409 bytes,
SHA256 `74cd7de3e5076490e20ba0218d4c9254853be72562946b9ef66fed6c10c7a53a`.

Fresh fixed-input cold pair: Phase170 195.101s → Phase171 188.395s, 3.44% less,
with identical QBE/assembly/object. Its publication-source N1→N2 build is 188.002s.
The older 180.677s observation uses the original fixed source and remains
historical evidence; do not mix observations or silently change benchmark input.
Each pair has one observation per image, prepared Base, CPU3, fresh processes,
and no filesystem-cache flush. No new upstream parity result.

77 finite controls, native64, hostedQBE19, JS45, C45, public-interface gates and
native/hosted sessions pass. Actual N1/N2/Q3 QBE and N1/N2 assembly/object reproduce.
Executable code/data match; raw loaded ELF bytes differ in explicitly audited
section-offset/build-id metadata. Fresh JS B2/B3 checks/reproduces that source.
Ordinary45 and timed45 QBE plus JS45/C45 products match qualified references exactly.
Installed cache/live, hosted, session and public commands pass; rollback is retained.
No generated-program runtime regression is implied by code changes: these benchmark
products are unchanged. This is not a fresh runtime score or full correctness theorem.

Phase172/173 architecture experiments remain separate. Phase175 began from this
installed source/image. Future campaigns must identify their actual compiler
explicitly and retain the frozen original full-source comparison alongside
changing-source self-build measurements.
No PR comment was posted.

## Phase173 closed — useful local capability, no cold-build win

[Report](../implementation/phase173/README.md) ·
[Design](../design/phase173/README.md) · [Final evidence](../implementation/phase173/evidence08/REPRODUCE.md).

Early consuming decomposition improves complete pattern/layout computations by
20.1%/20.8% manually. A general checked QBE pass improves selected unchanged
programs by11.05–49.95%; independent full values and62 finite controls pass.
Its full native compiler reproduces N2/N3 QBE/assembly/object/loaded ELF and
passes64 native cases. Six selected timed wrappers emit exact qualified QBE.
Those facts do not establish a broad runtime score or a cold-build improvement.

Same full candidate source: old producer201.615s, new N1 producer209.643s,
optimized N2 producer204.438s, one observation each. Execution improves2.48%
between new generations, but complete cost remains1.40% slower than old producer.
The2,035-line automatic pass is therefore experimental; Phase170 stayed installed at that close; Phase174 subsequently publishes Phase171.
The contextual materializer source ceiling is neutral at67.553→68.174ms across
four balanced pairs. Do not acquire more images for that overlay.

Indexed storage initially regresses2.003×. General tail-SCC fusion, owned-argument
adaptation and direct destinations recover much, but the matched original
comparison still trails1.155×. Wide returns rebox at consumers and fail the shape
gate. Do not migrate the full compiler based on these pilots.

The suspected stale-body publication bug was falsified: modified prepared bodies
reach private lowering. The seven relevant recursive-rebuild functions simply
have no p113d worker; non-tail parent/child-list recursion and non-flat variants
still obstruct their direct private execution. A future closed, stack-safe
non-tail region experiment needs its own complete-cost ceiling and transfer gate.
No100s result or recursive research acceleration was demonstrated.

307 guarded runs total53.01min, including26 failures; this is execution-lane
wall time, not agent effort or total research cost. Exact failure/resource
receipts and cold-intermediate restoration paths are retained. Qualified source,
runtime, images, controls and profiler dependencies remain intact. No PR comment.

## Historical checkpoint — Phase171 100s campaign

[Checkpoint](../implementation/phase171/README.md) ·
[Follow-up and next decision](../implementation/phase171/followup.md).

Four private Bend overlays gave 180.677s versus a fresh 188.620s full-source cold
build, 4.21% less, with exact QBE/assembly/object output. At that checkpoint this
was a single matched pair and an experimental native N1; Phase170 remained the
installed research compiler. Phase174 subsequently qualified and published the
Phase171 version as recorded above. The 100s target remains unmet.

The borrowed-descendant follow-up now promotes99.535% of calls to the selected `index_find` wrapper in the real-verifier
workload but improves complete runtime only1.25%; lookup and three exact-output
cleanup screens are neutral. Do not continue expanding these local hypotheses or
pay for a full image based on admission counts.47 finite controls and independent
complete values pass; a prototype sink-binding defect was found and corrected.
A sampler-only improvement recovers2,269 runtime callers in5,429 zero-loss full
request samples, with runtime intermediaries/unknowns kept explicit. No new
production or runtime change is made. Prefer a measured producer/consumer work
elimination across frontend terms or shared function semantics next; quantify the
whole-request ceiling before a larger implementation.

## Phase172 retry — no new full-build win

[Report](../implementation/phase172/README.md) · [Exact metrics](../implementation/phase172/metrics.json).

The next controlled full-source comparison is181.741→180.667s,0.59% less in one
pair: effectively neutral.100s remains unmet. The private runtime skips sealing
wrappers around verified immutable static constructors; real verifier runtime
improves4.19%, lookup is neutral, full compiler does not materially benefit.
Both full builds reproduce97,488,970 QBE bytes, assembly and object. Runtime
macro-off object and relinked baseline compiler exactly match their originals.
No installed, maintained compiler or runtime change; no new native qualification.

Other tested routes are also unselected: deferred pattern rows pass20 substitution,
24 flattening and complete loader/QBE controls but have neutral hosted loader
time. Guarded constructor inlining grows code, leaves verifier neutral and slows
lookup6.89%. Cold-only construction has zero full-compiler coverage. A proposed
native checker test was cancelled because its inputs do not exercise patterns.
Current closed-selector lowering already removes ordinary choose-helper closures.
Bendc uses linked code-point Strings; do not claim a packed String advantage.

The baseline-only sealing census finds637,184 static wrappers in the verifier
and770,000 in lookup, but that is35.46% and5.23% of new sealing wrappers, not of
whole-request cost. Removing many objects alone is not a large speed result.
Do not acquire another full compiler or run broad qualification for these neutral
variants. Next investigate a measured hot record reconstruction boundary only if
its dynamic cost and existing destination-pass coverage justify it. No80-second
removable category has yet been demonstrated.29 guarded jobs total563.670s;
all closed. Reviewed verified archiving recovered570.27MiB net. No PR comment.

# Previous frontier — Phase169 native self-build147.764s, canonical185.190s

[Report](../implementation/phase169/README.md) ·
[Reproduce](../implementation/phase169/reproduce.md) ·
[Program runtime](../implementation/phase169/program-runtime.json) ·
[Independent final audit](phase169/final-claims-audit.md).

The experimental direct-QBE native compiler now self-builds its1,538,604-byte
main closure in147.764s, one clean observation including QBE/assembly/link.
Native N1/N2 reproduce86,387,580 QBE bytes, assembly, object and mapped ELF bytes.
All64 maintained native qualification cases pass. Select the explicit
`quality-native-n2` image/receipt; installed and maintained production stayPhase152.
This entry supports single-request qbe-source-v1, not session/batch or newJS/C/GPU
qualification. A narrow150s single-run margin is not a stable timing guarantee.

The unchanged3,085,157-byte canonical workload improves244.461→185.190s,
24.25% less complete cold build time, preserving94,447,397 expected QBE bytes.
It has NOT reached150s. Prepared Base, runtime/toolchain and one CPU3 execution
lane are matched. Do not compare the smaller closure directly to the old244s.

Early verified callable interfaces remove dependent fallback/discovery work;
publication facts, lazy admission, exact scalar eligibility reuse and one full
unchanged final body verifier retain the cheap path. Original/static/adapter
checks and cold diagnostic order remain. A first148.821s image lost important
optimization capabilities and regressed editdist19.2×; it is rejected as a
general replacement. Actual source certificates, bounded ordinary composition
and cold-constructor metadata restore quality without restoring the old pipeline.

Final actual native45 acquisition passes all independent outputs. Four balanced
rounds plus a predeclared resolution repair yield392 correct observations:
44 timed ratios, geometric0.96896× versusPhase152 (3.10% less), family-weighted
0.95892×, worst1.03578×, no case above1.05×. The four shortest points use40×
repetitions for both variants; the original incomplete aggregate is retained.
This is not a new upstream ratio or mathematical compiler-correctness proof.

The profiling-led projection ceiling gives only1.46% on the real checker;
runtime helper tweaks2.15% on a small request. Neither is integrated. Large
ownership leaf shares do not imply removable costs. The next larger hypothesis
is one recursive computation plus bounded resumable frames, replacing repeated
continuation construction/analysis/rendering. Remaining scheduled code is77.9%
of text, not77.9% of time; obtain owner/stage attribution before promising a20%
full-build improvement. Keep final sources/images/receipts and Phase152 hot.
No PR comments posted.

# Previous frontier — Phase168 early interfaces recover execution quality

[Report](../implementation/phase168/README.md) · [Metrics](../implementation/phase168/metrics.json) ·
[Independent audit](phase168/quality-audit.md) · [Reproduce](../implementation/phase168/reproduce.md).

The demanded/observer-first alternative now has a useful joint tradeoff on two
real compiler computations. Matched fresh-process hosted verifier builds fall
31.558→27.759s (12.04%); four alternating native pairs give0.43819→0.42841s,
roughly maintained execution with visible first-pair drift. Lookup/complete-digest
builds fall11.754→7.037s (40.13%), but execution regresses0.53772→0.57496s (6.92%).
Both pass the pilot's≤1.10× runtime limit; the verifier misses its≈25% build target.
Build times are screens. These are Bun-hosted checked Bend compiler requests,
same authenticated prepared Base, not nativeN1/N2/full-self-build improvements.

The concrete capability is verified direct interfaces BEFORE continuation
discovery. Broad early inlining embeds stale owned helpers; selective scalar
preparation avoids that but does not recover quality alone. Callable flags added
after registry construction arrive too late. Seeding authenticated imports before
unchanged region analysis, with real p112w→p113d forwarders, restores local
composition. All93 direct bodies remain exact;36 added region-named functions
are import forwarders, not36 newly discovered region workers. Static jump sites
716→421 are descriptive, not dynamic cost attribution. No array-mode claim.

68 finite controls, independent verifier768 and lookup3279346725 outputs,
shared-data/affine-closure plus20000-depth recursion20040, and frozen Map/IO point
pass. Actual private final verification and additional public/borrowed-copy
verification remain. Source/type checking is not a new BendTT proof. Experimental
modules only; no production/runtime/installed change or new native qualification.

Next test one larger real checker/optimizer closure before full acquisition.
Preserve semantic interfaces across the preparation boundary; identify retained
frontend/region/verification cost rather than restoring all old passes. Lookup's
regression remains an explicit quality limit. The full249.222s qualified native
reference is unchanged; no10× path or recursive acceleration is established.

32 bounded root-owned guards used461.27s target-lane wall time (excluding agent
work/extraction/retention); one source-check failure retained. All runs archived
and verified. Phase152 stays qualified and available. No PR comments posted.

# Previous frontier — Phase167 architecture experiments; Phase152 stays qualified

[Report](../implementation/phase167/README.md) · [Metrics](../implementation/phase167/metrics.json) ·
[Admission graph](phase167/admission-obstructions.md) · [Reproduce](../implementation/phase167/reproduce.md).

Three experimental Bend paths now test substantial work elimination. On the real
39,333-byte nonempty verifier closure, clean fresh-process hosted compilation:
baseline31.276s; demanded direct/plain22.685s; single generic16.770s; single plus
regions19.509s. These are complete source-to-native-executable pilots under Bun,
not nativeN1/N2 or full250s build gains. Generated verifier runtime regresses
2.58×/3.60×/2.26×, so none qualifies. No full native image campaign or promotion.

The important new mechanism is early semantic capability:127 raw candidates,
61 locally error-free rejections with unavailable callees,11 explicit errors and
four independent error-free blocked SCCs. Earlier source-authorized observer
synthesis selects one owner and admits EXACTLY16 predicted original workers plus
its reader. Direct56→73, fallback families49→37, scheduled segments1223→983.
Matched complete build31.343→23.351s (25.50% less); fully matched native execution
0.4412→0.6554s (1.485× slower).35 controls and frozen verifier/Map outputs pass.
This validates the dependency mechanism, not runtime qualification or a10× path.

Prioritize reusable semantic summaries before alternate body construction, then
one canonical recursive computation with ordinary calls/explicit resumable frames.
Preserve scalar observer composition and retained-root ownership through returns.
Do not fix this by raising admission fuel, whitelisting recursion, changing the
backend or restoring every old pass blindly. The early renderer's hidden region
registry was found and separately removed; do not repeat the mistaken claim.

The native full cost model still has83.223 diagnostic CPU seconds before backend
entry. Generic construction alone is4.83% of the diagnostic request. Ownership
samples overlap stage times;2.132B allocation events remain unattributed by owner.
A free backend under unchanged execution cannot deliver10×. Keep the clean full
249.222s pipelined reference separate from diagnostic CPU and hosted pilot clocks.

41 bounded guarded jobs used about667s total execution-lane time. All are sealed
with verified retention receipts; failures and preliminary methods are retained.
No production/core/runtime/installed-image change. Three bounded source/audit
agents; root alone executed targets. No PR comments posted.

# Previous frontier — Phase166 execution boundaries; Phase152 remains qualified

[Report](../implementation/phase166/README.md) ·
[Metrics and receipts](../implementation/phase166/metrics.json) ·
[Native profiles](../implementation/phase166/evidence/lookup-profile-summary02.md).

Identical compiler-derived lookup/complete-consumer source runs in 0.54148s QBE,
0.35772s mature C and 0.15649s bendc C, four balanced runs at 10,000 rounds. Separate
clean/profile lanes confirm the gap. This is a tiny-book kernel, not compiler
throughput. 120 output-checked sampled captures pass pooled quality gates. QBE's
four constructor/take helpers account for 46.73% physical CPU; equality 5.57%.

Replacing lookup/index construction with independently specified complete records,
retaining the digest consumer, gives 0.28461/0.12483/0.11678s. Mature C approaches
bendc in this control; QBE still has a 2.44× gap. Sharing, reachability and inlining
change, so subtraction is not exclusive lookup time. Next test QBE unique-cell
constructor/take fastpaths with exact fallbacks, and a real compiler consumer
that preserves the borrowed lookup result through its use. Keep stack/alias gates.

Hosted backend census matches six complete C/QBE products and preserves ordered
stage admission. It exposes 19.27M Map Tuple events in comparisons, but native
borrowed comparison already eliminates per-character reconstruction. Do not sell
hosted events as native allocation savings. Prepared body reuse and indexed
verifier getters already work; another general cache/linear-lookup rewrite is
unsupported. The 2.132B native allocation residual remains unattributed.

Eleven guarded jobs used 235.08s. 108 complete raw record controls and 156 native
output checks pass; no production change, full acquisition or new cold-build gain.
All new runs are archived/verified. One old archived Phase149 SSA reclaimed 115.3 MiB;
qualified images remain hot. Read the report's fixture and runtime-policy limits.

# Previous frontier — Phase165 source bisection; Phase152 remains qualified

[Latest report](../implementation/phase165/README.md) ·
[Causal metrics](../implementation/phase165/metrics.json) ·
[Reciprocal transfer](phase165/transfer-note.md).

Same-executor bendc checker ablations now preserve complete outcomes on our
182 KB checker and full 3.085 MB compiler input. Removing native memo is neutral.
Portable Map alone costs 1.15× on full checking/reporting; portable Map+String
costs 1.76×. Crucially, transplanting our exact safe three-function equality into
bendc costs only 1.015×. Our existing algorithm already avoids Base's reconstructed
String pairs; do not infer a large new native-equality win for our compiler from
the Base fallback slowdown. All 72 observed outcomes agree with fixed oracles.

Complete shared-request backend screens put QBE at 1.26–1.57× mature C on Map and
1.77–2.04× on a verifier slice, two execution orders with exact complete products.
Both generated backends pass their independent IO points. Hosted diagnostic
clocks and warmup differences are explicit; these are not native/full-build ratios.
The source-sized verifier fixture executes an empty-program control, not a large
runtime verification workload.

Next measure ownership/call/representation cost around the existing predicate
and complete lookup under QBE, and bisect semantic production/private preparation/
verification/output from one checked request. The residual 2.132B allocation
count remains unattributed. No new cold-build speedup, production changes or
five-second forecast. Prefer explicit Phase152 N2 image+receipt: the default
asset named qbe-n2 is an older source and caused a preserved comparison refusal.

# Previous frontier — Phase164 mixed-route limits

[Latest report](../implementation/phase164/README.md) ·
[Mixed evidence](../implementation/phase164/mixed-metrics.json) ·
[Index experiment](../implementation/phase164/zipper-metrics.json).

Mixed direct-first lowering now executes ten original IO fixtures and compiles
its own native source. N2 self-emission exactly reproduces the predecessor QBE.
However, same-source full acquisition is201.931→201.271s: no meaningful cold
gain established. This1.556MB private source differs from the3.085MB maintained
source behind the249.222s qualified observation. N2 small native requests improve
about5% on two cases but regress5.6% on Map. Do not promote this route yet.

A100-line imports-only interface reproduces the clear Mandelbrot/Unicode runtime
gains (15.0%/12.4%, two pairs) while retaining all original lowering and checking;
editdist is neutral. No new broad score or native imports-only qualification.
Explicit index reconstruction passes356 complete host comparisons per variant
and17 fused native controls. List-plus-frame state is neutral; a fused recursive
frame saves5.37%/1.55% on two complete4096-key map workloads, four pairs. This is
not a whole-compiler speedup and does not justify another acquisition alone.

Next identify the exact existing local-region refusal on insertion/typed verifier
reconstruction and measure a complete checker request. Existing non-tail regions
already provide stack-safe execution; bendc's ordinary recursive C calls instead
rely on large guarded virtual stacks. Preserve that distinction. Generic fact
records, repeated hashing and semantic work remain separate measured leads.
No credible five-second full-build forecast, production change or recursive
acceleration claim. All30 target jobs sealed,18.6min target wall; exact failures
and source snapshots retained. See report for resource and validation boundaries.

## Previous direct-first experiment

[Latest architectural experiment](../implementation/phase163/README.md) ·
[Measured limits](../implementation/phase163/metrics.json) ·
[Hybrid follow-up](phase163/hybrid-direct-first.md).

Phase163 builds verified direct QBE workers without first constructing their
generic continuation bodies. Optimized native source→QBE requests on actual
compiler reversal/lookup workloads take 22.6%/34.7% less time; generated runtime
is 0.993×/1.070× the qualified reference. A same-policy hosted ablation emits
byte-identical QBE with 29.8%/16.4% less lowering time, two samples with visible
variance. These are bounded workloads, not full compiler or upstream ratios.

Only two of eight unrelated pure transfer computations are admitted; six refuse.
The restricted native CLI cannot compile its own IO entry. Compact-App controls
pass but native parse+check is 4.7% slower on the 182KB checker workload, so that
overlay is not promoted. The next architectural gate is mixed generic/direct
adapters with an independently checked direct-import registry. Preserve genuine
fallbacks and cold/ownership facts; do not claim all continuation segments can
disappear. No production source/selector change, new qualification, 5× full-build
gain or recursive acceleration. Phase156 publication integration remains pending.

[Latest investigation](../implementation/phase162/README.md) ·
[Source/work audit](../implementation/phase161/README.md) ·
[Same-source execution comparison](../implementation/phase160/README.md) ·
[Phase153 investigation](../implementation/phase153/README.md) ·
[Headroom metrics](../implementation/phase153/metrics.json) ·
[Qualification](../implementation/phase152/qualification.json) ·
[Independent audit](../research/phase152/final-audit.md) ·
[Experiment ledger](ledger.md).

## Qualified compiler results

Phase152 integrates the scalar lexer, compact dispatch and authenticated nullary
constants; original admission and final verifier remain intact. Exact source:
66,399 lines/8,265 declarations;112 protected hashes unchanged. Cold screens:
259.302→254.613→249.222s across native generations, one observation each, no fresh
upstream ratio. Smaller requests improve2.56% across four balanced rounds.
All45 ordinary QBE/assembly/object products remain exact;44 resolved runtime
points are neutral (0.99896×). Details and finite gates are in the linked report.

## Qualified and installed identities

Phase152 N2 is the latest qualified ordinary serial native research compiler:
`selfhost/build/phase152/native-n2/program`, SHA256
`d62712958b53ecdbe19998ca54c9184f895b556acc661ad014dae89754b952bd`.
Use its [qualification receipt](../implementation/phase152/qualification.json)
and explicit assets. Maintained source assembly exactly matches the qualified
3,085,157-byte source, SHA256
`027e15041035522ed7e40ef971eff75f24a09ef6a00e3f8fe335839f94bcb8a8`.
N2/N3 QBE, assembly and objects reproduce exactly; ELF files differ. N1 focused19,
N2 all64, 66 compiler-data controls, hosted JS8 and C6 spot checks pass.
These finite gates are not a new BendTT theorem or parallel/GPU qualification.

Installed JS/C/QBE releases remain the
[consolidated selection](../selfhost/manifests/current.json). Phase147 remains
available as the qualified parent. Use the one maintained source tree and
[workflow](../docs/self_hosted/workflow.md), not retired experimental overlays.
Metric definitions remain in the
[comparison guide](../docs/self_hosted/NATIVE_COMPILER_COMPARISON.md).

## Phase162: controlled frontend explanation

Same exact3.085MB source and75KBBase, original bendc check-only63.111s versus
private bounded-search runtime17.153s, identical122,602-byte unsafe verdict.
This3.679× effect changes runtime policy, not frontend algorithms. Do not treat
our prior66.52s prepared-Base diagnostic versus17.15s as a checker-algorithm ratio.
Counter controls confirm both complete parses,8761jobs and successful body checking;
an ill-typed @unsafe body fails before proof reporting.

Actual same-source C02 observations: checking613.60million allocations and
4.320billion requested words versus bendc224.19million/998.16million. Existing
Phase156 publication-only policy reduces ours to254.70million/1.708billion,
canonicalizations370→76, with all118,227,421 output bytes unchanged. Diagnostic
check31.543→12.344s; complete streamed C request178.990→148.379s. These are NOT
new clean QBE gains or production qualification; prior clean native gain4.62%
remains the relevant measured integration result. Runtime/GC changes the benefit.

Source-to-generated-C trace finds a concrete representation tax: generic KTerm
application plus child lists needs3objects/15words; typed bendc TApp needs1/4,
given existing operands/span. Cached tags are not new allocations. This is a
local cost, not a3.75× compiler-speed prediction. First count hot constructors
and test a compact typed term through a complete computation, retaining spans,
quantities, errors, ownership and exact checked outcomes; avoid conversion at
every consumer. Whole request still allocates2.132billion objects outside its
measured frontend, including Base and backend/output. Publication and compact
terms do not by themselves explain the remaining whole self-compilation gap.

No production changes. Two bounded audit agents, root-only guarded lane, exact
outputs and negative observer findings preserved. See
[operation metrics](../implementation/phase162/operation-metrics.json),
[representation trace](phase162/representation-note.md) and
[causal audit](phase162/causal-audit.md). Do not multiply incompatible ratios into
a purported explanation of the advertised100× comparison.

## Previous backend work frontier

[Phase161](../implementation/phase161/README.md) separates source inventory from
backend work. Fixed original Phase156 QBE executable/live Base: full3.085MB input
226.912s versus checked1.698MB native closure194.417s,14.32% less in one clean
observation each. Closure44,186 lines versus current bendc's six-module43,857:
raw source size is not an order-of-magnitude difference. Both QBE outputs still
have73,926 functions/56,649 dispatcher segments and about118MB. Closure changes
constructor/specialization identities and static data; it is NOT equivalent by
byte comparison or a qualified compiler. Do not promote it from source checking.

Fresh same-object diagnostic captures accept7,452/6,442 samples, zero loss,
99.43/99.35% CPU coverage. Stage totals239.794→207.461s;84% of savings comes
from parse/load, checking/publication and proof report. Both variants still walk
4,291 names through generic/signature/candidate enumeration. New full-source split:
generic body11.59s; private/direct candidates26.78s; signatures0.81s; SCC0.44s;
dependency admission0.51s. Initial optimizer23.67s, registry16.19s and render/
teardown40.21s remain substantial. Prepared-Base diagnostic clocks are distinct
from the clean live-Base request clocks; nested final verification is not added.

Prefer investigating which generic continuation bodies can remain unmaterialized
once a private implementation is admitted, while preserving actual fallback,
public/closure ABI, ownership, bounded stack and independent verification
obligations. First classify needs from verified metadata, not textual call grep;
prove one real owner/proxy before a broad refactor. Generic lowering alone is
only4.8% of staged time, so a large win needs downstream analysis, optimizer,
registry, emitted-body and destruction savings too. Gain remains unmeasured.

Do NOT add another common compacted-body cache: p112s_defs already prepares
NativeStaticBody for ordinary reachable definitions and both lowerers reuse it.
Two nc_compact_definition call sites do not prove duplicate compaction. Remaining
use/layout analyses need full producer/consumer evidence; Phase156's transported
use-set experiment was neutral. Typed checker Book/publication is a separate
promising structural simplification, starting with the already-measured Phase156
provenance improvement. bendc also has two frontend parsers and already-present
memoization/native intrinsics, not a magical single-pass/caching feature to copy.

Eight guarded jobs,15.30min target-lane time, two bounded source-audit agents.
No production/source/selection changes. Exact full and closure output gates,
rejected diagnostic-build attempts, source census and restoration/retention
receipts are preserved. Only obsolete authenticated Phase156 SSA/assembly/object
payloads were pruned; its request ELF and qualified compilers remain available.

## Prior runtime comparison — retained evidence

[Phase160](../implementation/phase160/README.md) now compares the **same complete
Bend compiler implementation** through QBE and bendc/C. Full3.085MB input:
223.237s QBE versus167.602s C; same118,227,421 independent QBE bytes. C with
only BEND_GC_FACTOR=1 takes138.383s:38.01% less than QBE, but peak RSS rises
from1043.4MiB QBE to4074.7/5057.3MiB C. One fresh observation per role, not a
qualified cold-build/TypeScript ratio or paired-median claim. Map and checker
pilots were2.55×/2.26× faster; they overstated full-source transfer.

The same compiler algorithms, live Base, checking, optimization, final verifier
and output/teardown execute in both roles. Source whitespace has an independent
exact structural parse bridge. C uses private bounded-search GC, no-local-free,
BEND_UNBOX=0, pinned Clang-O2 and nine effect adapters. This measures the bundle
of execution mechanisms, not Clang alone or default bendc. Default unboxing
failed Map: generated code passed a function list as an error String. Preserve
that counterexample; only the unboxed-off image passed complete output gates.

The accepted full C profile has1,672 samples,99.94% CPU coverage, zero loss:
55.62% tracing/collection/rescan,5.86% refill,7.95% generic apply.8ms was rejected
for36 overruns;100ms accepted. No pooling. Raising only allocation headroom
reduces full time17.43% and raises RSS24.12%, establishing cadence sensitivity.
Do not infer that a GC replacement or removal of every ownership operation is
sound/profitable. QBE's historical42.71% ownership/transport attribution overlaps
its stages and is not a matched physical subtraction from this new C image.

Next prioritize compact, lifetime-bounded complete compiler computations:
durable admitted IR/facts versus per-function temporaries, borrowed readers and
stack-safe direct returns. Output already streams; do not invent a retained
118MB String. Capture actual allocation/retention by owner before choosing a
region/representation change. Inspect the hot admitted worker, include setup,
conversion and teardown, then require transfer to full source. Preserve prior
negative evidence: local numeric/dense/use-set wins did not broadly transfer.

The native-main closure is now screened in Phase161 above. Its14.32% request
saving is not a qualified build gain or generated-program speed gain. Preserve
all maintained targets; target-specific assembly and semantic identity changes
need their own integration/qualification before promotion.

Current bendc self-emission separately reproduces its4.628MB seed C:
original runtime16.974/39.728s unchecked/checked; bounded-search runtime
5.981/11.374s. One observation each. Historical published9c54842e remains
4.499/8.810s medians from [Phase158](../implementation/phase158/README.md).
Different source, runtime, input, output and checking boundaries prevent using
these as an apples-to-apples ratio against ours. Both do whole-loaded-program
work; historical bendc is not allocation-free. See the source/work census.

Phase160 closes23 guarded jobs,28.30min target-lane time; two bounded agents.
Exact artifacts, failed acquisitions, wrong-code control and rejected profile
are preserved. No production edits or installed changes. Three already archived
Phase153 raw products were pruned with authenticated receipts; no broad deletion.

[Phase156](../implementation/phase156/README.md) remains the pending production
optimization: publication provenance skips redundant canonicalization only
after established coherent publication; childless inserts invalidate it. Two
reversed full-source pairs215.026→205.086s,4.62% less, identical QBE. The actual
checker slice is neutral; do not extrapolate from its static type adjacency.
Integrate compactly with original fallback/error/law scheduling and focused
controls, then qualify once. Shared-use lowering was neutral on actual requests;
its kernel win and initial nonrepeating Map regression do not justify promotion.
Dense storage needs snapshots/joins/old-state observations, not a naive mutable port.

[Phase153](../implementation/phase153/README.md) remains the complete QBE stage
profile:236.947s staged CPU; raw lowering39.27s, initial optimization23.55s,
output/cleanup38.63s, check/publication33.57s, parse29.64s. Nested final verifier
costs must not be double-counted. Reduce complete work, not just metric counts.

[Phase159](../implementation/phase159/README.md) demonstrated the original
bounded-search hypothesis on five captured owners:13.836→2.585s,5.35× in four
paired rounds, with roughly1.16GiB RSS. That kernel is not the complete compiler;
Phase160 supplies the larger transfer and exposes a different tracing bottleneck.
[Phase157](../implementation/phase157/README.md)'s original negative is therefore
not evidence against all GC/direct execution. Explicit RC failed its output gate.

Keep source checking, finite laws, structural admission and independently checked
BendTT proofs distinct. The [Phase129 audit](../research/phase129/selected-compiler-audit.md)
and [upstream assessment](../research/phase150/upstream-assessment.md) still apply.
No upstream migration, proof-strength claim or parallel/GPU qualification was
mixed into these experiments. Full self-reproduction/broad conformance is for
justified integration, not every early hypothesis.

## Resource, evidence and communication rules

One root-owned serial CPU3 target lane. Ordinary jobs use maintained process-tree
and disk guards,2GiB RSS,16GiB available floor and5GiB disk reserve. Larger image
campaigns need an explicit measured budget; the prior6GiB gate is not a default.
Separate-process parallel correctness pilots require an explicit disjoint CPU
mask, aggregate accounting and no concurrent performance target. QBE's qualified
runtime remains one heap mutator, one CPU worker, GPU off.

No unsafe/failure-runtime probes; do not resume Phase113 custom failure
reproductions. Use ordinary valid programs, finite compiler/data refusals and
frozen independent oracles. Never overwrite frozen artifacts or hardlinked
products. Close each run through maintained retention; preserve negatives and
exact evidence before optional pruning. No full image build without measured
benefit and disk admission. No PR comments unless explicitly requested.

Use bounded agents for independent work; root owns target execution. Track
compiler work, machine builds, validation, failures, agent effort and billing
separately. Guard seconds are not total research cost; unavailable quota data
must not be invented. Keep commentary updates during sustained work.

Recursive research remains an open question. Follow the
[Phase104 design](../design/phase104/recursive-improvement.md) and
[research](../research/compilers_architecture_and_techniques/recursive-self-improvement.md).
Self-reproduction is not recursive acceleration.1×/10×/100× describe research
ambition, never established speedups.
