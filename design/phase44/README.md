# Phase44: a composable JavaScript backend

User authorization: refactor the compiler into a clean modular IR and composable
backend, then optimize language constructs across programs. This replaces the
previous strategy of extending one workload-oriented eligibility path at a time.
The installed Phase43 checked14 release at `69d8c70` remains the reference until
a new candidate qualifies. Upstream stays pinned to
`018751270e800bc222a93dad7f257083ee53a5f7`; no PR comment or upstream migration.

## Problem and success criteria

Phase43's maintained 45-point corpus costs 6.161075 times TypeScript execution
time (equal point weighting). Its optimization rules recognize typed source
shapes, not benchmark names, but their separate purity, ownership, graph and
emission paths do not compose reliably. Some nullary applications remain generic
although emitted private workers exist. Source grew to 21,440 lines/2,413 defs;
Map compilation became 4.105 times slower than the prior release.

The new backend must make ordinary operations explicit, share reusable facts,
and remove replaced emission paths. An extra IR definition or a new whole-program
recognizer alone does not satisfy this phase. Runtime improvements, compile cost,
code size, semantic qualification and architecture migration are separate claims.
Parity is an objective, not a predicted outcome.

## Modules and ownership

The dependent checked `KTerm` remains the frontend/checker representation.
`src/back/js/ir/` is a separate runtime expression representation, implemented in
Bend. It is a structured tree initially, not a new SSA/CFG framework.

| Module | Responsibility |
|---|---|
| `model.bend` | Typed runtime operations and parameters; no inference or text |
| `lower.bend` | Resolve typing, erased slots, call chunks and delayed bodies |
| `facts.bend` | Conservative reusable operation/boundary facts |
| `simplify.bend` | Local passes over IR; no source-name optimization rules |
| `emit.bend` | Print established operations; no new type/purity decisions |
| `statement.bend` | Structured statement emission with explicit lexical scopes |

Initial operations are Local, Global, Null, Apply, parallel Let, Lambda and
delayed Match. Apply owns one valid saturation chunk and distinguishes tail
messages from forced calls. Erased arguments become Null without lowering their
source. Global access remains observable and may reevaluate computed initializers.

Two explicit migration boundaries retain legacy constructor/private lowering and
inherited guarded call selection. They are opaque to motion, deletion and alias
rewrites that would require seeing their source uses. Their coverage must be
reported; do not call a whole-function opaque wrapper a migrated function.
Migrate these boundaries in subsequent slices only when their behavior is explicit.

## Sequential implementation

### 1. Replace ordinary lowering without changing emitted behavior

Route real ordinary application chunks, functions, matchers and parallel bindings
through the typed IR. Retire their replaced KTerm-to-text implementations.
Retain exact output spelling where practical so byte identity is a strong first
check. Existing deep closure, constructor delay, primitive and guarded worker
paths remain explicit adapters with recursive ordinary children entering the IR.

Build a checked B1 with the maintained equality derivative; first compare a new
independently authored composition fixture and existing backend semantic probes.
Then compare the full maintained emitted corpus against the frozen Phase43
modules. Byte identity is artifact-specific evidence, not universal correctness.

### 2. Add general local passes and statement emission

Implement bounded local alias facts without treating a global load or opaque
adapter as pure. All parallel RHS expressions retain the old scope; a rebinding
invalidates aliases whose key or target is shadowed. Keep bindings when opaque
source uses cannot be transformed safely.

Emit nested Let bodies as statements and blocks where a function body permits
it. Evaluate all RHS expressions into private temporaries before introducing the
new source bindings, then emit the body in a nested lexical scope. Preserve
closure snapshots, delayed arms, exception order and trampoline returns. This
general lowering targets any eligible binding sequence, not an algorithm family.
Measure actual output; JavaScript engines may already optimize some IIFEs, so no
large runtime improvement is assumed.

### 3. Share planning facts and extend direct execution compositionally

Remove demonstrated repeated analysis before introducing new expensive passes.
Current code rewrites instance bodies twice and repeats some purity/call-graph
walks during emission. Reuse immutable per-definition or per-plan facts under the
same request/book identity. Measure normal compiler requests as well as program
runtime; fewer source walks are a hypothesis until timed.

General direct-call transformations must separate worker legality from permission
at the call site. Known callee and arity do not alone authorize bypassing mutable
public descriptors. Unknown/foreign calls can invalidate facts about host state.
Use explicit effect/demand boundaries, original fallback and scoped permission;
do not expand another scalar-only whole-program recognizer. First test the cost
and semantics of a local intervention before integrating a new runtime mechanism.

Public library G/code/env/bound and host-hook observations are stronger than the
upstream default wrapper interface. Retain that existing contract during this
phase. Closed executable assumptions must be explicit and cannot be substituted
for the library benchmark contract to claim parity.

### 4. Qualify, measure and consolidate

Run independently authored combinations of arbitrary ADTs, helper boundaries,
nullary/multiple arguments, partial/captured/unknown functions, recursion,
wrapping arithmetic, effects and reentry. Use pinned TS for shared value oracles
and installed Bend for its additional public runtime boundaries. Existing demand,
erasure, parallel shadowing, deep execution and foreign/native gates remain.

Measure changed output on the complete maintained corpus with controlled serial
roles, plus fresh feature combinations. Report strict median changes and all
regressions, geometric ratios by point/source, allocation/profiles when useful,
compile request costs and source/module growth. Do not pool short screens into
the final corpus result. Broad frontend checks and release installation happen
at integration, not for every IR edit. Preserve the old installed release.

## Work and resource discipline

Independent agents own IR schema, lowering/printer, analyses, validation and
review. Root owns integration and all heavy processes. Module ownership is
explicit; agree interfaces before editing, then build a useful vertical slice.
No repeated unbounded design investigations or separate per-feature release
frameworks. Reuse the existing checked workflow, acquisition, benchmark and
resource supervisors. Keep one experiment file per architectural claim and a
single campaign ledger; preserve consumed inputs and failed attempts.

Normal jobs: Node24.18, CPU3, 1GiB heap, 2GiB process-tree RSS ceiling, 2GiB free
floor, one heavy job at a time. Stop on resource limits. Baseline acquisition,
semantic validation and profiled runs never overlap runtime timing. Development
screens use 20/60 seconds; full 45 timing uses the retained three serial batches.
Track jobs separately from labeled analysis/integration/review windows; do not
describe unexplained elapsed time as validation waiting.

The 103 unrelated starting files and all closed Phase43 evidence are protected.
Commit design, implementation milestones and final report to `selfhost/bootstrap`
within existing authorization. Final architecture documentation links from the
compiler README and states which old paths remain and why.

## References

- [LLVM analysis and transform passes](https://www.llvm.org/docs/Passes.html)
- [OCaml Flambda simplification and effect analysis](https://ocaml.org/manual/4.14/flambda.html)
- [GHC demand analysis and worker/wrapper](https://ghc.gitlab.haskell.org/ghc/doc/users_guide/using-optimisation.html)
- [Phase43 measured report](../../implementation/phase43/README.md)
- [Checked development workflow](../../docs/PHASE5_DEVELOPMENT.md)
