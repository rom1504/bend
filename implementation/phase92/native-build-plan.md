# Phase92 matched native builds: offline acquisition audit

Build a fresh upstream-C native B1 from the exact frozen native07 Bend source,
then compare its ordinary requests with existing own-C native07. The minimum
new acquisition is upstream load, full checking and C emission; another JS
image is unnecessary. Preserve both runtime/provider implementations as emitted
by their respective backends. They are part of the comparison, not interchangeable
libraries.

This is an offline source/receipt audit. No compiler, C build, native program or
benchmark was executed by this agent. The prospective steps below do not confer
passing acquisition, cache admission or new native-chain qualification.

## Exact subject and existing comparison image

| Artifact | Exact identity |
| --- | --- |
| Frozen native source | `selfhost/tools/performance/phase90/observation/noindent01/compiler-noindent.bend`, 1,759,353 bytes, `d04ad79cf08c019b509cfbbd4be2b16ae9e4af189767715d12e0645b9eee8097` |
| Source assembly proof | `compiler-noindent.assembly.json` beside that source; 14 reversible replacements from the preserved Phase89 source |
| Existing own-C native07 | `selfhost/build/phase90/compiler-own-native07`, 16,913,416 bytes, `d7c7a47917884b14fd3ef37471d9f2a8660d7c4ab9bcc93a249c7cb6d0e37d3e` |
| Its exact build C | `selfhost/build/phase90/native06-new-runtime01/output.1.c`, 38,614,882 bytes, `dae071f0fae7aec4ae8036ccebe4954690a249e32f59a87ac485b2fa428016bf` |
| Output runtime | `runtime-accessor-transport02/runtime.c`, `9e1c59078878be94052cb4d2d63a713e19e29b41ed3f94b034f2175a50efd0a9` |
| Pinned upstream | `selfhost/.bootstrap/upstream-phase66`, revision `059266225b77c8ca256ac6b25ee5c21449bab151` |
| Canonical Base | `bend2/base.bend` in that upstream checkout, 75,064 bytes, `99ac43f2b2bb3e3f39acdcedcecbbd3cb44749ce13969c827d6973fa66f7facf` |

The frozen source includes the native profile's earlier owned-composition,
observer, cache-entry and consuming-equality changes, plus Phase90's stack/table/
fork/formatting changes. Current canonical JS source `4ffae2a3…` is a different
subject. Reassembling current production, using Phase89 source `4584cf08…`, or
using the earlier fork source `d8a94ce9…` would lose the matched-source comparison.
All 19 inputs of the final D04 assembly proof currently exist and match their
declared hashes; no restoration is needed for this derivation.

Native07's actual producer history remains explicit: diagnostic native06 emitted
the unpatched final C, a genuine JS B2 independently emitted identical C, Clang
built native07, and native07 reproduced that C. See
[build receipt](../../selfhost/build/phase90/compiler-own-native07.native-build.json),
[self receipt](../../selfhost/build/phase90/native07-self01/report.json) and
[public admission](../../selfhost/build/native/releases/phase90-native07/admission.json).
A fresh upstream B1 must not be inserted retroactively into those receipts.

## Minimum upstream-C acquisition

The existing [acquisition method](../../selfhost/tools/performance/phase90/acquire-native.mjs)
already admits the D04 assembly schema. Make a fresh Phase92 derivative with
only the output-boundary change and removal of the `emit-js` output iteration.
Retain these checks:

1. Parent is the exact completed
   `selfhost/build/phase89/native-self01/report.json`, SHA
   `eb6d743504b7636fd6dc7fdf176586ca4380d46ea25965f5c1a2b35a5c1a2743`.
   Its source is the exact `4584cf08…` ancestor.
2. Verify all D04 assembly inputs. Replay every replacement forward and backward;
   require exact subject bytes and recovery of the ancestor. Keep exactly one
   `import Base` and no other imports. The assembly's historical
   `acquisitionComplete:false` records what that offline producer did; do not
   rewrite it after a later actual check.
3. Verify the pinned Node binary and all 67 upstream source/provider identities
   from `selfhost/build/phase86/upstream.json`. Clear inherited `BEND_*` and
   `NODE_OPTIONS` overrides as the existing method does.
4. Actually call upstream `book_load` and `book_valid`, require zero holes and
   exactly the subject plus pinned Base in loaded source dependencies. Check
   foreign declarations from the loaded book against the upstream manifest.
