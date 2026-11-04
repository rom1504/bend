# Phase161 — source size is only a modest part of the bendc gap

The second difference is now investigated separately from execution-runtime
speed. Removing44.97% of our compiler input bytes reduced one fresh complete
compiler request from226.912 to194.417 seconds (**14.32%**). It barely changed
the emitted program:118.227→118.188MB and **73,926 functions in both**.
The reduced native input has44,186 lines versus43,857 in current bendc's six
compiler modules. A radically smaller source file is not the main explanation
of bendc's faster self-emission.

The stronger architectural difference is the work represented by that source:
our backend constructs generic scheduled bodies and private/direct candidates,
then optimizes, verifies, composes and emits them. The new stage split measures
11.59s for generic body production versus26.78s for private candidates. However,
**shared compacted-body preparation already exists**. Adding another body cache
would repeat an existing optimization. We corrected that initially attractive
hypothesis after tracing both consumers back to `NativeStaticBody`.

This phase changes research tooling/documentation only. The installed selection,
qualified Phase152 N2, maintained compiler source, optimization policy and
independent correctness gates are unchanged. A reduced-source executable is
**not qualified** by these measurements.

## Source inventory versus work inventory

Starting fork commit `d3588cfc5d6f0499208357b455b3043f436cd83f`, branch
`selfhost/bootstrap`; comparison bendc
[`56edcc65`](https://github.com/Lulzx/bendc/tree/56edcc65b3527a75838011682c231072d5b46097),
already locally pinned by Phase158. No new upstream migration or network survey.

| Input source, excluding Base | Bytes | Physical lines | Boundary |
|---|---:|---:|---|
|Our qualified assembled compiler|3,085,157|66,399|Maintained multi-backend source and included controls|
|Our checked native-main source closure|1,697,879|44,186|Original declaration bytes/order; transitive source references; all previously mapped native owners retained|
|Current bendc compiler modules|1,640,596|43,857|bendc, checker, core, JS/channel support and AArch64 modules; exact six-module inventory|

The native closure is only3.49% larger in bytes and0.75% in physical lines than
that bendc module set. This is **not feature equivalence**, equivalent checking
work, equal tokens, or a universal measure of complexity. It excludes each
compiler's Base, C runtime, external machine compiler, tests and separate proof
files. Historical bendc9c54842e had a different32,161-line module set; comparing
that older number to our current whole assembly exaggerates the present source
size difference.

Responsibility-bounded frontend counts are likewise close: our front/load/core/
check/diagnostic envelope has12,098 nonblank/noncomment lines versus10,792 in
bendc's selected checking **and** emission frontends. These include different
shared helpers, so this is not a precise complexity ratio. Our envelope contains
475 law blocks (2,623 code lines) and1,569 standalone `@unsafe` lines. Removing
formatting or declarations would not prove less algorithmic work. A law signature
is not automatically a mathematical proof; no proof-strength claim is made.

The [frontend audit](../../experiments/phase161/frontend-architecture.md) traces
publication, dependent application and normalized-value sharing. The
[backend audit](../../experiments/phase161/backend-architecture.md) traces
preparation, both body producers, admission, composition and emission, including
the same String equality helper in the two execution backends. Its broader
native/QBE/common source envelope is22,584 nonblank/noncomment lines; it includes
inactive/reuse/control paths and must not be treated as the exact active closure.
The [pinned census](../../experiments/phase161/responsibility-census.json) and
[reproduction tool](../../experiments/phase161/tools/responsibility-census.py)
make the frontend/support selections explicit.

## Controlled source-pruning screen

One fixed original Phase156 request executable, same live Base, source checking,
optimization, independent final verifier, output writing and teardown. Only input
source changes. Order: closure then full. Fresh processes on the root-owned
CPU3 lane, ordinary2GiB RSS limit,16GiB available floor and5GiB disk reserve.
This is compiler execution through QBE emission, **not complete machine building**
or eviction of filesystem caches. One observation each, not paired medians or
an uncertainty estimate.

| Metric | Full input | Native-main closure |
|---|---:|---:|
|Wall time|226.912s|194.417s|
|Peak process RSS|1041.36MiB|1002.06MiB|
|Generated QBE bytes|118,227,421|118,188,267|
|Generated functions|73,926|73,926|
|Dispatcher segments|56,649|56,649|
|Constructor catalogue entries|695|586|
|Complete qualified-output equality|Pass|Different; unqualified|

The fresh full request reproduces the independent qualified QBE oracle exactly.
The closure was already source-checked in Phase160, but pruning declarations
moves430 surviving constructor IDs and changes specialization identities,
dispatcher references and the static image. Of73,925 common function symbols,
64,005 bodies are byte-exact;9,915 changed bodies preserve instruction structure
under diagnostic local renaming and numeric erasure. Five remaining bodies and
one replaced private symbol belong to `p134v_list` specialization variants.
**Erasing numerical values is not an equivalence proof.** The
[bounded streaming output audit](../../experiments/phase161/closure-output-audit.md)
retains exact differences and rejects a diagnostics-only explanation.

Thus pruning is a plausible acquisition saving, not yet a replacement compiler
and not a measured improvement in its generated program speed. No additional
full machine build or broad qualification was justified for this architectural
investigation. The nearly unchanged output also gives no basis for claiming a
comparable saving in QBE machine construction.

## Finer profiling and falsified architectural shortcuts

Reused the exact qualified Phase152 program object and existing generic stage
observer. Six additional first/once boundaries partition the old raw-lowering
and initial-admission intervals. Only diagnostic runtime/sampler were relinked;
no Bend compiler rebuild. The final relink took6.73s including validation/binding.
A small Map request passed exact clean-output, actual ELF/FID binding, marker
order and multiplicity. Its75 samples are insufficient for quantitative CPU
attribution and are recorded as such.

The full capture passed the independent118,227,421-byte oracle, with7,452 samples,
zero loss and99.43% main-thread CPU coverage. The observer uses prepared Base
and the Phase152 object; its diagnostic times must **not** be subtracted from
the clean Phase156/live-Base request times above. All intervals below are
process-CPU clocks from the full diagnostic capture, not clean speed predictions.

| Measured region | Diagnostic CPU seconds | Implication |
|---|---:|---|
|Parse/load|29.52|Source inventory matters before reachability|
|Checking/publication|33.68|Typed Book/publication is a real but bounded frontend target|
|Generic body production|11.59|Not the whole39.5s raw-lowering cost|
|Private/direct candidate production|26.78|Main raw-lowering cost;835 samples permit stage attribution|
|Product signatures + local index|0.81|Not a major whole-request bottleneck|
|Candidate SCC cleanup|0.44|Low current priority|
|Dependency admission + bundle finish|0.51|Do not optimize this because its source says fuel32|
|Initial optimizer|23.67|A larger downstream cost than generic body production|
|First independent verifier|7.86|Keep independent structural checking|
|Observer composition + selected final admission|19.63|Includes9.26s conditional final verifier; do not add it again|
|Registry preparation|16.19|Materialization/index preparation after optimization|
|Render/output/teardown|40.21|Includes rendering, writing and destruction; not118MB retained as one String|

These selected rows omit smaller regions; the complete disjoint staged total is
239.794s in [profile-metrics.json](profile-metrics.json). Generic body/signature/
admission subprofiles have fewer than500 samples: their clocks are useful,
but distributions remain descriptive. Private-candidate active contexts include
use analysis, lookup, String comparison and layout substitution. Physical leaves
include destruction, comparison, scheduler and ownership helpers. These are
different overlapping views, not additive causal attribution or allocation
counts.

All three recursive enumerators—generic definitions, signatures and candidates—
enter4,292 times (4,291 names plus terminal call) on the full input. Twelve observed
`p113d_passes` entries cover all calls, including later composition; they are not
32 unconditional rewrites or necessarily12 initial rounds.

Several attractive proposals did **not** survive the code/profile audit:

- A new common compacted-body cache: already present. `p112s_defs` prepares
  ordinary reachable definitions; `nc_compact_definition` returns their
  `NativeStaticBody` fact in both lowerers. Duplicate call sites are not duplicate
  compaction. The remaining duplicated representations arise later.
- Faster dependency admission as the main breakthrough: only0.51s here.
- “Copy bendc's single-pass frontend”: bendc has separate checking and emission
  parsers and reparses on its checked build path. Its optimizer also performs
  several whole-loaded-program passes before reachable emission.
- “Add memoization”: both normalizers already memoize. bendc's memo functions
  use native cells, while ours uses explicit persistent graph state. That is a
  storage/lifetime question, and moving work into C must count its implementation.
- Drop all fallback/verifier/ownership machinery: these have current semantic,
  ABI, stack-safety and correctness obligations. Phase149 already showed that
  disabling optimization broadly damages generated-code quality.

## Where the smaller input actually saved time

A second accepted capture of the closure passed its own complete clean QBE
oracle and the strict marker/ELF contract:6,442 samples, zero loss,99.35%
main-thread CPU coverage. It is a same-source clean-versus-diagnostic check,
not an independent qualification of the reduced-source executable.

| Diagnostic region | Full source | Closure source |
|---|---:|---:|
|Parse/load|29.52s|18.89s|
|Checking/publication|33.68s|19.29s|
|Proof report|3.32s|1.21s|
|Generic bodies|11.59s|11.54s|
|Private/direct candidates|26.78s|26.34s|
|Initial optimizer|23.67s|23.28s|
|Registry preparation|16.19s|15.96s|
|Render/output/teardown|40.21s|40.10s|

The disjoint stage total falls239.794→207.461s. Parse/load, checking/publication
and proof reporting account for27.13s, **83.9% of the observed stage saving**.
Generic/signature/candidate enumerators still enter4,292 times each, and global
dependency-pass entries remain12. The dominant backend work survives source
pruning almost intact. This is stronger evidence than inferring runtime from
line counts or output size alone. Residual stage differences, including observer
composition, are single-capture observations with changed global identities;
we have not attributed every difference causally.

## What to do next

The useful simplification objective is **fewer complete intermediate programs,
analyses and lifetime transitions**, not a smaller line-count target.

1. **Experiment with demand-driven generic-body materialization behind an
   explicit per-owner plan.** Start with one family where an admitted private
   worker already supplies the complete executable body. Retain public identity,
   ABI/closure entry, ownership and independently verifiable semantic metadata;
   materialize generic continuation bodies only where actual fallback/control
   obligations require them. First classify the reasons generic bodies remain
   needed using the real verified graph, then construct one exact-output or
   independently checked proxy. A textual no-direct-call scan is insufficient
   because dispatch tables and dynamic calls retain references. This is the
   highest-leverage architectural hypothesis from the audit, not a demonstrated
   safe deletion or a recommended wholesale IR rewrite.

2. **Make repeated analyses cheaper across the existing two consumers.** Use the
   shared prepared body that already exists. Inspect actual private-candidate
   use/layout/lookup computations and their complete consumers. A compact typed
   summary might remove traversal and temporary products; a transported persistent
   set can cost more than recomputation, as Phase156 already demonstrated. Require
   a complete producer/consumer win and exact output before broadening it.

3. **Simplify checker Book/publication state in a separate bounded change.**
   bendc separates typed declaration/constructor/order/template maps; we encode
   semantic and index/cache records together and maintain list/index coherence.
   Integrate the already-measured Phase156 provenance optimization first, then
   test whether a typed state removes more recurrent coherence work. Preserve
   snapshots, law/fill order, duplicates, template rollback and diagnostics.

4. **Qualify the native source closure when acquisition savings justify it.**
   Treat this as target-specific assembly from the one maintained source tree,
   preserving JS/C/QBE support. First reconcile global constructor/specialization
   identity, then independent execution and the appropriate native fixed-point
   gates. Its14.3% screen saving is useful, but not the road to a5–10× gain alone.

For scale, deleting *all*11.59s generic production would remove only4.8% of this
staged request. Halving the combined38.37s generic/private production would save
about19.2s,8.0%, assuming no other change. These are **cost ceilings/scenarios**,
not achievable-gain estimates. A materially larger result must also avoid
optimizer, registry, emitted continuation and teardown work, or make the retained
operations faster. That is why delaying unnecessary materialization has more
potential than another cache around a single helper. Its downstream benefit is
unmeasured and must be established before a large refactor.

The prior same-source QBE-versus-bendc/C experiment remains the separate runtime
axis. It showed223.2→167.6s (138.4s with more GC headroom), with different memory
costs. bendc's11.4s checked self-C observation is a different compiler workload,
input, output and policy; it is not an apples-to-apples language-speed ratio.
Source size, backend work and execution representation interact. This phase
narrows the first two without pretending they explain the entire remaining gap.

## Reproduction, failures and cost

- [Design](../../design/phase161/README.md),
  [source-pruning hypothesis](../../experiments/phase161/P161-001-source-closure.md),
  [backend profile hypothesis](../../experiments/phase161/P161-002-backend-work.md).
- [Clean measurements](source-metrics.json), [stage measurements](profile-metrics.json),
  [resource accounting](cost.json), and [exact evidence capsule](evidence/capsule.json).
- `python3 -B experiments/phase161/tools/responsibility-census.py --check`
  reproduces the pinned frontend/support inventory without compiler execution.
- `python3 -B experiments/phase161/tools/summarize.py` derives the clean and
  diagnostic tables from retained receipts. The QBE difference audit includes
  its standalone reproduction command.
- Guard receipts preserve the exact clean request and diagnostic commands,
  source/image/Base identities, budgets, clocks, outputs and output oracles.
  The stage proposal records actual dispatcher/continuation evidence; do not
  transfer its numeric FIDs to a different compiler object.

Eight guarded jobs total **917.97s (15.30min)** of serial lane occupancy: two
clean source requests, two full diagnostic captures, one small clean/diagnostic
pilot and three small diagnostic acquisition attempts. Peak guarded process-tree
RSS was1.05GiB. Two acquisition attempts failed before any compiler request:
one omitted a read-only unwind-header alias, one used the wrong order in the
marker array. Both strict failures and their exact hash-matched methods are
preserved. The final version validates the marker spec before building; no gate
was loosened. Two unused earlier preparation directories are superseded, not
successful image preparations. Source checking, native generation agreement,
mathematical proof and runtime qualification remain distinct.

Two reused bounded agents performed independent frontend/backend audits and an
offline QBE difference analysis. Root alone ran targets. Lane time excludes
source investigation, documentation, offline tools and evidence archiving; no
quota/billing telemetry is available. This was an investigation, not a campaign
of new optimizer implementations or broad correctness runs.

All eight guarded jobs are explicitly closed; evidence is content-deduplicated,
reopened and hash-verified. Before runs,210,875,026 logical bytes of three obsolete
Phase156 native request-image intermediates were pruned **only after verifying
all their payloads in the committed Phase156 capsule**. The ELF/source/reports
and qualified compilers remain. Phase153's absent object/QBE diagnostic aliases
were restored as exact verified read-only hardlinks to existing Phase152 N3
products, without copying payloads or overwriting files. Detailed intent,
verification, pruning and alias receipts are included in this phase's capsule.
Two full-profile QBE outputs were deduplicated only after complete exact output
gates. No phase-directory deletion, lock replacement, production edit, installed
selection change or PR comment occurred.

The capsule pins prior Phase152/153/156–160 capsules for inherited inputs. Restore
payloads only into absent paths, verify their hashes, and preserve the immutable
qualified products. It includes the new diagnostic executable and exact changed
closure QBE, not just favorable summaries. Frozen system toolchain binaries remain
external prerequisites.
