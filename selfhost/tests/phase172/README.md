# Phase172 experimental modules

These files are reproducible experiments, not selected compiler sources.
[Report](../../../implementation/phase172/README.md) and
[reproduction](../../../implementation/phase172/reproduce.md) explain outcomes.

- `deferred-pattern*.bend`: private typed rows and ordered substitutions; only
  the explicit override changes `ff_match`. Checked complete values/QBE agree,
  but hosted loader time is neutral. Do not install it as a speed improvement.
- `inline-runtime*.bend`: postverification QBE templates. Cold-only construction
  has zero compiler coverage; already-sealed-field construction regresses lookup.
  The original runtime remains the fallback. Final verification is unchanged.
- `.mjs` files call checked Bend APIs and compare complete values/output; they
  implement no compiler transformation. Finite laws/controls are not BendTT proofs.
- `static-seal-pair.py`, `static-seal-binding.py`, `static-seal-observe.py` bind,
  relink and observe explicit runtime variants. The runtime experiment's exact
  patch and tools are in `experiments/phase172`; it removes static publication
  wrappers, but full-build transfer is neutral. Qualified runtime stays selected.

The lookup stdout comes from the fixed Phase166 workload and complete-value
oracle, reused in Phase171. The verifier stdout is the existing independent
`experiments/phase169/verifier.expected`. No timing text is normalized away.
Use only fresh artifact roots and the maintained serial CPU3/disk guard.
