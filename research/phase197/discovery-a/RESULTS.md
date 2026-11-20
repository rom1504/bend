# Six new current-ray alternatives: no substantial whole-program win

All six frozen alternatives ran, including the model's three predicted losses.
The largest local prediction—VEX scalar fusion, 33.0% fewer modeled cycles—gave
only 0.82% less whole-program time with project assembler flags and 1.91% with
default layout. Exact conversion inputs predicted 15.9% fewer local cycles but
were neutral/slightly slower in the program. No candidate clears a practical 2%
improvement in both layouts; this is one session, not replicated performance.
No production change or further timing campaign follows from these observations.

| Isolated ray edit | Model local cycle ratio | Project-layout paired ratio (faster/8) | Default-layout paired ratio (faster/8) |
| --- | ---: | ---: | ---: |
| VEX three-operand scalar fusion | 0.670199 | 0.991803 (7) | 0.980934 (8) |
| Exact 1/1000 conversion inputs; keep DIVSS | 0.841326 | 1.005495 (1) | 1.000000 (3) |
| Boolean-to-Boolean chain identity | 0.966556 | 0.991803 (7) | 0.989203 (6) |
| Early independent radius square | 1.016887 | 1.011050 (1) | 1.005450 (1) |
| Reversed ordered FP compare | 1.032781 | 1.005495 (1) | 0.997283 (4) |
| Retain discriminant across store/reload | 1.035430 | 1.000000 (3) | 1.000000 (3) |

Lower is faster. Ratios are medians of eight within-round candidate/baseline
ratios, never ratios against a differently assembled sibling. The regenerated
project/default baselines were 1.002762×/1.013812× actual N1. Several individual
paired observations have visible variation (retained in the raw record), and
integer-millisecond timing at approximately 180 ms limits resolution. These data
support rejecting a large-gain claim, not a precise claim that sub-percent effects
are zero. Independent repetition would be necessary before retaining a small win.

The ranking correctly put VEX above its predicted-loss alternatives, but badly
overstated the scale of its practical opportunity. Its second pick, exact
conversion inputs, did not improve the program. Instruction-count reduction
ranked the unsuccessful threshold edit first. There is no new evidence that a
simulator's score alone improves discoveries per unit research cost.

## Frozen scope, correctness and missing information

The [six-candidate freeze](frozen.json) predates model and target execution and
contains every before/after patch, current source/object/ELF pin, local legality,
qualitative expected effect and historical profile pin. Exact current emitted
object bytes match N1. The model uses one representative straight-line context;
the program applies the frozen edit to both corresponding paths (and four
predicate sites for Boolean variants). All six alternatives remain separate.
No Phase196 minimum/decrement or rejected ray-copy/memory/zero edit is repeated.

Retained hotness is **Phase194 nearest-owner 38.2969%**, explicitly a historical
proxy. It is not a measured current block fraction. The current emitter changed
table and sqrt handling. Local repeated-block cycles cannot supply branch
frequency, current critical-path occupancy, cache/layout behavior or an Amdahl
weight; no model ratio was presented as a whole-program estimate.

All 15 products (14 assembled siblings plus actual N1) matched the independent
C result on the original input and three alternates: 60 complete product-output
checks. Each timed run also validated result/count/warmup output. Alternate
inputs used the fixture's required initial result evaluation with empty repeated
loops, as in the retained Phase196 validator. These are finite controls together
with local reasoning, not an optimizer correctness proof.

The host gate observed `xcr0=0:7 mxcsr=1f80`, with CPUID AVX/OSXSAVE admission.
VEX clears upper YMM lanes; the complete generated source does not use them, but
general compiler use would need target-ISA/fallback and live-lane checks.
AVX/SSE transition effects are not isolated by this experiment. The scheduling
candidate retains operand association but can reorder possible FP exceptions;
its validity is restricted to the recorded masked-exception/ordinary-input
diagnostic, not general equivalence. Exact 1/1000 conversion edits deliberately
retain DIVSS, including its rounding and exception behavior. The ordered-compare
truth table includes equal/unordered cases, and SETNP remains to preserve r11b.

## Cost and retained evidence

Twelve LLVM-MCA processes consumed 0.341 s elapsed / 0.316 s CPU; model guard 0.969 s.
The whole-program job consumed 25.592 s guarded wall, including 1.361 s construction
and correctness checks, calibration and 120 timed program observations. Total
guard wall 26.561 s. Runtime peak declared output was 13.61 MiB under 64 MiB budget;
the standard 5 GiB reserve and 2 GiB RSS / 16 GiB available-memory controls remained.
No timeout, failed job or retry occurred. Agent preparation/analysis and billing
are not included in target guard cost and were not measured per candidate.

Both runs are sealed `completed`, kept hot for reproducibility, with no pruning.
CPU3 was handed back to qualification immediately after close. Complete model
stdout/stderr, exact model commands/tool/library pins, runtime ratios/oracles,
host admission and guard/retention receipts are copied in [evidence/](evidence/).
[summary.json](summary.json) supplies the compact comparison. The 15 actual
products remain under `selfhost/build/phase197/discovery-a-runtime01`.
The [harness](diagnostic.py) reproduces the screen with a fresh output directory
and an explicit coordinated guard; it changes no maintained source.
