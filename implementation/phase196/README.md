# Does hardware simulation select better Bend x86 optimizations?

On this batch, instruction-count reduction found **both replicated wins in its first four choices**. Unweighted LLVM-MCA found one. Weighting its predictions by sampled block time also found one, but picked the largest win first. The largest discovery transferred to the current compiler's generated code. Edit distance took **15.7% less runtime** after a local change to how it computes two unsigned minima. This is a measured assembly experiment. The production x86 compiler still uses the qualified Phase195 selection. [Frozen design](../../design/phase196/prospective-ranking.md) · [Predictions committed before timing](https://github.com/rom1504/bend/commit/ca3e8f4)

## Which rankings paid off?

All 15 edits were compiled and timed, including every low-ranked candidate. They span five complete programs and include address folding, repeated stack-pointer loads, integer comparisons, floating-point operand selection and copy removal. A win required at least 2% less median paired time and at least six faster pairs out of eight in **each** of two sessions. Each session reversed or rotated execution order. The threshold defines a practical research decision. The cases share workers and hardware and provide limited evidence about other processors or future workloads.

| Policy with a four-trial budget | Replicated wins found | Best win's rank | Rank correlation with actual savings | Missed win |
| --- | ---: | ---: | ---: | --- |
| Instruction count | 2/2 | 2 | 0.614 | None |
| Simulated cycles | 1/2 | 5 | 0.504 | edit-minima |
| Sampled time × simulated fractional saving | 1/2 | 1 | 0.007 | bst-decrement |

The test exposes two different mistakes. The unweighted model favored removing three reloads in tree sort and predicted 15.0% fewer cycles in the repeated block. That block accounted for 2.5% of sampled time and the complete program saved less than 1% in both sessions. Weighting corrected that priority, but put three alternatives from the *same* edit-distance block at the top. The block contained 97.5% of samples. Only the edit that shortened the two-minimum calculation improved runtime. A hot block can contain instructions that contribute little to the time between successive iterations.

| Isolated change | Block weight | Modeled local cycle saving | Session A runtime change | Session B runtime change | Replicated win |
| --- | ---: | ---: | ---: | ---: | --- |
| edit-minima | 97.5% | 12.9% | -26.03% | -25.98% | Yes |
| bst-decrement | 12.4% | 13.9% | -3.03% | -3.64% | Yes |
| tree-bool | 3.1% | 14.9% | -1.52% | -1.37% | — |
| tree-frame | 3.3% | 0.0% | -0.92% | -1.07% | — |
| ray-copies | 16.3% | 12.4% | -0.76% | -1.06% | — |
| tree-pop | 2.5% | 15.0% | -0.61% | -0.91% | — |
| ray-memory | 16.3% | -1.5% | -0.60% | -0.76% | — |
| lexer-captures | 4.7% | 15.0% | -0.56% | -0.37% | — |
| ray-zero | 16.3% | 12.3% | -0.15% | -0.30% | — |
| bst-frame | 2.6% | 9.4% | +0.00% | -0.30% | — |
| lexer-pop | 4.8% | 10.5% | +0.00% | -0.09% | — |
| lexer-immediate | 4.8% | 10.9% | +0.09% | -0.09% | — |
| edit-increment | 97.5% | 2.6% | +0.84% | +0.65% | — |
| bst-literal | 12.4% | 0.0% | +1.21% | +0.61% | — |
| edit-predicate | 97.5% | 7.5% | +0.93% | +1.02% | — |

Negative runtime changes are faster. Each table entry uses paired whole-program observations. The score files retain all ratios, ties and exclusions. The frozen policy also sums individual savings over its four picks. These sums were 31.54, 6.01 and 25.18 percentage points for count, simulated cycles and weighted cycles respectively. They cannot be composed into a suite speedup. [All rankings and pairwise observations](scores.json)

## Do the wins survive the current code and a different layout?

The profiled edit-distance, lexer and ray binaries were from Phase194. Tree sort and BST64 were Phase195. The historical edit-distance result (about 26% less time) therefore needed a current-generation test. Current Phase195 already eliminates several frame spills. Its remaining inner loop still computes two U32 increments and two unsigned minima using scratch-register copies, comparisons and conditional moves. The follow-up used the live operand registers for the comparisons and results, folded the increments, and retained the frame stores and original tail behavior. That removed 11 instructions from the 64-instruction straight-line part of the current loop.

The other winner replaced a register copy plus decrement with a single LEA before flags are overwritten. We retested both ideas on current Phase195 output. Each case included the actual qualified N1 executable, a regenerated baseline and its edited sibling under each of two assembler layout policies. All source objects used to identify the baseline matched their N1 product hashes. Ten rounds balanced the order of all five executables per case.

