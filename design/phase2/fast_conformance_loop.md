# Phase 2: conformance with a fast development loop

## Objective and working window

Improve semantic compatibility with pinned upstream while making a single failure
cheap to reproduce, fix, and verify. Build reusable tooling and extend the native
host so larger batches can use the faster Bend implementation. Keep actual
language work in Bend and preserve all checking gates.

The user authorized a three-hour session, 07:10–10:10 on their clock. The observed
start was 2026-09-21 14:10 UTC; use 17:10 UTC as the execution cutoff. Commit this
design before implementation. Commit coherent changes and evidence during the
session, with the final report in `implementation/phase2/report.md`. Reserve time
for validation, documentation, and the final push rather than starting an
unbounded rewrite near the cutoff.

## Starting evidence

Phase 1 produced a checked compiler with a verified JS fixed point, faster Bend
index/lexer modules, a 57.5-second checked build/component workflow, and an
experimental native main-plus-Base host. The native executable compiled its own
frozen source to exactly the verified JS bytes in 264.9 seconds. Native small
program compilations take 1.67–2.07 seconds. These are artifact-specific findings,
not a certificate of full language conformance or native self-hosting.

For a small edit, upstream can build the Bend JS API in roughly 21 seconds and
that API compiles a representative test in 6–7 seconds. Building the optimized
native compiler takes roughly 96 seconds, after which tests take about 2 seconds.
Thus use the checked JS bootstrap for a few cases after an edit; amortize native
builds across larger batches or reuse an unchanged binary. The marginal native
build cost requires roughly twenty small compilations to repay at these timings.

The frozen earlier phase 1 corpus has now observed all 1,378 fixtures / 6,019
probes. Coverage is complete but conformance is not. The comparison retains seven
changed observations, including three native timeouts, two borrowed-list runtime
failures, a native signal-diagnostic failure, and a detailed diagnostic change.
All 919 positive check probes still accept. This is evidence for that older
artifact only, not for the latest source or a phase 2 candidate.

The negative audit separates 173 presentation-supported differences, 16 identified
phase/rule differences, 186 unproven intended-rule cases, and two correct deferred
compiler gates. A rejection at the wrong phase does not establish the intended
rule. Phase 2 must retain these distinctions rather than relabel every rejection
as conformance.

## Priorities

1. Establish a targeted, reproducible differential loop using the pinned upstream
   implementation and an explicitly identified checked Bend API.
2. Fix demonstrated semantic mismatches, especially invalid acceptance, missing
   syntax restrictions, and wrong execution. Preserve negative witnesses and
   nearby positive controls for every fix.
3. Extend native hosting to imported modules and required JavaScript foreign
   assets, without introducing host-language parser/checker implementations.
4. Run broader frozen validation and fixed-point checks as milestones independent
   of the inner development loop. Optimize only a measured bottleneck in that
   loop; further general backend micro-optimization is not the main workstream.

Diagnostic wording follows semantic obligations. Hardware-gated GPU execution,
cross-platform runtime behavior, and full diagnostic identity remain explicitly
separate from tested CPU/JS behavior.

## Targeted conformance architecture

### Reuse the existing protocol

Extend `tools/conformance/run.mjs` and its existing inventory, worker, judge,
process-group deadline, output cap, and artifact identity protocol. The current
regex/lane filter is useful but does not express an exact failing `(fixture,lane)`
queue or retain generated artifacts for replay.

Add exact selection of fixture/lane pairs, a nonempty selection check, rejection
of unknown/duplicate pairs, and failure-first selection from a previous report.
Every rerun is a new immutable attempt linked to its predecessor by hash. Preserve
strict full-suite `complete`; expose a separately named selected-result verdict.
A filtered run must never become a whole-suite pass. Unexecuted selected cases,
unsupported lanes, timeouts, crashes and hardware gates remain visible.

Retain requests/responses, bounded streams, generated code, replay commands and
identity metadata for failing cases (optionally all cases). Preserve source paths
needed for imports and foreign files, and distinguish an exact replay requiring
unchanged inputs from a portable copied reproducer. Record source/support/effect
hashes, compiler/runtime/host/adapter hashes, the upstream pin, Node/compiler
versions, resource flags and deadlines. Detect drift before claiming success.
Do not copy secrets or arbitrary environment variables into reports; record only
the explicit compiler configuration needed to reproduce the run.