5. Call `C.compile_book(book)` once, retain the complete C, then rehash all
   acquisition inputs. Require both a completed successful outer guard and the
   acquisition's own complete/input-unchanged receipt.

Copying the frozen subject into the fresh acquisition directory is already the
method's transport behavior; verify its bytes equal D04. For matched **requests**
and self emission, pass the original canonical D04 path to both executables,
since source origins and prepared-Base admission retain paths.

Use the existing Node flags `--max-old-space-size=1024 --stack-size=4096`, CPU3,
2 GiB RSS and 4 GiB available-memory floor. A 150-second acquisition deadline is
reasonable. The nearby actual fork acquisition took 88.178 seconds, including
74.680 seconds emitting C and 6.900 seconds emitting unnecessary JS; peak RSS was
1,238,601,728 bytes. The preceding source took 87.366 seconds/1,234,472,960 bytes.
These support the existing limits, not a 3 GiB heap increase. Roughly 80 seconds
for C-only acquisition is an estimate, not a measured D04 result.

## Exact Clang settings and build receipt

Native07's actual [build command](../../selfhost/build/phase90/own-native07-build-guard/process.json)
is the comparison baseline. Replace only input C and output image paths:

```text
/home/ai/.elan/toolchains/leanprover--lean4---v4.32.0/bin/clang
  -isystem /home/ai/.elan/toolchains/leanprover--lean4---v4.32.0/include/clang
  -O2 -ftime-report NEW_UPSTREAM_C -o NEW_NATIVE_B1 -lm -pthread
```

Use the same guard wrapper with CPU2,3, core dumps disabled, a 64 MiB per-file
limit, 6 GiB process-tree RSS ceiling and 16 GiB available-memory floor. A
300-second build deadline has historical support: related upstream-C O2 builds
took 175.999 and 181.231 seconds, peaking around 4.00 GiB. Native07 itself took
308.201 seconds and 4,172,177,408 bytes on its much larger own-C file; that is a
different build observation. Do not switch to the obsolete O1/no-inline/10 GiB
diagnostic method or add the old O0 calling-convention overrides. `-std=c11` was
used in earlier phases but is absent from native07's actual command.

At acquisition/build start, keep enough free space for approximately 18 MiB of
upstream C, 10–17 MiB of image, Clang temporaries and retained logs, while
preserving the 160 MiB reserve. These output sizes are estimates from adjacent
images. No JS output or copied source tree is needed. Avoid keeping a second
full copy of either generated compiler C merely for a benchmark plan.

The proposed `selfhost/build/phase92/upstream-b1/build.json` should bind
`complete`, `source`, `c`, `image`, `clang`, exact `command`, `guard` and `checked`
(the completed acquisition reference). Verify the actual guard command contains
the exact emitted C and resulting image paths, exits zero with no resource stop,
and has matching source/Clang input identities. Record optimization flags from
the command; never infer them from a method's filename or a requested plan.
Use this as a distinct private upstream-built B1 receipt. Do not weaken or reuse
native07's public consumer admission for a different binary.

## Two provider layers and argument conventions

**Shared request assets:** both compared compilers must receive the native07
admission's exact Base path, runtime/template/five parts, nine effect files,
prepared carrier/stamp and the same input source. These are the compiler's
inputs when emitting user-program or compiler C. Their output should be exactly
the same full C; upstream-emitted compiler C itself is not that oracle.

**Executing image providers:** upstream `compile_book` lowers the entry's foreign
calls using upstream Base provider files and runtime ABI. Own-C native07 uses
our retained providers/runtime ABI. They implement the respective host image.
Their raw C is not interchangeable: upstream `args.c` uses `CID(Nil)` and a
two-argument `io_eff`, while retained `args.c` uses `CID_NIL` and three-argument
`io_eff`. Do not overwrite upstream providers with the nine request files or
force their raw hashes to match. The existing acquisition binds the real
upstream provider declarations; the shared request manifest separately binds
all nine output-provider files. This comparison includes backend/runtime code
generation, not only a selected optimization pass.

The Bend entry itself is identical, but its launch arguments require a small
explicit transport distinction:

```text
upstream B1: BINARY --threads 1 --gpu off -- INPUT BASE RUNTIME EFFECTS OUT CALLS [CACHE STAMP]
own-C B2:   BINARY --threads 1 --gpu off -- phase90-native INPUT BASE RUNTIME EFFECTS OUT CALLS [CACHE STAMP]
```

