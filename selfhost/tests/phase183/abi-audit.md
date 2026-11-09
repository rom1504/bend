# Phase183 assembly ABI audit and finite gates

This is a source audit and proposed gate sequence, not an execution receipt.
Only root runs checking, compiler acquisition, machine construction and targets.
The adapters here contain transport and independent observers; lowering remains
in the checked Bend compiler. No production backend source changed in this audit.

## Findings against the current contract

* `x181_program_data` renders the structured `P111QData` supplied by the shared
  verified preparation. `p111q_descriptor` now supplies ABI **11102**, a 192-byte
  descriptor, and the current effects table. There is no stale 11101 literal in
  the x86 emitter. The physical `P111State` remains 2088 bytes. The new
  `abi-contract.c` checks the maintained headers against the retained observer's
  exact state-canary size and the descriptor's pointer slots.
* `x181_program_main` preserves SysV `argc`/`argv` in RDI/RSI, places the descriptor
  in RDX, and tail-jumps to the current `p111_rt_main`. New argv/RTS interpretation
  belongs to that runtime. The application controls must use the authenticated
  provider's `bend-rts-v1` convention, not Phase181's old argument adapter.
* Primitive **86** is the appended `F32.from_nat` operation. The shared lowering
  passes it through `p111_rt_op(state, op, word_buffer, count)`. Its result is a
  U64 word containing F32 bits, not a C `float` return in XMM0. x86's ordinary
  integer/pointer call ABI therefore carries it unchanged. The current numeric
  fixture independently checks rounding and inputs above 32 bits through the
  full 48-bit Nat range. The header contract checks opcode 86 and limit 87;
  these static checks alone do not qualify the runtime conversion.
* `x181_alu`/`x181_condition` cover exactly the current `p111v_operator` set:
  add/sub/mul, and/or/xor, shl/shr/sar, and ten comparisons. There is no admitted
  native division opcode missing from x86: division and remainder use existing
  runtime helpers. Floating-point operations also remain runtime calls.
* Comparison `typ` is operand width. x86 compares at that width, writes SETcc
  into R10B, then zero-extends into R10D; the result matches the verifier's U32
  contract. Loads, stores and call/assignment narrowing preserve U32 truncation.
  Conditions use the low 32 bits because both verifiers require U32 conditions.
* Direct result counts are admitted only in **1..8**, so the 64-byte hidden
  result scratch is sufficient. Direct parameter count is at most 255. Alloca
  admission permits only **1..2048 bytes**, aligned **4, 8 or 16**, matching frame
  placement. State/scratch parameter collisions are already rejected by the
  shared verifier; `__x181` collisions receive the backend's explicit refusal.
* Incoming stack arguments are RBP+16 onward. The prologue preserves RBX, RBP,
  R12–R15 and aligns RSP to 16 bytes before calls. Outgoing argument sources are
  stack homes, constants, or callee-saved registers, so writing ABI argument
  registers cannot destroy a later source. `P113DAgain` uses its separate
  snapshot before parameter writes; the hidden output pointer is preserved.
* Imported `p112w_` forwarders are reconstructed only for the supported one-result
  signature. Missing legacy workers and reserved locals refuse explicitly.
  Streaming failures can leave partial assembly; only a successful maintained
  build receipt admits the artifact. No partial bytes count as a successful
  rejection or generated program.

No concrete new ABI mismatch or missing admitted scalar operation was found.
This is not a general proof of machine selection. The finite raw controls do
not observe alloca address alignment directly and do not invent out-of-range
raw-IR shift semantics. Linux AMD64 SysV, the declared assembler/linker policy,
one Bend heap mutator and GPU off remain the intended execution scope.

## Current adapters and unchanged oracle inputs

`machine-controls.mjs` uses the committed Phase181 `abi-controls.bend`,
`hygiene-controls.bend`, `abi-runner.c` and `abi-preserve.s` as fixture/oracle data.
It never imports their old orchestration. This retains the 17 actual functions,
ten namespace observations, full-word outputs, result/state canaries, callee-saved
register observer, spilled arguments and 100,001-iteration permutations.

The checked API source must include those two Bend fixture modules. Its roots
are `p181c_validate`, `p181c_functions`, `p181h_validate`, `p181h_controls`,
`x181_direct` and `missing`. Supply an independent source-check report for the
exact same source and current upstream revision. The machine runner pins all
fixtures, source, API, check inputs, current ABI headers, engine and explicit
machine tools. It links **no runtime object** for these pure machine controls.

```sh
selfhost/.assets/bin/bun selfhost/tests/phase183/machine-controls.mjs \
  --api CHECKED_EMITTER_API_REPORT \
  --source-check MATCHING_INDEPENDENT_SOURCE_CHECK_REPORT \
  --assets CURRENT_ASSET_MANIFEST --out FRESH_RUN_ROOT
```

`runtime-controls.py` invokes only maintained `tools/build/native.py` with target
`x86`. It requires ABI11102 and obtains runtime arguments from that explicit
provider. Existing Phase182 fixtures provide ten complete output/status oracles:
numeric, two unchecked-array forms, Unicode output, text/byte argv, files,
open errors, quiet exit 23, exit 255 and halt 7. Halt's stdout and stderr remain
separate. Every case gets an isolated writable directory. The adapter stops at
the first discrepancy and preserves its build/execution records.

```sh
python3 -B selfhost/tests/phase183/runtime-controls.py \
  --assets CURRENT_ASSET_MANIFEST --image-key X86_IMAGE_KEY \
  --host native --stage ACTUAL_STAGE --runtime-key qbe-runtime \
  --out FRESH_RUN_ROOT
```

An explicit `--image IMAGE --image-receipt RECEIPT` can replace `--image-key`.
The retained provider key `qbe-runtime` names the shared current runtime object;
it does not invoke QBE or change the assembly target.

## Minimal gate order

1. Independently check the exact current emitter plus fixture closure, acquire
   its checked API, then run the 17 machine functions and ten hygiene observations.
2. Run the ten current runtime controls through the maintained x86 path and
   ABI11102 object. Preserve exact stdout, stderr and requested exit codes.
3. Run all **64** cases using the current authority at
   `selfhost/tests/phase182/qualification-catalog.json`, with target `x86`, genuine
   image binding and the maintained qualification runner. The older default
   catalog revision is not the migration authority. All selected cases, including
   the three stage-specific refusals, must be accounted for; never relabel an
   unsupported refusal protocol as a pass.
4. Only after these gates, acquire current-source x86 generations and compare
   the same complete source's assembly/object/executable behavior. Machine
   controls, native64 and runtime10 do not establish bootstrap reproduction.

Every executable command belongs under one outer process-tree/disk guard with
fresh run roots. Current receipts must authenticate the actual image, source,
runtime, Base and tools; historical successful Phase181 receipts are provenance
only. No execution has been performed as part of preparing these adapters.
