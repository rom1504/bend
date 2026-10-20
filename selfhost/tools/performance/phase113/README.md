# Phase113 complete functions and flat products

This directory contains Bend compiler modules and ordinary experiment drivers.
Read the [design](../../../../design/phase113/qbe-program-parity.md) and
[report](../../../../implementation/phase113/README.md) before selecting a route.
Candidate31 improves generated programs, but full native compiler acquisition
hit its 600-second limit during lowering. Phase112 facts remains the qualified
native checkpoint. No production selection is changed here.

The compiler modules preserve complete typed functions and local loops, flatten
product results, inline bounded call regions, retain ownership and numeric facts,
and render explicit machine widths. `prepare.py` only composes exact Bend
declarations; host drivers do not implement compiler transformations.

## Reproducing the source

`selected-recipe31.json` records ordered module and override paths relative to
this directory. Pass each `modules` entry as `--module` and each `overrides`
entry as `--override` to `prepare.py`, with a fresh output below
`selfhost/build/phase113`. The required baseline is
`selfhost/build/phase112/facts-source01/compiler.bend`, SHA256
`1df2df372cb3614f7cb4d70f5d81741112b7b15943a4eba204407ef7c3232c71`.
The result must have SHA256
`287c85558f3eb40d5576b51a4f7c0238100a9c4c93fc36ee52e3b8bc4e2ac303`.
The source composer snapshots every exact module and records provenance.

This is an authenticated development recipe, not a self-contained fresh-clone
distribution: the frozen baseline, checked API acquisition tools, pinned QBE and
runtime assets must first be restored using their earlier phase recipes. Never
substitute a similarly named source/API/runtime without matching its pins.

## Fast and broad checks

`bench/manifest01.json` freezes six development programs. `bench/run.py` supplies
graded runtime checks; `bench/hosted45-v2.py` authenticates the same checked API,
runtime and staged emitter on the original broad45 corpus. Its optional reuse
map avoids rebuilding identical six-case products. The existing Phase112 broad
runner supplies the unchanged workload profile and three rotated timing rounds.

Keep source checking, full output comparisons, generated-program runtime,
compiler-request timing and full image construction separate. The broad corpus
has 45 output checks but 44 timing ratios: the zero-work control has no ratio.
Native generation acquisition is a separate gate in `bench/NATIVE-FINAL.md`;
the failed candidate31 acquisition does not qualify N1 or N2.

Use one serial CPU3 target lane, ordinary 2 GiB small-job or 4 GiB full-job
guards, a 16 GiB available-memory floor and explicit time/file limits. Reuse
immutable products. Preserve failure receipts and use fresh output paths.
`bench/FINAL-EVIDENCE.md` documents bounded JSON evidence collection; an incomplete
native capsule must stay explicitly incomplete. Do not run broad campaigns or
another full image before the smaller question justifies them.

The finite controls cover individual semantic boundaries. They are neither
whole-compiler proofs nor a substitute for unchanged complete-program outputs.
