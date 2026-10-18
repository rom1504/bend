# Phase107 constant propagation: independent static review

No concrete transformation bug was found in `inline/constant.bend`, reviewed
against `constant-spec.md` and `experiments/phase107/P107-012-scalar-constants.md`.
The reviewed pass is 9,070 bytes, SHA256
`7c8a6e4d0de9d111d352cf740db007ef23df676dd11a4bf49c46f7c2f424695f`.
Paths beginning `inline/` are under `selfhost/tools/performance/phase107/`.
This is a source audit; no target was built or executed for this review.

**Initialization and assignment.** Only declared U32 locals receive initial zero
facts, matching the Nx contract. Parameters start unknown. The verified combined
parameter/local namespace is unique. Assignment rewrites the right side using
the old environment, then removes the destination's old fact before installing
a resulting U32 literal. Therefore `x = x + 1` observes the old value, and an
independent earlier copy of `x` remains a valid snapshot. Ptr and U64 literals
never become facts. The existing literal folder only folds supported U32
operations; it leaves unsupported operations and other widths intact.

**Branches and returns.** Each arm starts from the same incoming facts; the join
keeps only matching name/value pairs. It considers both arms even when the
condition is constant. Including a terminating arm in a later join can lose
precision but cannot invent a fact absent from a continuing arm. Returns and
branch structure are retained. The verifier excludes statements directly after
an unconditional terminal return in a statement list.

**Loop fixed point.** `nx_cp_header` intersects each candidate header with the
abstract body exit. It never adds a name or changes a retained value. Fact names
remain unique, so equal old/new counts imply identical facts rather than merely
equal cardinality of different sets. Every nonterminal iteration removes at
least one fact; starting with `k` facts, `k+1` iterations include the final stable
check even when all facts disappear. Exhaustion returns no facts. This reasoning
depends on the subset invariant; a future richer lattice cannot safely reuse
the cardinality shortcut without revisiting it.

Only the stabilized header rewrites the condition and body. Retained facts hold
on entry and are preserved by one body iteration, hence by repeated iterations.
The loop exports that header, not facts from a single body execution, preserving
zero-trip behavior. During abstract transfer, a nested loop forgets every variable
assigned anywhere in its body; the actual rewriting walk analyzes that nested
loop separately. This is conservative even when the nested loop executes zero
times or contains early returns.

**Effects.** Calls, allocations, loads, stores and frees stay in their original
positions and control structure. Effectful results cannot produce a literal fact.
Other private scalar facts may survive because current Nx has no operation that
takes the address of a local register. This assumption must be rechecked if the
IR gains references to local storage or an effect that mutates caller registers.
Pointer arguments can contain rewritten U32 offsets, but pointer identities and
memory contents are not inferred by this pass.

**Coverage and limits.** Inspected fixtures cover invariant and changing loop
values, equal/differing branch joins, snapshots, effectful results, wrapping U32,
U64 nonpropagation, nested loops, parameter initialization and cascading loss of
facts requiring multiple header probes. An additional return-arm join control was
requested from the implementer. Frozen independent observations and deliberate
stale-header/branch mutants remain execution gates owned by the root experiment.
The function/program/depth caps and nonincreasing-node/output-verification checks
bound publication, but do not prove pass correctness or guarantee low analysis
cost. Runtime gains and pass cost require separate measurement.
