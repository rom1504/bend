# One maintained self-hosted compiler and research toolchain

Plan, 2026-10-31. Inspected HEAD: `a5f7a6a` on `selfhost/bootstrap`.
This document proposes the cleanup; it does not change the compiler or selectors.

The user's desired end state is **one best maintained version of compiler code
at HEAD**, supporting JS, C and QBE and retaining the optimization, profiling,
build, correctness and performance-measurement capabilities already developed.
The next performance objective is **cold compilation**, not more incremental
optimization. Existing incremental capabilities must remain recoverable and
explicitly classified, without becoming the main implementation campaign.

## 1. End state and boundaries

One authoritative module tree supplies the compiler. One maintained implementation
of each research tool serves all applicable backends through explicit adapters.
Experiments record revisions, inputs, hypotheses and results; they no longer
contain the implementations that current builds depend on.

"One version" means one authoritative implementation of each responsibility.
It does not mean one backend, one executable, or forcing distinct runtime contracts
into an identical implementation. JS, C and QBE emission remain distinct where
necessary. Bootstrap B1/B2 and native N1/N2 are generated artifacts of a recorded
source revision, not separately maintained compiler sources. Trusted upstream
bootstrap/reference code remains an independently pinned dependency.

"Best" means preserving qualified behavior and the strongest compatible accepted
optimizations for each supported configuration. The latest phase number does not
establish that a source is best for every target. Rejected experiments must not be
silently enabled, and two competing implementations must not survive indefinitely
under renamed `old`, `new` or phase directories.

Completion requires:

- Maintained code, build recipes and tools do not read historical phase source,
  generated compiler source snapshots, or undeclared existing build directories.
- Each compiler declaration has one authoritative source location. Backend-specific
  algorithms have explicit responsibilities rather than duplicate common frontends.
- JS/C/QBE and existing public entry points have a capability matrix, independent
  correctness evidence and performance continuity against their proper incumbents.
- Current tools cover builds, profiling, compilation latency, program execution,
  code inspection, laws/conformance and evidence retention.
- Historical implementation copies leave HEAD after their Git references and any
  non-Git inputs have been preserved and restoration checked.
- A fresh worktree with explicitly acquired pinned bootstrap assets can run the
  documented current workflow without the original workspace's accidental state.
- README and selectors identify the same current implementation and accurately
  distinguish installed, qualified and experimental configurations.

This is source/workflow consolidation, not a new universal IR, backend migration,
language rewrite, Git-history rewrite or promise of a 10k-line compiler. Compiler
algorithms remain in Bend. Existing host tools may orchestrate execution and
transport; this cleanup does not relocate compiler logic into Python or JS.

## 2. Actual starting point

| Responsibility | Current source of authority | Consequence for cleanup |
| --- | --- | --- |
| Maintained JS/frontend tree | `selfhost/src/compiler.json`, installed `selfhost/dist/release.json` | Preserve direct JS, compatibility interfaces, source loading and JS-hosted behavior; the current module manifest is not the full latest QBE implementation. |
| Installed native C compiler | `selfhost/tools/native/selection.json`, Phase102 candidate04 admission and `selfhost/tools/native/profiles/phase102-lowering04/profile.json` | Source is reconstructed from a baseline capsule and deltas. Preserve its public native CLI and C optimization/runtime contracts. |
| Latest qualified QBE compiler | `implementation/phase146/candidate.json`, `selfhost/build/phase146/source03/compiler.bend` | Qualified ordinary-native research source, not installed or incremental-qualified; source must become maintained code rather than a build artifact. |
| QBE preparation | `selfhost/tools/performance/phase146/prepare-v01.py` | Imports Phase131 composition and consumes qualified Phase144 source/metadata. Phase131 itself reads Phase113 verification declarations. Moving folders alone cannot remove these dependencies. |
| General native profiling | `selfhost/tools/profiler/` and Phase144 event extension | Preserve samples, source attribution, stages, physical callers, runtime events and independent ABI controls. |
| Program timing/diagnostics | `selfhost/tools/performance/programs/`, later catalogs and native/QBE adapters | Preserve input/oracle identities and timing definitions, not just a convenient new command. |
| Disk lifecycle | `selfhost/tools/build-retention/` | Already maintained tooling; reuse its lock, budgets, closure and exact recovery. |