### A live upstream reference

Add an upstream adapter using the pinned exported TypeScript compiler APIs.
The pinned CLI requires Bun, unavailable in this environment; invoking it under
Node is not an equivalent reference. Mirror the CLI's load/check/ownership/TODO
and execution gates for implemented lanes, including relevant host policies.
Support each lane honestly and mark unsupported effects or capabilities rather
than substituting the port's implementation into the reference.

Compare both live compilers with the fixture oracle and with each other. Keep
accept/reject status, actual phase, `checked`, diagnostics, exit code and execution
output separately. A shared wrong result cannot pass merely because both compilers
agree. An exact fixture pass and semantic agreement are different fields. A
frontend rejection cannot earn checker/proof rejection evidence, and a check-only
acceptance of a runtime-negative program is not automatically a soundness bug.

A thin paired runner should accept explicit API/runtime and case selections,
execute the reference and candidate through the same isolation protocol, and
produce a concise discrepancy list plus retained evidence. It should not rebuild
the compiler or invoke full self-hosting for every selected test.

### Build and feedback policy

Build edited Bend code through the existing checked upstream bootstrap workflow.
Use a fresh frozen artifact per source revision; validate API/build-report/source
identity before using it. Reuse an unchanged artifact. If adding a build cache,
key it by every compiler source module, runtime, relevant host/build tools,
upstream source identity and build options; a stale or ambiguous artifact must
fail closed. Reusing tests for unchanged code is not permission to skip checking
changed compiler input.

Start with one failing case and a few positive/negative neighbors. Measure total
build-plus-selected-test wall time, not just warmed worker time. Aim for roughly
one minute for an ordinary small edit and a few cases, using component builds
where useful. The target is an observed workflow budget, not a weakened deadline
or a guaranteed limit for arbitrarily large programs.

## Semantic repair workstream

Before each fix, run a fresh pinned reference and candidate on a small witness.
Separate current-source behavior from historical corpus observations. Retain a
before result, implement the rule in Bend, then test the witness, the upstream
fixture and adjacent valid cases through a checked rebuilt API.

Initial candidates from code review are hypotheses pending execution:

* Filling an existing law with `def ... -> NewType:` may replace the declared
  signature. A Base-importing witness removes the original fixture's unrelated
  undefined-`Nat` failure. Test both a changed type and a redundant same type.
* Law clauses may omit the leading-template restriction already applied to
  ordinary definition parameters. Test late `~` clauses and valid leading ones.
* Local assignment patterns may bypass the validator used for match rows. Give
  the invalid RHS an explicit type to remove an unrelated inference failure;
  preserve valid binders and constructor patterns.
* Imports after declarations may reach filesystem resolution instead of syntax
  rejection. Use a late existing Base import to remove an ENOENT mask.
* Reproduce `reg/borrow_fork_hold` execution and `io/stack_fault_trap` under
  controlled current artifact/resource settings before attributing the old
  report's changes to compiler semantics.

Do not replace a failed proof check with a parser rejection and call it a proof
fix. For acceptance bugs, include a well-typed neighboring example to guard
against over-rejection. For runtime fixes, check deep recursion, sharing,
ownership, effects and generated-program execution as applicable. Do not edit
the pinned human-written `bend2/bend.ts` or upstream fixture oracles.

## Native host expansion

### Explicit graph boundary

Extend the experimental host through a versioned explicit manifest describing
the main module, Base, available module paths and available JavaScript assets.
This first expansion can require a complete manifest; automatic import discovery
is a separate capability and must not be implied. The wrapper performs filesystem
canonicalization, snapshot/provenance management and process orchestration only.
It must not discover imports with regular expressions or implement Bend parsing,
checking, elaboration or emission in JavaScript.

Preserve both lexical import identities and canonical physical paths. Construct
native `FSource{name,path,text}` records and call the existing Bend `f_load_graph`.
That implementation owns dependency order, canonical deduplication, namespaces,
aliases, cycle checks and elaboration. Parse only reachable modules: an unused
malformed available source must remain irrelevant. Missing required graph entries
fail explicitly; there is no fallback to the TypeScript or JS compiler.

