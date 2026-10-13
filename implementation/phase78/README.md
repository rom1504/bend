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

## Structural trials and fresh attribution

Compiler10 removes only39–73 closure segments from the timing sources; its
paired result is0.9312× Phase77 B1 /1.7870× upstream. Compiler11 extends the escape
certificate to ordinary nonescaping direct entries and removes inlined intrinsic
entries. It passes six native execution checks and produces21–23% less C on the
three timing sources. Its paired result is0.9041× Phase77 B1 /1.7302× upstream.
These are18-request screening measurements, not final confidence intervals.

Compiler12 removes all160 branch helpers and the scanner rewrites. It retains
annotation/layout and structural entry changes in164 added/18 removed lines
across six production files, and exactly reproduces compiler11 C on three cases.
It costs about3% against compiler11 in these screens but avoids the large source
expansion. Compiler13's exact string-pattern tag discriminator creates48,945 bytes
of B1 JS; compiler14 factors prefix characters. Neither improves the short screen,
so both are rejected. [Further screens](screens02.json).

[Fresh compiler11 profiles](diagnostic11.json) show observer routing123–195ms,
native preparation95–114ms, and final C rendering96–117ms. String.cmp is a
successful expensive observer route. Nat.read.trim bears the first substantial
annotation cost, including possible cold JIT work; do not infer a body-specific
algorithmic defect just from that attribution. Compiler15 tests an exact cheap
negative intrinsic-name filter on the smaller compiler12 source.

The next larger proposal is [reusable native library products](../../design/phase78/native-library-products.md).
Prepared-native-library measurements must remain separate from the existing
prepared-frontend-only baseline, with preparation and reading/admission reported.
No product implementation or parity claim is made at this checkpoint.
