# Phase173: specialize wider rebuild interfaces into one owned decomposition

The accepted two-argument experiment removes repeated root ownership work from
`setter(root, F(getter(root), extras))`. Root reports an 11.05% runtime gain on
unchanged `f_pattern_sub` and 48.29% on the unrelated packet workload, with
independent complete-value oracles. Those are the established small-workload
results; they are not a forecast for this extension or a whole-compiler gain.

The next source-level obstruction is an interface, not a missing backend IR:

```text
k_rebuild(t, nm(t), ix(t), qt(t),
          nq_layout_subst_list(ks(t), id, value), rm(t), kb(t), ke(t))
```

`selfhost/src/core/term.bend:k_rebuild` accepts root plus seven arguments. Its
KTerm branch preserves the original tag and substitutes the supplied metadata;
its KLambda branch additionally preserves the original quantity-presence flag;
its KLiteral branch ignores the arguments and returns the original variant.
The measured two-argument recognizer declines this interface before building a
semantic plan.

## Smallest extension

Specialize the setter's verified row at the actual call, then reuse the existing
`P173ODRow`, one-replacement planner and final emitter. There is no new backend IR,
calling convention, runtime helper, verifier exception or general inliner.

The new call collector permits root plus two to seven arguments. Each argument
must be one of:

* A saturated, ordinary getter applied to exactly the same root variable.
* An already evaluated Var, NWord or authenticated leaf NStatic, without the root.
* Exactly one saturated ordinary call `F(getter(root), extras)`, where extras
  are the existing permitted atoms and do not reference the root variable.

The setter's actual erased Mat arm must contain the certified constructor-field
lambdas, then precisely the declared remaining argument lambdas, then the same
constructor. Each output field must be an original field variable or a formal
argument variable. No unknown expressions, helper calls or alternate constructor
are admitted in that row. The ordinary closed Data catalogue, field quantity,
count, constructor identity and scalar-mask checks remain.

Constructor-field lambdas retain the existing quantity-2 requirement. Setter
formal arguments may have quantity 1 or 2, since the call has already evaluated
them; erased/foreign quantities and duplicate or field-colliding binders refuse.

For each referenced argument, the analysis resolves its provenance once:
unchanged getter values become the appropriate root field or a permitted closed
constant; caller atoms remain atoms; the one computed argument becomes the
existing symbolic replacement variable. The computed getter is expressed in
the same field basis. The specialized row must use its replacement exactly once.

An independent audit found an important error in the first unexecuted draft:
resolving only arguments mentioned by the setter would erase an unused getter
call without proving that getter was a pure projection. The implementation now
authenticates **every** getter descriptor for a selected row, including ignored
arguments before and after the computed call. Any refusal leaves that variant
on the complete original fallback. Inert compiler-data controls represent a
non-projecting getter and verify refusal; the represented function is never
executed. This negative finding is part of the admission design, not a runtime
failure that was hidden by benchmark selection.

Resolution builds each output field directly. It does not repeatedly substitute
into a partially modified expression, which could accidentally rewrite an
inserted caller variable. Caller atom IDs must be disjoint from helper field IDs
and the symbolic replacement. Existing final fresh-ID checks remain in force.

The generated match therefore contains the same strict replacement Let and
constructor expression that the original one-replacement emitter already
supports. `present` on KLambda survives because it is an original positional
field, not an inferred default. KLiteral does not use the replacement, so the
analysis emits no specialized row for it. The complete original call remains in
the fallback and evaluates every original argument, including an ignored F.

## Modules and gates

Select these experimental modules together:

1. Existing `owned-decomposition-summary.bend`.
2. New `owned-decomposition-multi-summary.bend`.
3. `owned-decomposition-multi-transform.bend` **instead of** the original
   transform. Its only behavioral edit is the wider-arity entry; the original
   two-argument route and planner/emitter remain unchanged.
4. `owned-decomposition-multi-call.bend`.
5. Existing controls, then `owned-decomposition-multi-controls.bend`.

The current pure or QBE-scoped permission/entry module is unchanged. This
extension neither grants effect permission nor authenticates arbitrary foreign
providers. Its semantic facts come from the unchanged checked source book.

The new finite export `p173om_controls` contains 30 structural controls:
single-computation admission, extra computations, binder collisions, field
mapping, closed constants, unknown origins, duplicate replacement use and
unused-result fallback, all-argument validation and formal quantities. These
supplement the existing 16 controls. They are
not a source-semantic proof.

The ignored-getter counterexample has a paired positive row with the identical
constructor/schema and a certified unused getter. Both use the encoded erased
constructor identity, matching the raw fixture body's passage through normal
erasure. This prevents a name mismatch from making the refusal test vacuous.

`p173om_layout_summary(request)` is an explicit diagnostic query for the actual
checked k_rebuild/nm/ix/qt/ks/rm/kb/ke definitions. Those names are query inputs;
they are not an implementation whitelist. Require real summary admission and a
reported rewrite in unchanged `nq_layout_subst` before machine construction.

Reuse `borrow-layout-workload01.bend` and its complete output oracle for actual
compiler transfer: matched and unmatched variables, malformed variable children,
both lambda representations and quantity-presence values, unknown syntax tags,
literals, aliased roots and aliased replacement terms. For an unrelated transfer,
`owned-decomposition-multi-workload.bend` retains the original packet workload's
full output while changing only its helper interface to a five-argument rebuild.

After source and finite gates, inspect the emitted native worker for removal of
root getter/reconstruction ownership operations and continued stack safety.
Only then run controlled native timing and event counts. Preserve the existing
two-argument measurements and compare identical workload sources under each
compiler, rather than timing two differently written algorithms.

## Risk, cost and expected scope

The main correctness risks are branch-local parameter IDs, accidental changes
to quantity or constructor-variant metadata, duplicated computation, discarded
strict arguments and atom/field capture. The implementation uses bounded
authenticated rows and keeps unsupported variants on the original fallback.

The implementation is a small extension in concepts but adds experimental
source and tests. A reasonable work budget is roughly 30–60 minutes for the
bounded implementation and review, then 20–40 minutes for decisive source,
admission and native gates if no new obstruction appears. Full-image
qualification should follow only after the extracted compiler workload wins.

The larger-arity entry considers more applications. It now delays setter book
and arity lookup until the bounded argument collector has accepted exactly one
computed call; all-atom or invalid argument lists avoid that lookup. Before
promotion, measure complete compiler-request overhead. If lookup still
dominates, reject candidates without the nested-computation syntax before other
book/arity queries. Reuse a
selected helper schema only when measured repetition justifies it; do not add a
general cache as part of this experiment.

The exact all-getter pattern appears in `nq_layout_subst`, `nw_restore` and
`jd_word_unanns`. Other compaction/erasure calls supply constants for removed
metadata and source spans; the atom path may admit them. Calls with another
computed metadata expression, a precomputed child variable, unsupported setter
shape or non-atomic extra arguments still decline. A source count of rebuild
calls is not a count of admitted hot sites, so no whole-compiler gain is claimed
before the actual admission census and profile transfer.

At preparation time this agent has run only source inspection and mechanical
delimiter checks. The parent owns target execution and the controlled lane.