The [inventory](inventory.json) counts tracked paths and logical bytes, not unique
disk blocks or semantic duplicates. It found 8,726 source-like files under phase
performance directories (54.56 MiB), versus 270 files under `selfhost/src` (2.15
MiB). Many are tests or legitimate distinct experiments. No extension-based
deletion follows. Large evidence trees dominate bytes; removing source copies
primarily improves navigation, dependency clarity and agent context.

A bounded declaration comparison found substantial divergence: many JS/C bodies
inside Phase146 differ from those in the canonical JS source. Examples include
`j_module_exports` using later string/tag helpers and `nc_ctor_owned` delegating
to `p144o_owned`. Therefore containing JS/C declarations does not establish their
performance or semantic qualification. Phase146's entry uses `p111_native_args`;
the native C CLI uses `p86_cli`. They need deliberate host/entry integration.

Phase146's selected runtime permits one Bend heap mutator. Do not replace the
C target's supported runtime/parallel behavior with this serial policy. CPU/GPU,
foreign effects, source imports and error handling remain explicit capabilities;
this plan does not claim currently unsupported GPU or host/target combinations.

## 3. Proposed maintained layout

Keep useful existing paths; avoid moving modules merely for cosmetic uniformity.

```text
selfhost/
  src/
    compiler.json             authoritative module/entry manifest
    core/ check/ front/ load/ diagnostic/
    back/common/              genuinely shared semantics and analyses
    back/js/                  accepted JS optimizations and emission
    back/native/              existing C responsibilities, named explicitly
    back/qbe/                 accepted direct-QBE optimizations and emission
    host/ driver/             thin host adapters and target dispatch
    runtime/                  JS/C/QBE providers and explicit policy contracts
  tools/
    build/                    acquisition, source assembly, bootstrap, linking
    profiler/                 retain and consolidate the existing general tools
    bench/                    catalog-driven compiler/program measurements
    conformance/              existing independent validation infrastructure
    build-retention/          existing disk guard and closure workflow
    history/                  small revision/recovery index, no copied compilers
  tests/ proofs/              maintained fixtures, laws and proof workflows
  manifests/                 toolchain/runtime/assets and capability identities
  build/                     ignored generated artifacts and temporary worktrees
  dist/                      generated selected release, not editable source
experiments/                 hypotheses, config, exact revisions and results
design/ implementation/ research/ docs/
```

Paths are a target organization, not a required mass rename. In particular, retain
the profiler's stable path and working CLI while consolidating its extensions.
New build tools are adapters around proven mechanisms first. Remove redundant
implementations only after those adapters work without historical imports.

An optimization inventory maps each accepted capability to its source owner,
target/policy, legality controls and product/performance evidence. Include JS
regions/representation/fusion; C ownership/direct calls/loops/observers; QBE
virtual products, helper/resume composition, representation preservation,
construction elimination, borrowed queries and retained checked context. Audit
the actual selected code to finish this list; historical claims alone are not
proof that an optimization executes.

## 4. Capability and performance contract

Record three independent dimensions: **compiler host**, **output target** and
**bootstrap generation**. Generation names keep their actual producer lineage;
do not relabel N1 as an upstream-produced B1. A QBE-built native compiler can in
principle emit JS or C, but each advertised combination must be exercised.

Phase A produces a matrix of currently supported combinations, CLI/API commands,
input/import handling, effects, refusal cases, runtimes, threading/GPU scope,
proof workflow, bootstrap reproduction and benchmark support. Every cell has an
incumbent identity and status: qualified, experimental, unsupported or historical.
Preserve current supported combinations; do not require a fictitious fully tested
Cartesian product before a useful migration can proceed.

| Metric | Preservation rule |
| --- | --- |
| Cold build | Same source, executing compiler host/stage, preparation mode, runtime, toolchain, flags and machine lane; report complete source-to-executable plus stages. No source-specific semantic/object reuse. OS caches need not be flushed, but state this. |
| B1/B2 compiler speed | Preserve request/process/preparation boundaries and each supported host/target pairing. Keep native N1/N2 lineage separate where appropriate. |
| Generated-program speed | Same inputs, independent outputs, runtime/toolchain and corpus weights. Report per-target geometric mean, positive log-slowdown, family effects and material individual regressions. |
| Conformance | Preserve exact positive outputs, invalid-program refusal, diagnostics, effects/ownership and supported public APIs; retain existing known gaps explicitly. |
| Simplicity | Count maintained compiler modules/code, host support and independent concepts separately from fixtures, reports, generated source and Git history. Track historical dependencies and duplicated authoritative definitions. |
| Research cost | Acquisition, source checking, profiling, clean timing, machine builds and qualification are separate clocks. Include failed work and disk/RSS peaks. |

