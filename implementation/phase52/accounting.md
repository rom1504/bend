# Phase52 source accounting: checked direct05

The frozen direct05 compiler adds **2,082 physical Bend lines (+8.80%)**,
**1,709 nonblank/non-comment lines (+8.77%)**, and **278 definitions** to Phase51.
All 92 pre-existing manifest modules are byte-identical; nine direct-backend
modules are added. The whole compiler is larger. The new mode provides a simpler
execution representation while retaining the compatibility and native backends;
this is not a 2,082-line standalone compiler or a reduction in total source.

These counts describe `checked-direct05`, independently of later qualification,
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
manifest modules, manifests, attempts and compiler images, then rehashed all 205
inputs consumed by the snapshot helper. The additional frozen direct-runtime and
driver files were checked against their snapshot records. It did not execute a
compiler or generated program, write historical evidence, or count the mutable
working tree as the candidate.

| Artifact | SHA-256 |
| --- | --- |
| Phase51 attempt | `c3d4ff1ad83127a8651849e57b9b6d020d4473e7b705770d3445d9bd6fef9e53` |
| Direct05 attempt | `4b988ca6471d4f46994beb8ab8d21d4f26be7550dcead7caf8a04e68605c770a` |
| Phase51 source manifest | `598d2563fecc08f64d7081501478c35dce20998b0e46f67e68b3290847779704` |
| Direct05 source manifest | `7b81d4baf16656ce5a8ebc0b17f88ab311c8500c691ea4115aadacb1d1fc3b12` |
| Phase51 derived B1 API | `c15718cbf3e744e47c0795d7d78db6351a61c21983f53ec9c722272782dba061` |
| Direct05 derived B1 API | `ab23e1f04f13112fe38e5fd7a74893c5056e926e18d6ab8fc79d26680fa8d2b5` |
| New direct runtime | `417d2d47f98116d4eae889ff53132d9255c8a0ffaf047dd497b877f2df0c188a` |

The exact inputs are `selfhost/build/phase51/checked-candidate01/attempt.json`
and `selfhost/build/phase52/checked-direct05/attempt.json`; each identifies its
immutable source snapshot. Both target upstream commit
`018751270e800bc222a93dad7f257083ee53a5f7`.

## Manifest-listed Bend source

| Metric | Phase51 | Direct05 | Change |
| --- | ---: | ---: | ---: |
| Physical lines | 23,662 | 25,744 | +2,082 |
| Nonblank/non-comment lines | 19,489 | 21,198 | +1,709 |
| Definitions | 2,673 | 2,951 | +278 |
| Laws | 629 | 629 | 0 |
| Type declarations | 87 | 95 | +8 |
| Modules | 92 | 101 | +9 |
| Source bytes | 1,047,916 | 1,153,946 | +106,030 |

The following partition uses directory ownership, not an assertion that every
file in a backend directory is exclusive to that backend.

| Source partition | Modules | Physical lines | Code lines | Definitions | Types |
| --- | ---: | ---: | ---: | ---: | ---: |
| Shared frontend, checker, loader, diagnostics and driver | 37 | 11,921 | 9,974 | 1,257 | 51 |
| Existing JavaScript backend and shared JS helpers | 38 | 9,649 | 7,770 | 1,130 | 19 |
| Existing native backend | 17 | 2,092 | 1,745 | 286 | 17 |
| New direct JavaScript backend | 9 | 2,082 | 1,709 | 278 | 8 |

All nine additions are under `selfhost/src/back/js/direct/`:

| Module | Physical lines | Code lines | Definitions | Types |
| --- | ---: | ---: | ---: | ---: |
| `model.bend` | 159 | 123 | 28 | 1 |
| `primitive.bend` | 231 | 201 | 17 | 1 |
| `constructors.bend` | 176 | 144 | 21 | 0 |
| `pattern.bend` | 272 | 223 | 36 | 2 |
| `host.bend` | 324 | 269 | 44 | 0 |
| `calls.bend` | 340 | 274 | 50 | 2 |
| `core.bend` | 303 | 251 | 43 | 0 |
| `program.bend` | 175 | 142 | 27 | 1 |
| `reach.bend` | 102 | 82 | 12 | 1 |
| **Total** | **2,082** | **1,709** | **278** | **8** |

