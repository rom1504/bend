# Phase78: B1 parity experiments (in progress)

The installed compiler remains Phase77. No parity or new release is claimed.
[Design](../../design/phase78/b1-parity.md). No agents; one guarded CPU3 process
tree, 2GiB aggregate RSS, 4GiB available-memory floor. No upstream modifications.

## First discriminators

| Candidate | Change over predecessor | B1 / same-run Phase77 B1 | B1 / TypeScript |
| --- | --- | ---: | ---: |
| compiler02 | Direct scanner branches | 0.9936 | 1.9021 |
| compiler03 | 19 native helper functions | 0.9649 | 1.8991 |
| compiler04 | Retain normalized annotation heads | 0.9407 | 1.8143 |
| compiler06 | Central lowering/erasure branches | 0.9305 | 1.7991 |
| compiler08 | Checked annotation-driven layout | 0.9217 | 1.7371 |
| compiler09 | Compact injective C symbols | 0.9426 | 1.7924 |

Each screen has 18 fresh requests, 2 rotations over numeric/array/lexer. Compiler02
through08 reproduce Phase77 C exactly. Compiler09 reproduces an independently
lexically alpha-renamed C oracle exactly (strings/comments/non-symbol tokens
unchanged). The compact-symbol prototype did not improve request time; it is not
in compiler10. These small screens do not establish statistically precise gains.

The broader direct-branch rewrites add many helpers for only a few percent; prune
or reject them if an ablation does not justify that complexity. Compiler01 failed
at parsing a computed match scrutinee; compiler05 failed at typed definitions with
existing laws; compiler07 failed a linear-use check. Corrected versions use normal
Bend syntax and passed the checked bootstrap plus its36 frontend cases.

Compiler10 tests a larger change: whole-program escape analysis to omit curried
closure factories for admitted host workers referenced only by exactly saturated
calls. This changes C and is not selected before execution/conformance checks.
Checked layout also remains provisional pending differential and own-source gates.

Raw attempts, snapshots, pins, guard receipts, errors and complete C files are in
`selfhost/build/phase78`. [Screen medians](screens01.json) are a checkpoint, not a
final evidence capsule. Experimental source has not replaced the released image.
