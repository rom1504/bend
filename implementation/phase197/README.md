# Taking two simulated x86 optimizations through the compiler

Phase196 found two promising edits to assembly. We implemented both in Bend, separately and together, and ran a new hardware-model search alongside the compiler experiment. The baseline is the qualified Phase195 x86 compiler at source SHA-256 `ee95d489522b4fdbdf253137319417f3eb09abe12f192db493d840c542adb8c5`. The six-program compiler screen was selected before timing. [Design](../../design/phase197/README.md) · [Phase196 predictions and machine edits](../phase196/README.md)

## What the compiler can express

The first rule composes a verified integer comparison and conditional selection with the register allocator's placement. When the chosen destination already holds one arm, the emitter uses the corresponding condition or its complement to write the other arm directly. It preserves the width of the comparison, normalizes U32 results and publishes each result to its original destinations. The Phase196 hand edit also folded two increments. Those are outside this rule. [Bend implementation, contracts and controls](../../research/phase197/minimum/README.md)

The second rule folds a register copy and immediate add or subtract into one x86 address calculation. An address calculation leaves arithmetic flags untouched. A bounded scan therefore has to find a later flag writer before any instruction could observe the difference. Labels, calls, partial writes, out-of-range displacements and unknown instructions can trigger fallback. The first candidate failed Bend's affine checker. The second made the budget and shared results explicit. [Bend implementation, refusal cases and controls](../../research/phase197/decrement/README.md)

An instruction scan of the 45 qualified executables found the particular minimum sequence 110 times in five programs, and the particular copy/decrement sequence 55 times in 22. These are counts of baseline shapes. Legality, heat and runtime impact require separate evidence. [Per-symbol census and ELF hashes](../../research/phase197/coverage/qualified-shapes.json)

## Measured compiler results

Across the six selected workloads, the combined compiler used **8.8% less runtime** than qualified Phase195 in the two four-role sessions. Minimum alone used 6.9% less, decrement alone 1.5% less. Three cases exercise closely related edit-distance code. In the separate three-role C-reference session the six-case geometric ratio moved from **2.696× to 2.485× mature Bend C**. These targeted numbers have a different population from the full-suite qualified **1.865× C**.

| Workload | Minimum / Phase195 | Decrement / Phase195 | Both / Phase195 | Phase195 / C | Both / C |
| --- | ---: | ---: | ---: | ---: | ---: |
| editdist | 0.875× | 1.001× | 0.855× | 1.901× | 1.627× |
| local-pair | 0.877× | 0.997× | 0.849× | 1.904× | 1.623× |
| coverage-bst-64 | 1.003× | 0.947× | 0.947× | 3.790× | 3.634× |
| coverage-bst-32 | 0.999× | 0.996× | 0.996× | 4.250× | 4.258× |
| variation-editdist-3-123 | 0.872× | 0.994× | 0.853× | 1.901× | 1.657× |
| mandelbrot | 0.974× | 0.974× | 0.985× | 3.468× | 3.476× |

The first three columns use the geometric mean of the two balanced sessions. The last two compare all three executables directly in a fresh, three-round position-balanced run. Every timed execution checked the benchmark result and repetition counts. The six-case geometric result includes the unrelated Mandelbrot control. Its three candidate objects were byte-identical to baseline, yet individual session ratios varied from 0.956 to 1.014. The apparent movement on that case is noise. Minimum also leaves both BST objects identical. [Per-session results and dispersion flags](../../research/phase197/measurement/runtime-summary01.md)

Disassembly accounts for the edit-family improvement. The hot row body shrank from 64 instructions and 277 bytes to 56 and 253 with minimum, then to 55 and 247 with both rules. Disassembly shows two register-to-register compare/select sequences and preserves the stack output. The decrement rule also fires on both BST inputs; only the larger input shows a repeatable material win. [Exact instructions and offsets](../../research/phase197/minimum/machine-audit.md)

## What the hardware search found

