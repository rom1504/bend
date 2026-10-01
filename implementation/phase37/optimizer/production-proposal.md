# Production proposal after the private-tree screen

Status: **proposal only; no compiler source changed and no result assumed**.
The companion saved-output derivation and controls are ready for root's serial
execution after the expanded Phase36 baseline. This proposal deliberately
separates a small nonrecursive mechanism from recursive tree workers.

## Decision table

| Screen observation | Next step |
| --- | --- |
| Guard-only materially changes speed | Account for that separately before attributing any dispatch gain |
| Zip wins, finite adds little | Implement only reusable nonrecursive sum matching/construction |
| Finite wins substantially beyond zip | Include acyclic scalar helpers and existing Bool decisions in that same worker plan |
| Only warp/component wins | Do not disguise an iterative tree-to-tree worker as a small match extension; implement only after a separate ordered-recursion proposal |
| None wins materially | Keep expanded coverage, record the negative experiment and select another mechanism |

The screen includes `finite` specifically to distinguish a reusable acyclic
worker from a much larger recursive lowering. The initial design names source
functions only as experiment subjects. Production may not inspect benchmark
names, source paths, constants, binder IDs or checksums.

## Acyclic sum workers

The smallest reusable route is a **private worker for a complete finite pattern
prefix**, under the existing whole-root scoped proof. A worker retains the same
tagged tree objects and runs only when its inputs originate inside that root.

Admission starts from the original checked definition and requires:

1. An ordinary nonforeign definition with known complete arity, no erased or
   dependent arguments, and existing local/pure type admission.
2. Closed nonnative constructors with a complete, unique constructor permutation
   ending at `Efq`; Bool matches may reuse existing admission. No partial/default
   matcher, lifted function, function-valued result or arbitrary native layout.
3. Only constructor-field binders and remaining original parameters in the
   prefix. Every arm consumes its complete specialized telescope.
4. A leaf body accepted by existing region analysis, extended only for nested
   **inert nonnative constructors**. Recursive nested constructor syntax is
   allowed; hidden helper calls, native conversion, arbitrary field effects or
   foreign values are not newly allowed.
5. An acyclic direct helper graph. Reject any remaining nonnative `JResidual`
   that can return to this worker. In particular, directly emitting recursive
   JavaScript calls for `warp` is **not** an acceptable implementation of the
   iterative saved-output result.
6. Shared visit/definition budgets, using existing failure/fallback behavior.

The useful unifying observation is that source matcher prefixes already contain
their binder structure. Do not invent a second pattern matrix. Preserve `Lam`
and `Mat` prefix nodes in a private wrapper plan, for example `JFinite{body}`.
Analyze each leaf with `j_region_expr`, its original binder environment and the
checked result type. This avoids changing global positional-slot allocation.

The emitter receives a list of argument expressions, initially `$p0...$pN`:

```text
emit_prefix(Lam(id, body), [arg, ...rest]):
    bind the original local id to arg
    emit_prefix(body, rest)

emit_prefix(Mat(ctor, arm, other), [arg, ...rest]):
    dispatch on the already forced argument's constructor
    emit_prefix(arm, [arg.a[0], ...arg.a[fieldCount-1], ...rest])
    emit the remaining complete constructor arms

emit_prefix(checked_leaf, []):
    reuse j_region_return for the original leaf result
```

Constructor field expressions must be bound before later scopes can shadow
their names. Existing globally fresh binder IDs solve source capture; generated
temporary scopes must still be explicit. Match order is retained, and only the
selected arm executes. Inert nested constructor emission calls the existing
`ctor` or produces precisely its nonnative object layout; no flattening, scalar
replacement or representation change is needed for the first implementation.

This is more general than extending `JUnpack` in place: `JUnpack` currently puts
fields after the last ordinary argument. It cannot represent the multiple
successive input matches in zip merely by removing its `left == 1` check.

## Reaching residual generic callers

This is the major implementation boundary, and must not be omitted from the
estimated cost. Producing a private zip function inside a region closure does
not optimize `warp`, which remains a separately emitted generic residual.

The saved-output experiment succeeds by calling a private worker only while the
complete scalar-root proof is active. A production equivalent needs:

* A generated module-private worker binding for each admitted definition, with
  its complete dependency names. Public `G[name]` descriptors remain unchanged.
* At statically known saturated calls to eligible workers, a private branch
  conditioned on coverage by the active proof; otherwise emit exactly the
  existing staged generic expression. Do not allocate a fallback closure on
  every call and do not expose the worker map through public exports.
