This is a proposed bounded first-emitter gate, not an executed qualification.
No source fixture, runtime, compiler semantics or existing verifier changed in
this task. Compare two emitters consuming the same admitted `N111Stmt` /
`P113DStmt` program, with the same static data, IDs, runtime and machine policy.
Keep backend support refusals distinct from incorrect execution. Start with at
most 32 small valid IR functions, nine existing positive source fixtures, then
the two compiler workloads below; do not acquire a full compiler image first.

The existing contract is explicit in `../../src/back/qbe/model.bend:4`: binary
`typ` is operand width, comparisons produce U32, and memory offsets are bytes.
Generic segments receive only `state` (`:32`). Direct functions have hidden
`state`, plus a result-buffer pointer when result count differs from one
(`../../src/back/qbe/verify-direct.bend:264`, `:281`, `:334`). Count those hidden
arguments when testing the six integer/pointer argument registers. Multiple
results are ordered eight-byte buffer stores with status zero; they are not a
new two-register return convention. `P113DAgain` snapshots every old argument
before assigning any new one (`:235`, `:247`). Preserve this ABI initially.

The following are finite, newly proposed machine controls. Inputs and outputs
are mathematical integer/byte observations, independent of either emitter.
Create valid functions through the checked IR constructors/verifier; do not
make unsupported test imports legal by weakening admission. Pass operands as
parameters where applicable, so constant folding cannot discharge the test.
Use fixed-width hexadecimal output for raw words; result canaries and status
are separate observed fields. The test host observes results and ABI state;
it does not implement Bend evaluation.

| Control | Exact input / expected output | What must be present in admitted IR |
|---|---|---|
| Width and high bits | U32 `ffffffff + 1 -> 00000000`; U32 `0 - 1 -> ffffffff`; U64 `00000000ffffffff + 1 -> 0000000100000000`; U64 `ffffffffffffffff + 1 -> 0000000000000000`; U64 `0000000100000001 & 00000000ffffffff -> 0000000000000001` | Both widths, a nonzero high immediate, wrap, low-word zero extension. Reuse the construction style in `../../tools/performance/phase113/width/cases-v2.bend`; its cases 9/12 deliberately retain the unmasked result, so they must not be treated as U32 operations. |
| Shifts | U32 `80000001 shr 1 -> 40000000`, `sar 1 -> c0000000`, `1 shl 31 -> 80000000`; U64 `0000000100000001 shr 32 -> 1`, `1 shl 40 -> 0000010000000000`, `8000000000000000 sar 63 -> ffffffffffffffff`; count zero preserves the input for one U32 and one U64 case | Constant and variable counts, destination/source aliasing, and live values across a variable-count shift. Counts stay below operand width; do not invent a contract for out-of-range IR shifts. |
| Compare result width | U32 `ffffffff` versus `1`: `ult=0`, `slt=1`; U64 `00000000ffffffff` versus `1`: `ult=0`, `slt=0`; U64 `8000000000000000` versus `1`: `ult=0`, `slt=1` | Signedness follows operand width. Observe the whole zero-extended comparison result, not only a branch outcome or its low byte. |
| Spill threshold and call lifetime | `weightedN(a1..aN)=sum(i*ai)`, inputs `ai=i`: N=6 -> `91`, N=7 -> `140`, N=8 -> `204` | With hidden state these are 7/8/9 machine arguments: one/two/three stack arguments and both padding parities. Keep original operands live across a nested ordinary call; inspect the actual parameter/call IR before counting coverage. |
| Tail parallel transfer | Eight values initially `1..8`, swap a1/a8 on each `P113DAgain`, then weighted sum: one iteration -> `155`, two -> `204` | Permutation across register/stack arguments. The old argument vector must be read before overwritten destinations. The existing four-argument rotate fixture below independently checks a cycle. |
| Multiresult plus spilled argument | Five user inputs `1..5`, hidden state + output pointer: return `[a5, a1+a4, 0000000100000001]` -> `[5,5,4294967297]`, status `0` | Three distinct eight-byte result slots, at least one incoming stack argument, full high-word preservation. Two nested calls must consume the first result before the shared scratch buffer is reused. Test both direct caller and public wrapper where admitted. |
| Memory width and offsets | Start bytes `88 77 66 55 44 33 22 11`; U32 store `aabbccdd` at offset 4 -> U64 load `aabbccdd55667788`. A U32 load at offset 4 -> zero-extended `00000000aabbccdd` | Valid `N111Alloca`, `N111Offset`, load/store widths and byte offsets; surrounding eight-byte canaries unchanged. Use a declared alignment at least eight. |
| Static relocation | Data words `W=[0000000100000001,8000000000000000]`; a relocation to `W+8` dereferences to `8000000000000000`; a function-table relocation invokes its declared function returning `37` | Actual `P111QReloc{symbol,offset}`, not an immediate address substitute; byte/word/long/zeros data and descriptor alignment checked. Preserve the existing `p111_segments`, constructor and show tables (`../../src/back/qbe/emit.bend:249`, `:357`). |
| ABI preservation | Seed RBX/RBP/R12–R15 with distinct full-width constants; invoke the valid spill/multiresult target; all six unchanged and stack pointer restored. At an ordinary callee entry `rsp mod 16 = 8` | A small external ABI shim saves/restores its own state. Check a path with a nested call and local scratch allocation. No assertion depends on caller-saved registers surviving. |

