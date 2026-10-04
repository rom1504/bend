# Phase45: remove the generic execution protocol from private work

The user requests aggressive progress from the current approximately 6× execution
slowdown toward parity or faster. Start from installed Phase44 checked04 at
`8f57b1b`; its pinned TypeScript comparison is 6.0832× with equal-point weighting,
8.3015× with equal-source weighting. These are a maintained corpus, not a random
sample of programs. Parity is the objective; no unmeasured gain is promised.
Upstream remains `018751270e800bc222a93dad7f257083ee53a5f7`.

## Evidence and direction

Phase44's shared ordinary IR is real, but removing local bindings and wrappers
left the larger runtime protocol intact. Records and Map still allocate heavily;
profiles contain apply, force, invokeExact and project. TypeScript's backend emits
direct positional calls, field access and SCC loops. A faster helper that retains
our protocol failed its Phase44 screen.

The target is therefore executed allocations and dispatch on private edges.
Public G/code/env/bound mutation and demand remain supported at boundaries. They
do not require every private edge to use public descriptors or argument vectors.
Unknown callbacks, getters, coercions and Error hooks can invalidate permission;
a source-purity assertion alone does not erase these boundaries.

## Independent first experiments

1. **Immutable result boundary.** Contextual workers currently require scalar
   results even though their internal proof admits native String. Admit exact
   immutable String results with unchanged scalar inputs and complete graph,
   provenance, prefix, host and dependency checks. Measure whether general
   String-returning functions actually acquire and execute a private worker.
   Follow-on owned record/array results need explicit reconstruction/alias proof.
2. **Projection scalar replacement.** Two inherited private emitters allocate
   native constructor projection vectors and immediately read their fields.
   Lower already proved String/Char projections through one shared plan with
   scalar field bindings; preserve evaluation order and generic fallback. This
   is a type/layout rule, not a benchmark-name rule. Count actual activation.
3. **Exact-entry state ablation.** Replace the private per-entry permission object
   with saved/restored lexical slots, retaining observable code.call/env order,
   reentry consumption and finally restoration. Test saved runtime bytes before
   touching production. This is potentially modest; reject if the screen is flat.

Each experiment has its own file under experiments/phase45. Source changes,
unchecked JavaScript derivatives, actual selected output and observed execution
remain distinct. Combine only survivors; preserve failed and inconclusive runs.

## Main architectural step

Use explicit private case/projection/call operations and positional live parameters
inside proved regions. Retire replaced source/text paths as they migrate. A shared
worker representation must express constructors, matches, branches, local values
and calls across arbitrary admitted ADTs, without a new whole-algorithm selector.
Public descriptors remain adapters. Begin with acyclic private calls and retain
existing iterative component execution until its tail transfers can be represented
with an explicit stack policy. Native recursion is not an acceptable replacement
for unbounded trampoline safety.

First make a small saved-output or IR vertical slice that removes matcher objects,
argument vectors or forcing on executed private edges. Check counterexamples,
activation and varied sources before expanding the implementation. Avoid adding
another helper around unchanged dispatch. Derive required capabilities from the
operations a region uses rather than assuming every primitive family is relevant.

## Fast loop and promotion

Root owns all target execution: CPU3, Node24.18.0, 1GiB heap, 2GiB process-tree RSS
cap, 2GiB free-memory floor and bounded per-job deadlines. Independent agents own
separate code/read-only investigations. Builds, profiling and timed execution
remain serial; code/review work can overlap jobs. Reuse existing supervisors,
checked workflow, prototype binding, qualifier and benchmark tools.

For runtime proposals, first run test-apply, owned-runtime and the 34-case exact
application differential where applicable. For compiler changes, build a checked
B1 and use the eight maintained suites plus mixed-feature composition fixtures.
Use arbitrary constructor/helper names, Unicode, shadowing, erasure, captures,
partial/oversaturated calls, public mutation, host hooks, Error reentry and deep
stacks. A transformation needs evidence that it activates, not merely emitted
unused worker text.

Run a 20/60-second selected screen against exact saved checked04 modules and
unchanged pinned TypeScript. Expand to unrelated inputs if the result survives.
Measure normal compiler requests and code size separately. Run the full 45-point,
23-source, 669-sample comparison only for a selected integrated candidate; never
pool the short screens into it. Report point/source/family weights and regressions.
Reserve full frontend/backend and installed CLI qualification for integration.

## Preservation and publication

Use only the new `selfhost/build/phase45` raw root; all previous raw campaigns
stay closed. Preserve the 103 unrelated starting files. Keep a campaign ledger
and report merged job occupancy separately from mixed analysis/code/review time.
Do not create a parallel validation framework or repeatedly requalify unchanged
components. Commit design, useful implementation milestones and final reports to
`selfhost/bootstrap` within existing authorization. Do not post PR comments.

References: [Phase44 report](../../implementation/phase44/README.md),
[IR contracts](../../selfhost/docs/JAVASCRIPT_IR.md),
[profiles](../../implementation/phase44/diagnostics.md),
[portable loop](../../selfhost/tools/performance/phase44/README.md),
[pinned TypeScript backend](../../selfhost/.bootstrap/upstream-phase23/bend2/comp.ts).
