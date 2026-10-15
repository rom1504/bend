# Own-backend native compiler: build and ABI controls

The integrated native compiler now builds from unpatched Bend-emitted C and
re-emits that same complete C. Native07 builds at Clang O2 in 308.201430 s with
4,172,177,408 bytes peak process-tree RSS. Its full self request takes 164.322 s
and produces all 38,614,882 bytes of `dae071f0…`, identical to its build input and
the independent genuine JS-B2 emission. This is C-output self-reproduction for
the frozen compiler source/runtime/effects tuple, not ELF-binary reproduction or
a proof of full-language conformance. Public release qualification is separate.

The earlier failures and diagnostic image below remain part of the evidence.

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
Our runtime initially lacked that guard. The final canonical
runtime/template/driver repair now includes it, together with the dispatch-table
accessor described below.

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
IR memory. The larger build budget was tested and rejected below; existing LLVM
analysis-cache defaults were checked rather than presented as a new optimization.
Normal compiler requests remain limited to 2 GiB.

Native self-emission is a separate guarded request. Eight request
controls alone do not establish self-reproduction or full-language conformance.
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

The single10GiB O1 attempt also stops at its RSS guard after120.231s, peaking
at10,743,463,936bytes while retaining17,336,156,160bytes host memory available.
There is no further limit increase. Its final pass trace cannot flush after
the guard kills it. A separate 6 GiB diagnostic drained LLVM pass messages,
keeps64 recent events and bounded counts, and flushes pass/RSS snapshots every
0.5 s. Full verbose logs were intentionally not retained. The resulting
[memory localization](clang-memory-localization.md) identified late
callgraph/CGSCC growth and motivated the successful accessor intervention.

# Optimized native execution and complete self-emission

The two-edit dispatch-table diagnostic `compiler-own-native06` builds with
Clang22.1.4 atO1 in267.681s, peaking at4,170,858,496bytes. Its exact patched
build C is `a4cd3990…`; the independent Bend-emitted parent C is `81ca2837…`.
The distinction remains explicit in its build receipt. See
[memory localization](clang-memory-localization.md) for the mechanism and
small controls.

All eight live/cache Small, Map, Unicode and file-I/O requests pass exact-C
comparison. Live request clocks are71/1759/69/377ms; cached clocks are
74/1839/73/388ms. These are single diagnostic observations, not a new statistical
comparison with upstream.

`own-native06-self01/report.json` then completes full self-emission in163.217s
request time (164.056s guarded wall time), peaking at1,648,939,008bytes. All
38,614,586 output bytes match `81ca2837…`, independently emitted by checked
JS-hosted B1 and genuinely self-emitted JS B2. This establishes successful
native execution of the complete own-backend compiler. That particular run did
not establish the final runtime's native fixed point: the diagnostic executable
was built from the C-patched image, while the request deliberately used the
original runtime.

## Integrated runtime and native07

The applied runtime change adds the upstream O0 attribute guard and selects a
pure noinline table accessor on the host when `FID_ENTER >= 4096`. The condition
appears after the generated numeric FID definition. Optimized smaller images
retain direct dispatch; the device branch is unchanged. The coordinated
three-file change adds seven runtime lines, updates the checked Bend-generated
five-part template and updates its driver digest. It adds no new mutable state,
cache or compiler representation.

Native06 and genuine JS B2 then emitted the frozen D04 compiler source using
these same new runtime assets. Their complete C outputs match byte-for-byte:
SHA `dae071f0fae7aec4ae8036ccebe4954690a249e32f59a87ac485b2fa428016bf`,
38,614,882 bytes. Native07 is the actual O2 build of that unpatched output,
binary SHA `d7c7a47917884b14fd3ef37471d9f2a8660d7c4ab9bcc93a249c7cb6d0e37d3e`.
Its build took 308.201430 s and peaked at 4,172,177,408 bytes under the 6 GiB
guard. It is not a fresh upstream-built compiler and its receipt retains the
diagnostic ancestor honestly.

Native07 passes eight complete-C live/cache comparisons on Small, Map, Unicode
and file IO; two malformed-source/type-error rejections; and four actual O2
generated-program builds and executions, including file IO. Its full self
request then returns the same `dae071f0…` C: 164.322 s request time,
165.171738 s guarded wall time and 1,649,618,944 bytes peak RSS under 2 GiB. The
request uses the authenticated prepared Base carrier; startup preparation and
Clang image construction are outside the request clock. These are single
observations, not an upstream speed ratio or a matched O1-versus-O2 experiment.

All 45 retained benchmark programs have `FID_ENTER` between 22 and 606. Applying
the two runtime edits to their retained C gives exactly identical whole O2
preprocessor output in all 45 cases, with the same stdin filename, environment,
compiler and 163 prebound headers. This is a derivative-C preservation check,
not 45 fresh new-runtime emissions or execution timings. Four separate tiny
controls pass compilation and execution at threshold 4095/4096 and O0/O2,
checking the dispatch/attribute branch and the live word-bank checksum. They
use two real functions and a synthetic threshold value, not a 4096-function
program. GPU execution and the accessor's performance on arbitrary large
programs remain untested; 4096 is a policy threshold, not a measured crossover.

Final raw evidence under `selfhost/build/phase90`:

- `new-runtime-c-equality01.json` and `compiler-own-native07.native-build.json`;
- `own-native07-build-guard/process.json`;
- `native07-qualification01/report.json` and `native07-self01/report.json`;
- `runtime-cpp45/report.json` and `runtime-boundary01-results/report.json`.

These native gates establish the frozen image and source/runtime C-output fixed
point. They do not themselves promote the image into the public launcher or
complete the separate refreshed JS release workflow.
