# Phase52 source accounting: selected direct06

The selected direct06 compiler adds **2,128 physical Bend lines (+8.99%)**,
**1,746 nonblank/non-comment lines (+8.96%)**, and **284 definitions** to Phase51.
All 92 pre-existing manifest modules are byte-identical; nine direct-backend
modules are added. The whole compiler is larger. The new mode provides a simpler
execution representation while retaining the compatibility and native backends;
this is not a 2,128-line standalone compiler or a reduction in total source.

These counts describe `checked-direct06`, independently of later qualification,
timing or installation. See the [phase report](README.md) for their status and
the [contract comparison](parity-contract.md) for the explicit interface split.

## Scope and reproducible identities

Counting reuses the unchanged Phase47 [counting helper](../../selfhost/tools/performance/phase47/measure-size.py),
SHA-256 `8e59af66ae57c32cb335bacd480404fa1c8e52105b45aab0f4028450cfcf8681`.
Its `snapshot` and `counts` functions read each frozen attempt and only the Bend
modules listed in that snapshot's `src/compiler.json`. Physical lines use
`splitlines`; code lines exclude blank lines and lines whose first nonspace
character is `#`. Definitions, laws and types count declaration lines beginning
with `def`, `law` and `type`. These are syntactic counts, not a complexity score.

The data-only comparison ran on CPU 0. It checked the recorded hashes of all
manifest modules, manifests, attempts and compiler images, then rehashed all 395
inputs consumed by the snapshot helper. The additional frozen direct-runtime and
driver files were checked against their snapshot records. It did not execute a
compiler or generated program, write historical evidence, or count the mutable
working tree as the candidate.

The fresh receipt is `selfhost/build/phase52/accounting-final06.json`, SHA-256
`a1da53ff3f07678957830703e6d763eeef8c2befd30c48def9b8320331253e93`.
It separately verifies that all 101 live manifest modules match selected direct06,
including restored `core.bend` SHA-256
`35da873a876469bdfbeb97b755f23eb2b6ba5bb90083ace2e4532da4ff623c58`.
The manifest, driver, both runtimes and all 40 vendored FFI package files also
match their selected snapshot. This establishes source agreement, not installation.

| Artifact | SHA-256 |
| --- | --- |
| Phase51 attempt | `c3d4ff1ad83127a8651849e57b9b6d020d4473e7b705770d3445d9bd6fef9e53` |
| Direct06 attempt | `cf2e8ea55f70aef6796b10ebbda65ffa2367428e50afb6d6f9ae0f59b7730835` |
| Phase51 source manifest | `598d2563fecc08f64d7081501478c35dce20998b0e46f67e68b3290847779704` |
| Direct06 source manifest | `7b81d4baf16656ce5a8ebc0b17f88ab311c8500c691ea4115aadacb1d1fc3b12` |
| Phase51 derived B1 API | `c15718cbf3e744e47c0795d7d78db6351a61c21983f53ec9c722272782dba061` |
| Direct06 derived B1 API | `472da578ff9066413f0a2b8e5c0053b5bc26eae8c3cb343b5b0cbb2a62c03a3a` |
| New direct runtime | `417d2d47f98116d4eae889ff53132d9255c8a0ffaf047dd497b877f2df0c188a` |

The exact inputs are `selfhost/build/phase51/checked-candidate01/attempt.json`
and `selfhost/build/phase52/checked-direct06/attempt.json`; each identifies its
immutable source snapshot. Both target upstream commit
`018751270e800bc222a93dad7f257083ee53a5f7`.

## Manifest-listed Bend source

| Metric | Phase51 | Direct06 | Change |
| --- | ---: | ---: | ---: |
| Physical lines | 23,662 | 25,790 | +2,128 |
| Nonblank/non-comment lines | 19,489 | 21,235 | +1,746 |
| Definitions | 2,673 | 2,957 | +284 |
| Laws | 629 | 629 | 0 |
| Type declarations | 87 | 95 | +8 |
| Modules | 92 | 101 | +9 |
| Source bytes | 1,047,916 | 1,156,193 | +108,277 |

The following partition uses directory ownership, not an assertion that every
file in a backend directory is exclusive to that backend.

| Source partition | Modules | Physical lines | Code lines | Definitions | Types |
| --- | ---: | ---: | ---: | ---: | ---: |
| Shared frontend, checker, loader, diagnostics and driver | 37 | 11,921 | 9,974 | 1,257 | 51 |
| Existing JavaScript backend and shared JS helpers | 38 | 9,649 | 7,770 | 1,130 | 19 |
| Existing native backend | 17 | 2,092 | 1,745 | 286 | 17 |
| New direct JavaScript backend | 9 | 2,128 | 1,746 | 284 | 8 |

All nine additions are under `selfhost/src/back/js/direct/`:

