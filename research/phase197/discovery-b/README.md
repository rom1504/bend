# Integer and tree optimization discovery

Four generated-assembly alternatives shortened their local LLVM-MCA traces. None met the frozen whole-program threshold. Following the BST tag test through its loop exposed a fifth, separately frozen control-flow hypothesis, described in [the absorbing-state experiment](absorbing/README.md).

## Prospective screen

The baseline is the qualified Phase195 N1 object and its matching assembly at c07b44a. Every projection authenticates two retained 8/13 ms sampled-PC captures per case and the object/executable pair. The sample share covers each complete edited straight-line block, including instructions that survive the change. It estimates physical CPU time at those PCs. The model repeats each complete straight-line block 100 times with LLVM 11's Ivy Bridge schedule and no-alias setting. The ranking sums block shares times modeled fractional cycle savings. [Freeze](frozen.json) · [Scores](model.json)

| Alternative | Edited sites | Block sample share | Weighted model score | Project layout, sessions A / B | Default layout, sessions A / B |
|---|---:|---:|---:|---:|---:|
| BST 16-bit tag equality | 2 | 13.05% | 3.70% | 0.9881 / 1.0000 | 1.0024 / 1.0096 |
| BST dominated complement predicate | 1 | 1.87% | 1.51% | 0.9904 / 1.0073 | 0.9786 / 0.9760 |
| BST direct constructor-field stores | 4 | 2.79% | 0.58% | 0.9952 / 1.0048 | 0.9881 / 0.9808 |
| Tree constant packed header | 4 | 0.79% | 0.46% | 0.9976 / 0.9780 | 1.0072 / 0.9715 |

Table entries at right are medians of four candidate/assembly-sibling pairs per cell. Two sessions use independently seeded, rotated role orders. Layout order alternates. Advancement required a median ≤0.98 and at least three faster pairs in every layout/session cell. Tag comparison led the model scores but produced no repeatable material benefit. The lowest-ranked packed header had two faster pairs in every cell. The complement rule cleared the cutoff under the default layout alone. Each binary checked the ordinary fixture result/count and three more inputs against mature C. The direct N1 executable also passed those four controls. [Raw timings, roles, pins and checks](diagnostic.json)

- A shifted tag needs a 16-bit equality comparison when only its low 16 bits are tested, the compare result feeds JNE, and the widened register value and literal scratch are dead. The old mask and literal move then disappear.
- An unchanged predicate known false on its sole predecessor has a known true complement. The projected code recreates all live values and final test flags.
- Known local constructor field addresses select direct frame-relative stores with identical addresses, widths and order when both scratch registers die before the helper. An immediate must fit the signed store encoding.
- Constant constructor tag and arity bits combine before code generation. The final payload OR preserves flags and the literal scratch dies before use.

The guarded model used 0.722 s for 22 invocations plus preparation. Building, performing finite checks, calibrating and recording 96 timed samples took 24.175 s on CPU3. Both guards sealed successfully. The assembly alternatives have no native45 qualification. [Guard receipts and raw MCA outputs](screen-receipts.tar.gz)

## Replay

Run from the repository root with the retained Phase195 binaries, exact sampled profiles and toolchain. The scripts accept fresh alphanumeric run names. The model output must be copied alongside the frozen projection before timing.

```sh
d=research/phase197/discovery-b
python3 -B "$d"/freeze.py
python3 -B "$d"/guarded.py discoveryBModelReplay 30 24 "$d"/model.py
cp selfhost/build/phase197/discoveryBModelReplay/model.json "$d"/model.json
python3 -B "$d"/guarded.py discoveryBTimingReplay 85 64 "$d"/diagnostic.py
```
