# Zig 0.17: compact IR, bounded work in flight, and what Bend should copy

The useful comparison is **representation bytes, retained lifetime and avoided
work**, not our whole-program QBE text versus one Zig function's binary IR.
Zig does not demonstrate that a compiler this size needs only 1 MB of total IR.
Its own code comments describe substantial MIR expansion and explicitly budget
the number of functions moving through code generation.

This is a source audit, not a Zig performance or heap measurement. No Zig
compiler was built or installed, and no target was executed.

## Pinned sources and relation to the earlier study

The [official download index](https://ziglang.org/download/index.json), read on
2026-10-24, advertises stable **0.17.0**, dated 2026-10-01, and development
`0.18.0-dev.470+6817928c3`. We inspect the stable
[official source archive](https://ziglang.org/download/0.17.0/zig-0.17.0.tar.xz),
23,049,960 bytes, SHA-256
`b6c7f1728f043700d6529bac980800792f824256a9d2f1839b3d62beed0b8abd`.
The downloaded archive matches that digest. Exact inspected-file hashes are in
[zig-source-manifest.json](zig-source-manifest.json). The local extraction is
`/tmp/zig-phase133-0.17.0`; large source files are not copied into this repository.

This updates [our 0.15.2 study](../compilers_architecture_and_techniques/zig.md).
The basic compact representations persist, but backend files now live under
`src/codegen/` rather than `src/arch/`. Source links below point to the release;
the official archive and per-file hashes are the inspected evidence if a source
browser is unavailable. We do not assume uninspected development-head behavior.

## Actual representation, not textual dumps

| Representation | Actual storage and identity | Lifetime / qualification |
| --- | --- | --- |
| ZIR | Per-source-file immutable untyped instructions; separate tag/data columns, byte string pool and `u32` extra payloads; instruction references are `u32`. | Reusable across semantic analyses; sufficient for successful semantic/code generation without revisiting the AST, with diagnostic exceptions. |
| AIR | Per-function typed instructions, tag/data columns and `u32` extras. References distinguish instructions and interned typed values. | Produced by Sema, verified/legalized, then consumed by codegen; explicitly freed when the owning task completes. |
| x86-64 MIR | Separate opcode, operand-form and payload columns; additional words, bytes, locals, tables and frame-location arrays. | Target-specific machine work; final encoding/offset decisions follow. It is not another whole-program string. |
| InternPool | Canonical typed values/types use `u32` identities; common item is tag plus `u32` data, with variable payloads and byte strings stored separately. | Compilation-wide shared semantic state, not bounded by the current function's AIR size. |
| Liveness | Four common bits per AIR instruction, with sparse tables and additional branch/operand data. | Function-local analysis, freed after codegen; unused-result handling also respects operation semantics. |

Primary definitions: [Zir.zig](https://codeberg.org/ziglang/zig/src/tag/0.17.0/lib/std/zig/Zir.zig)
lines26–36,159–167,2198ff;
[Air.zig](https://codeberg.org/ziglang/zig/src/tag/0.17.0/src/Air.zig)
lines1–38,1061ff;
[x86-64 Mir.zig](https://codeberg.org/ziglang/zig/src/tag/0.17.0/src/codegen/x86_64/Mir.zig)
lines1–25,1323,1599ff;
[InternPool.zig](https://codeberg.org/ziglang/zig/src/tag/0.17.0/src/InternPool.zig)
lines970–1023,3932ff;
[Liveness.zig](https://codeberg.org/ziglang/zig/src/tag/0.17.0/src/Air/Liveness.zig)
lines24–70.

`MultiArrayList` stores each field in its own contiguous column. This avoids
per-record padding and allows tag-only scans. It does not eliminate capacity,
alignment, allocator bookkeeping or variable payloads.
[Implementation](https://codeberg.org/ziglang/zig/src/tag/0.17.0/lib/std/multi_array_list.zig),
lines9–29.

### What byte counts can actually be inferred

In a build with runtime safety disabled, both ZIR and AIR assert their `Data`
union is **8 bytes**, while their tag is `enum(u8)`. Their logical base columns
therefore contain **9 bytes per instruction**, plus extra words, string data,
capacity and allocation overhead. The assertions explicitly allow larger
unions in safety-enabled compiler builds. This is source-derived field
accounting, not measured RSS. ZIR serialization writes a one-byte tag and
eight-byte payload even when safety builds need an intermediate conversion
buffer. [ZIR payload](https://codeberg.org/ziglang/zig/src/tag/0.17.0/lib/std/zig/Zir.zig)
lines2390–2526;
[AIR payload](https://codeberg.org/ziglang/zig/src/tag/0.17.0/src/Air.zig)
lines1290–1371;
[ZIR serializer](https://codeberg.org/ziglang/zig/src/tag/0.17.0/src/Zcu.zig)
lines3029–3140.

x86-64 MIR has two one-byte fields (`Tag`, `Ops`) and an eight-byte no-safety
payload: **10 logical base bytes per instruction**, before its several side
arrays. InternPool's common item contributes one tag byte plus four data bytes,
but hashing, concurrency structures, strings and payloads are additional. Do not
describe either number as total bytes per semantic object or total compiler
memory. [MIR definitions](https://codeberg.org/ziglang/zig/src/tag/0.17.0/src/codegen/x86_64/Mir.zig)
lines19,560,1323,1726;
[pool item](https://codeberg.org/ziglang/zig/src/tag/0.17.0/src/InternPool.zig)
lines3932,4789.

## The more important change: bounded lifetimes

`analyzeFuncBody` constructs one AIR, retains an explicit ownership flag and
either transfers ownership to codegen or keeps it where a backend/linker needs
the same AIR. The queue may block semantic production while codegen/linking
catches up. The owned worker eventually deinitializes AIR; liveness has its own
deferred destruction. Optional verbose AIR output is a debug facility, not a
mandatory serialized transport between all stages.
[PerThread.zig](https://codeberg.org/ziglang/zig/src/tag/0.17.0/src/Zcu/PerThread.zig)
lines2297–2327,4533–4578;
[owned codegen task](https://codeberg.org/ziglang/zig/src/tag/0.17.0/src/Zcu.zig)
lines5508–5524.

The particularly informative source comment is in `CodegenTaskPool`: its authors
report MIR typically around **20× AIR**, with an observed worst case around
**50×**, and use an approximate 10 MiB AIR-in-flight budget to aim for roughly
500 MiB of AIR/MIR. These are the source authors' observations and design
heuristics, **not measurements performed here**.
[Pool policy](https://codeberg.org/ziglang/zig/src/tag/0.17.0/src/Zcu.zig)
lines5358–5366.

That budget is not an RSS ceiling. The charging formula at line5436 uses
`instruction_count * 5 + extra_word_count * 4`, which does not match the
nine-byte physical no-safety AIR base established above. Oversized individual
functions are admitted using a capped effective charge. Global semantic state,
capacity, allocator retention and varying MIR expansion are outside that
counter. We therefore treat it as a pipeline scheduling estimate, not a heap
measurement or a guaranteed 500 MiB cap.

InternPool also explicitly retains some old backing allocations so concurrent
readers remain valid; its arena lifetime follows `Compilation`, and the source
describes collection of that arena as not implemented. Compact data and
per-function AIR disposal do not imply that every compiler allocation is
short-lived. [Pool arena contract](https://codeberg.org/ziglang/zig/src/tag/0.17.0/src/InternPool.zig),
lines970–976.

## Caching and backend separation

ZIR's file cache contains a header, instruction tag/data arrays, string bytes
and extra words. `loadZirCacheBody` allocates the arrays; `saveZirCache` writes
them with vectored output. It is binary lowering reuse, not a cache of arbitrary
AIR or a proof that all semantic work is avoided.
[Cache implementation](https://codeberg.org/ziglang/zig/src/tag/0.17.0/src/Zcu.zig),
lines3040–3140. Semantic reuse needs separately tracked declaration value/type,
layout, source and namespace dependencies. Pool identity is compilation-local;
an equal integer from another pool is not a valid persistent semantic identity.
[Dependency categories](https://codeberg.org/ziglang/zig/src/tag/0.17.0/src/InternPool.zig),
lines17–87,3938–3945.

The native route consumes function AIR through backend-specific legalization,
liveness where requested, MIR generation and final object emission. The
dispatcher exposes different MIR types rather than a universal backend IR.
[codegen.zig](https://codeberg.org/ziglang/zig/src/tag/0.17.0/src/codegen.zig),
lines92–218.

The LLVM route lowers AIR into the LLVM object and does not return native MIR.
The source explicitly distinguishes updating a function's LLVM representation
from producing the compilation-unit object. Thus incremental frontend progress
does not imply LLVM object emission is incrementally cheap. This audit does not
claim all targets default to native codegen. Debug and native backend selection
are separate choices; the LLVM interface selects no codegen optimization for
Debug and aggressive codegen optimization otherwise.
[LLVM branch](https://codeberg.org/ziglang/zig/src/tag/0.17.0/src/Zcu/PerThread.zig)
lines4567–4578;
[LLVM emission](https://codeberg.org/ziglang/zig/src/tag/0.17.0/src/codegen/llvm.zig)
lines349ff,598–603.

## Apples-to-apples comparison with Bend

Our [Phase132 census](../../implementation/phase132/census01.json) measured
**107,059,385 bytes of whole-program QBE text**, 2,294,179 instruction lines and
63,239 functions. Its continuation category alone has 41,455 functions and
1,482,137 instruction lines. These are static emitted counts, not dynamic hot
work or live structured-IR bytes.

Comparing those 107 MB with one function's compact Zig AIR, or with Zig's
in-flight accounting budget, changes both representation and lifetime. It is
not a valid size comparison. As an illustrative fixed-inventory calculation,
2,294,179 records at nine base bytes already need **20,647,611 bytes**, before
payloads. This is not a proposal to translate QBE instructions one-for-one to
AIR, nor an information-theoretic lower bound: different lowering can remove
instructions entirely. It shows why a 1 MB whole-program target requires more
than switching textual names to numeric IDs.

Our [compact-symbol experiment](../phase132/compact-symbols.md) already halves
text while preserving machine code, but saves only 0.65 s across one descriptive
14 s downstream build pair. That does not disprove packed internal data:
the experiment retained the compiler's original String construction and added
a slow host rewrite. It only falsifies a 10× downstream machine-build gain from
shorter text alone.

For a valid comparison, report: binary/text IR bytes for the same semantic
inventory; retained semantic/persistent state; peak current-function and queued
work; output buffers; cumulative allocations; peak live bytes; RSS; and separate
frontend, rendering and machine-generation time. None can stand in for the
others.

## Strongest transferable opportunities, in order

1. **Bound the lifetime of verified output units.** Keep final global semantic
   validation and deterministic ID tables, then render/write/release one
   function or bounded batch. Preserve success/error atomicity with a temporary
   output if needed. First measure chunk sizes and retained bytes on an already
   useful compilation. Success is lower peak live output or fewer copied String
   nodes with byte-identical QBE, not merely smaller files. This can retain QBE.

2. **Pack repeated identities and immutable facts before backend expansion.**
   Replace repeated name/type/constructor trees with checked unit-local handles
   and compact summaries, with explicit book/runtime identity and independent
   admission. First target an actual hot lookup or ownership-summary boundary.
   This can remove string hashing, comparison and destruction across several
   stages. A new numeric-ID wrapper that still performs every tree search is
   not that optimization.

3. **Retain immutable high-level units; rebuild transient lowerings selectively.**
   Distinguish a source body hash from interface, layout, ownership and effect
   dependencies. Reuse only unchanged checked facts, then regenerate bounded
   function AIR-like work. Do not persist every transient compiler view just
   because it can be serialized. The Phase132 real-edit locality witness is the
   right discriminator before building this cache.

4. **Reduce the lowered inventory, not just its spelling.** The large continuation
   and transport inventory suggests keeping complete verified computations
   local longer, materializing scheduler/boxed boundaries only where required.
   Measure which instructions and runtime transitions disappear, then transfer
   to unrelated workloads. This is the path capable of reducing both compiler
   work and emitted-program work; a compact IR alone creates no such reduction.

5. **Only then consider native emission as a measured backend tradeoff.** Zig's
   native pipeline avoids compulsory textual interchange, assembler and LLVM
   optimization, but entails target selection/encoding, relocations, diagnostics
   and incremental linking. Our current downstream machine build is about14 s
   while full source compilation is hundreds of seconds. Eliminating the former
   alone cannot deliver the desired short research loop.

The strongest new lesson is the combination of **canonical persistent facts,
short-lived function lowerings and backpressure**. The goal should be to avoid
recreating and retaining irrelevant work, not to replace a 107 MB text artifact
with a differently named 107 MB in-memory graph.
