# Phase173: expose known state transitions as control-flow edges

Status: private experiment, not production-selected. Root's `dispatch-api01`
source acquisition passed in 15.24 seconds. `dispatch-finite01/report.json`
passes all 30 new renderer controls, 25 argument-adapter controls and 21 SCC
controls. Native execution and runtime measurement remain separate gates.
No target was executed by the implementation agent.

Revision1 transferred nine SCC workers but conservatively refused the two
largest relevant components. Source-grounded inspection found the exact cause:
`p173dj_terminal` recognized a conditional only as the final statement. The
raw `p173match_15` body at `12/no/12/yes/21` and `p173branch_37` at
`9/no/8/yes/20` both contain a non-final conditional followed by scalar work,
calls and a common result. Those are valid under the independent flow verifiers.
The unchanged legacy snapshot spelling in actual QBE also excludes the typed
emitter route as the cause of this refusal.

Separate version2 files add one general rule: a non-final conditional can reach
the common suffix's terminal. The original final verifier still checks branch
liveness, early transfers, forbidden statements after transfer and result types;
the plan's comparison-temporary and backedge checks are unchanged. Six additional
controls cover common results/backedges, one-sided early return/backedge, and
preservation of existing Boolean-diamond and ordinary branch rendering. The
version2 suite contains 36 controls; it is not yet reported as executed here.

## Measured reason to try this

The argument bridge removes the principal store loops' scheduler dependence.
The new complete computation nevertheless remains slower than the original
recursive-term version. Inspection by the independent vertical agent finds 50
literal-tag compaction backedges returning to the same 36-way dispatcher. Its
machine code still executes comparison/Boolean/test chains, with stack traffic
between tests. Those observations establish that dispatch survives lowering;
static instruction counts alone do not establish its dynamic cost.

The existing IR already contains the missing fact: each transition's first
`P113DAgain` value is a literal state. The proposed change exposes that state as
a direct control-flow edge, while leaving every value transfer intact.

## Minimal implementation

`dispatch-jumps.bend` is a private Bend render-plan module. Its overlay changes
only `p113e_stmts`, and only when called immediately after the existing
`@p113_loop` label. That seam covers the ordinary direct emitter and its existing
heap-hoisted variant. Their function prologues, array transformations, scratch
allocation, final IR verifiers, runtime and function/result ABI remain unchanged.
The separate typed/P126 emitter paths are outside this first slice.

Recognition requires:

* A selector in the first full-word function parameter, with at most 32 lanes.
* Only already-hoisted alloca declarations before the dispatcher.
* An exact chain of full-word equality tests against distinct 32-bit literals.
* Distinct comparison temporaries, each used only as its own dispatch condition.
  No arm may read or redefine any of them.
* Terminal arms and correctly sized recursive argument vectors.
* At most 63 tested arms plus a default, and a free private label namespace.

No source or function name is recognized. A local plan retains the exact arm
bodies, including their original lane-to-local bindings. It emits the ordinary
dispatcher for initial entry and dynamic backedges. A literal backedge first
uses the existing full-word `p113e_snapshot` over **all** values, then performs
**all** parameter assignments, and finally jumps to its exact arm label. An
untested literal selects the existing default arm. Nonliteral or wide literals
retain `@p113_loop` as their target.

The context renderer retains the existing scalar lowering, width-pair and mask
optimizations, Boolean diamonds, result conventions and nested branch handling.
Unrecognized functions use the original renderer unchanged. This introduces no
new `P113D` instruction, native runtime helper or verifier exception.

The comparison-temporary condition matters: merely bypassing a verified test is
unsound if an arm observes the result left by that test. Likewise, backedges
must not skip observable prefix work. Alloca/test-name overlap is already
rejected by both final verifiers as a pointer/value redeclaration; a negative
control retains that boundary rather than weakening it.

## What could disappear

The immediate target is repeated state comparisons. A second hypothesis is that
direct successor blocks let QBE infer destination-specific lane liveness,
eliminating dead tag writes, unused padded copies and spills. The Bend emitter
still writes the tag and every parameter: removing them is QBE's responsibility.

Neither effect is presumed to remove allocation, array operations, reference
counts or output construction. Layout changes can also hurt performance. Compare
the identical frozen corpus, source/preparation policy and output oracle.

## Cheap gates before a broad campaign

The finite suite `p173dj_controls` has 30 initial controls. It checks noncanonical
names and noncontiguous tags; both independent final verifiers; exact parallel
swap ordering; selector reads within arms; default and dynamic transitions;
scratch lifetime; refusal of effect/load/set prefixes, observed temporaries,
duplicate states, differing selectors, malformed comparisons, nonterminal arms,
wrong arity and namespace/nested-entry collisions. Rejected plans must reproduce
the old emitted text.

The next execution gates reuse the existing owned-list swap, shared-alias and
deep-cycle workloads. Then inspect the full store's emitted QBE: its known
backedges must target arms, while initial dispatch and prologue allocation stay
present. Compare assembly and clean runtime against the frozen argument-bridge
candidate. Only a demonstrated benefit justifies wider integration or support
for additional emitter paths.

Source checking, finite structural controls, independent IR verification and
native execution establish different properties. None is a general mathematical
proof of the compiler, and this experiment adds no such claim.