Combine observations where useful to remain within the 32-function cap. Include
one branch join that defines and later reads the same destination on both arms,
and one terminal branch whose sibling falls through, using the existing
`closed-branch-suffix` source below. Unsupported IR should refuse before
assembly; unknown symbols/IDs must never become zero or a runnable placeholder.
The Phase147 render cases (`../phase147/render-controls.bend:28`) are useful
inputs for mixed widths, function/constructor IDs and symbols, but their old
QBE text strings are not an assembly oracle. The Phase113 direct-IR manifest
explicitly marks its artificial originals **never executable**; retain that
suite only as compiler-data verifier/refusal evidence. Likewise, malformed
prepared-constant controls in `../phase152/prepared-constants-controls.bend`
are not native targets.

Reuse these positive source/output pairs unchanged. The first four come from
`../../tools/conformance/qualification-catalog.json`; the remainder are frozen
by `../../tools/performance/phase113/controls/manifest01.json`, with separate
`.stdout` files under its `expected/` directory. A listed source does not by
itself establish that a direct worker or multiresult route was selected: retain
the actual lowered function/statement inventory for the relevant names.

| Existing source | Complete expected stdout | Purpose |
|---|---|---|
| `../consolidation/native-focused/u32-wide-wrap.bend` | `94 q\n` | Large literals, wrap and wide literal matching |
| `../consolidation/native-focused/u32-divmod.bend` | `9\n` | Preserve runtime-mediated total division/modulo, including zero divisor; do not replace this with raw trapping machine division |
| `../consolidation/native-focused/pure-aggregate.bend` | `([7, 7, 7], (1, 2n, 'c'), [[True{}], []], [3, 3], [])\n` | Static values, constructors and show-descriptor registration |
| `../consolidation/native-focused/higher-order-capture.bend` | `captured=42\n` | Generic closure/dispatcher route |
| `../../tools/performance/phase113/controls/fixtures/tail-argument-permutation.bend` | `123\n231\n312\n312\n` | Inputs 0/1/2/100001 iterations; simultaneous argument transfer |
| `../../tools/performance/phase113/controls/fixtures/closed-branch-suffix.bend` | `93\n92\n82\n4294967213\n` | Branch join, subsequent call/use, unsigned wrap |
| `../../tools/performance/phase113/controls/fixtures/array-scalar-return.bend` | `107\n17\n7\n` | Array owner and scalar across two product returns |
| `../../tools/performance/phase113/controls/fixtures/string-field-alias.bend` | `leftλ\nλtfel\n20\nλtfel\nleftλ\n` | Owned fields, surviving aliases and release order |
| `../../tools/performance/phase113/controls/fixtures/non-tail-reconstruction.bend` | `0\n0\n57\n` | Recursive reconstruction on `[]`, `[4294967295]`, `[1,4,2,8]`; preserve genuine fallback |

