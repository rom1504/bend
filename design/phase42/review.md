# Phase42 adversarial review plan

Baseline: Phase41 checked01, commit `5ec82b3`, API
`9900abf49719575db7f7bbee32c6b16e10bcd554f9de22cde0799eb859cc6f0b`.
Reviewer owns only this document, the implementation review, and `review/` tools.
Root runs compiler acquisition, semantic jobs and benchmarks. No historical raw
evidence is modified. A saved-output ablation is never a checked source result.

## Minimum matrix before source admission

| Risk | Minimum discriminating case | Required observation |
| --- | --- | --- |
| Whole private component direct calls | Replace each transitive dependency binding; then install a getter returning the original binding | Exact generic result/error and getter/code trace; optimized entry count unchanged; proof closed |
| Reentry and proof restoration | Dependency getter reenters a scalar public entry, replaces itself, or throws; active proof hits a throwing combiner | Same event order and error; nested entry cannot revive a refused outer proof; subsequent clean entry works |
| Saturation and graph closure | Saturated wrapper, first-class-only reference, nullary/scalar/Nat-first wrapper, transitive wrapper backedge | Actual generated helper presence/absence; retain precise frontend refusal phase |
| Binary compact continuation | Asymmetric children, different scalar state per child, nested different branch sites, leaf return between resumed frames | Full result equal to independent model; right arguments use original parent state, join uses left saved result and current right result |
| Unary compact continuation | Reconstruction with operands before and after recursive child; mixed unary/binary worker | Preserve `before` values and phase3 evaluation order, or explicitly leave/refuse unary admission |
| Frame reuse | Uneven trees causing deep then shallow paths and repeated ordinary calls | No stale site, left result or scalar slot; no native recursion in admitted worker |
| Deep stack | 30,000-depth chain, iterative decoder | Complete structure summary, no native stack overflow; recursive ceiling failures retained separately |
| Private ADT layout | Public host object with getters on `$`, `a`, and child slots; internal leaf/nullary/nested constructor; shared child | Public tagged ABI and exact host demand trace; fresh result and preserved zero-flow child aliases; no private representation escape |
| Layout fallback | Dependency mutation during demanded access and transitive backedge into generic/public path | Packed input never reaches generic matcher/readback; generic output never silently treated as packed |
| Fusion | Empty, singleton, uneven/shared inputs; U32 seeds 0/17/max; both directions; demand/throw probes | Full values equal independent direct-unfused model; allocations/identity and error order preserved at every observable boundary |
| Actual reachability | Ordinary scalar public `bench` plus diagnostic full value adapter | Actual emitted optimized site entered; clean timed file remains exact emission/derivation bytes |

Inherited Phase41 owners may supply unchanged obligations with exact identities.
Do not count an inherited assertion as coverage of a new representation, admission
or dependency. A score/sum/hash alone cannot certify full structure. A diagnostic
adapter forcing proof or directly invoking a worker cannot certify public entry.

## Cheap witnesses and stopping conditions

Use the existing Phase41 independent nested-array model and its corrected deep
equation: `nodes=2*d+2`, `leaves=2*d+3`, `sum=7*(2*d+3)` for the flow adapter.
`review/oracles.mjs` contains only small independent structural helpers; it is not
a new validation framework. Root may import them into concrete controls.

Reject or defer on any semantic mismatch, unproved transitive guard, private
representation escape, source admission beyond the reviewed shape, or native
stack failure. Do not waive a gate for a speed result. Correct an invalid oracle
only with a derivation, versioned successor and retention of the failed tool/run.
Freeze source/helper/ABI and clean/diagnostic identities before timing. Compare
fusion against Phase41 direct-unfused output, not an older generic denominator.
