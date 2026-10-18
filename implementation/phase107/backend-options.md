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

## Next extension: optimize the complete loop

Phase106's measured Cranelift `speed` object generation was2.60–3.22ms for
seven workloads and13.64ms for `many`; linking was21.14–22.37ms. Phase107's
`graphs-arithmetic04/report.json` recorded441.36ms inside the capture frontend,
with1.003s for the full capture process. These are different experiments, useful
for bounding priorities, not a combined measured benchmark. Under a hypothetical
441ms frontend plus3ms object generation plus21ms linking, eliminating linking
entirely improves throughput by only1.047× before execution costs. With a500ms
validation program the gain is smaller still.

The441ms also has an important qualification: the original capture wrapper
injected `api` into `inspect`, setting `ownedApi=false` in `typed-driver.mjs`.
That intentionally disables trusted prepared-world/native-prefix/layout paths.
The existing `createPersistentInspector` preserves owned API identity and decoded
Base state but admits only parse/check. The capture number therefore measures a
diagnostic fallback, not the selected compiler's fastest available frontend.
Likewise, the old21.15MB declaration-context output has already been removed from
the current capture script. Neither cost should be attributed to QBE/Cranelift.

| Next change | Expected benefit, conditional estimate | Cost / main risk |
| --- | --- | --- |
| Trusted checked-graph capture, then keep one captured graph in memory across optimization policies | Avoids diagnostic fallback and repeated frontend/JSON costs. Reusing441ms frontend across eight backend candidates saves~386ms per candidate on average; actual benefit must be measured on the owned path | Narrow host integration; preserve source checking, compiler/Base identity and graph lifetime. Best immediate choice |
| Reuse common runner; batch several policy variants into one linked executable | Runner reuse is already implemented. Amortizing21ms linking across eight variants could save~18ms each, but little if execution dominates | Approximately30–60min prototype. Unique symbols and common dispatcher required; candidates still need isolated executions and independent expected values |
| Cranelift JIT over the same IR | Removes object file/link step. Roughly3–6× for a prechecked-IR loop with3ms compilation and1–5ms execution; about5% or less for the illustrative441ms-source loop | Approximately1–2h bounded prototype plus dependency acquisition. Preserve identical result checks, code-memory lifetime and failure isolation; no new code-quality benefit |
| Per-function object cache | At most the eliminated2.6–13.6ms object-generation cost for these existing examples; far more promising only once compiling a much larger graph | Approximately2–4h bounded prototype. Cache post-optimization function IR plus ABI/backend/target/runtime identities; inlining must invalidate changed caller bodies |

These effort/gain ranges are estimates, not measurements. The first extension
is implemented as `inspect(file,{mode:'native',captureCheckedGraph:true})` in the
host driver. It preserves the owned API, returns `checkedGraph` plus source files
after source/ownership/layout admission, and stops before native foreign-source,
runtime and C processing. `foreignValidated:false` states that boundary. Injected
APIs, other modes and nonboolean option values refuse. No installed compiler
image changed, and no JIT dependency/build or object cache has been started.

`capture-controls01/report.json` establishes exact graph equality with the old
wrapper, the three option-boundary rejections and rejection of ill-typed source.
The single guard finished in1.024seconds with134.2MiB peak RSS. The owned call ran
first and took513ms; the wrapper control ran second and took328ms. This ordered
admission test does **not** demonstrate a frontend speed gain. Import/JIT/cache
warmup and request ordering require separate controlled measurement. The useful
change already established is direct access to the trusted annotated graph,
without disabling the driver's optimization/admission paths or serializing the
whole context.

The adapter currently hard-codes `ObjectModule` in `Lower`, `signature`, `runtime`
and `build`. A JIT should generalize lowering over the existing `Module` trait,
then choose object serialization or `finalize_definitions`/entry-pointer lookup.
Use a fresh module for each candidate initially; retain runtime symbols and ISA
configuration, not arbitrary generated heap state. The pinned JIT crate is not
in our current dependency cache, and current online API documentation does not
establish exact0.121.2 source compatibility. Current upstream source confirms
direct callable emission, explicit symbol binding, relocation finalization and
that freeing module memory invalidates all its function pointers.
[JIT implementation](https://github.com/bytecodealliance/wasmtime/blob/main/cranelift/jit/src/backend.rs).

QBE1.3's local `main.c` compiles each parsed function independently and frees its
temporary compiler state afterwards. This naturally permits function-level
object caching without inventing an SSA cache, but our private `$nx_*` symbols
must become linkable across object boundaries. Cache complete post-inlining IR,
so changed inlined bodies change caller identities. GNU `ld -r` produces a
relocatable combined object; its description as an incremental link does not
mean it persistently patches a running executable. A resident runner still
needs a link/load boundary unless a JIT or custom relocation loader replaces it.
[GNU linker options](https://sourceware.org/binutils/docs/ld.html).