Two investigations froze alternatives and ran every candidate, including the lowest-ranked ones. The ray investigation used a historical owner profile and current, authenticated machine code. Its six candidates took 0.97 s to model and 25.59 s to build, check and time. Three-operand AVX arithmetic reduced modeled local cycles by 33%; whole-ray runtime fell by 0.8% and 1.9% under the two assembler layouts. Preconverting two exact integer constants reduced modeled cycles by 16%; whole-ray runtime was flat or slower. No ray candidate cleared the 2% screen in both layouts. [Ray models, ISA assumptions and measured results](../../research/phase197/discovery-a/RESULTS.md)

The second investigation tested four local alternatives for BST and tree sort. Twenty-two model invocations took 0.72 s including preparation. Whole-program construction, checks and timing took 24.18 s. Narrowing tag comparison ranked first with a 3.70% weighted saving, but its four measured ratios ranged from 0.9881 to 1.0096. None of the four passed the predeclared two-session, two-layout threshold. [Rankings and complete outcomes](../../research/phase197/discovery-b/README.md)

Following that failed tag optimization through its successor blocks exposed the largest opportunity. When descent reaches an empty leaf with fuel left, every remaining iteration reconstructs the same loop state except for decrementing fuel. Returning the same result early reduced total BST64 runtime by **23.3–23.8%** and BST32 by **4.3–7.0%**. All 32 timing pairs favored the change. Separately instrumented executions counted **4,160 → 429** positive-fuel steps on BST64 and **1,056 → 528** on BST32. This directly explains the difference between inputs. Both fixtures exercise the same algorithm. The machine experiment preserves the original zero-fuel behavior and passed independent result and ABI controls. [Frozen edit, counts, argument and reproduction](../../research/phase197/discovery-b/absorbing/README.md)

The two modeling batches together cost 1.69 s; the corresponding physical screens cost 49.77 s including builds and correctness checks. These are costs of different operations. The useful contribution was identifying a hot loop worth inspecting. Measuring how frequently it repeated a useless state revealed a much larger gain than the predicted saving on the local instruction. Static scheduling alone supplies no such frequency.

## Validation and cost

The three checked emitters produced 18 direct objects that passed their catalog oracles. Independent mature Bend C executables agreed on all **90** candidate output comparisons at 30 case/input points, including 24 inputs outside those six catalog points. Across direct-object and rendered-assembly controls, the combination passed **104 structural checks** and **48,100 independent C observations per route**. The two routes share the typed selector. Full x86 sources for minimum and the combination separately passed the pinned upstream checker with zero unresolved holes. These finite machine controls and source checks leave end-to-end semantic equivalence and native self-reproduction open.

Sharing invariant preparation across the three variants cost 29.18 s for the six inputs. Complete emission took 119.80 s under the guard. Across the six inputs, selection/rendering/object encoding summed to 28.76 s for minimum, 29.19 s for decrement and 28.43 s for the combination. These are single-pass hosted observations with fixed role order. Cold compiler throughput remains unmeasured here. The complete x86 source grew from 1,849,936 to 1,858,809 bytes with both rules (+0.48%). [Guarded job index](../../research/phase197/measurement/evidence-index.json)

## Decision

Keep both opt-in compiler implementations for broader qualification. The strongest evidence is the three edit-family results, followed by BST64. The most promising new optimization is an early exit from a pure loop arm that reaches a fixed state while consuming fuel. An IR-level rule could canonicalize that state once and set remaining fuel to zero on its backedge. The existing zero-fuel path then handles publication and ownership. Validate a second algorithm, zero and nonzero fuel, observable effects and aliasing before promoting the rule. A capture of the actual typed IR reproduced the qualified BST assembly byte for byte. The canonical leaf is defined inside one branch and the recursive backedge reads it after a join. A local peephole cannot certify that relation. An independent text-search example lowered to public scheduler segments with ownership operations and falls outside this rule. The qualified Phase195 frontier and its native45 ratio remain the reference. [Reproduction](reproduction.md) · [Raw compiler experiment receipts](receipts.tar.gz) · [Admission analysis](../../research/phase197/discovery-b/absorbing/admission.md)