The recent 247.000s complete cold build and 237.491s Phase146 request measure
different input/scope boundaries; neither is a new unified cross-target baseline.
Use the recorded identity bridge where possible and measure missing comparisons
once when a decision requires them.

## 5. Sequential implementation phases and exit gates

### A — Freeze authorities and make the migration map

Resolve each selection to exact source, source recipe, runtime, Base, toolchain,
entry, oracle and qualification. Record external assets and uncommitted inputs
separately. Protect unfinished Phase6/68 work and other user changes. Build a
file/declaration ownership map from imports, loaders, receipts and actual command
construction; plain text search alone is not a deletion proof.

Classify each historical implementation: active dependency to migrate, accepted
optimization to integrate, unique test/proof to retain, rejected experiment to
reference through Git, or generated duplicate. Name the replacement and evidence
for every retirement. Capture a small rollback manifest and reachable Git refs.

**Gate:** no target or required tool lacks an identified incumbent; ambiguity is
recorded before source extraction. This is mostly read-only work, not a fresh
full benchmark campaign.

### B — Recover maintained source from qualified artifacts

Extract Phase146's exact declaration bodies into maintained modules, preserving
names, order, proofs, unsafe annotations and whitespace needed for literal
reassembly. Put source maps in separate metadata initially. Assembly must not
read Phase144 source from `build/`, replay a chain of textual overrides, or import
Phase131/113 tools. An assembled output is disposable, never the editing surface.

Use the JS/C authority map to identify missing APIs and conflicting declarations.
During the transition their old authorities remain available as baselines; this
is an intermediate checkpoint, not completion of "one version at HEAD". Avoid
renaming phase-prefixed internal symbols in this step: renaming can change IDs,
layout, diagnostic attribution and emitted code without helping consolidation.

**Gate:** new QBE assembly reproduces the exact qualified source bytes, protected
proof/verifier bodies and entry/runtime contract. JS/C authorities remain usable.
A clean-worktree assembly works using only tracked modules and declared assets.
Exact identity can reuse existing qualification; no full native rebuild is needed
solely to prove a file move.

### C — Converge JS, C and QBE on the maintained source

Resolve conflicting implementations one responsibility at a time. Prefer the
strongest compatible common implementation after differential checking. Keep
legitimate backend policies explicit; introduce a thin adapter if entry/transport
differs. If algorithms truly differ by target, place them in the relevant backend
with distinct contracts rather than duplicating the entire checker/frontend.

One manifest selects supported entry closures from this shared tree. It must not
select historical versions of the same frontend or maintain overlay chains.
Avoid linking every backend's unreachable code into every compiler image simply
to achieve a single source tree. Preserve existing reachability and target scope.

Exercise installed public JS and native C behavior as well as direct-QBE research
commands. Carry optimized C and JS runtime/effect providers forward independently
of QBE's serial runtime. Migrate proof/law ownership and associated tests without
upgrading finite controls into mathematical proof claims. Source checking,
BendTT checks and emitted-program equivalence remain separate gates.

**Gate:** all promised capability cells pass their focused continuity checks;
conflicts have decisions and evidence. Changed generated products trigger targeted
correctness and timing before expanding. No backend silently falls back to a
historical compiler or upstream implementation. If a conflict is unresolved,
report that the migration is incomplete rather than deleting its working source.

### D — Consolidate tools around one execution/evidence contract

Move required build, profiler and benchmark mechanisms into maintained locations.
Share resource supervision, identity checking, output handling and report utilities
where their contracts match. Keep target-specific acquisition and observation
adapters. Replace hardcoded phase paths with explicit manifests/arguments.

The [tool and oracle migration map](tool-map.md) identifies the concrete current
mechanisms and catalogs. Resolve repository roots through one explicit workspace
contract; moving scripts without fixing `__file__.parents`, dynamic imports,
phase-restricted outputs and hashed helper dependencies will break execution.
Use a bounded operational asset manifest separately from historical provenance.
Changing a path creates a new binding record; it must not mutate an old receipt
or claim the relocated artifact has the old method identity.

Preserve the following interface families; command spelling can follow the
existing working CLI rather than requiring a new launcher language:

