# Phase111: direct QBE compiler

Implementation in progress. [Design](../../design/phase111/direct-qbe-selfhost.md)
and [experiment](../../experiments/phase111/P111-001-direct-qbe-selfhost.md).

The new generic backend is written in Bend. It retains checked erasure,
ownership placement, closures and the portable continuation trampoline, and
emits QBE functions plus program data directly. The cached runtime object is
built separately from retained runtime C. Ordinary program builds use QBE,
assembler and linker; they do not emit C or invoke cproc.

## Established so far

- Exact 64-bit constants: 272 independent decimal cases, two exact textual
  data checks, and compiled machine readback of words, bytes and relocations.
- Generic lowerer and QBE emitter check together in about 3.5 seconds. The full
  assembled compiler plus direct entry checks in about 8.5 seconds, below 1GiB
  measured process-tree RSS on this machine. These are development API
  acquisition observations, not native compilation benchmarks.
- Cached runtime acquisition: about 1.3 seconds with GCC. Ten frozen runtime
  cases pass, covering scalar/F32/array/representation behavior and expected
  fail-stops. Sequential atomics are tested, not concurrent linearizability.
- The structured verifier passes 53 named cases: 11 positive and 42 negative.
  This checks types, identifiers, import signatures, control flow and bounded
  accesses; it is not an ownership or whole-compiler proof.
- Real checked-source closure/IO case emits QBE, links the runtime and prints
  the exact independent result `captured=42`. A separate small structured
  program returns and displays U32 `42` through the real runtime.
- The complete first five-case checked-source gate passes in 16.74 seconds:
  capturing closures, non-tail recursion, array aliasing/IO, U32 readback and
  Unicode String readback. This includes emission, QBE, assembly, linking and
  exact independent output checks for each case.

The remaining focused cases found two integration faults: missing foreign
providers were admitted until runtime, and native floating-point primitives
were incorrectly included in the foreign-provider dependency list. Source05
adds capability admission before lowering and applies the mature primitive-first
classification. All four previously failing cases then pass (`repaired01`,
13.12 seconds). Together with `fast01` and the passing cases in `focused01`,
this covers all 19 focused cases across revisions; it is not a fresh 19-case
run on the final source.

The complete native compiler image now builds directly from QBE and emits the
closure fixture byte-for-byte identically to the checked development API. The
installed compiler is unchanged. The complete native focused suite now passes:16positive programs and3expected
refusals in97.10seconds, below91MB observed peak tree RSS. Native self-compilation,
broad coverage, comparative speed and default promotion remain separate gates.

## Architecture

The [module list](../../selfhost/tools/performance/phase111/modules.txt) defines
the order of the source components. [Source preparation](../../selfhost/tools/performance/phase111/prepare.py)
authenticates the selected mature compiler and appends exact new modules after
renaming its old entry. Its small-check mode selects unchanged declarations;
the actual language checker validates every resulting reference. No host tool
implements semantic lowering.

The structured model distinguishes U32, opaque 64-bit Terms and pointers.
QBE constructs SSA from mutable temporaries, so a separate SSA builder and
per-local stack slots are unnecessary. Function and constructor IDs use the
existing indexed map. Metadata carries exact constants and relocations, with
separate incoming continuation widths and segment output widths.

The runtime has a versioned 192-byte program descriptor, a 2088-byte state and
fixed 256-word capacities. Actual program widths and metadata are validated.
Program tables, constructor names, show descriptors and effect requirements
come from QBE data. Existing allocator/reference-count/closure/array/effect
semantics remain in the cached runtime. The first route is single-CPU and
deliberately bypasses optional optimized worker and static-image planning.

Details: [lowering audit](segment-lowering-audit.md), [runtime audit](runtime-notes.md),
[emitter](emitter-notes.md), [show descriptors](show-audit.md),
[verifier](verify-audit.md), [coverage](coverage-notes.md).

## Findings and failures retained

The incoming continuation result count cannot be replaced by a segment's
output width. They coincide in some examples but drive different runtime
operations; the model now preserves both.

The retained closure dispatcher subtracted one from an unchecked arity. GCC
warned that malformed metadata could underflow into an oversized register copy.
Runtime-source03 guards closure FIDs, arities and copy widths while retaining
the legitimate built-in IO closure. Source01/02 and their status remain frozen.

The small source checks caught an extra delimiter, module ordering and an old
segment pattern after the model grew. Exact source slicing initially omitted
law signatures used by inferred definitions; the slicer now keeps those
unchanged signatures with their bodies. These are failed development checks,
not successful semantic observations.