The direct emitter still depends on the existing parser, checked specialization,
annotation, kernel terms, indexes and type normalization. It also reuses JS
helpers for typed application spines and telescopes, constructor lookup, quoting,
literal decoding, finite F32 expression generation and foreign-source resolution.
For example, `j_app_type`, `j_layout_ctor`, `j_quote`, `j_word` and
`j_private_float_magnitude` remain in shared existing modules. Their cost is not
hidden by describing the new directory as the complete implementation.

## Runtime, driver and images are separate

| Artifact | Phase51 | Direct05 | Change |
| --- | ---: | ---: | ---: |
| Compatibility runtime core, physical lines | 383 | 383 | 0; byte-identical |
| Compatibility runtime bundle, bytes | 57,500 | 57,500 | 0; byte-identical |
| Direct runtime, physical lines | — | 466 | +466 |
| Direct runtime, bytes | — | 12,952 | +12,952 |
| Host driver, physical lines | 700 | 730 | +30 |
| Host driver, bytes | 48,273 | 51,612 | +3,339 |
| Derived B1 API, bytes | 1,628,734 | 1,786,857 | +158,123 (+9.71%) |
| Checked bootstrap API, bytes | 1,608,575 | 1,763,825 | +155,250 |

The 466-line [direct runtime](../../selfhost/src/runtime/js/direct.mjs) is a
separately attributed static adaptation of the pinned TypeScript compiler's
native JS/runtime sections and float rounding helper. Ordinary compilation does
not run the TypeScript compiler to generate program bodies. The existing
compatibility runtime is retained for the compiler host and compatibility output;
direct output embeds the new runtime. These runtime lines are not Bend source
and are not added to the manifest's line total.

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

In direct05, exact live reachability temporarily emits each reached definition
and scans its reserved metadata; final output emits again and rebuilds call facts
on the retained graph. This is a concrete compiler-work cost of the narrow
correctness repair. A later structured emission result could share code and
dependencies instead of rebuilding them. No measured compiler-throughput benefit
or cost for that future change is claimed here.

## Development-loop observation

The supervised direct05 checked build and its focused gate completed successfully
in **59.536 seconds**, with peak summed process-tree RSS **1,402.76 MiB** under
a 2 GiB cap. The receipt is
`selfhost/build/phase52/build-guard05/run.json`, SHA-256
`2a82f9fa71426de725764660d6650372982020ac30c4d1673fb55eba18193c78`.
RSS sums can count shared pages more than once.

This is one development-workflow observation, including build/qualification work.
It is not a paired program-compilation benchmark, a throughput comparison with
TypeScript, a bootstrap fixed point, or the time for the whole Phase52 campaign.
Generated-program execution measurements and semantic qualification remain
separate from source size and this build time.

## Direct06 checkpoint; final selection pending

Direct06 adds caller-side expansion for already evaluated intrinsic arguments.
The direct05 tables above remain its exact historical source inventory; they are
not silently relabeled as a newer image. The same frozen counting method gives:

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
Any direct07 successor must be counted from its own frozen manifest after final
selection; no prospective count or installation claim is included here.

## Final evidence collection plan

The [compact evidence collector](../../selfhost/tools/performance/phase52/collect-evidence.py)
is prepared but has not been executed. After final selection, portable bundle
publication and closure of all raw writers, it will copy reports, command/resource
receipts, failed observations, catalogs, methods, fixtures and the selected frozen
source graph verbatim into a fresh evidence directory. Its index records original
paths, hashes and copy paths. The existing 39-file prototype packet stays intact.

The collector requires the selected attempt, an explicit writer-closure receipt
and the final 103-file protection audit. It verifies the selected API/direct
runtime against the portable candidate and preserves the Phase51 reference
identity. It retains failure outcomes as recorded; it does not reinterpret a
known mismatch as a pass. Its 8 MiB file / 128 MiB packet bounds make oversized
omissions explicit, with hashes and a requirement for the full raw capsule.

Runnable benchmark artifacts use the existing Phase52
[candidate](../../selfhost/tools/performance/phase52/freeze-candidate.py) and
[baseline](../../selfhost/tools/performance/phase52/freeze-baseline.py) freezers,
with archive reopening and member verification. The complete raw campaign uses
the existing [streamed terminal archiver](../../selfhost/tools/performance/phase42/validation/archive-campaign-v1.py)
only after writer closure. That separate archive must preserve omitted compiler
images, historical snapshots, large logs and all failed receipts. The compact
packet explicitly does not claim that archive has been joined or verified.
No compression, large copying or publication runs concurrently with clean timing.
