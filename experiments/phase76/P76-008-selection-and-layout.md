# P76-008: separate compilation wins from executable regressions

Candidate08's complete 45-request comparison cuts B1 request time by 32.25%
and B2 by 22.20%, to 1.99078x/1.51774x upstream. These are three sources,
three rotated/reversed rounds, with old/new B1/B2 and upstream run together.
The complete twelve-family runtime gate nevertheless repeats tree (+3.66%)
and Array.map (+4.93%) regressions. Correct results alone do not justify release.

Saved-C 32/64/128-byte alignment, patchable-entry and hot-section probes did
not recover both. Candidate10 eliminates scalar reconstruction, passes 20,521
independent controls and removes word-building loops, but also fails this screen.
The last hot-section probe has substantial Array.map timing drift; it supplies
no evidence for promotion. No alignment option or runtime change is selected.
Hot machine-code sequences compared equal after address normalization, apart
from error-message references. Layout is a plausible explanation, not proven
microarchitectural causality. The account lacks usable hardware perf counters.
CPU error guards compile away (`DEVICE && ...`), so removing them is not a host
optimization opportunity.

Preserve the complete candidate10 change in `prototypes/candidate10.patch`,
relative to 6becf8675ce6b485ea8072df374bf61aeb564d09, plus its Bend pattern module.
Snapshots and earlier attempts remain in the raw evidence capsule. Select only
lazy intrinsic/call admission and representation certificates for candidate12.
Require twelve exact C files/binaries, clean paired timing, native/raw integration,
genuine B2/B3, self-source checking and installed CLI validation. Do not report
the larger rejected prototype's speed as the selected compiler's speed.

Candidate11 is a preparation failure: the rollback script used the wrong manifest
path, leaving the experimental module in its snapshot. It failed its build and
is not qualification evidence. Candidate12 corrects the manifest and removes the
experimental module from production. No historical raw evidence was overwritten.
