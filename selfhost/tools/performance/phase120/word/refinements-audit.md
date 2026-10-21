# Phase120 bounded refinements after word03

These modules are isolated experiments, not selected production changes. The
parent agent owns compilation, ordinary controls, machine inspection and timing.
No target or compiler has been executed by this source-audit agent.

## Structural prefilter: model06

`model06.bend` retains model03 and adds a cheap two-bit syntax scan before the
list-based reaching facts. The existing <1024 node bound remains the outer lazy
gate. A function lacking either any `shr` or any `or` returns unchanged. The
scanner includes both scalar and direct If arms and stops after finding both.

This is a necessary condition, not a proof that a rewrite exists. The fact
domain can create a canonical sign fact only from a logical right shift; the
only replacement consumer is OR. Parameters and fresh opaque values contain
neither fact. Therefore no accepted replacement is lost. It deliberately does
not require literal31 at the shift instruction: a copied constant count remains
eligible in model03. It does not require shl, since the input sign-fill may be an
already folded constant. Model06 should emit byte-identical QBE to model03.

This removes fact tables from impossible functions; it does not make the
accepted-function list domain cheaper, remove the original size scan, or remove
the independently checked second range commit. Those costs still need measuring.

The frozen model04 first failed parsing because inferred signatures do not allow
`+` duplication markers without parameter annotations. Model05 attempted explicit
types, but existing law-backed definitions require inferred signatures instead.
Model06 uses `(body, flags):` with local duplication of flags; the body is used
exactly once as a parameter match scrutinee. These are source syntax failures,
not semantic validation failures; no target execution was reached.

## Exact renderer projection: word-width

`word-width.bend` overrides only `p113w_look` and retains its previous body under
`p120wp_original_look`. It recognizes exactly three adjacent integer statements:

```
y:U64 = shl x,32
y:U64 = sar y,32+k
y:U64 = and y,0xffffffff
```

For 1<=k<=31, these equal `extuw(sar32(low32(x),k))` for every U64 input. The first
shift discards the upper32 bits and places low32's sign in bit63; the 64-bit
arithmetic shift reproduces the 32-bit sign fill. Masking obtains exactly the
zero-extended 32-bit result. Destination/source aliasing is safe: the emitted
word temporary reads x before writing y. No assumptions about implicit narrow
extension, source types, or the signed-word analysis are needed.

All three destinations must match, both intermediate reads must refer to that
destination, all types must be U64, and shift/mask constants must match exactly.
The third statement is checked by the existing `p113w_mask_of`. A fresh temporary
uses existing `p113w_word` and its counter-room gate. No statement, branch or
effect can intervene. The original verified structured body is unchanged.

`word-width-controls.bend` exports 17 finite shape/output controls. Negative
shapes are analysis inputs only. Existing ordinary boundaries provide executable
semantics coverage. Existing width controls should also remain unchanged.

`word-width-floats.bend` is optional when composing the Phase120 float-region
modules. It preserves the same triple inside `p114so_old` and
`p120nr_lane_bin`; the lane path invalidates only the one written local. Every
fallback body is copied from the existing implementation. Calls, other locals,
float operations and fact lifetimes remain unchanged. This prevents a combined
float candidate from silently losing the standalone integer improvement.

## Canonical Boolean range identity

`boolean-range.bend` overrides only `p113k_bin_stmt`, using the already computed
P113KFact full-value bound. When x is proved in {0,1},

- eq(x,1) and ne(x,0) equal x;
- eq(x,0) and ne(x,1) equal x xor1.

The right operand must be proved exactly0 or1. Unknown or wider full values are
refused. This is not a claim that arbitrary U32 values or tagged Bool terms are
canonical. Existing exact-result folding takes precedence; original answer
facts, mutation epochs and branch-relation recording remain unchanged. The
replacement writes the comparison's original U32 result representation. No
extra scan, new analysis state, statement movement, or effect removal is added.

Eleven finite `p120wb_controls(Unit)` cases include all four identities, wider
and unknown refusals, overwrite invalidation, constant false/true, and valid or
wider branch joins. The original range pass commits through the existing
independent verifier as before. Control shape success alone is insufficient:
compare actual instructions and complete ordinary outputs.

This is distinct from Phase117's near-neutral adjacent comparison/diamond
normalization. Current word03 scalar machine code still contains canonical
comparison results widened and compared with literal1 (4059c1 and405a04 in the
retained machine dump). Phase117 removed only the immediate cnew normalization,
which QBE could already simplify. The new experiment uses a full reaching range
fact through copies and joins to remove the later equality. Its runtime gain is
unknown until the parent measures it; fewer IR instructions are not a claim.

## Parent-run observations motivating these refinements

The parent reported word03 scalar313ms versus431ms, Mandelbrot718ms versus807ms,
and numeric recurrence419ms versus421ms, with ordinary boundaries passing.
Retained scalar disassembly has122→90 total instructions,7→4 setcc and four
conditional branches. Three shl32/sar40 pairs remain. These are parent-run
observations from `selfhost/build/phase120/word-machine03/report.json` and the
corresponding screen, not measurements by this audit agent. Prepared compilation
cost rose on the scalar workloads; the prefilter must be evaluated against that
cost and must retain exact emitted output before attribution.

## Rejected Boolean version01 and width-preserving version02

The first Boolean candidate passed its eleven range-shape controls and ordinary
outputs but regressed runtime sharply in the parent-run word14 screen. This was
not evidence that redundant Boolean comparisons are fast. The rewrite produced
invalid typed IR, and the trusted verifier correctly rejected the candidate.

`p111v_value` requires exact local-width equality. U64 comparisons return U32,
but their operands remain U64. The proposed U32 copy/XOR therefore illegally
read a U64 local. `p113i` also applies `p113k_function` after inlining, so this
failure rejected inlining as well as the subsequent range commit. Both gates
retained their previous valid compiler behavior, preserving outputs but losing
optimization. Static mit comparison confirms the mechanism: word13 has three
SAR instructions and only the unreachable failure call; word14 has zero SAR and
seven restored ordinary calls (three asr8, two b2u, two sel), plus the failure
call. This is a rejected candidate, not a backend performance result to average
into retained gains.

`boolean-range02.bend` instead preserves original operand type and comparison
result width. It changes only proved eq(x,1) to ne(x,0), and ne(x,1) to eq(x,0).
Comparisons against0 and exact-result folding stay unchanged. The hypothesis is
that QBE will simplify the equivalent zero tests through existing Boolean
materialization; no speedup is assumed. No verifier is broadened and there is no
new implicit conversion contract.

`boolean-range-controls02.bend` adds three checks at the missing boundary: a
complete valid private function is verified before and after the range pass;
the earlier invalid U32-copy form is explicitly required to produce the exact
assignment-width error. That negative form is pure verifier input, never native
execution. Together with the original eleven range/overwrite/join controls,
these fourteen checks separate semantic algebra from IR representability.