Use a transport whose paths/text cannot become executable source, with explicit
version, record boundaries, lengths/count limits, malformed/truncated-input
rejection and Unicode tests. The manifest and input snapshots are trusted only
after validation; retain their content hashes. Keep the existing main-plus-Base
entry compatible where practical.

### Foreign assets and phase boundaries

Keep all check, ownership, TODO, specialization, reachability, foreign, annotation
and layout gates. Determine required external files with `j_foreign_paths` on the
selected annotated definitions. Preserve first-occurrence order and the qualified
logical path used by `j_modules`; canonical paths are for filesystem access and
identity, not replacement of that logical binding key.

Read only required foreign assets. A missing unreachable foreign file must not
become an error. A missing required file must retain compile-phase, checked-true
evidence. Supply actual bytes as the existing `Source`/`Text` terms to Bend
`j_modules`, then invoke the existing emitter. Preserve builtin IO handling and
program/library export policy. No optional reporting difference is allowed to
hide an omitted semantic check.

Protect all source, module, asset, runtime, binary and manifest inputs against
output aliasing, including symlinks/hardlinks. Keep the temporary-output and atomic
publication behavior; failures and timeouts preserve an existing destination.
Detect input changes during a run. Do not publish partially compiled output.

### Native validation and harness routing

Compare exact emitted JS bytes and execution against the checked JS host for
nested/sibling/parent imports, diamonds, repeated imports, aliases, symlinks,
conflicting namespaces, cycles, missing modules, imported errors, templates and
ADTs, program/library modes, Unicode paths and strings, and unused malformed
available modules. Exercise reachable/imported/shared foreign assets, builtin IO,
missing reachable and unreachable assets, and invalid manifests/output paths.

Expose the expanded native path to targeted conformance through an explicit
adapter/configuration. Record actual compiler execution mode and declared
capabilities. If a selected lane is outside native scope, report it or choose an
explicit JS run; never silently relabel JS fallback as native coverage. Compare
elapsed batch work including manifest/build overhead before recommending native
for the normal edit loop.

## Validation, rollout and evidence

1. Harness unit/integration tests cover exact selection, empty/unknown cases,
   failure ordering, retained replay, process-group timeout cleanup, output caps,
   artifact/input drift and strict filtered-versus-full verdicts.
2. Differential regression cases establish each semantic fix before/after and
   preserve nearby valid programs. Rebuild actual Bend source with full checking.
3. Run the existing component and relevant backend/runtime suites on the combined
   candidate. Test native host boundaries and semantic matrix independently.
4. Freeze a candidate before broader sweeps. Keep old and new artifacts/reports
   distinct. Full corpus observations may run in background with unchanged
   deadlines; timeouts and GPU gates cannot be converted into passes.
5. Where the session permits, run a checked self-emission/fixed-point milestone
   after meaningful compiler changes. Native emission of matching JS is useful
   evidence, but is not a native self-hosting fixed point. A new candidate is not
   promoted solely on a filtered suite or successful positive examples.

Reserve physical CPUs for timed runs and coordinate agents so experiments do not
share a core. Fast targeted checks may run on other cores while a frozen milestone
continues. Do not pause a live test inside its timeout window. Record shared-host
limitations instead of claiming unrealistically isolated measurements.

The report must state implemented changes, exact artifacts and commands, measured
iteration/batch latency, before/after semantic outcomes, unchanged failures,
unsupported native scope, failed attempts and remaining validation. Documentation
must provide runnable build/select/replay/native-manifest recipes and be linked
from the repository README. Commit and push coherent milestones throughout.

## Session completion criteria

Deliver the targeted paired loop, checked and measured semantic repairs, usable
native module/foreign expansion with differential evidence, and updated docs plus
report. Report precisely any part that remains incomplete at the three-hour
cutoff. Full language conformance, every diagnostic difference, GPU execution and
default-artifact promotion are not inferred from this bounded phase. Prioritize
the highest-impact demonstrated bugs over maximizing a cosmetic pass count.
