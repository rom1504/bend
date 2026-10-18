# Phase107 backend options and implementation boundary

Research and tool inspection started2026-10-18. This note separates official
backend capabilities, local availability, and work actually implemented. Root's
campaign report owns execution, timing, admission and installation claims.

Local inspection found GCC10.2.1 and GNU assembler/linker2.35.2. No `qbe`, `tcc`,
`zig`, `ld.lld` or `clang` executable was in PATH; the pinned Clang used in earlier
phases exists at its separately recorded absolute path. Available disk was
approximately1.1GiB, so another large Rust toolchain build is not the first step.

| Option | What it removes | What remains / uncertainty | Decision |
| --- | --- | --- | --- |
| Existing Cranelift object plus GCC/binutils link | Clang dependency for native object/link pipeline | Approximately20ms linking seen in Phase106 remains; producer acquisition is separate | Root can test immediately; no new compiler logic needed |
| QBE over the same typed IR | Clang machine optimization and C parsing; small independent optimizer/code generator | Text IL parsing, GNU assembler/linker, runtime quality and function-boundary losses require measurement | Implement a bounded third backend now |
| TinyCC over Bend-emitted C | Heavy optimizing C compiler; its own assembler/linker can also remove external link steps | Simpler expression-local optimization may make candidate execution slower; production Clang-only attributes/ABI are not supported by assumption | Retain as a cheap follow-up, especially for very short-lived tests |
| Direct Cranelift JIT | Object serialization and external assembler/linker | Executable memory, symbol binding, cold process startup, compile/run clocks, and persistent-state isolation need a separate protocol | Worth testing after AOT portability/quality; no claim that JIT is already implemented |

QBE explicitly targets compact implementation and useful optimizations, including
small-slot registerization and the C ABI. Its IL can represent the v1 scalar,
pointer, call and control operations; a normal assembler/linker consumes its
assembly. Its published performance aspiration is not a Bend measurement.
[Project](https://c9x.me/compile/), [IL reference](https://c9x.me/compile/doc/il.html).

TinyCC's manual describes integrated object/executable emission, direct execution
and `libtcc` dynamic compilation. Its code-generator description states an
expression-local optimization scope. The manual is version0.9.27 and contains
historical target details, so it is not evidence of current support for our
production native runtime or LLVM-specific conventions.
[Manual](https://bellard.org/tcc/tcc-doc.html).

Cranelift exposes `JITModule` for code/data emitted directly into callable memory.
This changes artifact/loading machinery, not the high-level optimizations missing
in Phase106. A persistent JIT can amortize process setup only when the experiment
explicitly measures its lifetime and invalidates changed functions correctly.
[Cranelift JIT API](https://docs.rs/cranelift-jit/latest/cranelift_jit/).

## Implemented source

[`qbe.bend`](../../selfhost/tools/performance/phase107/backends/qbe.bend) is a
Bend-written consumer of the existing verified `NxProgram` graph. It emits
QBE1.3 IL and the same entry/arity ABI as the C and Cranelift consumers. It does
not parse source independently or translate generated C strings. Mutable locals
become private typed stack slots; QBE can registerize them. This avoids adding a
second SSA constructor merely to test another backend.

The official1.3 archive is275KiB, SHA256
`d587905d620dc5e1d2bfa7c2cc642b9b837aa89a3188c6e37b53d756cf66e320`, commit
`c0818978acec60ebb6167fade60fb7012cbf20ca`.
[Official release metadata](https://c9x.me/compile/releases.html).
Root acquired and built the official pinned source, then granted one serial
CPU3 slot for the focused controls below. Backend performance and production
admission remain separate gates.

Static review found no emitter semantic discrepancy in the supported forms:
argument expression text is sequenced left-to-right; the common verifier excludes
nested effects and checks direct/indirect arities and argument types; unsigned
comparisons select `cultw`/`cultl`; boolean results use32bits and pointers64bits.
Typed locals are initialized to zero. Every branch/loop path closes its block;
an early-return arm gets no appended jump. Allocation zero-extends the byte count
and uses the same zero-size/null behavior as the other consumers. The only
foreign calls are ordinary SysV libc `calloc`, `free`, and `abort`; no raw syscall
convention is invented. Indirect target signature/lifetime remains a trusted
fixture obligation, exactly as in the existing experimental consumers.

The proposed [edge inputs](../../selfhost/tools/performance/phase107/backends/edge-cases.json)
cover unsigned boundaries, masked shifts, empty allocations/traversals, both
closure targets, and retained-owner observations. The implemented controls also
cover full-width U64 arguments and returns, pointer arithmetic across the unsigned
32-bit boundary without dereferencing fabricated pointers, zero-sized allocation,
and nested/loop early returns. Crossing the six-integer-argument SysV boundary is
still a useful additional control.

## Focused execution result

The complete batch finished in **11.133 seconds**, peak process-tree RSS
**160.1MiB**, under the Phase86 CPU3/resource guard. Checked Bend producer source
acquisition took1.216seconds within that batch. No emitter or fixture repair was
needed after the first checked-source gate.

- 15 programs under both `raw` and `fold` policies, all accepted by `nx_verify`.
- 646 cases checked by the independent interpreter and mathematical expectations.
- 1,938 matching executable results across QBE1.3, GCC10.2.1 `-O2`, and pinned
  Cranelift0.121.2 `speed`, using the same GCC-built common runner.
- Eight malformed-IR inputs refused by the Bend verifier and QBE emission wrapper.
- All90 executables rejected an intentionally wrong `--expect`, including an
  even repetition count that could conceal the mutant in a checksum-only test.

Evidence is `selfhost/build/phase107/qbe-controls01/report.json`, its checked
`source.bend`/`api.mjs` and emitted artifacts, and
`selfhost/build/phase107/qbe-controls-guard01/process.json`. The reproducible method
is [`controls.py`](../../selfhost/tools/performance/phase107/backends/controls.py),
with Bend-owned construction/emission and a Python evaluation oracle. This
establishes finite ABI/semantic agreement for these inputs. The diagnostic batch
is **not** a performance comparison, a production source-language completeness
claim, a GPU/parallelism test, or a whole-compiler correctness proof.

The clean architecture lesson is an explicit executable IR with multiple
consumers and a versioned runtime ABI. Backend choice should minimize
**emission + machine compilation + linking + required validation execution**.
Replacing Clang with a faster compiler that emits much slower validation programs
can lose that objective. Keep native source semantics, CPU/GPU boundaries,
ownership obligations and held-out tests independent of the chosen machine tool.