* A scalar-entry fallback for roots that have a complete `JPure` graph containing
  at least one useful worker, but whose entire graph cannot be lowered by the
  current region planner. Reuse exact entry, canonical scalar input checks,
  `regionHostGuard`, `localGuard`, proof opening and `finally` closing. Force the
  original complete result before closing the proof.

The call-site branch may only reorder parameter evaluation across a match if
the proof establishes inert, fully materialized arguments and a total complete
match. The first implementation should further limit arguments to existing
variables, literals or inert constructor expressions. This covers the proposed
zip/leaf sites without inventing a general demand analysis.

An active proof is insufficient for arbitrary public reentry. Whole-root purity
must exclude callback-producing operations; error construction already suspends
the proof. The generated root must bind every live generic dependency, including
ones skipped by the new private call, to preserve public mutation behavior.

For native `Bool.xor`, prefer adding a narrowly checked residual-native signature
and runtime snapshot, then preserving its normal call inside the initial worker.
Only add private `!==` lowering after a separate direct-native control. Do not
silently add a new public intrinsic whose mutation behavior changes outside the
proof. This first candidate may be slightly slower than the hand prototype; the
checked actual-output screen decides whether its gain remains useful.

## Estimated implementation cost

These are inspection estimates, not measured line counts or time promises.

There is a smaller alternative if the zip-only result is already useful: inline
the validated prefix at a known saturated call site, inside an IIFE conditioned
on the active complete proof. Original globally fresh binder IDs can be bound
from captured argument temporaries. The generic expression remains the false
branch. This avoids a module-private worker registry and reaches the actual
residual `G.warp` call site directly. Give it a strict combined analysis/code-size
budget, for example 128 source nodes, and initially admit no recursion or
unbounded helper expansion. Estimated total is **120–220 Bend lines**, using
the same root proof fallback. Its risks are repeated analysis and duplicated
generated bodies; emitted size and normal compilation timings must decide
whether this is simpler in practice. The initial control should not substitute
an unmeasured inline form for the saved direct-call result.

| Work | Estimated Bend lines | New concepts |
| --- | ---: | --- |
| Complete finite prefix admission + emission | 90–150 | One private prefix-plan wrapper; reuses original Lam/Mat, region leaf analysis |
| Inert nested constructors + Bool native proof | 25–50 | Extends existing admission rules |
| Module-private worker wiring + eligible call branch | 45–90 | Private binding for existing function identity |
| Pure scalar fallback entry + useful-worker gate | 45–80 | Reuses existing scoped-proof entry protocol |
| **Total acyclic route** | **205–370** | **No new type representation or general optimizer IR** |

Runtime work should be limited to one additional captured native descriptor and
possibly a small proof-coverage helper. Adding a second independent guard system
would violate the intended design. The estimated source increase is about
1.1–2.0% of the current 18,174 Bend lines. A small zip-only gain may not justify
that cost; the decision table is meaningful.

The implementation should reuse one computed private plan during emission,
instead of rerunning whole-graph analysis at every source call. Whether this can
be passed through the existing definition-emission context or requires a small
module plan table needs inspection before selecting a patch. Repeating an
expensive planner per call would risk recreating the Phase35 compilation-cost
increase. Final normal compiler costs are mandatory.

A recursive tree-to-tree route would add another estimated 150–250 Bend lines
for structural child-call validation, multiple pattern environments and an
ordered reusable frame machine. That cost is **additional**, not hidden in the
acyclic estimate. Existing producer/fold frames are useful building blocks, but
their present proofs do not establish arbitrary mutual or nested recursion.

## Required gates before promotion

1. Saved-output controls and clean same-protocol screen, including original and
   guard-only control. Preserve all variants and failures.
2. Independent review of exact source/type admission, deferred-field refusal,
   dependency completeness, native Bool handling and callback/error reentry.
3. Checked B1 and Focus36 inherited ownership checks, plus actual-source finite
   sum fixtures: multiple constructors, multiple input matches, nested inert
   fields, aliases, nonnative marker names, refusals and live mutation witnesses.
4. Actual emitted entry counters tied to the final API, followed by clean
   execution on original bitonic and independently selected expanded inputs.
5. Expanded catalog transfer/regression run and normal checked compilation cost.
6. Existing justified integration, install/CLI and source identity gates. No
   conformance denominator, pinned upstream, historical module or prior report
   is silently rewritten to make the new worker pass.

The anticipated focused edit/build/semantic screen is under a minute after the
initial tools exist, but broad validation remains an integration action. If the
screen requires a larger worker, retain the narrowed experiment and make the
architectural decision explicitly rather than accumulating unrelated special
cases to reach a predetermined performance headline.
