# P123-004: can fewer instructions hurt branch layout?

Status: focused ablation passes; original45 machine-policy qualification complete. The combined candidate improves
original44-point runtime6.15%, but two already-fast list cases regress15.6%/21.9%.
Retain this result. Their active fused loop loses one instruction (34→33 whole
function), while cmp/jcc moves from0x405bc0/0x405bc4 to0x405bbe/0x405bc1, crossing
a32-byte boundary. This is a concrete layout hypothesis, not a demonstrated cause.

First replay the same authenticated products with longer batches. Then use the
existing GNU assembler's documented `-mbranches-within-32B-boundaries` option on
exactly the same QBE output. No generated source/IR/assembly edits, semantic gate
changes or unsafe probes. Check the two list cases plus editdist and Mandelbrot;
record exact commands and resulting function assembly. It is an assembler-policy
experiment, not a new Bend optimization. Retain the original toolchain comparison.
Do not adopt a changed machine-build policy without separately checking its
original45 outputs and runtime; no full compiler image is justified.

Longer unaligned replay confirms+11.9%/+21.3% list regressions. The assembler
option recovers13.6%/21.4% relative to the same candidate in a four-program
three-round screen; editdist/Mandelbrot remain neutral and all36 outputs pass.
See implementation/phase123/branch-alignment.md for exact medians and causal limits.

Final policy passes405 observations with no point slowdown above2.5%. Its
full44-point score is2.00584×upstream. Source/QBE/runtime remain identical to the
ordinary-assembler candidate; only the machine-build policy differs.
