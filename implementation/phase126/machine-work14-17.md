# What source14 and source17 removed

Read-only audit of saved QBE, assembly, source and complete root-owned timing
receipts. No new compiler, native program, benchmark or profiler was run.
[machine-work14-17.json](machine-work14-17.json) pins inputs, static counts and
the original observations. Counts cover whole named functions, including cold
paths and prologues; they are not dynamic instruction counts.

## Numeric recurrence: expose the operand, not another helper removal

The source14 screen reports parent415ms versus candidate301ms; source08 was417ms.
`p37.numeric` already had **zero calls** before this change. Phase118 had expanded
operation58 (`F32.to_u32`) late, but the local explicit-operand audit did not admit
that use of the shared scratch buffer. Adding58 to `p114so_group_call` lets the
whole arithmetic chain use the existing local float-lane renderer.

| Saved `p37.numeric` assembly | Phase125 parent | Source14 | Source17 |
| --- | ---: | ---: | ---: |
| Instructions | 60 | 40 | 40 |
| Stack memory operands | 9 | 0 | 0 |
| Integer/XMM transfers | 9 | 2 | 2 |
| Calls | 0 | 0 | 0 |

The2048-byte scratch frame disappears. The old chain repeatedly stored operands
and moved intermediate F32 bits through integer registers. The new chain keeps
its multiply/subtract/multiply/conversion operands in XMM registers; only the
existing full-Term loop backedge reboxes `y`. Source14 and17's entire numeric
worker assembly are byte-identical. Their301/303ms cross-screen difference
therefore does not indicate a Nat-take gain in this worker.

The conversion still performs ordered single-precision comparisons against0 and
2^32, truncates only the admitted numeric range, and zero-extends the U32 result.
Negative values, NaNs, infinities and values at/above2^32 yield0; negative zero
yields0. The largest accepted F32 is4294967040. No fast-math, fused operation,
NaN-payload or floating-environment equivalence is claimed. This is the same
boundary documented in the retained Phase118 F32-to-U32 audit.

## Ordinary ray: remove a frequent recursive predecessor call

Source14→17 screen medians are436→394ms for ordinary ray, while active-ray is
884→886ms. These are separate screens, not a paired causal estimate. The saved
QBE for `$product.nearest`, `$product.trace` and `$direct.pixel` is exactly
unchanged across14/17. Their numeric computations did not improve in17.

The executed recursive `$direct.colf` worker does change:

| Saved colf assembly | Source14 | Source17 |
| --- | ---: | ---: |
| Instructions | 179 | 173 |
| Stack memory operands | 43 | 37 |
| Static call sites | 6 | 5 |
| `p111_rt_special_take` sites | 1 | 0 |

The original call setup/reload becomes `subq $1, %rsi` plus the existing scratch
store. Full-U64 subtraction, output slot0 and status1 exactly match runtime
`P111_SPECIAL_SUCC`; the original typed call remains in verified IR. Six ray
functions lose one such call each, but only colf among them is a selected private
worker. The other changes include generic rowf, harness and number rendering.

The ordinary source always walks64 rows ×2^14 column leaves, then rejects
out-of-width columns before pixel computation. At width80, recursive traversal
is substantial independent of the expensive active-pixel arithmetic. Removing
one call at each nonzero colf descent is therefore a credible mechanism for
the ordinary-ray gain; neutral active-ray is consistent with a different work
distribution. Neither observation proves a general10% improvement.

## Remaining region boundaries

Source17 nearest still has eight static scalar-selector calls across two
duplicated intersection paths: sx/sy/sz/sr twice, plus two sqrt calls. One normal
path uses four selectors and one sqrt; six additional fail-call sites are cold
and must not be counted as normal per-iteration work. There is no remaining
isect5 call in that worker. The optional table-call projection targets this
concrete boundary, without requiring a broader inliner first.

Trace/pixel still cross full-Term call boundaries, and sqrt retains the exact
single→double library→single semantics. Numeric recurrence still converts each
iteration to an observed U32 hash and moves `y` through the full-Term backedge.
Colf retains two keep sites, explicit continuation traffic and a frame helper.
These are distinct remaining categories; static sizes alone do not predict
their gains or justify changing the qualified fallback.