For the first real compiler computation, compile the maintained substitution
closure with `../phase177/substitution/controls.bend`, without Phase180's rejected
representation override. Its 20 `P177SCase` records already contain literal
complete expected terms; `p177sv_actual` must equal `p177sv_expected`, and the two
direct-root `subst_node` results must equal `p177sv_node_expected`. Observe every
term field, including source spans, removed names and lambda quantity presence;
retain input/replacement aliases until observation. This reaches the real
`p177s_loop`, beta restoration, frames, field lists and ownership calls. Its
existing `workload.bend` provides the larger exact input: `p177sw_run()` runs 64
seeds starting at 1, incremented by 7919, with the original depth-12 mixed tree
and alternating hit/miss IDs. Keep construction, result observation and teardown
inside the workload. Freeze an incumbent-QBE observation before an assembly run;
the digest has no independently established decimal constant in this plan and
must not be invented. The literal complete-value controls remain its separate
semantic evidence.

For the transfer workload, emit the same unchanged Phase175 frontend harness
(`../phase175/frontend-plan.bend`, `frontend-native.bend`, `frontend-digest.bend`)
through both backends. Execute `p175fp_plan("check", seed, path, text)` using the
authenticated prepared Base binding and the frozen compiler input
`selfhost/build/phase175/baseline-source03/compiler.bend`: 656,302 bytes, SHA256
`351ad0e69554e5b12cf8367d5cdde648ab5a1787825614e23158196f5d0e851b`.
The expected constructor is `P175FBook{"check", checkedBook, ""}`, never
`P175FError`; the complete checked book must match an authenticated incumbent
observation. Reuse `../phase175/frontend-values.bend` and its literal
`p175fv_expected()` for independent small complete-value observations. Native
stdout is `phase175 frontend check hash=<frozen incumbent value>\n`; freeze that
value first and label it supplementary differential evidence. The accepted
timing stderr format is already checked by `../phase175/native-frontend.py`.
Use `check` mode first, then a single `request` transfer only if semantic/ABI
gates pass; this is actual compiler work, not a full self-build score.

The maintained harness is reusable in parts, not by disguising assembly as QBE.
`../../tools/build/native.py:24` requires target QBE and `:57` invokes QBE.
A separate experimental assembly adapter should reuse its input pins,
`common.py` process bounds, fresh-output policy, recorded assembler/link jobs
and exact execution observation. Keep the same authenticated runtime, assembler
flag `-mbranches-within-32B-boundaries`, linker `-no-pie`, libraries `-pthread -lm`,
and runtime arguments `--threads 1 --gpu off` (`native.py:30`, `:178`). Record a
distinct backend/protocol and adapter receipt; do not fabricate a QBE build
receipt to satisfy the frontend runner. A small experimental observer adapter
can accept both genuine receipts while requiring identical source/runtime and
the same assembler/linker policy. Assembly/object bytes may legitimately differ;
compare complete execution observations and preserve both binaries and IR pins.

All execution remains root-owned under one process-tree/disk guard, with explicit
fresh run roots and whole-run disk admission. Do not run historical failure
probes or the Phase113 strict-unused-overflow case. Stop on the first semantic
or ABI discrepancy, retain its exact source/IR/assembly/object/output, and repair
that bounded case before expanding. After correctness, one balanced B/C/C/B
comparison of the same real workload is enough for this first screen; retain
emission, assembly/link and execution clocks separately. No claim here is a
proof, broad backend qualification, installed promotion or full-build speedup.