```text
build/assemble/acquire/bootstrap  host + target + source + runtime + output
bench compiler                  source set + host/stage + target + preparation
bench programs                  catalog + artifacts + target + cases + budget
profile                         workload + exact image + samples/stages/events
inspect generated               JS/C/QBE syntax, machine code, paired comparison
check                           frontend/backend/ownership/proofs/public CLI
retention close                 explicit classification + archive/prune choice
```

Keep the 20/60/300/600-second program-screen budgets, explicit case selection,
candidate/upstream roles, independent outputs, raw timing samples, V8 diagnostics
and native machine/source attribution. Budgets are ceilings with honest incomplete
results, not identical coverage across all targets. Compilation/acquisition and
diagnostic time remain outside program-execution timing where the old protocol
excludes them. Preserve original45's 44 timed cases plus zero-work control and
other named catalogs; do not quietly replace them with a smaller unified corpus.

**Gate:** replay frozen receipts and negative controls through old/new analyzers;
reproduce verdicts, case ordering, units and aggregations. Run one bounded live
build/benchmark/profiler smoke for each distinct adapter contract. New reports
pin the new harness revision and retain a compatibility record; never rewrite
old receipts to claim their methods had different hashes.

### E — Retire historical implementation copies from HEAD

Commit any unique uncommitted experimental input before retirement, or preserve
it as an authenticated patch/blob when it cannot enter the implementation branch.
Record a reachable source commit, path, blob digest, configuration and dependency
manifest. Preserve meaningful negative findings and independent oracles.

Historical replay uses a detached worktree at that exact revision with pinned
assets. Do not rewrite an old consumed method in place, replace it with a shim
claiming the old identity, or move all duplicate source into a new archive folder
at HEAD. Keep small history records and data-only evidence capsules; generated
source/method snapshots already retrievable from Git need not remain duplicated
inside current capsules. Non-Git source, binaries, profiles and unreconstructible
inputs require explicit artifact retention instead of a hash alone.

Do not rebuild every old capsule just to remove embedded code. A capsule already
in reachable Git history can leave HEAD as a whole when its record points to the
exact commit/blob and restoration passes. Extract unique scientific results into
the compact current evidence index only where necessary. This avoids both a new
archive-recompression campaign and a disguised second source tree.

Remove retired scripts/source and superseded bulky snapshots in bounded commits
only after new tooling has no dependency on them. Independent frozen benchmark
fixtures are allowed even when written in Bend: they are input programs, not a
second maintained compiler. Qualified fallback binaries and upstream bootstrap
assets are also explicit exceptions, stored as assets rather than editable code.

**Gate:** maintained dependency/command audit has zero references to historical
phase implementation paths; a clean worktree exercises all current tools; a small
historical experiment can still be restored and replayed from its commit. Keep
Git history intact. Deleting HEAD paths reduces checkout/context, not necessarily
`.git` size. Use the existing retention policy for ignored build bulk.

### F — Qualify, publish and document the coherent version

Run one final integration campaign against the capabilities actually advertised:
independent source checking, relevant JS/native bootstrap reproduction, broad
backend/conformance gates, installed/relocated CLI checks and performance
continuity. Reuse earlier exact artifacts when their full relevant identities
are unchanged; do not build every host × target × generation combination merely
for symmetry. Keep required JS bootstrap/recovery and independent oracles.

Publish one release/capability manifest for the maintained revision with its
generated host artifacts. Update current selectors only after their gates pass;
retain the qualified predecessor as an explicit fallback asset. Update README,
selfhost README, development/profiling/benchmark guides and current status to
point to maintained commands. Move historical numerical narratives behind the
experiment index instead of repeating them in the getting-started path.

**Gate:** end-state checklist in section 1 passes, current release builds from a
clean worktree, and no supported target/tool is supplied only by an old checkout.
Report any remaining experimental incremental mode separately. Resume cold
compilation optimization on this source after the consolidation checkpoint.

Existing session and machine-object reuse are included in the final tool gate:
preserve no-op, real-edit, revert/error recovery and source/runtime/policy
invalidation behavior. The Phase140/142 session remains experimental and is
tested against mode-matched references; Phase146 ordinary qualification cannot
be extended to it by file movement. Unresolved integration is an explicitly
incomplete migration, with historical recovery intact, not a silent feature loss.

## 6. Validation budget and regression decisions

