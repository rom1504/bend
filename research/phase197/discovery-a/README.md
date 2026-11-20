# Discovery A: six new current-source ray alternatives

Completed: [whole-program results](RESULTS.md). All six candidates passed finite
outputs, but none produced a 2% gain under both assembler layouts. The model's
33% local VEX prediction became only 0.8–1.9% program improvement in one session.
No compiler change is proposed from this batch.

This screen freezes six isolated generated-assembly edits to the current
Phase195 N1 `variation-ray-active-64-2440` product. They exclude the Phase196
minimum/decrement, redundant-copy deletion, memory-operand folding and zero-
conversion edits. The aim is prospective model-guided selection, with every
candidate retained for complete-program testing, including low-ranked choices.
No maintained compiler source changes.

[frozen.json](frozen.json) was written before modeling or target execution.
It contains exact before/after sequences at every patched site, legality and
scope, qualitative expectations, current ELF/object/source pins and historical
profile evidence. Both repeated arithmetic sites are patched in each arithmetic
variant; Boolean variants also patch both repeated threshold sites. Each model
uses one representative straight-line context. The current emitted object hash
equals the actual N1 object hash, not merely a source resemblance.

The retained Phase194 profile puts 38.2969% in `$product.nearest`. This is an
explicitly **historical owner proxy**, not a current block weight; tables and
sqrt handling changed in Phase195. No profile-weighted whole-program prediction
is reported. Current byte-level/shape changes prevent silently transferring
Phase196's historical 16.3% arithmetic-block weight.

| Frozen candidate | Model cycles after/before | Block throughput ratio | Instructions ratio |
| --- | ---: | ---: | ---: |
| VEX three-operand scalar fusion | 0.670199 | 0.571429 | 0.824324 |
| Exact 1/1000 conversion inputs, retaining DIVSS | 0.841326 | 1.000000 | 0.756098 |
| Boolean-to-Boolean chain identity | 0.966556 | 1.000000 | 0.959459 |
| Early independent radius square | 1.016887 | 1.035714 | 1.013514 |
| Swapped ordered FP comparison | 1.032781 | 1.000000 | 0.986486 |
| Discriminant retained across store/reload | 1.035430 | 1.071429 | 1.013514 |

The exact-threshold alternative removes conversions of exactly representable
integers 1 and 1000; it retains division rather than assuming a rounding mode to
fold 1/1000. Ordered comparison uses reversed UCOMISS/SETA and retains SETNP to
preserve r11b; unordered, equality and signed-zero behavior remain defined.
The Boolean identity retains both original frame stores and final TEST.
Discriminant retention keeps the original memory write and requires the existing
zero-upper-XMM provenance; xmm8 is unused by the whole generated source.

VEX fusion combines necessary MOVAPS/two-address scalar operations; it does not
repeat Phase196's deletion of redundant round trips. It requires actual AVX/OS
state support and dead upper YMM lanes: VEX writes clear those upper lanes.
Mixed AVX/SSE transition cost is a real performance boundary, and a compiler
implementation would require ISA selection/fallback. Early-radius scheduling
keeps FP operand association but reorders an independent possible exception;
it is only a masked-exception ordinary-input diagnostic, **not general
equivalence**. The harness checks CPUID/OSXSAVE/XCR0 and records MXCSR masks
before candidate execution. None of this qualifies a production optimization.

The authenticated LLVM11/Ivy Bridge batch made 12 calls with 100 iterations and
`-noalias=true`, requiring exit 0, empty stderr and exact instruction counts.
Model processes cost 0.341 s elapsed / 0.316 s CPU; guard wall 0.969 s. The model's
store-forwarding, alias, cache/layout and SSE/AVX boundaries limit extrapolation.
Exact inputs/outputs and tool/library pins are in
`selfhost/build/phase197/discovery-a-model01/model.json`; that run is sealed.

[diagnostic.py](diagnostic.py) is the executable whole-program screen. It uses
the existing Phase196 output validator and four independent C-oracle inputs,
including alternate inputs with the fixture's required one-result evaluation
and empty timed loops. It builds every variant and a sibling baseline under
both the project's assembler flags and default assembler layout, retaining the
actual N1 executable as another control. Eight rounds rotate/reverse order with
at least 100 ms per timed observation. It records every ratio and correctness
observation, not just model winners. A single session is a screen; independent
repetition is needed before calling a runtime improvement replicated.

Only root's coordinated target-lane handoff authorizes diagnostic execution.
Model jobs use the shared guard/lock; all new runs retain the 5 GiB disk reserve,
explicit output roots, and maintained close receipts.
