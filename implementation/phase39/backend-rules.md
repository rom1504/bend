# Phase39 retained JavaScript backend rules

These rules are present in the selected checked05 candidate. Final performance
and release integration are pending; the installed Phase37 image retains its
own validation. See the [Phase39 report](README.md)
and [four-owner protocol](new-owner-gates.md).
The runtime bytes and public representation remain unchanged. The rules add
emitter cases using the existing graph proof, plan tags and private-entry
protocol rather than a general optimizer IR.

`j_region_number_counter` also applies to ordinary eligible scalar Nat loops.
The predecessor must occur exactly once, as the first saturated self-tail
argument; the use walk includes annotations and closures. Existing admission
establishes a canonical Nat below 2^48, so the private decrement and zero test
are exact Number operations. The captured `regionCounterNumber` conversion does
not call a replaced global `Number`. Other Nat slots, observable predecessor
arithmetic, results and public arguments remain BigInt. Failed admission retains
the original matcher/trampoline path and its demand behavior.

`j_region_root_done` reuses `j_tree_scope` around eligible residual root work.
This requires the existing scalar/flat-record signature check, a residual and
an independently proved pure original graph. The full emitted `$guards` closure
and public host/entry checks stay intact. The scope exists only while that call
executes, restores its predecessor in `finally`, and is suspended during mutable
Error construction. It is never a cache across public calls. Numeric roots that
already had one outer scope do not gain another scope optimization.

`j_component_plan` recognizes a bounded two-child structural component: the first
argument has a closed nonnative datatype, there are at most eight arguments and
512 core nodes, and typed lambda/match prefixes have bounded depth. Each
recursive leaf has exactly two strict independent `Let` RHS self calls whose
first arguments are proper field descendants of the original first input.
Result binders must be fresh relative to that prefix environment and absent
from both RHSs. Other leaves contain no self reference. A complete `JPure` graph
must pass, and another graph definition may not reference the worker.

The private helper saves original argument vectors in explicit left/right/combine
frames. Ordinary leaf and combine emission retain the original environment;
tagged objects and child aliases are preserved. Entry requires an active proof
covering the whole graph. Public trees, getters and raw entry do not acquire
ownedness from this rule; partial calls retain their existing application stages.
Unsupported/dependent shapes and mutual helper backedges retain their applicable
fallback. The common `j_l_def` hook emits each `$tree` declaration using the same
context definition used by call planning; selected annotation-expanded bodies
are not a second eligibility authority. Controls require every emitted helper
call target to resolve to exactly one declaration.

`j_producer_plan` retains the existing two-child producer first, then considers
a unary producer. There must be one recursive reference, a saturated known
combiner with at most eight arguments, and a recursive child at exactly the
Nat predecessor. Existing scalar-input/recursive-sum result restrictions, graph
closure, typed lowering and node budgets still apply. Earlier arguments are
saved before descent, the child completes, and later arguments run during
unwind before the private combiner. This preserves first-error order even when
Nat computations fail before, within or after the recursion.

Only the already proved `@producer` context admits bounded nested constructors.
Their leaves use the existing atom/native-primitive grammar, and every field
still passes typed constructor/argument planning. Arbitrary helper calls inside
those fields remain ineligible. The unary path reuses `JProducer` with an
existing flag and child index; it introduces no new plan datatype. Shared
subtrees retain their original identity, and deep traversal uses explicit
frames rather than recursive JavaScript stack growth.

Actual checked-output owner controls cover Number admission/refusal, the entire
ray guard closure, host mutation/reentry, complete component structures, alias
identity, deep tail cycles, and unary pre/child/post error order. They must be
rerun against the final selected API; old screening builds are not release
evidence. Synthetic fault injection and diagnostic owned-input adapters are
identified separately from actual source-root admission.

The known-callback experiment was rejected. Its direct call saved a little
against its own scoped variant but was slower than the original generated
program. Function-valued interfaces therefore remain outside `JPure`; this phase
adds neither a general callback domain nor list fusion. Source expands by
364 physical Bend lines and 42 definitions across the whole compiler, with no
additional module/type/law. Compile cost and whole-program gains require their
separate final measurements.
