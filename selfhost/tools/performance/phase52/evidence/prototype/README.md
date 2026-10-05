# Phase52 prototype evidence packet

This compact packet copies completed reports verbatim so the prototype results
can be reviewed without access to the working machine. It contains **39 exact
copies**, about 2 MB, plus this guide and the [identity index](index.json).
Original absolute paths remain provenance; this is not a runnable benchmark
bundle, full raw archive, compiler image or installed release.

Start with the [prototype report](../../../../../../implementation/phase52/prototype.md).

| Observation | Original direct02 | Revised direct03 |
|---|---|---|
| Timing results, eight points and 72 samples each | [report](screen-direct02/report.json) | [report](screen-direct03/report.json) |
| Explicit new callable contract | [receipt](screen-direct02/phase52-comparison.json) | [receipt](screen-direct03/phase52-comparison.json) |
| Checked acquisition and source/module identities | [manifest](prepared-direct02/manifest.json) | [manifest](prepared-direct03/manifest.json) |
| Three-call exact-output smoke per point | [report](smoke-direct02/report.json) | [report](smoke-direct03/report.json) |
| Guarded checked build resources | [receipt](build-guard02/run.json) | [receipt](build-guard03/run.json) |

Both runs use the exact saved [Phase51 and TypeScript reference](reference01/manifest.json).
Acquisition sidecars under each prepared directory preserve source, compiler,
direct runtime, emission-input and output hashes. The index records the original
location, byte size and SHA256 of every copy.

The independent [direct03 library result](semantic-direct03-controls01/report.json)
passes 55 scenarios across14 fixtures. The [explicit subset](catalogs/semantic-catalog-library-v1.json)
excludes four program/FFI fixtures; it is not a59-scenario direct result. The
[reference-only result](semantic-reference-controls03/report.json) passes59
upstream scenarios. The [join receipt](semantic-direct03-join01.json) retains
checked-module and catalog lineage. Original failed reference runs are pinned
in the index and remain in raw evidence; their large repeated error stacks are
not included in this compact packet.

No direct02/direct03 result qualifies a later source/runtime image. No timings
from separate runs are mixed to construct a denominator. Full45 performance,
program/FFI semantics and final release work remain separate gates.
