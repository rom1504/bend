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

Historical investigation below predates the native frontend and object-cache implementation.
Those followups are now qualified in [the campaign report](README.md) and
[supervision/latency results](supervision.md); retain the original estimates as history.


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

## ABI entry-wrapper cost

Read-only `objdump -dr` inspection of `measure02/source-{erased,arithmetic}-4096-`
objects identifies a concrete difference after source-level inlining. Counts
below include the entry wrapper and its called benchmark body, exclude alignment
padding, and include QBE's `endbr64` instructions.

| Input | C `-O2` instructions / bytes | QBE instructions / bytes | Cranelift instructions / bytes |
| --- | ---: | ---: | ---: |
| `erased` | 4 / 11 | 14 / 37 | 16 / 42 |
| `arithmetic` | 9 / 33 | 20 / 62 | 21 / 70 |

C folds argument-array loads and benchmark arithmetic into `phase106_entry`.
QBE and Cranelift retain an additional direct call/return between that wrapper
and the benchmark. QBE's wrapper creates a frame; Cranelift creates frames in both
functions. This is static evidence of removable work, not proof that it explains
the entire runtime ratio. The shared runner overhead remains in every measurement.

A bounded consumer change can emit the same entry `NxFunction` body directly
under the exported argument-array ABI: load parameters, initialize typed slots,
then call the existing statement emitter. Keep the original private function for
recursive calls and address-taking. This applies to every admitted entry body,
without a benchmark-name check or new source semantics. The established U64,
control-flow, allocation and indirect-call matrix must still pass before a paired
runtime comparison can establish a gain. The same construction is possible in
Cranelift by reusing its function-body lowering instead of generating a call-only
wrapper.

The optional QBE change is now implemented in additive `qbe-entry.bend`, exported
as `nxq_program_fused`; baseline `qbe.bend` remains byte-identical. A fuel-bounded
walk permits at most512 expression/statement nodes before retaining the baseline
wrapper. No function is deleted or given a different ordinary-call signature.

`qbe-fused-controls01/report.json` and the corresponding guard establish670
independent model cases and2,010 native results across18 programs, two policies
and three backends. All108 executables rejected wrong expectations; eight invalid
graphs were refused. The full batch took12.390seconds with164.9MiB peak RSS.
Fixtures structurally verify fusion at exactly512 nodes and fallback at516, and
execute recursion through the entry function's ordinary function pointer. These
are admission results; root's separately controlled timing determines any gain.

`units.bend` adds a single-verification batch API for separate QBE objects:
`nxq_units(program,fuse)` returns typed named text units plus an error field.
Runtime and all function symbols are exported across object boundaries; the
entry unit contains the argument-array ABI and arity word. This is source-ready
and passed the integrated `bridge-check08` source/API gate in1.697seconds. Actual
separate-object link/cache controls are still required.
No object cache or host-language compiler logic is implemented in this file.

## Native frontend acquisition feasibility

The selected Phase102 source (`projection-cost-source01/compiler.bend`,
SHA256`63ef222c4c6de73bb54c8e51d3b0a0552979b5791ea98e64d1098051a9cda237`)
contains the same KTerm/KDef ABI used by the new scalar lowerer and has no existing
`Nx`/`nx_`/`nxq_`/`nxk_` definitions. Its exact `p86_plan_*` chain starts near
line38415 and reaches checked annotation near38515. A narrow replacement result
can return annotated definitions at that point, retaining parsing, prefix checking,
ownership, entry and layout admission, and omitting `nr_prepare_annotated` and the
old generated-C backend from the reachable executable.

Use that selected source, replace its `main`, clone the admitted plan chain, and
append the already checked Nx lowerer/optimizer/QBE modules. Existing
`p86_read_file`, `p86_write_file` and `p88_cache_prepare` provide Base IO/cache
decoding. The source remains large, so frontend parsing/checking during acquisition
will still cost time even if unreachable machine-backend functions disappear from
generated code. No smaller image or speedup is established before emission.

Phase103's retained receipts provide a useful upper-scale comparison: native
emission123.035seconds/1.41GiB peak RSS, followed by Clang `-O2` compilation
369.876seconds/2.42GiB. That full image produced30.40MB C and a21.16MB executable.
One frontend-oriented acquisition is therefore plausible within roughly5–12min
plus source preparation/admission, conditional on no unexpected compiler issue.
Current disk headroom is~1,003MiB; reserve200–400MiB for source, generated C,
object/executable and tool temporaries, avoid duplicate image trees, and keep the
existing serial memory guard. This is a feasibility estimate, not a scheduled run.

Do not simply append Phase103's public CLI to the candidate: its three
`NativeHost.*` foreign methods were admitted by a separate exact-source B1 bridge.
That authority was deliberately not granted to ordinary installed-compiler input.
For a bounded native experiment, existing Base File IO avoids that new FFI
boundary. Authenticate the selected Base/cache bytes in the external research
harness before launching, or prepare Base live; the embedded p88 stamp and
structural decoder do not authenticate arbitrary replacement file contents.
Read the actual selected chain rather than restoring the older Phase88 source.

Successful acquisition would mean ordinary experimental requests execute native
Bend parsing/checking/lowering and QBE/binutils, with neither Bun nor Clang in
those requests. One-time acquisition would still use the existing compiler and
Clang, and the new target would remain the explicitly admitted scalar subset.
It would not yet mean a QBE-self-hosted compiler, full ownership/GPU integration,
or a replacement for the installed general compiler.

