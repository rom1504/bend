# Phase143 — remove repeated work from cold compilation

2026-10-26. Starting commit `4fd100d`; [design](../../design/phase143/README.md).

**The same-source cold build takes about20% less time.** The Bend compiler's
own execution falls374.677→296.541s. Including independently measured QBE,
assembly and linking gives390.347→311.758s. Including both resource supervisors,
launch/authentication and output verification gives393.979→315.310s.

The complete115,909,112-byte QBE product and machine object are identical.
The gain comes from less compiler work, not smaller output or weaker optimization.
This is one controlled cold pair, not a confidence interval or an upstream speed
ratio. The150s/75s/50s milestones remain unmet.

## What changed

The most important finding is that **an indexed definition table still rebuilt
its ordered list for every successful definition publication**. The checker also
searched the remaining raw declarations repeatedly to find a later definition.

The new private checker prepares exact first-later-definition information once,
updates the existing collision-safe index in the same order, and defers obsolete
childless-definition removal until it must return a complete canonical world.
It preserves the original law-fill, template, error, fresh-name and diagnostic
behavior. The original checker remains the independent reference and fallback.

Two smaller changes remove other repeated traversals:

- Ordinary erasure uses the existing full-name index for visited membership,
  retaining its exact ordered names, queue, facts and missing-name behavior.
- Fresh-variable admission tests a cyclic U32 range during one syntax traversal,
  replacing repeated scans for each candidate ID. It retains Var-leaf behavior,
  unsigned wrap and exact first-match environment/sentinel semantics.

All implementation logic is checked Bend. Host scripts observe, supervise and
compare products. There is no new cross-revision cache or backend replacement.
The only overridden entries are `p86_plan_loaded`, `nr_walk`, `nd_comb_fresh`.
Source grows63,659→63,983 physical lines:324lines,41 added declarations including
two data types. This buys one private semantic view and two bounded algorithms;
it is not a compiler simplification or a new universal IR.

## Controlled cold comparison

Both engines compile the **same Phase142 source**, SHA`15f5cada…7dac1`, using the
same prepared Base, runtime, CPU3 and complete independent QBE oracle. Each
request starts a fresh process with no previous-source semantic or object reuse.
OS page caches are not flushed. Acquisition of the already-built compiler,
Base and runtime is separate from using them for a cold request.

| Measurement | Baseline | Candidate |
| --- | ---: | ---: |
| Compiler process, including source/output I/O |374.677s|296.541s|
| QBE + assembly + linking |15.669s|15.218s|
| Sum of target build operations |390.347s|311.758s|
| Complete supervised build operations |393.979s|315.310s|
| Peak compiler RSS |1,071,353,856bytes|1,071,468,544bytes|

Machine construction is only about4% of the original total. Its small timing
change is not an optimization claim: the machine objects are byte-identical.
The earlier346.9s incremental cold-seed observation used an older input and
different path. Historical52s JS and144–164s C observations are also different
pipelines; none is substituted for this denominator.

[Metrics and identities](metrics.json) · [candidate](candidate.json) ·
[qualification](qualification.json).

## Fast experiments and rejected choices

The private checker passes20 complete-state controls. The original and both
ablations compare full worlds, indexes, memo/fresh/checked state and diagnostics,
not just a successful verdict. Ten additional controls bind the real prepared
Base and assert both the actual route and expected success/refusal. They include
law filling, TODO preservation, template instantiation/failure and a real hash
collision with `Unit`. Erasure adds12 full-closure controls; occurrence/range
logic adds47 explicit controls and72 constructed queries over real Lexer/Map
bodies. These tests and source review are not new mathematical proofs.

Hosted checking of1,000 small definitions falls1.677→0.279s. That6× local result
does not predict a6× full-build gain. An always-enabled prepared checker was
actually slower on small real programs: Lexer0.0782→0.0917s, Map0.0178→0.0244s,
closures0.0221→0.0340s. Finalizing the unchanged Base has a fixed cost.

Prepared-Base scaling at16/64/256/1024 added definitions gave candidate/original
ratios1.371/0.966/0.624/0.259. The production hook therefore counts at most256
eligible childless definitions and retains the original checker below that
conservative threshold. Legality and profitability remain separate.

The final N2 also has a paired native small-request check: three alternating
fresh-process pairs per input. Ratio-of-medians is0.981 for Lexer,0.993 for Map,
1.008 for closures; closure's median paired ratio is0.999. All outputs are exact.
This supports no material small-request regression, not a precise speed claim.
Every pair is retained in [native-small.json](native-small.json).

The alternative occurrence-set construction was not selected. The simpler
range predicate gave hosted paired geometric ratios1.005/0.507/0.306 for1/4/64
queried IDs; tiny intervals are noisy and early environment failure is roughly
neutral. The data do not justify an additional set-selection policy.

