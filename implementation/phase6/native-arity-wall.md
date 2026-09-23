# Native arity-wall footprint

The final broad backend gate found one positive candidate timeout: `reg/arity_wall.bend`, native, at120,069ms. Fresh pinned TypeScript passed the same fixture in2,396ms with stdout `1\n`. These are correctness-run observations under shared resources, not isolated benchmark samples. The timeout remains a failure.

The candidate emitted C before the deadline. Its request file was written03:02:26.103UTC, native emission was logged03:02:35.870, C was written03:03:17.326, and timeout capture closed 03:04:26.172. No candidate binary, native-build report, or runtime output exists. The frozen host writes C immediately before `buildNative`, which invokes Clang16 at `-O3`. This supports a toolchain-stage timeout after roughly51 seconds of compiler work, with roughly69 seconds remaining; there is no per-subprocess timing trace establishing exact Clang duration. No contention explanation is assumed.

| Retained C property | Pinned TypeScript | Derived Bend |
|---|---:|---:|
| Bytes | 80,723 | 3,716,568 |
| Lines | 3,150 | 109,232 |
| Segments section bytes | 3,598 | 3,583,513 |
| `WL_CASE` bodies, including runtime entries | 9 | 382 |
| `FID_ARITY_T` entries | 7 | 380 |
| `CID_ARITY_T` entries | 16 | 123 |
| `Term` registers in `WL_SIG`, including `rp` | 3 | 256 |
| Tables section bytes | 1,724 | 56,875 |

Thirty-two marked runtime/scaffold sections are byte-identical, totaling 67,044 bytes per file. The differing marked regions are Tables, Err, Spins, Segments and Show. This is chiefly generated program expansion, not a46× larger copied runtime. The candidate’s 255 segments containing the literal return sequence `r0 = 1ull; WL_RETN(1);` total3,486,765 bytes—93.8% of its whole C file—with 32,386`e.mem[` and 64,773`STK(` occurrences. These are syntactic occurrence counts, not measured executed operations. The largest segment is27,203 bytes; successive large segments grow by 107 bytes as another retained field is added.

The source explains the pattern. [`nc_sequence`](../../selfhost/src/back/native/bridge.bend) creates a `Let` for every constructor field, including already compacted scalar literals. `nc_let` retains the growing live prefix; `nc_cut` emits both sequential-stack and task-frame save paths. Each literal returns through another continuation that reloads and saves previous fields. This creates quadratic textual repetition for the255 literal fields. [`nb_bank`](../../selfhost/src/back/native/tables.bend) then chooses one global register width from segment parameter counts, making every worker signature wide. `ne_segments` in [emit.bend](../../selfhost/src/back/native/emit.bend) serializes those expanded segments. The presence of more helper segments and constructors is real, but the literal continuation chain dominates this witness.

This is a concrete native generation/toolchain bottleneck. It does **not** establish the cause of the separate roughly6× whole-compiler workload deficit. No compiler or emitter change was made. The next experiment is [a bounded emit-only scaling falsifier](../../design/phase6/native-code-size.md), followed by ownership and evaluation-order controls before any optimization.

Reproduce the static analysis with `python3 implementation/phase6/native-arity-wall.py` from the repository root. [Its JSON](native-arity-wall.json) records exact C/source hashes and section/segment counts. Candidate C SHA is `a2d6f3c453ca7a3ad7193d2773ff210e57952718a5fc2a9f139ed4538fcf2432`; TS C SHA is `1e33c67eac8f7518f79da3e783e9a8a89f03d13719bb06ea5f1733a2ac111139`. Actual C, TS binary/build report, timeout logs and replay inputs are retained in the [broad backend archive](../phase5/broad-backend-evidence/README.md). Static source identities use the consumed attempt05 snapshot; links above are convenient current-source navigation.

The authorized follow-up completed 03:21:14.457UTC. Preregistration preceded execution; three fresh CPU1 workers used the same verified derived compiler, frozen host, runtime/Base and API-specific validated cache. Each authoritative native-emission result was `ok`, `phase:compile`, `checked:true`, with stable recorded inputs. No Clang or generated program ran.

| Fields | C bytes | Literal continuation bytes | Literal stack references | Signature `Term` registers |
|---:|---:|---:|---:|---:|
| 32 | 217,752 | 62,299 | 995 | 33 |
| 64 | 396,504 | 230,651 | 4,035 | 65 |
| 128 | 1,075,095 | 888,091 | 16,259 | 129 |
| 255, retained earlier anchor | 3,716,568 | 3,486,765 | 64,773 | 256 |

The dominant continuation region grows about 3.70× and 3.85× when field count doubles; stack references grow 4.06× and 4.03×. This corroborates quadratic prefix copying in emitted text. Total C includes a substantial fixed/helper component and is not expected to quadruple exactly. Mechanical source checks verify each record has the requested U32 fields, constructs every field as 1, and returns `f0` through the same `pick`/IO shape. The smaller fixtures retain the original regression commentary; their actual declarations/matches/arguments are separately checked. This is source-shape and checked-emission evidence, **not runtime equivalence**.

[The small scaling archive](native-scaling-evidence/README.md) retains the preregistration, full C, source, successful gate reports, bounded child logs, exact tool/API/host inputs, static audit and earlier 255 C anchor. The run wrapper is `selfhost/tools/performance/phase6/native-scaling.mjs`; `native-scaling-audit.py` recomputes size and source-shape checks without running a compiler. No production optimization was made.
