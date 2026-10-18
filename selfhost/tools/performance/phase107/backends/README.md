# Phase107: independent native machine backends

`qbe.bend` adds a Bend-written QBE1.3 emitter for the exact verified `NxProgram`
graph used by the Phase106 C and JSON consumers. It contains no Bend source
parser, checker or alternate source-language semantics. Include it after the
Phase106 model/verifier/C support, then call `nxq_program(program)`.

`nxq_program` refuses an invalid graph by emitting `INVALID_NX_PROGRAM`, which
QBE cannot compile. Callers should independently check `nx_verify` to report a
structured error rather than publishing an invalid output artifact. Successful
source emission alone is not correctness or performance qualification.

## Pin and pipeline

QBE1.3, official2026-06-01 release:

- Archive: <https://c9x.me/compile/release/qbe-1.3.tar.xz>
- SHA256: `d587905d620dc5e1d2bfa7c2cc642b9b837aa89a3188c6e37b53d756cf66e320`
- Commit: `c0818978acec60ebb6167fade60fb7012cbf20ca`
- Release metadata: <https://c9x.me/compile/releases.html>
- IL semantics: <https://c9x.me/compile/doc/il.html>

Root acquires/builds the backend once and retains those costs. No global
installation is required. For a verified producer-emitted `program.ssa`:

```sh
path/to/qbe -t amd64_sysv -o program.s program.ssa
as -o program.o program.s
gcc runner.o program.o -o program
./program --expect EXPECTED --repeat REPEATS ARG0 ARG1
```

`runner.o` is acquired once from the unchanged
`selfhost/tools/performance/phase106/cranelift/runner.c` using system GCC.
The runner ABI remains `phase106_entry(const uint64_t *) -> uint32_t` plus
`phase106_arity`; every result is independently checked. Compilation, assembly,
linking, emission and runtime must be timed separately and added when measuring
complete turnaround. Comparing QBE-only time with C compile-plus-link is invalid.
This path uses no Clang in machine compilation/linking; it retains GNU tools and
libc. How the Bend producer was acquired is a separate provenance boundary.

## Semantics and deliberate scope

The first target is Linux amd64 SysV. `u32` maps to QBE `w`; `u64` and pointers
map to `l`. Constants retain all32bits, comparisons produce `w` zero/one, and
logical shift counts are explicitly masked by31/63. Pointer offsets zero-extend
unsigned byte counts. Entry word loads implement the common ABI on this
little-endian target. No portable big-endian wrapper is claimed.

Functions have a private initial block holding typed, zero-initialized mutable
slots. QBE's stack-slot registerization may promote these to SSA values; generated
assembly and actual timing determine whether it did. All control-flow blocks
end in jumps/returns; backedges never target the initial block. Both branches
returning suppress an unreachable merge block. A while loop remains stack-safe;
ordinary direct/indirect calls have no guaranteed tail-call contract.

Memory operations preserve the existing experimental ABI: zeroed allocation via
`calloc(1,max(bytes,1))`, abort on null, explicit `free`, and typed loads/stores.
A small QBE allocation helper implements that contract. Function pointers are
normal C ABI pointers; explicit environments remain ordinary arguments. The
verifier does not prove pointer bounds, alignment, lifetime or indirect signature
validity. Production Bend ownership/scheduler/GPU integration remains outside
this experiment. Unsupported source behavior must be refused before this emitter.

Required validation includes zero/high-bit inputs, wraparound and shift counts,
nested branches with early return, zero/nonzero allocation, recursive traversal,
indirect calls, and the existing ownership controls. Pair the same Bend-emitted
IR with C/Cranelift outputs and independent expected values. Do not describe a
successful tiny object as a self-hosted QBE compiler image.

## Focused differential controls

`controls.bend` adds four verified IR witnesses for full-width U64 arithmetic and
entry/return ABI, unsigned pointer offsets without dereferencing fabricated
pointers, zero-sized/zero-initialized allocation, and early-return control flow.
`edge-cases.json` supplies their boundary inputs alongside the existing Phase106
workloads. These are correctness controls, not representative speed workloads.

Run `controls.py` inside one Phase86 resource guard. It snapshots a checked-source
producer input, appends the controls, checks it through `stage0-library.mjs`, and
asks Bend to produce QBE, C and JSON from the same raw/fold graphs. It compares the
independent interpreter and mathematical answers against QBE/GCC executables,
optionally also the existing Cranelift adapter. The common runner checks every
result; wrong `--expect` values must fail even with an even repetition count.

```sh
python3 selfhost/tools/performance/phase86/guard.py \
  --out selfhost/build/phase107/qbe-controls-guard01 --seconds 180 -- \
  python3 selfhost/tools/performance/phase107/backends/controls.py \
  --source selfhost/build/phase107/qbe-emitter01/source.bend \
  --qbe selfhost/build/phase107/toolchain/qbe-1.3/qbe \
  --adapter selfhost/build/phase106/cargo-target/release/bend-native-ir-cranelift \
  --out selfhost/build/phase107/qbe-controls01
```

The source input must already include the QBE emitter and Phase106 IR, optimizer,
verifier, JSON/C consumers and workload constructors, but not `controls.bend`.
Use fresh output paths. The resulting report retains commands, expectations,
checked-source identity, model allocation/reclamation counts, verifier rejections
and failures. Its diagnostic wall times are not performance results.
