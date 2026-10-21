# Phase121 materialization ceilings

These six Bend programs are **diagnostic source specializations**, not changes to
the compiler and not evidence that a general transformation is implemented. They
ask whether removing complete intermediate structures has enough runtime upside
to justify implementing a compiler capability.

`prepare.py` authenticates the original Phase93 sources through the frozen
Phase112 original45 manifest, inserts a helper, and replaces exactly one expression
in `bench`. The entire `# Phase93:` wrapper suffix remains byte-identical: the
runtime arguments, success-count check, timing interval and complete expected
result are unchanged. `manifest.json` records the parent, helper and result hashes.
No build or target execution was performed when preparing these files.

| Variant | Inputs | Work removed |
|---|---|---|
| `mapfold` | list128 and list512 | `dbl`'s complete mapped list and its later consumption |
| `full` | list128 and list512 | generator, filter and mapped lists |
| `treefold` | map-churn32 and map-churn128 | `Map.to_list`'s list cells and Sigma pairs before digest |

## Semantic boundary

`mapfold` implements `suma(dbl(xs), acc)` by a single traversal. It performs each
original `U32.mul(h, 2)` and `U32.add(acc, mapped)` with its original wrapping
semantics and keeps the original left-to-right fold order. It consumes `xs` once.
The generator and filter remain unchanged. The original map completes before the
fold begins; the diagnostic interleaves them. That is sound here because the
mapped operation is total and pure, and the intermediate cannot escape or be
observed. This is not permission to fuse arbitrary effectful or partial functions.

`full` keeps the original Nat countdown and exact LCG operations
`add(mul(seed, 1664525), 1013904223)`. It filters the same `mod(seed, 16)` heads by
`is_gt(h, 1)`, multiplies each surviving head by two, and adds in the original
order. It changes the scheduling of total scalar operations across list phases;
it does not reassociate arithmetic or exploit the fixed test inputs. No list is
returned, shared, stored or passed to an unknown function by this fused region.

`treefold` follows the actual `Map.to_list.go` definition in `bend2/base.bend`:
`to_list.go(lo, to_list.go(hi, acc))` produces the lo sequence before the hi sequence.
The direct digest computes `digest(hi, digest(lo, acc))`, preserving that sequence
even though the original list construction visits hi first. Key hashing and value
mixing are total and pure. Every key and value is consumed exactly once. This
preserves the noncommutative hash rather than treating the Map as unordered.
Tree recursion remains bounded by tree depth, but no stack-safety or native
qualification claim follows from preparing the source.

The unchanged frozen expected outputs must check each generated binary. Broader
ordinary inputs should compare the original and diagnostic function outputs before
any compiler generalization. Resource exhaustion is not a semantic oracle for
these allocation-eliminating diagnostics; no special failure probes are proposed.

## Reusable compiler evidence

The existing JS backend already has structural admission machinery for the full
numeric pipeline in `selfhost/src/back/js/region.bend:820–1058`:
`j_fusion_producer`, `j_fusion_map`, `j_fusion_filter`, `j_fusion_fold`,
`j_fusion_owner`, and `j_fusion_pipeline_defs`. Admission validates constructors,
primitive identities, total scalar expressions, exact structural recursion and
non-escaping nested uses; its emitter produces JS text. A QBE experiment can reuse
the semantic recognizers while replacing the emission boundary with KTerm or
structured native IR. That is narrower and cheaper than inventing a separate
whole-program analysis, but it initially covers this numeric pipeline shape only.
It does **not** prove the Map treefold transformation.

Current native QBE demonstrates the missed work directly:
`selfhost/build/phase118/p120-combined-broad-emit01/coverage-list-pipeline-128.ssa`
has the generator's `p118_rt_extend1` near line747, the map's
`p118_p111_rt_take2`/`p118_rt_extend1` near lines846/864, and the fold's
`p118_p111_rt_take2` near line921. Destination passing made construction iterative;
it did not remove the constructed list.

For compiler transfer, first attribute live producers. The native compiler's
reclamation samples alone cannot identify a removable intermediate. One concrete
source opportunity to investigate is `nt_append` in
`selfhost/src/back/native/text.bend`: it materializes a reverse then consumes it
through a second reverse. Many worklist traversals call it. A general list
elimination contract could cover this, but no inclusive-cost or speed claim is
made here. Avoid replacing this with unbounded recursion without preserving its
stack-safety purpose.