Use progressively stronger gates; do not spend minutes of native acquisition on
every path rename. Keep one resource-intensive execution lane and bounded parallel
agents for source mapping, tool extraction and independent review.

| Change | Immediate gate | Escalation |
| --- | --- | --- |
| File extraction/order/recipe only | Exact assembled source, manifest/runtime identity, clean-worktree assembly | None if relevant bytes and contracts are unchanged |
| Harness extraction | Frozen report/negative-control replay and one live adapter smoke | Affected protocol comparison if observations differ |
| Common algorithm or entry reconciliation | 20–60s focused semantic/refusal controls and independent output comparisons | Affected target compile/program screen, then integration |
| Changed runtime/ABI/ownership/target products | Relevant ownership/effect/stack/ABI controls | Native build, target semantics and fresh timings of changed products |
| Final adoption | Capability matrix, source checking, relevant reproduction and broad correctness | One controlled performance campaign where artifact continuity does not suffice |

Initial performance decision limits: no confirmed cold-build or compiler-request
slowdown above 5%; no confirmed generated-runtime regression above 2% overall or
per family, or 5% per case. These are investigation thresholds, not confidence
intervals or permission to hide regressions under noise. Confirm flagged cases
with alternating same-machine samples; do not rerun every suite until a preferred
result appears. A material tradeoff needs a documented decision, not silent loss
of a previously accepted optimization. Exact unchanged code/runtime evidence can
preserve historical performance evidence, but is not a new timing measurement.

Cold timing includes loading/parsing/checking, lowering/optimization/verification,
render/write, QBE or C machine construction, assembly and linking as applicable.
Also report external source/proof checks and qualification separately so moving
work out of a quoted interval cannot masquerade as a gain. Maintain raw/live and
prepared Base modes and account for candidate acquisition.

## 7. Work allocation and checkpoints

The earlier 1–2 hour suggestion applies to an initial consolidation checkpoint,
not a guaranteed complete JS/C/QBE reconciliation. The source audit shows real
implementation divergence, so deleting historical directories within that window
would be an unsafe definition of success.

First block, approximately 90–120 minutes of implementation effort:

1. 0–20 minutes: freeze authorities, finish capability/dependency/conflict maps.
2. 20–65 minutes: exact current-QBE module extraction and maintained assembly;
   separate agents map JS/C conflicts and tool adapters without large builds.
3. 65–95 minutes: eliminate the first historical preparation dependencies and
   run identity/clean-worktree gates; carry unchanged artifacts forward.
4. 95–120 minutes: commit the coherent checkpoint, document unresolved conflicts
   and update the cost estimate using measured work.

Then complete C/D/E in small integrated commits and run F once. Rough planning
allowances: source/profile reconciliation 1–3 additional hours, tool consolidation
and retirement 1–2 hours, final qualification roughly 30–90 minutes depending on
which identities change. These are estimates, not commitments or a reason to
pad work. Re-estimate after B; correctness conflicts can dominate the schedule.
Tool/document work can overlap source work, but root coordinates integration and
all resource-heavy jobs. Do not have agents build independent full compilers.

Stop an extraction step if it cannot preserve identity without changing semantics;
split that semantic change into its own reviewed transition. Stop broad deletion
when a dependency remains unresolved. Do not turn the cleanup into optimization
research merely to justify a changed product. Preserve failing controls and time
spent; success is a simpler working development system, not the number of files
deleted or the number of validation jobs launched.

## 8. How this serves the cold-build goal

Moving files is not a compiler speedup. This plan should remove tool duplication,
historical dependency chains, accidental rebuild inputs and repeated manual setup.
Any measured saving is reported at its actual stage. Source size can initially
stay similar while the checkout and conceptual model become much simpler.

The next optimization campaign then targets the measured whole computations:
complete numeric-ID verifier state, retaining checked semantic products, compact
parser/identifier boundaries and reducing representation reconstruction/teardown.
Use the consolidated profiler and the same frozen cold workload to compare them.
Incremental experiments remain a separately named capability; they do not replace
the cold source-to-executable objective or inflate its gains.

The final cleanup report should show the maintained source/tool counts, removed
historical dependencies, surviving backend capabilities and optimizations, cold
build/B1/B2/program-speed results, correctness/proof scope, restore checks and
remaining limitations. Commit and push each validated transition with exact
reproduction records. This planning commit runs no compiler or benchmark targets.
