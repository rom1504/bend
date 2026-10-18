# Phase107 constant propagation: independent static review

No concrete transformation bug was found in `inline/constant.bend`, reviewed
against `constant-spec.md` and `experiments/phase107/P107-012-scalar-constants.md`.
The final reviewed pass is 9,807 bytes, SHA256
`b8ddd581983f242d067e6c063d5511e7f25db76bd01285af2d530ade71a29516`,
commit `5fadc9e`. The intervening e9de89f snapshot added only three required
`+fuel`/`+depth` annotations to the initial 7c8a6e4d transformation. The final
change adds the identity prefilter reviewed below; transformation logic is unchanged.
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

**Final identity prefilter.** `nx_cp_eligible` contains exactly the existing
per-function binding/body/depth limits and is shared by the early scan and the
transforming function walk. The binding-count test now branches before traversing
the body. If no function is eligible, every function would have been returned
unchanged by the old pass, so returning the original program before verification
is a valid identity shortcut. If any function is eligible, the original verifier,
global caps, transformation and output gate still run. The early predicate is a
necessary condition for doing work, not validity or whole-program admission: an
invalid program can return unchanged, and a globally oversized program can have
an eligible function. Callers must not interpret identity output or a true
prefilter result as a validation certificate. No soundness issue was found in
this small final change.

**Coverage and limits.** Inspected fixtures cover invariant and changing loop
values, equal/differing branch joins, snapshots, effectful results, wrapping U32,
U64 nonpropagation, nested loops, parameter initialization and cascading loss of
facts requiring multiple header probes. The twelfth fixture now includes a
returning arm and a continuing sibling, with 96 frozen input/result rows across
the twelve families. Frozen independent observations and deliberate
stale-header/branch mutants remain execution gates owned by the root experiment.
The function/program/depth caps and nonincreasing-node/output-verification checks
bound publication, but do not prove pass correctness or guarantee low analysis
cost. Runtime gains and pass cost require separate measurement.

`selfhost/tools/performance/phase107/constant-capacity.mjs` adds 18
host controls: immediately below/at/above all five caps, invalid exact identity,
a literal-substitution witness, and exact pure-operand substitutions inside
ordered allocation/store/call/load/free roots. It independently counts JSON nodes
and compares the Bend count, checks complete identity on refusals, and retains
before/after graphs and source pins. Capacity graphs are not emitted or executed
as generated programs. The effect witness has an independent expected result of
9, while this host-only harness checks its exact transformed graph.

**Closing evidence.** The root-owned `constant-capacity02/audit-report.json`
records all 18 controls passing and pins the final b8ddd581 source. The completed
`constant-prefilter01/report.json` records 20 predicate controls and 78 identical
JSON/C/QBE products, explicitly reusing earlier finite execution evidence rather
than claiming new native executions. `constant-final01/report.json` confirms 78
product identities and independently interprets both effect graphs as 9, each
with one allocation and one free. `kernel-measure05/report.json` is complete and
passed with 18 native/JS kernel comparisons. These paths are under
`selfhost/build/phase107/`; the root also reports checked bridge22 and audit02
gates passing. This reviewer inspected the final source diff and retained report
status without rerunning compiler or generated targets. The independent review
and its writer are closed for the Phase107 freeze.