| Current Phase195 workload | Candidate / baseline with project assembler flags | Faster pairs | Candidate / baseline with default assembler layout | Faster pairs |
| --- | ---: | ---: | ---: | ---: |
| editdist | 0.8429× | 10/10 | 0.8416× | 10/10 |
| local-pair | 0.8433× | 10/10 | 0.8401× | 10/10 |
| coverage-bst-64 | 0.9663× | 9/10 | 0.9576× | 9/10 |

Local-pair exercises the same generated row worker through a different caller. Its result supports transfer across those callers. BST tests a different transformation in an unrelated workload. Each quoted gain compares against a sibling built with identical assembler flags. Across the three cases the regenerated project-layout baselines measured within 1.3% of the actual direct-object N1 executables. These observations do not establish a native45-wide gain or qualify a production compiler change.

## Cost and correctness

- Thirty LLVM-MCA processes took **0.620 s** after preparing the inputs. The guarded model stage, including reading profiles, matching instructions and authenticating inputs, took **2.34 s**. Building and checking the 20 original screen binaries took **1.78 s** on the successful attempt.
- The two complete benchmark sessions took **147.0 s** together, including calibration, for 320 timed invocations. The current-generation and layout follow-up took **57.5 s**, including construction, correctness, calibration and 150 additional timed invocations. The main experiment used existing profiles. Their three original capture jobs cost 207.6 s combined and also covered other roles and cases.
- A replay accounting of measured child time for the four choices under each policy, counting each needed baseline and its calibration once per session, gives 47.9 s for count, 50.2 s for the model and 49.3 s for the weighted model. Model execution and preparation would be additional. Static selection found two wins at roughly the same timed cost as one for each modeled policy. Engineering and manual analysis time were not attributed per candidate, so these data do not establish a long-term discoveries-per-hour rate.
- All binaries passed the original result and repetition-count oracle. Each also matched mature Bend C on three alternate inputs. The first construction attempt exposed the harness's baked-in success count for alternate inputs. We kept the refusal and used the fixture's mandatory one result evaluation with empty repetition/warmup loops at those extra inputs. Timed runs always validate their complete repetition counts. These are finite checks alongside local instruction/register reasoning.
- Profile weights used the addresses of the straight-line block, two sampling periods and the executable hash from the capture. LLVM-MCA repeated the block with the Ivy Bridge model and the historical no-alias assumption. Conditional edges, path frequencies, layout and cache behavior can affect the real rankings.

## Decision

Keep instruction count as the cheap first sort. Use the profile to identify the loop worth investigating, then use the model to compare plausible ways of shortening a real dependency within it. Retain at least one pick outside any single ranking. The first compiler change justified by this experiment is a typed x86 compare/select rule that reuses the operands' assigned registers for an unsigned minimum when destination placement, scratch liveness and flags permit. The separate decrement rule is cheaper to implement and has a smaller measured return. Each still needs actual compiler emission, correctness controls and broader transfer checks before adoption.

## Reproduction

The original predictions were frozen with the four Python files present at commit ca3e8f4. Later measurement and archive scripts in the directory add method-hash entries on a replay, without changing the model inputs or ranking formulas.

The retained worktree needs the exact historical products, captured profiles, runtime and LLVM11 tool identified in the frozen manifest. All workload jobs ran on one guarded CPU. Use fresh output names for a replay. The following commands show the original successful measurement inputs.

```sh
cd /home/ai/bend2/build/publish/bend
p=research/phase196/screen
b=selfhost/build/phase196
python3 -B "$p"/guarded.py model01 45 32 "$p"/freeze.py
python3 -B "$p"/guarded.py build02 90 120 "$p"/measure.py build
python3 -B "$p"/guarded.py timingA 160 16 "$p"/measure.py measure --built "$b"/build02/build.json
python3 -B "$p"/guarded.py timingB 160 16 "$p"/measure.py measure --built "$b"/build02/build.json --reverse
python3 -B "$p"/score.py "$b"/build02/build.json "$b"/timingA/timing.json "$b"/timingB/timing.json --out /tmp/phase196-scores.json
python3 -B "$p"/guarded.py transfer01 145 112 "$p"/transfer.py
```

The archived observations include the raw model outputs, baseline and candidate hashes, independent outputs, paired raw timings and failed preparation receipt. [Frozen source projections](../../research/phase196/screen/frozen.json) · [Receipt inventory](observations.json) · [Raw observations](observations.tar.gz)
