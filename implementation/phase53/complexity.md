# Phase53 source complexity: ordered02 checkpoint

This accounts for the checked `ordered02` source and the identical live compiler
at this review cutoff. It is not a final promotion, installation, performance or
complete-conformance result. No compiler or generated program ran for this audit.

The change adds one composable expression representation and its scope rules;
it increases source size. The whole compiler grows **361 physical lines (1.40%)**
and **288 code lines (1.36%)** relative to selected Phase52 direct06. Keeping both
JavaScript contracts remains deliberate; neither backend was removed.

## Counts

The unchanged [Phase47 counting method](../../selfhost/tools/performance/phase47/measure-size.py)
counts physical lines with `splitlines`, code lines as nonblank lines excluding
leading-whitespace `#` comments, and declarations by leading `def`, `law`, or
`type`. A definition count includes compiler helpers; it is not a count of
independent concepts. Only modules listed in `src/compiler.json` enter the Bend
totals. Runtime JavaScript and the host driver are separate.

| Measure | Phase52 direct06 | Phase53 ordered02 | Change |
| --- | ---: | ---: | ---: |
| Manifest Bend modules | 101 | 103 | +2 |
| Physical Bend lines | 25,790 | 26,151 | +361 |
| Code lines | 21,235 | 21,523 | +288 |
| Definitions | 2,957 | 3,004 | +47 |
| Laws | 629 | 629 | 0 |
| Types | 95 | 99 | +4 |
| Bend source bytes | 1,156,193 | 1,175,720 | +19,527 |
| Direct-backend modules | 9 | 11 | +2 |
| Direct-backend physical lines | 2,128 | 2,489 | +361 |
| Direct-backend code lines | 1,746 | 2,034 | +288 |
| Direct-backend definitions | 284 | 331 | +47 |
| Direct-backend types | 8 | 12 | +4 |

Only three Bend files differ:

| Module | Physical lines, before → after | Code lines, before → after | Definitions, before → after |
| --- | ---: | ---: | ---: |
| `direct/core.bend` | 348 → 342 | 287 → 281 | 49 → 49 |
| `direct/ordered.bend` | 0 → 222 | 0 → 177 | 0 → 28 |
| `direct/ordered-values.bend` | 0 → 145 | 0 → 117 | 0 → 19 |

All other **100 Phase52 Bend modules are byte-identical**, including all 92
modules preceding the direct backend. The live manifest and all 103 live Bend
modules match the checked ordered02 snapshot. The live direct runtime and driver
also match that snapshot. These facts do not establish unchanged generated code:
the modified core delegates to the new expression emitter.

| Separate artifact | Phase52 | Ordered02 | Change |
| --- | ---: | ---: | ---: |
| Direct runtime physical lines | 466 | 471 | +5 |
| Direct runtime bytes | 12,952 | 13,212 | +260 |
| Host driver physical lines | 751 | 761 | +10 |
| Host driver bytes | 53,086 | 53,800 | +714 |
| Derived compiler API bytes | 1,790,409 | 1,814,920 | +24,511 |
| Checked bootstrap API bytes | 1,767,260 | 1,791,533 | +24,273 |
| Compatibility runtime bytes | 57,500 | 57,500 | 0 |

The compatibility runtime is byte-identical. Compiler-image size is distinct
from emitted user-module size and from program execution speed; neither latter
measure is inferred from this table.

## Conceptual change and remaining duplication

The central addition is `JDOrdered{prefix, value, next}`: emitted statements, a
pending value expression, and a fresh temporary ordinal. Its three companion
types carry argument, constructor-field and binding results. Four new data types
therefore serve one representation rather than four separate optimization passes.

Three scope rules account for most of the additional logic:

- **Two-stage argument lowering:** child prefixes are emitted first; native
  templates then hold pending non-atomic actuals. Ordinary named and unknown
  calls retain pending expressions, following the pinned emitter's observable
  order rather than a presumed universal left-to-right policy.
- **Demand and capture:** demanded parallel Let RHSs use the old environment;
  the body value remains pending. Held aliases use source binder IDs and reserved
  ordinals so a nested closure's temporary names cannot shadow captured values.
- **Composition:** constructor fields, partial/overapplied calls, returns and
  existing parallel SCC transfers carry the same representation. Erased work and
  closure bodies retain their demand scopes. Native literal/inverse-view folds
  precede field lowering.

This replaces six lines of core printing with delegates but retains the old
expression/call/constructor helpers as reused leaves and primitives. Some typed
telescope/field traversal and rendering logic is consequently still duplicated.
There is no new general effect system, whole-program inliner or runtime permission
protocol. A later consolidation can unify those shared traversals after the
ordering controls are stable; deleting a fallback without checking demand and
closure scope would not be a safe line-count reduction.

The [existing graph limits and quadratic closure work](scaling.md) are unchanged.
The new syntax walker does not unfold named bodies and has no arbitrary depth64
fallback; its recursion descends finite terms, field lists or missing-formal
telescopes. That structural termination argument is not a measured compiler-cost
improvement or a guarantee against deep-source host-stack/resource limits.

## Development cost and provenance

`build-ordered02/run.json` records one successful checked development workflow:
**61.091599 seconds**, peak supervised process-tree RSS **1,512,972,288 bytes**
(about 1.41 GiB), within its 2 GiB ceiling. This is one build observation. It is
not paired compiler-request throughput, self-compilation speed or a causal cost
estimate for the added emitter.

Inputs were read on CPU0 and all **326 consumed identities** were rehashed after
counting. The audit used the frozen attempts, their module manifests and source
hashes, API images, runtime/driver files, and the corresponding live sources.
Historical snapshots and evidence were not modified; no additional raw receipt
or archive was produced by this documentation-only task.

| Input | SHA-256 |
| --- | --- |
| Counting method | `8e59af66ae57c32cb335bacd480404fa1c8e52105b45aab0f4028450cfcf8681` |
| Phase52 direct06 attempt | `cf2e8ea55f70aef6796b10ebbda65ffa2367428e50afb6d6f9ae0f59b7730835` |
| Ordered02 attempt | `c8e1a28b53d42a44eb7d8ebe69a17fa52967359019ea8eac7bd02671e961ba0f` |
| Ordered02/live manifest | `559e008be9865497eb104912a636416e0c083b86b0173645ebd0150a47d2369d` |
| Ordered02 API | `3e3fb8c3bc4c445567696ce62bd95979e36746ddde5bb9e0aad3038fc362c9b9` |
| Ordered02 direct runtime | `c328b77360c98489343d4752d4644d93f64de9d697d2c964f5fbae6442a77d23` |
| Ordered02 driver | `eb4bb871371fb2fb61fa1c077d093a817a1f6ae35205ebb2beecfb6e064fc417` |

Frozen inputs are `selfhost/build/phase52/checked-direct06/attempt.json` and
`selfhost/build/phase53/checked-ordered02/attempt.json`; the latter's `snapshot/`
contains the accounted source. Later source revisions require a new accounting
checkpoint. The [phase report](README.md) owns the current qualification and
selection status.
