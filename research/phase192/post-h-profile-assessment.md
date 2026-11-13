# Post-H physical profile assessment

The new profiles confirm a large reduction in physical scheduler/continuation
work. They now expose constructor/take helpers and the generated recursive
workers as the main remaining costs. This is diagnostic attribution of the
selected product, not another optimization or a causal ablation of H alone.

## Authentication and admission

`selfhost/build/phase192/profile-analysis02/{derive.py,comparison.json,report.json,contrast.json}`
contains the offline audit. All frozen program, timing, binary, sampler, raw
capture, mapped-object and analysis identities were verified. Python
`compare.summarize_reports` reproduces the persisted comparison exactly;
Python `analyze.analyze_capture` independently reruns all **12 raw captures**
and reproduces their full analyses exactly. ELF metadata is read with readelf.
No target, compiler, Bend/Bun, or native analyzer was executed. These are the
maintained profiler's Python-analysis receipts; this audit does **not** claim
an independent Bend implementation cross-check. All six case-role workloads
remain separate, with **zero cross-role pooled comparisons**.

Capture `profile02` is complete/passed, all outputs valid, unchanged inputs.
Its aggregate `profilesUsable=false` is preserved: individual period captures
have fewer than 500 samples. Pooling the two periods within each exact role
command passes the maintained comparator's admission for all six pools.

| Case / role | Repetitions | Pooled samples | Unknown samples | Unknown weighted share |
|---|---:|---:|---:|---:|
| tree candidate | 5,429 | 606 | 29 | 4.2332% |
| tree C | 17,497 | 581 | 0 | 0% |
| expression candidate | 1,142,896 | 577 | 5 | 0.7873% |
| expression C | 1,318,829 | 581 | 0 | 0% |
| lexer candidate | 2,585 | 570 | 1 | 0.1418% |
| lexer C | 7,435 | 577 | 0 | 0% |

All pools have both 8,000/13,000-us periods, zero dropped samples/overruns,
zero rejected captures, complete thread lifecycles, at least 99.9017% capture
window child-CPU coverage and 99.9941% sampled-thread CPU coverage. Unknown
PCs remain in denominators. The extra historical **zero-unknown** requirement
would fail all three candidate pools; it is not silently waived or described
as passed. Sampled/clean wall ratios range 0.9973–1.0352; tree candidate is
1.0352. One clean observation and two periods give no confidence interval.

## What changed physically

Every figure below divides that role's clean CPU by **its own** repetition
count. Startup, warmups and validation remain included. Pre-H is profile01's
Phase191 baseline; post-H is profile02's exact selected-build01 candidate.
The mature C executable SHA256 identities are unchanged between captures.

| Case | Pre-H CPU us/invocation | Post-H CPU us/invocation | C pre / post us/invocation |
|---|---:|---:|---:|
| tree | 784.030 | 531.295 | 165.636 / 164.426 |
| expression | 5.79035 | 2.51719 | 2.18861 / 2.18331 |
| lexer | 1,967.527 | 1,089.432 | 385.774 / 382.023 |

Physical owner estimates multiply within-role period-weighted share by clean
CPU/invocation. The following disjoint name groups use the regexes retained
in contrast.json. Anonymous continuation bodies contain required computation;
their disappearance as symbols does not mean all their work was eliminated.

| Case | Explicit dispatch us, pre → post | Anonymous continuations us, pre → post | Constructor/take us, pre → post |
|---|---:|---:|---:|
| tree | 122.266 → 36.592 | 155.559 → 45.070 | 149.184 → 158.594 |
| expression | 0.83554 → 0.06474 | 1.93192 → 0.03479 | 0.61151 → 0.50071 |
| lexer | 254.319 → 8.692 | 303.098 → 18.157 | 178.731 → 176.550 |

Explicit dispatch means rt_jump/rt_return/set_regs/work_loop, not every runtime
helper. Changes in attribution and owner boundaries prevent treating these
deltas as isolated speedups. Low-count rows remain low precision.

- **Tree:** new p114r warp is 19.89% / 105.67 us; ctor2 15.74% / 83.63 us;
  take2 13.14% / 69.79 us; structured warp_leaf 10.21% / 54.26 us.
  Constructor/take aggregate is 29.85%, with roughly unchanged absolute CPU.
  Dispatch plus anonymous continuations still occupy 15.37% / 81.66 us.
  C physical warp is 28.15 us, but its ownership operations can be inlined;
  these owner boundaries do not define equivalent units of source work.
- **Expression:** p114r eval is 40.34% / 1.01551 us; recursive expression
  builder 13.65% / 0.34349 us; take2+ctor2 19.89% / 0.50071 us.
  C eval is 1.16673 us. Remaining aggregate CPU gap is only about 0.334 us,
  so even the 0.501-us helper share is not an achievable savings forecast.
  Runtime-op dispatch is 9.59% / 0.24133 us (pre 0.27166 us); its increased
  percentage mostly reflects a smaller denominator. rt_frame remains
  3.87% / 0.09732 us. The optional scoped-frame experiment was not selected;
  these profiles describe the unscoped maintained H consumer.
- **Lexer:** recursive gen is 18.14% / 197.60 us, product.lex 16.31% /
  177.71 us, take2 12.71% / 138.50 us, product.step.at 8.94% / 97.35 us,
  and structured gen.at 7.71% / 84.03 us. C gen is 23.48 us, gen.at 74.25 us,
  classification step 117.66 us, lex 117.40 us. The step leaf is therefore
  not evidence for the largest remaining gap. Runtime-op has 7.07% /
  77.07 us and destination-fill 3.92% / 42.69 us; these are physical helper
  totals, without source-caller or per-operation attribution.

## Strongest next mechanism

The strongest cross-case evidence is now **ownership/allocation fast paths
plus generated recursive-worker overhead**, not a return to scheduler-only
or tiny register-copy tuning. Tree and lexer retain roughly 159/177 us in
constructor/take helpers even after most continuation dispatch disappears;
C already places fast ownership/allocation paths in generated workers.
These 29.85%/16.21% physical shares are upper envelopes containing necessary
work, not expected recoverable savings. The capture supplies no allocation
counts, cache misses, inclusive stacks, or fast/slow-path proportions.

Within the H lowering specifically, lexer gen remains a strong target for
source/CFG inspection: its 197.60-us physical leaf is prominent while its
ready gen.at helper is near C's physical leaf. Tree p114r warp remains
prominent too. Earlier machine audits showed the P113 state-loop carries
parameter/mode/depth/value transitions and extra snapshots; direct local
case edges with live edge values could preserve the same explicit runtime
stack while reducing those transitions. That mechanism still needs exact
path accounting and a separately gated experiment, not inference of its
ceiling from symbol shares. No further optimization or target job was run.

Artifact size: the four audit files total 234,164 bytes (228.7 KiB); raw captures
are reused in place, not copied. The authenticated combined adaptive runtime
report remains the performance authority; this profile contrast is descriptive.