Source review restored two mature scheduling conditions: bang references do
not receive the eta-factory shortcut, and matcher application eagerly sequences
extra arguments only under the original admission rule. General source/runtime
qualification is still needed beyond these correspondences.

Disk began below the guard floor. [Cleanup01](evidence/cleanup01.json) reclaims
about 70MiB of independently authenticated archived generated outputs.
[Cleanup02](evidence/cleanup02.json) losslessly compresses historical diagnostics
and generated output, verifying every decompressed byte and recording restore
paths; it reclaimed about 1.09GiB. Source, installed executables and historical
result statuses are preserved.

## Current evidence locations

All paths below are repository-relative local artifacts pending final sealing.
Frozen inputs and commands are in each report/guard receipt.

| Gate | Evidence |
| --- | --- |
| Exact data and native readback | `selfhost/build/phase111/data-controls01/`, `data-readback01-guard/` |
| Combined lowerer/emitter checking | `selfhost/build/phase111/backend-api01/` |
| Complete direct-entry source checking | `selfhost/build/phase111/full-source05/`, `full-api05/` |
| Cached runtime and guarded revision | `selfhost/build/phase111/runtime-source01/`, `runtime-source03/` |
| Ten runtime boundaries | `selfhost/build/phase111/runtime-boundaries01/` |
| 53 structural controls | `selfhost/build/phase111/verify-controls01-guard/` |
| Checked-source closure and IO | `selfhost/build/phase111/source-closure01/`, `closure-build01/` |
| Real-runtime pure U32 return | `selfhost/build/phase111/pure42-build01/`, `pure42-execute01-guard/` |
| Remaining focused cases and repairs | `selfhost/build/phase111/focused01/`, `repaired01/` |
| Staged orchestration byte agreement | `selfhost/build/phase111/staged-closure01/` |
| Five-case direct source gate | `selfhost/build/phase111/fast01/`, `fast01-guard/` |

## Full acquisition attempts

`full-emission01` checked the complete source: 4,955 definitions, 1,902 reached
names. Preparation took 1.40 seconds and the Bend frontend took 142.71 seconds.
The 300-second guard then stopped the process during generic lowering, at a
3,526,885,376-byte observed peak tree RSS. This is a deadline failure, not a
compiler diagnostic or successful full image. `full-emission02` retries the exact
frozen inputs with a 900-second deadline and the unchanged 4GiB memory cap.
Per-stage records distinguish checking, lowering, verification and QBE emission.

The longer unchanged attempt succeeds in 345.42 seconds, with 3,733,917,696-byte
peak process-tree RSS. It emits 50,664,292 bytes of QBE (SHA-256
`143521cc2e747a1af741aa8e62bd16bb476b2221836322ee5bb023e0da4466b2`):
37,018 segments, maximum arity26, incoming/output width1, 442constructors,
maximum constructor arity10, six required effects. The 65,532-segment ABI bound
is respected.

| Checked Bend API stage | Seconds |
| --- | ---: |
| Prepared Base | 1.37 |
| Frontend | 138.78 |
| Generic lowering | 148.25 |
| Structural IR verification | 47.99 |
| QBE emission | 7.26 |
| File write | 0.73 |

The first QBE build (`full-native01`) reached the historical 64MiB file limit
while writing assembly metadata, exiting with SIGXFSZ. It is preserved as a
failed build. The Phase111 guard retains the shared lock, deadline and process
memory supervisor, adds an explicit bounded file cap, and requires disk space
for two such files plus160MiB. With a128MiB cap, `full-native02` succeeds:
QBE7.68s, assembly2.37s, link0.22s, total build10.26s. The complete assembly is
68,809,177bytes and executable15,731,056bytes. No per-program C/cproc is used.

`native-closure01` then runs that compiler against the unchanged closure source
in4.78s; its61,184-byte QBE output matches the independently acquired checked
Bend API exactly, and its executable prints the frozen expected output. This
establishes a real native source request, not yet native self-reproduction.

The [source dependency slice](source-slice-audit.md) cuts source size65.4% and
definitions58.0%, preserving declaration bodies. `sliced-api01` successfully
checks its full entry and acquires12exports in6.59s. Native qualification and
self-reproduction of this smaller complete compiler remain separate.

## Next integration

N1 is now compiling its exact full source with the same inputs as the checked
API. The native wrapper compares complete QBE bytes before rebuilding N2 with
the same runtime. The broader semantic corpus follows this gate. The
checked Bend API can emit the complete Phase111 source directly to QBE. If that
works, use the directly built native image to emit its successor; this avoids an
extra C/cproc image acquisition. Preserve resource limits and diagnose failures
on small examples before repeating full builds. No native performance or
upstream parity claim is established yet.