Several setup failures are preserved: two control-fixture source errors, the
gate's initial pattern-order source error, a row-format observer mismatch, and
a wrongly typed law-fill fixture. The last produced the same correct fallback
and TODO in original and candidate; an inferred fill then passed the intended
route. There was no demonstrated production semantic mismatch in these failures.

## Profiles and backend comparison

The new ordinary cold native profile has12,017 samples, zero loss and99.64%
process CPU coverage. Active contexts include lookup6.27%, ordered-list removal
5.52%, constructor ownership4.63%, text append4.59%, verifier lookup4.08%, parser
prior lookup3.86%, visited membership3.44%, and occurrence checks3.35%.
Physical destruction/reclamation occupies27.48%; this overlaps the owner
categories and must not be added as another potential saving.

The timeline exposes early parser/checker scans, middle erasure/constructor and
occurrence work, then verifier lookup and text construction. Active contexts
are not inclusive call stacks or exact pass boundaries. See the
[profile analysis](../../research/phase143/cold-profile.md).

A small optional diagnostic now timestamps exact existing dispatch entries by
relinking the unchanged compiler object. All11 markers occur once, in order,
with exact Lexer output and independently checked linked addresses. This costs
a small runtime build instead of another full compiler acquisition. Its
[pilot](../../research/phase143/milestone-pilot.md) is useful for the next precise
stage experiment; no full-source milestone timing or neutral-overhead claim is
made here. The initial sampler configuration and milestone-observer path failures
are retained with their corrected versions.

The same checked Bend implementation under Bun/JS passed small exact-QBE output,
but the full run hit the3GiB process-tree cap after230.97s during frontend work.
It was stopped safely, before OS OOM; it has no successful full-build ratio.
Current-source C execution was not acquired. The existing explicit-source
upstream-C route is available, but historical Clang acquisition already needed
about4GiB for a substantially smaller compiler. Its cost and argv difference are
documented in the [execution comparison](../../research/phase143/execution-backend-comparison.md).
Historical C figures are not presented as measurements of this source.

## Correctness and usable checkpoint

The exact integrated source is independently checked by pinned upstream.
Qualified Phase137 produces N1; N1 compiles its own source to reproduce the whole
independent QBE; N2 is built from that product. N1/N2 machine objects match.
Both focused19 gates pass, and N2 passes all45 frozen native programs. All16
positive focused products and all45 broad products match their QBE references.
Original proof and final-verifier declarations remain byte-exact.

Generated-program quality is preserved on these complete-product checks. We did
not rerun a broad runtime-speed campaign or establish full-language correctness.
This is ordinary native qualification; incremental-session and JS/C-specific
qualification remain separate. Installed/default selection and the qualified
Phase137 fallback are unchanged. The new N2 checkpoint is available explicitly
through `candidate.json` for subsequent cold-build research.

## Research cost

The57 guarded jobs total40.91min on one root-owned CPU3 execution lane:
acquisition8.12min, controls1.35min, measurement17.53min, profiling6.66min and
qualification7.25min. Eight failed jobs cost4.56min, mostly the bounded full
JS-hosted attempt. These categories partition guarded time; failures overlap
them and must not be added again. Source analysis, implementation, bounded agent
audits, report preparation and archival work are additional wall time. Token or
quota billing is unavailable. The receipts retain every guarded attempt.

The evidence capsule retains controls, method versions, source snapshots,
samples/owner bindings and the exact diagnostic executable. It also retains the
baseline and new N2 executables and N2 object for native-first recovery. Large
generated APIs/QBE/assembly are omitted; their identities and reproduction
commands remain in the receipts. This is a measured checkpoint, not a portable
binary release or a replacement for independent checking.

All12 Python observers parse and all7 JavaScript observers pass syntax checks.
The staged whitespace check reports only the frozen `override-v02.bend` trailing
blank line, retained to preserve the measured module identity.

## What remains worth doing

First reuse the inexpensive stage probe or retained-object profiler on this new
engine. The baseline's percentages cannot simply be treated as its residual
profile after removing78s of work.

The clearest structural follow-ups are an exact parser-prior index, an earlier
constructor-ownership view shared across erasure/lowering, and compact verifier
value identities. Preserve first-match/shadowing/first-False semantics; existing
indexes are not automatically equivalent. Rendering and representation work also
remain substantial. These opportunities should be tested on actual consumers,
including preparation and reclamation, before another full build.

The present small query buckets alone do not establish a route to150s. A fair
same-source native-C execution comparison would help distinguish remaining QBE
generated-code cost from unavoidable work in our algorithms, with acquisition
and a safe higher memory budget charged explicitly.

This change makes compiler-bound experiments cheaper. It does not demonstrate
recursive research acceleration: agent time, acquisition, qualification and
failed attempts must still be included in any such experiment.

[Reproduction tools](../../selfhost/tools/performance/phase143/README.md) ·
[cost accounting](costs.json) · [evidence inventory](evidence01/inventory.json).
