# Checked03 scope and guard review

This review inspected the final frozen checked03 changes without running a
compiler or test. The finite proof-scope review is independent: the reviewer
did not author that change. The DataView portion is explicitly author review;
the reviewer proposed its original correction and subsequent narrowing.

The selected API is
`ea5db4a2857ffddce8263406041f56acc9b613754660d7a20c6b7c58682c86a1`.
Reviewed `finite.bend` SHA256:
`8998f43394e465ab9d3add60ca2dd432b633faca57249dc0063d4222cb4a1cf6`.
Reviewed runtime `core.mjs` SHA256:
`2db3975c945912eb50fecb79865fe597aefd101b145d8dabb9d91b3df718e4f9`.

## Independent finite scope review

The change in `j_finite_useful` skips a selector whose entire function signature
has scalar inputs and a scalar result. Such a selector can still use the existing
finite call optimization when a valid proof is already active. It simply cannot
justify creating another root proof by itself. A graph needs at least one
otherwise eligible selector with a non-scalar input or result before the new
root wrapper is emitted.

This is a profitability restriction, not a new ownership shortcut. It narrows
the circumstances that open a proof and changes neither finite readiness nor
typed prefix validation, materialization assumptions, dependency coverage,
public fallback, exact-entry protocol or `finally` cleanup. The scalar case
falls back to the existing compiler path. No new correctness blocker was found
in this source inspection.

The criterion is structural and contains no source name, benchmark identity or
point constant. Its usefulness is plausible because direct scalar arithmetic
selectors avoid little allocation while a new root pays the complete host and
descriptor guards. That reasoning is not a measured speed claim. A graph can
still contain a qualifying selector only in an unexecuted branch; the policy is
a conservative cost filter, not a dynamic profitability model or a guarantee
that every admitted root is faster.

The new `kc` gate also avoids finite-readiness analysis for an already scalar
signature. Repeated graph and call-site analysis remains elsewhere. Actual
checked-request compilation measurements remain required to assess that cost.

Root's completed `finite-controls02` report records 154 oracle observations,
nine admission records and 76 boundaries, all passing on the candidate emitted
by checked03 in `finite-cohort05`. Its 44 diagnostic selector sites include live
entries for all five intended selectors. Both 30,000-step tail cycles record
one outer root entry, a terminal finite-selector entry and an inactive proof
after completion. The added `leaf_scoped` case provides the needed proof scope;
older `choice_check` and `leaf_check` paths retain differential coverage without
incorrectly requiring them to use this newer wrapper.

Finite report SHA256:
`66e10f892921d1ddb2b21ecc050b5d0d92e958ed678459783a52f026f62ae127`.
This is inspection of root-run evidence, not an independently executed test.

## Author review of the narrowed DataView guard

The final diff removes exactly the live global-constructor and constructor-
prototype records plus the prototype-parent snapshot/comparison. It retains the
shared view's exact prototype check, all four own-method refusals, and all four
captured prototype method checks. The runtime still constructs the view only
once at import; all later accesses use that retained instance.

Therefore replacing the unused constructor binding or changing the captured
prototype's parent cannot affect these four method lookups: the guarded own
data methods terminate lookup before the parent. A leaked view with an own
method or replaced instance prototype is still refused. Future code that creates
a new DataView inside a guarded region would add a new constructor obligation.

The earlier checked02 cast/DataView successes do not validate this changed
runtime. Fresh checked03 source emissions and all actual cast/DataView controls
are required, followed by final owner closure and broad regression gates.
Performance conclusions must come from the final clean measurements, including
short scalar roots, rather than from counting the three removed reflection
checks.
