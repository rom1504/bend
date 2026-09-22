# Private tag-comparison experiment

Not promoted. Replacing 439 comparisons of compiler-owned term tags and
definition kinds with direct JavaScript string comparisons did not improve the
real compiler-core workload. The ordinary runtime, public libraries and emitted
programs were unchanged.

The transform recognizes only exact `tg`/`dk` workers followed by `String.eq`
against a well-formed literal, inside generated worker bodies. It excludes user
names and arbitrary string comparisons. Its assumptions require the private
data-only worker boundary: compiler-created tags, immutable globals, no incoming
raw graphs, callbacks or JavaScript getters. It is an experimental ablation, not
a public code-generation optimization.

Both variants start from the same checked Phase 3 H and use the winning private
call/projection/runtime/constant transformations. The control image is
byte-identical to canonical private release3
(`1905c283551d4ad93c129549f8c540d8d21b47eb0486d88036f0afa9a0d4f9ab`).
Every timed request uses a fresh process on CPU 1; order alternates across three
repetitions. Each compiler has a separately validated Base cache prepared outside
the timer. All ordinary output-runtime and host inputs are identical.

| Request median | Private control | Tag experiment | Change |
| --- | ---: | ---: | ---: |
| Tree emission | 2.402 s | 2.357 s | 1.9% faster |
| List-sort emission | 4.293 s | 4.226 s | 1.6% faster |
| Bytes rejection | 1.666 s | 1.669 s | 0.2% slower |
| Compiler-core library, 312 declarations | 40.297 s | 40.398 s | 0.3% slower |

The small three-way matrix, including pinned TypeScript, passed all 27 exact
outcome/byte/execution samples. All six real-core samples had identical results
and emitted bytes; emitted libraries also loaded successfully. The larger null
result does not justify adding this transform to the supported private tool.
These measurements do not compare generated-program execution speed.

Retained evidence: [small matrix](evidence/tag-small.json.gz),
[core matrix](evidence/tag-core.json.gz),
[image preparation](evidence/tag-preparation.json.gz), and
[provenance verification](evidence/tag-provenance-supplement.json).
The core runner initially omitted an automatic comparison against the preparation
manifest. The supplement verifies that both exact image hashes recorded before
and after both benchmarks match that manifest. The current runner enforces the
check before launch; the [consumed original runner](evidence/tag-core-run1.mjs)
preserves the actual timing recipe.
