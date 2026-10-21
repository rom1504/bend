# DCE exposes the pattern but does not improve the hot machine loop

The bounded DCE is structurally successful. It exposes the intended two Boolean
diamonds to the existing recognizer, while the resulting Mandelbrot machine loop
has **two more instructions and the same branches**. The independent matched
follow-up records a regression. Do not promote this experiment for runtime speed.

This document reads root-produced artifacts only. The offline counting method is
[dead-scalars-machine.py](dead-scalars-machine.py); exact source, QBE, assembly,
binary and receipt pins are in [dead-scalars-machine.json](dead-scalars-machine.json).
No compiler or target was executed by this analysis.

## Exact Mandelbrot comparison

Parent is `broad-emit01/mandelbrot.ssa` and
`phase111/p118-broad01-mandelbrot-build/program.s`. Candidate is
`dce-emit03/mandelbrot.ssa` and `phase111/p118-dce03-mandelbrot-build/program.s`.

| `$direct.mit` property | Phase118 parent | DCE v3 |
| --- | ---: | ---: |
| QBE function lines | 618 | 435 |
| QBE `jnz` | 9 | 7 |
| QBE Boolean normalization projections | 7 | 9 |
| Machine loop instruction lines | 97 | 99 |
| Machine loop conditional jumps | 3 | 3 |
| Machine loop `setcc` | 7 | 9 |
| Machine loop conditional moves | 5 | 3 |
| Machine loop calls | 0 | 0 |
| Machine loop frame-memory references | 0 | 0 |
| Explicit frame reservation | 8 bytes | 8 bytes |
| Saved general registers besides frame pointer | 5 | 5 |

The loop is assembly lines1509–1608 in the parent and1509–1610 in DCE. Counts
include both selection paths, not execution frequencies or cycles. There is no
new spill evidence: neither loop accesses its frame. Register allocation and
instruction scheduling change, but these counts do not measure peak pressure.

The two intended new projections occur at candidate QBE lines2068 and2285:

```qbe
%v_condition =w copy %v_raw_comparison
%v_condition =w xor %v_condition, 1
%p113_bool_N =w ceqw %v_condition, 0
%v_result =l extuw %p113_bool_N
```

Here abbreviated local names replace the long inlining prefixes. The exact
artifact retains them. Previously each was an If with0/1 constant assignments.
QBE already implemented those as conditional moves. Exposing `p113bq` replaces
that branchless selection with another `cmp/setz/movzx` normalization chain,
after an existing comparison/copy/complement sequence. Thus deleting two QBE
diamonds does not delete either of the two remaining **machine** selection
branches, which choose retained versus newly computed coordinates.

The sign-mask arithmetic is still expressed through comparisons and conditional
moves rather than upstream's simpler arithmetic-shift mask. This DCE does not
change that representation, nor remove the coordinate selection copy chains.

## Lexer transfer is almost entirely smaller intermediate text

Lexer QBE shrinks891,811→837,409 bytes (6.10%), but generated assembly is
736,815→736,816 bytes. The main inspected workers retain exactly the following
machine properties in both products:

| Worker | Instructions | Conditional jumps | `setcc` / cmov | Calls | Frame references |
| --- | ---: | ---: | ---: | ---: | ---: |
| `$direct.gen.at` | 161 | 7 | 9 / 3 | 8 | 14 |
| `$product.lex` | 160 | 7 | 9 / 3 | 7 | 12 |
| `$direct.lex` | 187 | 9 | 10 / 3 | 13 | 18 |
| each TRMC ident/num worker | 88 | 1 | 0 / 1 | 3 | 10 |
| borrowed String.cmp worker | 125 | 9 | 1 / 0 | 13 | 15 |

Unlike the two new Mandelbrot sites, the inspected lexer workers gain no new
Boolean projections. The complete assembly diff is a few register-allocation
changes in `fnv`, `mix` and token construction: an extra register `xchg` in one
worker and one removed move in another. Do not equate the6.1% QBE reduction with
runtime improvement or an established reduction in complete compilation cost.

## Root measurements and control-driver correction

The first finite control driver mistakenly required boxed `{$:'True'}` values;
this checked API transports Bool as JavaScript `true`. All15 body/liveness checks
already passed in `dce-finite03/report.json`. Root preserved that failed driver,
changed the new `dead-scalars-controls-v2.mjs` to require exactly `x === true`,
and `dce-finite04/report.json` passes all15 structural plus9 policy checks. This
was a **host assertion/ABI error**, not a Bend compiler failure or relaxed gate.

`dce-screen03/report.json` passes18 ordinary observations, but its older Phase117
baseline does not isolate DCE. The correct isolated follow-up is
`selfhost/build/phase118/dce-clean01/report.json`, which compares the Phase118
float parent against DCE with five matched longer rounds:

| Program | Parent median | DCE median | DCE / parent |
| --- | ---: | ---: | ---: |
| Mandelbrot | 845 ms | 913 ms | 1.0805× |
| Lexer | 833 ms | 830 ms | 0.9964× |

Mandelbrot times vary across rounds, so this table is a screen rather than a
confidence-interval claim. Nonetheless, both machine structure and the paired
result oppose promotion. Lexer is effectively neutral at this precision.

## The older adjacent-comparison rule does not rescue these new sites

`phase117/scalar-identities-v2.bend:p117s_pair` requires an **immediately preceding
N111Bin comparison** that defines the diamond condition. The exact original
structured dump `inspect-mandel01/functions.json` shows that both newly exposed
conditions are instead last assigned by `N111Bin{...,N111U32{},"xor",...,1}`.
The preceding assignment copies the raw comparison. Both are live and remain
after DCE; current QBE lines2065–2068 and2282–2285 confirm this provenance.

Therefore merely composing the unchanged Phase117 rule cannot match these two
sites. Seven earlier direct-comparison normalizations existed before DCE and
were already within its previous scope. No additional matcher or general
copy/value-numbering framework was implemented in this audit.

Preserve this negative result. If structured cleanup is later useful for another
transformation, revisit its extra verification and live-set cost against that
measured benefit; smaller IR alone is not sufficient justification.