Upstream `comp.ts:5938–5939` initializes `io_argv=argv; io_argc=1`, retaining the
executable name. Retained `runtime.c:3083` starts at `argv+1` with zero arguments.
The frozen `p86_cli` consumes the first string as the program element. Therefore
only native07 needs the explicit sentinel. Replacing the native07 launcher's
binary path while retaining its sentinel is incorrect for upstream B1. The
Phase89 native wrapper provides the existing upstream convention; the Phase90
launcher provides the own-runtime convention.

## Private admission and chain gates

Start with Small and Map, then the existing eight live/cache Small/Map/Unicode/
file-I/O requests. Require exact C against independently qualified oracles,
normal exit and unchanged assets. Preserve syntax/type error controls as exact
refusals with no output, not successful compiler invocations. The private cache
carrier is typed Bend data, not a C heap dump, so the transport may be shared;
nevertheless the new binary still requires its own live/cache result gates.
Do not claim admission solely from its source matching another image.

Run paired cold and repeated requests with the same request assets, source
order, CPU3, one runtime thread, GPU off, call count and boundary. Base decode,
runtime preparation, request-only time and process wall must stay separate.
Both roles can use the same prepared carrier after qualification. Internal
`request_ms` is millisecond-quantized; tiny cases need enough independent samples
and process clocks to avoid overstating small differences.

For the full native-chain qualification, fresh B1 should emit D04 to C2 with
the same assets. Require every byte of C2 to equal native07's retained build C,
then require native07's fresh D04 emission to equal C2. Reusing the exact already
built native07 executable avoids an unnecessary five-minute Clang rebuild and
can establish that it is a build of byte-identical B1 output. Report that reuse
honestly; do not claim the historical native07 binary was chronologically built
by this new B1. If a new physical B1→Clang→B2 build is required, perform it as a
separate explicit step. Neither C equality nor that chain proves ELF equality,
full language semantics or parallel-runtime correctness.

## Read-only toolchain dependency record

The pinned Clang driver is a 119,320-byte ELF launcher, not a monolithic compiler.
`readelf -d` shows `$ORIGIN/../lib` RUNPATH and dependencies including the Clang
and LLVM shared libraries. The following current files were hashed offline:

| File under Lean v4.32.0 toolchain | Bytes | SHA256 |
| --- | ---: | --- |
| `bin/clang` | 119320 | `9fcd5fc4baeea9c449bcc9ca4b9db7714465107669498b0056a853f22f5f4def` |
| `lib/libclang-cpp.so.22.1` | 65075176 | `e11640dbbd29d2abebcdb62f8e90e8a965d7276df914e3cdcfd5263f427208eb` |
| `lib/libLLVM.so.22.1` | 77258216 | `5145af96bc961289f6dff7efc0dc7f75cbc4b91634aa3b5d517749dce5f3f300` |
| `lib/libc++.so.1` → `.so.1.0` | 1337744 | `0ec88ab403524f6c3bc3d9029772b97d9af08837267a2973bf6b24fa79119704` |
| `lib/libc++abi.so.1` → `.so.1.0` | 408152 | `3cb42a1a34f48dd20da4aa7559e634ca2eaeab6b019869fd060f90128ae3cb8b` |
| `lib/libunwind.so.1` → `.so.1.0` | 69928 | `c54929622b0991b21088050bf3f23d6756d3d2e082acd293b0e788ddc901da72` |

The dynamic dependency list also names system `libpthread`, `libm`, `libgcc_s`
and `libc`; this table is not a complete linker/sysroot closure. Existing native07
build inputs pin the driver and C only, so do not retroactively claim historical
shared-library hashes were recorded. Current `CC`, `CFLAGS`, `CPPFLAGS`,
`LDFLAGS`, `CPATH`, `C_INCLUDE_PATH`, `CPLUS_INCLUDE_PATH`, `LIBRARY_PATH`,
`LD_LIBRARY_PATH` and `SDKROOT` are all unset in this audit. Record relevant
environment values when launching the actual build.

The explicit resource-header directory is `include/clang` in the same toolchain.
Phase90's `runtime-cpp45/report.json` retains the 163-header host O2 inventory;
its optimization-only additions are explained in
`selfhost/tools/performance/phase90/regalloc/runtime-cpp45-optimization-headers.json`.
That is useful existing evidence, not proof of the fresh upstream C's eventual
complete include closure. No target preprocessor was run for this audit.
