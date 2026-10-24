# Phase136 ordinary cold source-to-executable baseline

The qualified Phase134 N2 compiled the fixed actual Phase131 full compiler source
through the existing monolithic QBE pipe, assembler and linker in **375.923
seconds guarded**, with **1,018,036,224 bytes** sampled peak process-tree RSS.
The complete107,059,385-byte QBE digest equals the independent historical oracle;
compiler, QBE, assembler and linker succeeded. No full textual QBE was spooled.
This is one controlled observation, not an upstream comparison or a new native
qualification.

Producer source is `a0001924…fa19fb57`, producer image `9909f18f…2a57d21b`.
Input source is `1bc5930e…728f9` at its unchanged historical path. The generated
executable is `4345df69…60a16a4`; installed/qualified selection is untouched.
The input source and producer source are deliberately different identified roles.

The internal pipeline clock is374.939s, with369.031s for overlapping compiler
emission/QBE,4.773s assembly and0.265s linking. The outer guard additionally
includes preflight and supervision. Do not add these nested clocks or identify
369.031s as compiler-only CPU time.

“Cold” here permits the pinned immutable compact prepared Base, prebuilt runtime
and existing qualified executable. It forbids source/edit/optimizer/object
session reuse; it does not flush OS page caches or charge toolchain/Base/runtime
acquisition. These are the same explicit policies recorded before execution.

Exact local receipts:

- `selfhost/build/phase136/cold-baseline-plan01/plan.json`
- `selfhost/build/phase136/cold-baseline-launch-audit01.json`
- `selfhost/build/phase136/cold-baseline-guard01/process.json`
- `selfhost/build/phase134/p136-cold-baseline01/report.json`

The [source audit](source-audit.md) ranks bounded structural experiments using
actual query contracts and prior Zig/Go research. The appended Bend query proxy
now passes independent source checking,14 controls and30 exact observations;
see [query results](query-results.md) and [compact JSON evidence](evidence01/summary.json).
It changes no qualified declaration. Its counter schedule is not a measurement
of real whole-request call frequency or a speed improvement.

The first diagnostic source was correctly refused for a missing sharing annotation;
see the [preserved failure and source02 correction](query-check-failure.md).

The compact evidence directory retains19 files (83,025 bytes), including failed
and successful checks and closed cold-baseline receipts. Generated compiler QBE,
APIs, assembly and executables are excluded; exact identities remain recorded.
