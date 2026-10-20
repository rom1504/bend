# Late operation-derived scalar facts

This optional pass runs after direct-function inlining and before QBE emission.
Inlining exposed a recurring gap: a comparison becomes the full-word integer
0 or 1, but subsequent generic Bool matching still extracts and tests a boxed
constructor tag. QBE does not recover every such range across mutable joins.

The pass tracks exact 64-bit constants or an unsigned upper bit width for each
mutable local. Facts derive from actual IR operations, never from source
ownership kinds such as `N_W32`, whose Terms may include packed constructors.
Parameters, loads and call results start unknown. Every destination assignment
replaces its previous fact. Pointer values are neither analyzed nor rewritten
as integer representations.

Copies, comparisons, bitwise operators, bounded shifts and conservative
arithmetic bounds propagate facts. Exact bitwise and unsigned comparisons fold.
A mask disappears only if it preserves every possibly set low bit. A constant
condition selects its reachable branch; a join retains only facts true on all
continuing paths. Returning and self-tail branches do not pollute continuing
facts. Each function starts with an empty environment; there is no assumed
initial value for loop parameters and no loop fixed-point analysis.

Raw QBE shifts have modulo counts. This prototype folds only known counts less
than the operation width, leaving other counts intact. It conservatively keeps
signed comparisons and arithmetic right shifts. Full-width Nat and Term values
remain U64; this is not a scalar ABI or representation change.

The original direct verifier runs before and after transformation, with full
rollback on failure. Functions at the 4,096-node size cap are unchanged. Runtime
calls, stores, loads and ownership operations retain their order; only an
unreachable branch can remove its effects. Original fallback programs remain
unchanged. The pass does not introduce speculation, code growth or new runtime
imports.

Integration order after the existing product/inliner modules:

1. `domain.bend`
2. `transfer.bend`
3. `walk.bend`
4. `entry.bend`
5. Optional final declaration override `overrides.bend`

Export `p113k_optimize`, `p113k_lowered` and `p113d_verify`. Independent finite
controls are in `../controls/scalar-facts/`; root owns checked API acquisition,
actual execution and timing. Source review is not empirical qualification.