| Module | Physical lines | Code lines | Definitions | Types |
| --- | ---: | ---: | ---: | ---: |
| `model.bend` | 159 | 123 | 28 | 1 |
| `primitive.bend` | 231 | 201 | 17 | 1 |
| `constructors.bend` | 176 | 144 | 21 | 0 |
| `pattern.bend` | 272 | 223 | 36 | 2 |
| `host.bend` | 324 | 269 | 44 | 0 |
| `calls.bend` | 341 | 275 | 50 | 2 |
| `core.bend` | 348 | 287 | 49 | 0 |
| `program.bend` | 175 | 142 | 27 | 1 |
| `reach.bend` | 102 | 82 | 12 | 1 |
| **Total** | **2,128** | **1,746** | **284** | **8** |

The direct emitter still depends on the existing parser, checked specialization,
annotation, kernel terms, indexes and type normalization. It also reuses JS
helpers for typed application spines and telescopes, constructor lookup, quoting,
literal decoding, finite F32 expression generation and foreign-source resolution.
For example, `j_app_type`, `j_layout_ctor`, `j_quote`, `j_word` and
`j_private_float_magnitude` remain in shared existing modules. Their cost is not
hidden by describing the new directory as the complete implementation.

## Runtime, driver and images are separate

| Artifact | Phase51 | Direct06 | Change |
| --- | ---: | ---: | ---: |
| Compatibility runtime core, physical lines | 383 | 383 | 0; byte-identical |
| Compatibility runtime bundle, bytes | 57,500 | 57,500 | 0; byte-identical |
| Direct runtime, physical lines | — | 466 | +466 |
| Direct runtime, bytes | — | 12,952 | +12,952 |
| Vendored FFI providers, JS files / physical lines | — | 37 / 731 | +37 / +731 |
| Vendored FFI providers, JS bytes | — | 18,042 | +18,042 |
| Host driver, physical lines | 700 | 751 | +51 |
| Host driver, bytes | 48,273 | 53,086 | +4,813 |
| Derived B1 API, bytes | 1,628,734 | 1,790,409 | +161,675 (+9.93%) |
| Checked bootstrap API, bytes | 1,608,575 | 1,767,260 | +158,685 |

The 466-line [direct runtime](../../selfhost/src/runtime/js/direct.mjs) is a
separately attributed static adaptation of the pinned TypeScript compiler's
native JS/runtime sections and float rounding helper. Ordinary compilation does
not run the TypeScript compiler to generate program bodies. The existing
compatibility runtime is retained for the compiler host and compatibility output;
direct output embeds the new runtime. These runtime lines are not Bend source
and are not added to the manifest's line total.

The standalone FFI package also contains a manifest, license and README. All 40
files together total 38,508 bytes and 1,194 physical lines, including the 37 JS
providers above. These attributed provider sources are a separate maintained
input closure, not part of the 466-line core runtime or the nine Bend modules.
The evidence collector preserves their exact selected bytes and attribution.

The host-driver changes select the explicit direct interface, route runtime and
foreign-source output, and integrate exact emitted-definition reachability.
The manifest itself grows from 98 to 107 physical JSON lines. Driver, runtime,
manifest, compiler images, tests and experiment tooling are separate quantities;
adding their line counts would obscure what is maintained source versus output.

## Concept inventory and remaining duplication

The new directory implements seven broad mechanisms; this inventory is an
architectural description, not a measured concept count:

1. **Typed direct calls and closures:** source arity and erased slots determine
   positional calls, partial application and native unary closures. Fresh lexical
   bindings retain each iteration's captured values.
2. **Native values:** numbers, booleans, strings, arrays and named-field records
   carry checked language values without the compatibility descriptor transport.
   Internal Number Nat and public marshalling remain distinct responsibilities.
3. **Shared match rows:** Word/F32 and Nat row plans retain pattern coverage,
   views and predecessor demand. Call analysis consumes those same rows.
4. **Tail-call graph facts:** bounded reachability derives strongly connected
   components and whether a named callee can return an unknown-closure bounce.
   Component dispatch uses parallel argument transfers; forcing is selective.
5. **Live-definition closure:** emitter-owned `JD_REF` metadata follows actual
   erased-argument, dead-let and match demand before selecting foreign imports.
6. **Callable exports and FFI:** type-directed host marshalling, partial public
   calls, foreign CPS requests and once-per-source registration follow the direct
   interface rather than mutable `G` descriptors.
7. **Program readback:** a finite type worklist builds descriptors for pure result
   display; IO programs use the pinned runtime's effect/CLI protocol.

There is still duplication worth making explicit. Primitive semantics and some
layout/marshalling logic exist in more than one backend. The two JavaScript
interfaces deliberately retain separate transports and runtimes; deleting either
requires a migration decision and compatibility evidence. The direct path also
has several views of a definition: typed source, tail facts, emitted body and
reachability metadata. Reusing shared match rows prevents independent pruning
algorithms, but does not remove every repeated traversal.

In direct06, exact live reachability temporarily emits each reached definition
and scans its reserved metadata; final output emits again and rebuilds call facts
on the retained graph. This is a concrete compiler-work cost of the narrow
correctness repair. A later structured emission result could share code and
dependencies instead of rebuilding them. No measured compiler-throughput benefit
or cost for that future change is claimed here.

## Development-loop observation

