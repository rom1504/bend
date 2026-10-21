P114-011 passes its checked API/admission, actual-source structural gate and both ordinary complete-output cases. In the root's three-round matched screen, active ray falls from **411 to 369 ms** versus the scalar-operands parent: **0.8978×**, or **10.22% less time**. Versus the selected compiler in the same run, it is 423→369 ms (**12.77% less time**). The result supports this bounded local representation-reuse hypothesis; it does not establish broad generated-program parity or default promotion.

| Program | Selected | Scalar operands | Float lanes |
|---|---:|---:|---:|
| Active ray 256/2240 | 423 ms | 411 ms | 369 ms |
| Local-pair | 391 ms | 390 ms | 389 ms |

Ray samples are selected `[425,423,421]`, operands `[411,412,410]`, lanes `[369,369,371]`. All 30 complete-output/count observations across five roles, two programs and three rounds pass. The two-program geometric mean is 0.9463× the operand parent and 0.9316× selected. These aggregates include local-pair as a no-code-change control: its three QBE files are byte-identical, SHA-256 `47f686f066a9ee3de3dfb1899883c46a14cae33484c88bac77ab2f73ead73a57`. Its 1–2 ms differences are not an optimization effect. Millisecond timing resolution and three rounds limit small-gain claims.

The machine witness is `isect5` in the exact three ray builds:

| Static function property | Selected | Scalar operands | Float lanes |
|---|---:|---:|---:|
| GPR/XMM moves | 49 | 49 | 25 |
| Assembly instruction lines | 200 | 166 | 131 |
| Explicit stack reservation | 2072 B | 24 B | 24 B |
| QBE word-to-F32 casts | 44 | 44 | 26 |
| Explicit U64 result assignments | 28 | 28 | 28 |

The exact ordered QBE numeric-operation sequence is unchanged, as are all word-result destination names and the function signature. All ten arguments remain integer `l` after the state pointer, and the result remains `l`; five argument words still arrive on the stack. This is reuse of existing internal `s` temporaries, not a typed floating-point call ABI. Assembly retains 19 scalar arithmetic instructions, two floating comparisons and the same runtime/failure call list. Instruction selection changes one subtraction into an addition with a sign operation, so individual assembly opcode counts are not claimed identical. Remaining conversions, generic sqrt and integer call transport are outside this experiment.

The actual-source gate observes `copy_chain` with 26 local copies, four groups and three repeated result destinations: casts8→4. `convert_chain` has eight copies/two groups/one rebinding and casts2→0; `arithmetic` casts8→6. Ordered float operations and U64 results agree with the parent in every witness. Unsupported sqrt fallback is byte-exact. Eight independent fact-map assertions pass; ordinary `copy-chain` and the unchanged float fixture produce their literal expected outputs. This scope is narrower than a general floating-point conformance campaign.

`results.json` pins measurement, API/admission, structural/ordinary observations, assembly/QBE and build/emission receipts, with exact function line references and counting details. The primary report is `selfhost/build/phase112/p114-float-lanes-screen01-measure/report.json`. Machine lines for `isect5` are selected1185, operands1161 and lanes1155 in their respective `program.s` files. This summary inspected existing artifacts only; no target was executed and no frozen module or root report was changed. The selected broad score and native qualification remain separate.
