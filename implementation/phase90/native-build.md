# Own-backend native compiler: build and ABI controls

Checked JS-hosted Bend B1 emitted the complete compiler C, SHA81ca2837…
(38,614,586bytes). Clang-O1 hit the6GiB process-tree RSS guard after94.884s.
An O0 attempt failed after93.388s with register-allocation errors, at3.16GB.
These are separate resource/toolchain failures, not semantic failures or host OOM.

A1.5KB control reduces the O0 error to a preserve-none indirect must-tail call.
Direct-tail and ordinary SysV controls compile and return the expected result.
Greedy allocation and omitting the frame pointer do not repair it. The first
control keeps every argument live, including rp, and also fails atO1. That
stronger control is not representative of the runtime's intentionally dead
padding slot. A corrected dead-padding control succeeds atO1 and fails atO0;
O1 with IR passes disabled also fails. Keep both controls and their scopes.

Pinned upstream comp.ts already gates preserve-none/preserve-most with
`defined(__OPTIMIZE__)`, explicitly documenting the O0 allocator limitation.
Our runtime lacks that guard. The canonical runtime/template/driver repair is
prepared separately; it has not yet been applied.

For the first actual image, explicit build flags
`-O0 -Dpreserve_none=cdecl -Dpreserve_most=cdecl` consistently select the ordinary
calling convention while preserving emitted C bytes and must-tail transfers.
The tiny control compiles and executes successfully. Full native03 then builds
in99.895s with3,165,581,312bytes peak process-tree RSS. Its46,403,800-byte image
is bound to the actual checked JS-B1 C producer and successful Clang receipt;
no upstream/native-B2 lineage is fabricated.

All eight native03 live/cache requests pass with complete C identical to the
new token-qualified B1 oracles. The four sources are Small, Map, Unicode and
file IO; the file-IO gate checks compilation, not execution of the emitted
program. Live request milliseconds are361/9653/354/2104, cached376/9732/367/2147.
These unoptimized-build clocks are diagnostic, not a speed qualification.

An optimized O1 build with heuristic inlining disabled also reaches6GiB after
90.781s. This rejects that flag as a sufficient solution to the resource cap.
The complete own C has39,643 segments. Textual inline-call counts suggest
possible duplication but do not establish actual inliner decisions or retained
IR memory. A bounded larger build budget and optional analysis-cache
invalidation are recorded in the design; normal compiler requests remain2GiB.

Current native self-emission is a separate guarded request. Eight request
controls do not establish self-reproduction or full-language conformance.
Raw evidence lives under selfhost/build/phase90; tiny controls and build methods
are under selfhost/tools/performance/phase90/regalloc and clang-build.py.

Native03 self-emission subsequently times out at240.007s with201,973,760bytes
peak RSS and no C. This unoptimized image's timeout is not a heap failure or a
semantic mismatch; it does not establish native self-hosting. The four-minute
request and independent successful eight-case qualification remain separate.

LLVM AST clearing is already enabled in the exact local driver, and LLVM22.1.4
already defaults eager analysis invalidation on. These are not new optimizations
to try. See the exact driver evidence and primary-source links in
[the memory-options note](../../selfhost/tools/performance/phase90/regalloc/memory-options.md).