The bounded candidate is now assembled at
`selfhost/build/phase107/native-source01/compiler.bend` (1,886,779bytes,
SHA256`1620f50a20776769d5db2e430ad2c694f0d6953ca852188e1765cf67687437fe`).
Its manifest authenticates the selected source, exact13-function plan clone,
shared Nx modules and Base/cache inputs. `frontend/native/entry.bend` exposes
typed JSON, combined QBE or separate QBE-unit output, with explicit raw/fast and
cached/live-Base choices. The fast policy applies self-tail conversion, bounded
4096-node deep inlining and folding; fusion retains its independent512-node cap.

`frontend/native/run.py` authenticates a structured image receipt binding the
executable, prepared manifest and source pins, plus the manifest's Base/cache.
The image source must equal the source manifest's declared source. It records
process and authentication clocks separately and only writes fresh output paths.
The image receipt must come from an independent retained acquisition: identity
checking alone does not prove source-to-binary correspondence. Twelve initial
host-only controls in
`native-host-controls01/report.json` passed, including changed-hash/length
refusals and exact plan-clone checks. No native acquisition or execution result
is implied by those controls; the root campaign owns that separate guarded gate.

The structured launcher has13 further host-only controls in
`native-host-controls02/report.json`: valid cached/live identities, incomplete
or wrong-version envelopes, mismatched source/manifest binding, changed manifest,
image and acquisition hashes, changed cached Base carrier, and changed Base.
The live mode correctly ignores the carrier. Every image fixture is explicitly
non-executable text; no native workload ran in these authentication tests.

The installed native compiler successfully emitted source01 to C in
110.886seconds with772.34MiB peak process-tree RSS
(`native-emit01-guard/process.json`); that image was not linked. The second bounded
candidate is source02,1,889,751bytes,
SHA256`960c447acf6fe12343dbae7cb5148106ff083cd98f3c7a3c8bd4ad56fa86e9f2`.
It includes the external-Bool-argument refusal and changes the fast policy to
bounded entry-first inlining. The full assembled source preserves this exact
implementation even if shared source modules change afterwards.

`frontend/native/compile.py` now provides a complete native-input host shell:
authenticated native Bend emits the graph and QBE units; QBE/GNU assembler produce
objects; GCC compiles the shared runner and links the executable. The script does
not execute that program. Graph JSON, IL, assembly, objects and commands remain in
fresh request directories. Hashed filenames prevent valid long identifiers from
exceeding filename limits. Content keys bind post-transformation text, all
signatures, entry ABI, compiler source/image and backend identities. Runner objects
are separately cached. Corrupt object, assembly or metadata entries are rebuilt.

Thirteen host-only cache checks passed in `native-cache-controls01/report.json`,
covering exact hits, source/image/tool/ABI/text invalidation, long names and all
three corruption cases. Thirteen image-receipt checks passed again in
`native-host-controls03/report.json`. These use non-executable fixtures. Actual
native-source02 emission, acquisition, source differential controls and runtime
measurements remain separate root-owned gates.

Source02 subsequently acquired successfully: native emission111.818seconds,
followed by Clang260.208seconds/1.63GiB peak RSS
(`native-emit02-guard`, `native-link02-guard`). Its first units request exposed a
transport bug: `nx_quote` deliberately accepts only restricted identifiers and
does not escape QBE's literal newlines. Native processing succeeded in0.123seconds,
but host JSON parsing correctly refused the malformed output
(`native-cli01/report.json`). This was a serializer integration error, not evidence
of incorrect generated code. The failed receipt is retained.

The fix uses the existing selected compiler's `sk_quote`, which escapes arbitrary
JSON string contents. Before another expensive image acquisition, a tiny checked
source extracted the exact transport functions and their escaping dependencies.
The first extraction omitted `kp_digit`'s law-defined signature and was refused;
the corrected extractor retains matching laws and definitions. The source gate
then passed in2.085seconds, and43 transport controls passed in0.064seconds
(`native-transport-check02`, `native-transport-source02/controls.json`). They cover
every control byte, quotes/backslashes, QBE newlines, Unicode/surrogates and four
list shapes. This cheap gate is now retained for future transport changes.

`compile.py` now defaults to whole-object mode, also explicit as `--whole-object`;
`--units` retains the separate-object path. Whole mode requests QBE directly and
binds complete IL, selected entry/runtime ABI, compiler image/source and tools.
It omits graph JSON explicitly rather than silently adding another frontend call.
This works with image02: `native-cli02/report.json` completed in0.490seconds,
including0.168seconds native frontend, and root's execution returned4268337842
for arguments19,23. That is one functional smoke result, not a representative
speed claim. Whole-object caching also avoids per-function process launches on
cold requests; the relative benefit requires controlled measurement.

Source03 was assembled only after the focused gate. Its source is1,894,829bytes,
SHA256`01e31ba2abe107f2b24d8366f107ae6d48ef1471e2047ac1b795410cb94cdc14`.
It includes full JSON escaping and the separately admitted reachability pass after
tail conversion, entry-first inlining and folding. The manifest explicitly records
the ordered fast pipeline,4096-node inline budget and512-node fusion cap; host
harnesses need not infer policy from image generation numbers. Acquisition and
native differential validation for source03 remain root-owned gates.