The supervised direct06 checked build and its focused gate completed successfully
in **59.008 seconds**, with peak summed process-tree RSS **1,405.93 MiB** under
a 2 GiB cap. The receipt is
`selfhost/build/phase52/build-guard06/run.json`, SHA-256
`b9e535297fce916444a41a6656f8d784ecadbc9fda53e72ab75ccc8f2bd445a0`.
RSS sums can count shared pages more than once.

This is one development-workflow observation, including build/qualification work.
It is not a paired program-compilation benchmark, a throughput comparison with
TypeScript, a bootstrap fixed point, or the time for the whole Phase52 campaign.
Generated-program execution measurements and semantic qualification remain
separate from source size and this build time.

## Preserved direct05 checkpoint and rejected direct07

Direct06 adds caller-side expansion for already evaluated intrinsic arguments.
The table below preserves its predecessor's exact historical source inventory.
The same frozen counting method gives:

| Metric | Phase51 | Direct05 | Direct06 |
| --- | ---: | ---: | ---: |
| Physical Bend lines | 23,662 | 25,744 | 25,790 |
| Nonblank/non-comment lines | 19,489 | 21,198 | 21,235 |
| Definitions | 2,673 | 2,951 | 2,957 |
| Laws / types / modules | 629 / 87 / 92 | 629 / 95 / 101 | 629 / 95 / 101 |
| Bend source bytes | 1,047,916 | 1,153,946 | 1,156,193 |
| Derived B1 API bytes | 1,628,734 | 1,786,857 | 1,790,409 |

Only two manifest modules differ from direct05: `direct/core.bend` adds 45
physical lines, 36 code lines and six definitions; `direct/calls.bend` adds one
physical/code line so terminal intrinsics do not leave dangling graph edges
after expansion. Direct06 therefore adds **2,128 physical lines**, **1,746 code
lines** and **284 definitions** relative to Phase51. Its direct directory has
2,128 physical lines; the original 92 modules remain unchanged.

The direct06 attempt is
`selfhost/build/phase52/checked-direct06/attempt.json`, SHA-256
`cf2e8ea55f70aef6796b10ebbda65ffa2367428e50afb6d6f9ae0f59b7730835`;
its derived API is
`472da578ff9066413f0a2b8e5c0053b5bc26eae8c3cb343b5b0cbb2a62c03a3a`.
Its manifest and compatibility runtime identities are unchanged from direct05.
The supervised build took 59.008 seconds, again a development-workflow observation.
Direct07 is **not selected**. Its eight-point short screen measured a candidate/
direct06 geometric time ratio of **1.257466×**, or **25.75% slower**. The original
`screen-direct07-ordered/report.json` and rejected image remain preserved. That
rejection screen does not replace the selected direct06 full-corpus measurement.

## Final evidence publication

The [compact evidence collector](../../selfhost/tools/performance/phase52/collect-evidence.py)
completed after final selection, portable bundle publication and closure of all
raw writers. It copied reports, command/resource
receipts, failed observations, catalogs, methods, fixtures and the selected frozen
source graph verbatim into the final evidence directory. Its index records original
paths, hashes and copy paths. The existing 39-file prototype packet stays intact.

The collector requires the selected attempt, an explicit writer-closure receipt
and the passing final 103-file protection audit. It verified the selected API/direct
runtime against the portable candidate and preserves the Phase51 reference
identity. It retains failure outcomes as recorded; it does not reinterpret a
known mismatch as a pass. Its 8 MiB file / 128 MiB packet bounds make oversized
omissions explicit, with hashes and a requirement for the full raw capsule.

Runnable benchmark artifacts use the existing Phase52
[candidate](../../selfhost/tools/performance/phase52/freeze-candidate.py) and
[baseline](../../selfhost/tools/performance/phase52/freeze-baseline-v2.py) freezers,
with archive reopening and member verification. The complete raw campaign uses
the existing [streamed terminal archiver](../../selfhost/tools/performance/phase42/validation/archive-campaign-v1.py)
after writer closure. That separate archive preserves compiler images,
historical snapshots, large logs and all failed receipts. It reopened and verified
every member, then rechecked the complete raw input inventory and hashes.
No compression, large copying or publication ran concurrently with clean timing.

The [publication receipt](../../selfhost/tools/performance/phase52/publication.json)
joins both artifacts and rehashes all compact copies. The review packet contains
13,930 files / 106,115,555 bytes, with no oversized omissions; its index is
separate. The complete archive contains 18,396 files / 265,448,514 uncompressed
bytes and occupies 36,902,819 compressed bytes. Its SHA-256 is
`fc788dd884d808cff8b564e4266df99f8cbfe1a8f0bcfd53b62dfba4c5b6d016`.
These evidence sizes are not compiler source or generated-program sizes.

All 103 inherited unrelated files retained their original bytes and remained
unstaged. The selected installed API equals the measured and qualified direct06
image. Publication does not strengthen the scoped 95/96 semantic result.

The staged whitespace check passes outside the verbatim evidence packet. Its
11 reported trailing blank lines belong to copied pre-existing source and a
captured test log; their exact bytes are intentionally retained. All packet files,
including 19 files matched by broad repository ignore rules, are included in Git.
