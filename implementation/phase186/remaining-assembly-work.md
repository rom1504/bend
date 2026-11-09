# Remaining assembly work: local-fold

This is an offline machine-code comparison, not a new timing or causal profile.
It identifies concrete remaining selection and placement work after Phase186.
The same catalog input is `n=4096, seed=17`, with expected output `2339999928`.
The retained benchmark includes its normal per-invocation oracle checks.

## Exact inspected artifacts

Paths are relative to the repository root; hashes are SHA-256.

| Role | Artifact | Bytes | SHA-256 |
|---|---|---:|---|
| Final x86 | `selfhost/build/phase186/xmm-live-x86-build01/local-fold/machine/program` | 188624 | `c23445dd711400ca8bf6f2aa136949cb5577823f8ede697af485ed50722e1e6d` |
| x86 assembly | `selfhost/build/phase186/xmm-live-x86-build01/local-fold/machine/program.s` | 439314 | `92e46d062f24067f18b0f8b8ac1fab1742fb80018f2092fed5039e1822e9d50f` |
| QBE | `selfhost/build/phase185/release-native45-acquire01/local-fold/phase185-qbe-n2/machine/program` | 157752 | `6c410c38145e41d297ea65da0ff662aae49fb2a861056cf6cfa6312dfcbdc27d` |
| Our C backend | `selfhost/build/phase184/bend-products01/local-fold/bend-c/program` | 93664 | `ddf9f48cb789b857115946cc18a79796f344e747094b6ceff2e6f1229c8a0ffc` |
| Generated C | `selfhost/build/phase184/bend-products01/local-fold/bend-c/emission/program.c` | 272902 | `1f5640b686ac1bb2e1fa1a5b6fe77ac9a82607378ce767da304e7574cacd2bc0` |
| Bend fixture | `selfhost/tools/bench/catalogs/native45/fixtures/local-fold.bend` | 2737 | `2252256562cc415348f3aa53c960b318f87c4a8b5fd118a0a2f115d446723125` |

`selfhost/build/phase186/xmm-live-x86-paired01/recipe.json` binds C, before and
candidate products. Before and candidate local-fold assembly have the same hash
above: this case has no floats, and its improvement is not attributable to XMM.

## Actual positive-iteration paths

Read-only `nm -S` and bounded `objdump -d --disassemble=SYMBOL` were used.
For x86/QBE the symbol is
`p113d_FID_36_112_114_111_100_117_99_116_46_102_111_108_100_46_108_111_111_112_`
(`$product.fold.loop`), not the separate `p117v_` fallback.
Count the x86 inclusive spans `0x409d14..0x409d34` and `0x409d63..0x409e50`;
the QBE inclusive span is `0x407380..0x4073b1`.

| Static work per positive iteration | Final x86 | QBE |
|---|---:|---:|
| Instructions | 66 | 17 |
| Explicit rbp/rsp frame references | 21 | 0 |
| Array reads / writes | 1 / 1 | 1 / 1 |
| Helper calls | 0 | 0 |

The x86 path contains 47 moves. Frame homes include index `rbp-64`, accumulator
`rbp-80`, invariant mask/base `rbp-2320`/`rbp-2336`, and scalar intermediates.
It materializes two complementary conditions, multiplies the index by four,
and separately reconstructs the load/store address. QBE keeps these values in
registers, uses scaled addressing and has one loop-exit comparison.
The x86 prologue reserves 2624 bytes once per 4096-iteration invocation;
neither per-iteration allocation nor call ABI traffic explains this path.

The C symbol `WL_FID_36_100_105_114_101_99_116_46_102_111_108_100_46_108_111_111_112_`
(`$direct.fold.loop`, `0x9f90`, 594 bytes) has a different tuple representation.
Its ordinary loop retains inline tuple/free-list work, but keeps loop values in
registers and folds scaled array addressing. Cold helper paths remain possible.

## Smallest reusable next changes

1. **Comparison-to-branch selection.** `selfhost/src/back/x86/register-binary.bend:56`
   materializes `cmp/setcc/movzbl`; `selfhost/src/back/x86/function.bend:65`
   reloads the Boolean and emits `test/jz`. Two eight-instruction sequences occur
   on this path. Fuse an adjacent comparison and branch only when its Boolean
   has no other uses; retain the old route otherwise. Check operand aliases,
   U32/U64 comparison semantics, nested branches and reused results. Removing
   the second complementary test requires separate dominating-condition proof.
2. **Loop-weighted fixed-home allocation.** The three-static-read threshold in
   `selfhost/src/back/x86/regalloc.bend:111` leaves r14/r15 unused here.
   `selfhost/src/back/x86/transient.bend:97` and `:204` deliberately exclude
   cross-branch ranges and parameter/setup homes. Weight loop reads in the
   existing unique, globally fixed callee-saved allocation before attempting
   broader lifetime allocation. This is a selection-policy experiment with
   unchanged placement legality; test backedges, calls and parallel Again moves.

No runtime percentage follows from these static counts. The older accepted
`selfhost/build/phase185/array-profile02/plan/comparison.json` attributed 840/841
samples to this function, but used an older binary and had no independent clean
CPU denominator. Its SHA-256 is `6795d19575e00a24c27ba086dc9bbdc5c45217b2f87533bd3a2c2b5cd7a4d99b`.
Fresh matched timing and profiling are required to establish either change's gain.

A separate F32 follow-up is to let the new opcode23 conversion participate in
that same private operand/effect plan. It deliberately remains a conservative
call barrier in this phase even though its final selector emits instructions.
That safety boundary makes the first change easy to isolate, but leaves scratch
stores and prevents some XMM regions from composing across conversions. Use the
existing typed plan and shared effect summary, with explicit one-cell reads,
instead of adding another unrelated recognizer. The current ray profile and
machine audit justify investigating it; they do not establish its gain. Recover
repeated analysis cost as these facts are shared across passes.
