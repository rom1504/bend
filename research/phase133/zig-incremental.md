# Phase133 — What Zig's millisecond rebuilds actually establish

Research date: 2026-10-24. Bend checkout: `d636752`, `selfhost/bootstrap`.
Read-only investigation; no Zig compiler was installed, built or benchmarked.
This updates the [0.15.2 source study](../compilers_architecture_and_techniques/zig.md)
and applies it to the measured [Phase132 frontier](../../implementation/phase132/README.md).

**Zig supports the ambition of much faster local Bend edits. Its central lesson
is avoiding repeated semantic work and preserving stable identities, alongside a
bounded function pipeline. A smaller textual IR alone does not explain its speed.**

## Pins and evidence boundaries

The [official download index](https://ziglang.org/download/index.json) advertised
stable **0.17.0**, dated **2026-10-01**, and development
**0.18.0-dev.470+6817928c3**, dated **2026-10-22**, when inspected. Source analysis
below uses the stable release, not an unpinned development checkout.

The shared research lane downloaded the [official 0.17.0 source archive](https://ziglang.org/download/0.17.0/zig-0.17.0.tar.xz):

```text
size:   23049960 bytes
sha256: b6c7f1728f043700d6529bac980800792f824256a9d2f1839b3d62beed0b8abd
```

The archive checksum matches the official index. Only selected source files were
extracted for inspection. File/line references below refer to this exact archive;
the release-tag links provide navigation, while the archive digest pins content.
Codeberg web reads failed, so these claims come from actual archive contents.
The old GitHub mirror must not be mistaken for the current development branch.
The retained [source manifest](zig-source-manifest.json) hashes inspected files;
the companion [IR and lifetime audit](zig-ir.md) covers their physical layouts.

## Timing claims: distinguish the experiment being timed

These are author demonstrations on their hardware, not measurements on ours.

| Primary evidence | Reported time | Correct interpretation |
|---|---:|---|
| Matthew Lugg, July 2026: Fizzy pixel editor | About 5 s initial; 50–70 ms after changes | Actual application edits, warm persistent compiler, then-current development version; not merely no-op caching. |
| Same article: one traced update | About 37 ms | Around 31 ms is global reference resolution; semantic analysis 1.2 ms, codegen 240 µs, link 170 µs. |
| Same article: all compiler `src/` files | About 920 ms | Serial parsing and AstGen only, not semantic analysis or a compiler executable build. |
| Official May 30, 2026 devlog: compiler with LLVM libraries enabled | 36 s initial; 228–288 ms updates | Native Debug compiler build through `--watch -fincremental`; text does not identify each edit, so this is not a controlled body-edit benchmark. |

The first three observations come from the implementation author's
[incremental-compilation internals article](https://mlugg.co.uk/posts/incremental-compilation-internals/).
It required x86-64 Linux and a persistent `zig build --watch -fincremental`
process; at publication, complete semantic-state restoration between processes
was unfinished. It also warns that incremental behavior was not fully stable.
These observations establish feasibility, not universal latency guarantees.

The compiler demonstration and April LLVM update are in the
[official 2026 devlog](https://ziglang.org/devlog/2026/). `-Denable-llvm` means the
produced compiler includes LLVM capability/libraries; it does not establish that
LLVM generated that Debug executable. LLVM frontend incrementality now exists,
but the April report explicitly excludes a reduction of LLVM's object-emission
work. Full optimized builds therefore have a different cost floor. Neither
demonstration includes rebuilding LLVM itself or performing complete compiler
qualification. The May linker entry's debug-information limitation is dated
evidence, not a claim about every 0.17 target.

## What the pinned implementation actually reuses

### 1. Syntax lowering is a separate, inexpensive cacheable product

`Zcu.saveZirCache` writes an instruction-tag array, instruction payloads, string
bytes and extra words directly through vectored IO. `loadZirCacheBody` allocates
those arrays and reads their contents back. Debug-safety tagged-union layouts
require an explicit payload conversion; it is therefore too strong to say
serialization is always literally zero work.

Evidence: [Zcu.zig](https://codeberg.org/ziglang/zig/src/tag/0.17.0/src/Zcu.zig),
lines 3040–3141, and
[Zcu/PerThread.zig](https://codeberg.org/ziglang/zig/src/tag/0.17.0/src/Zcu/PerThread.zig),
cache load/save callsites around 657 and 771. The cached syntax representation
does not itself prove that semantic analysis or emitted machine code remains valid.

### 2. Dependencies are on facts, not just source files or entire definitions

The release has **seven** analysis-unit kinds: compile-time declaration, named
value, named type, type layout, struct defaults, runtime function body, and
memoized compiler state. Its dependency target additionally distinguishes source
hashes, function inferred error sets, source/embedded files, namespaces and
individual namespace-name membership.

Evidence: [InternPool.zig](https://codeberg.org/ziglang/zig/src/tag/0.17.0/src/InternPool.zig),
`AnalUnit` at 422 and `Dependee` at 746. This is more precise than a graph whose
edge means only “function A mentions function B.”

`Zcu` separately tracks outdated and potentially outdated units. A changed input
can force one unit to be reconsidered without forcing every transitive consumer
to re-run. A concrete source example compares the newly resolved type identity
with the old type; it marks type dependents outdated only if that result changed.
Evidence: `Zcu.zig:3212–3423` and `Zcu/PerThread.zig:1880–1906`.

**Bend transfer:** a caller may consume a callee signature, reducible body,
constructor layout, ownership summary or private-worker admission result. These
are different dependencies. A signature-only key is unsound for dependent
checking or specialization; a whole-book key destroys useful reuse. Failed
lookup/admission facts also need keys: adding a definition can change a previously
negative answer. The existing Phase132 plan already recognizes these obligations;
Zig provides a concrete implementation of result-sensitive propagation.

### 3. Stable semantic identity survives source instruction renumbering

`updateZirRefs` maps old ZIR instructions to new ones for changed files and repairs
tracked references. If no files changed it returns early. Changing a file's module
invalidates the entire file's mapping deliberately. Evidence:
`Zcu/PerThread.zig:796–860`. This machinery explains why indexed storage and stable
identity are related but not identical: an array offset alone is not an identity
that survives edits.

**Bend transfer:** Phase132's local edit changed 476 emitted functions, including
numeric-literal and static-data relocation churn. Cache named owner-local units
before final numbering/static binding. A stable identity must include ownership
and ABI context; simply hashing the final QBE text reproduces the churn.

### 4. Keep useful semantic state, discard finished function IR

`CodegenTaskPool` explicitly limits AIR in flight because MIR may be much larger.
Its comment reports observed MIR/AIR ratios around 20×, with a 50× worst case,
and chooses a 10 MiB AIR budget to target approximately 500 MiB of AIR/MIR. This
is an implementation heuristic, not a measured whole-compiler memory guarantee.
The accounting expression is also not a complete heap-size measurement.

The owned-AIR worker frees AIR after code generation. Thus caching semantic
results does not require retaining all lowered instruction graphs simultaneously.
Evidence: `Zcu.zig:5358–5516`, especially `CodegenTaskPool.start` and
`workerCodegenOwnedAir`.

**Bend transfer:** the approximately 1.90 GB late RSS increase in Phase132 is a
strong reason to test bounded verified-function production and emission. It is
not proof that the entire several-minute request is serialization. Measure peak
live state, allocation/reclamation work and total wall time independently.

### 5. A warm process is a real architectural component

`main.serve` preserves a `Compilation` object while handling repeated update
messages, calling `comp.update` and making its output writable/executable around
each update (`main.zig:4391–4480`). Incremental cache mode namespaces artifacts by
stable configuration and source path, deliberately excluding source contents;
whole-cache mode includes all inputs and rebuilds on a miss
(`Compilation.zig:1360–1391`, `2278–2327`).

Do not infer completed cross-process reuse from the presence of `saveState`.
The 0.17 implementation writes a `.zcs` file but still lists namespaces,
declarations and compilation errors as TODOs (`Compilation.zig:3586–3835`). No
matching complete restore path was established in this audit. The demonstrated
fast path remains the long-lived compilation object.

Current limitations are visible in source too: `Compilation.zig:2886–2895` says
updating C linker inputs incrementally needs proper full-rebuild handling and
currently skips C-object updates once prelink has occurred (issue 32081).
Incrementality is not permission to hold external inputs or compiler options
constant without checking them. A Bend research producer or runtime change must
start a new identity epoch unless compatibility is independently established.

## What is new relative to our earlier Zig research

The repository already documented compact ZIR/AIR, InternPool, dependency
propagation and separate function lifetimes. Another general “use packed IR”
proposal would repeat that work. The useful update is the concrete operational
combination: fact-specific invalidation, stable remapping, persistent request
state, bounded codegen/link queues, and updated native/LLVM limitations.

Go's reusable package artifacts and Zig's fine-grained live semantic graph solve
different granularity problems. Bend can first reuse checked lowering units and
QBE objects without replacing QBE or adopting Zig's linker. An incremental native
linker is a later opportunity if ordinary cached-object linking becomes the
measured dominant cost. The Phase132 frontend currently dwarfs that cost.

## The strongest next experiments for Bend

These are proposals, not implemented performance gains. Preserve the qualified
compiler, independent final verifier and source/runtime identity.

| Experiment | Why it can change the scale of the problem | Decisive rejection condition |
|---|---|---|
| Preserve one checked/lowered named-unit result across a real local edit | Skips actual semantic/preparation/lowering work, instead of merely reusing machine artifacts after 369 s of emission | Dependency closure remains broad, or verification/rebinding consumes the saved work. |
| Emit and release one independently verified function group at a time | Removes simultaneous retention and repeated traversal of whole-image text/IR; useful even for cold builds | RSS falls but complete time does not, or whole-program verifier obligations force equivalent retained data. |
| Split interface/body/layout/admission fingerprints for that same unit | Lets unchanged consumed facts stop invalidation; directly tests whether fine granularity pays | Fingerprint construction costs more than redoing the selected work, or hidden dependencies invalidate the model. |
| Keep the compiler process alive for successive requests | Reuses preparation, indexes and facts without serializing every object graph | Startup/preparation is a small fraction, or mutable state makes invalidation/qualification disproportionately complex. |

Start with the same source-edit controls used in Phase132 and add changes to a
consumed inline/reducible body, layout, policy and failed lookup. Compare cold,
warm no-op, private body edit, interface change and producer change separately.
Compare actual whole outputs to a fresh independently checked build. A compact
unit that recompiles incorrectly is not a speedup.

For the 350 s→10 s ambition, at least **97.14%** of the original work must disappear
or become cheaper, before accounting for new overhead. Fine-grained reuse can
make that conceivable for a narrow warm edit; no observation here predicts it
for a cold self-build or an optimization change affecting most functions.
Likewise, a sub-1 MB dirty-unit payload is compatible with a large unchanged
whole compiler; it is not evidence that the complete equivalent IR fits in 1 MB.

The first investment should therefore be a stable, independently verified reuse
boundary and bounded emission, with explicit counts of dirty units and repeated
work. Changing backend or pursuing text compression first would leave the main
measured barrier intact.
