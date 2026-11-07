# Bend2 compiler written in Bend

The maintained compiler source is [`src/`](src/), ordered by
[`src/compiler.json`](src/compiler.json). One module tree supplies the JS, C and
QBE algorithms; explicit entry profiles select the compiler interface. Compiler
algorithms remain in Bend. Python/JavaScript/C host tools provide file/process
transport, runtime support, measurement and independent validation.

Start with the [maintained workflow](../docs/self_hosted/workflow.md). It explains
source assembly, image/asset admission, native requests/builds, actual bootstrap
generations and the distinction between current source and installed artifacts.
The [Phase174 promotion report](../implementation/phase174/README.md) records the
current installed artifacts and qualification. The [consolidation report](../implementation/repository-consolidation/README.md)
retains the source migration and historical recovery record.
The pinned upstream language is `059266225b77c8ca256ac6b25ee5c21449bab151`
(Bend2.0.36).

The current modules include [Phase175](../implementation/phase175/README.md):
parser lookahead reuse and indexed report names. The complete frozen-source
QBE build takes 185.55→178.94s in a fresh pair, with unchanged generated products.
Its qualified native N2 is an explicit research image; installed selectors
remain the Phase174 publication of Phase171. See the report's reproduction
commands to select the new image without confusing source and release versions.

| Task | Maintained entry |
| --- | --- |
| Assemble `qbe`, `native-c` or `js-api` source | [`tools/build/source.py`](tools/build/source.py) · [assembly recipe](../docs/self_hosted/workflow.md#assemble-before-building) |
| Request/build/bootstrap | [`tools/build/`](tools/build/) · [operational assets](manifests/assets-native.json) |
| Compiler speed and prepared JS/C/QBE program speed | [`tools/bench/`](tools/bench/README.md) |
| Native sampling, source owners, callers, events and stages | [`tools/profiler/`](tools/profiler/README.md) · [guide](../docs/self_hosted/PROFILING.md) |
| V8 CPU/allocation and generated-code inspection | [Benchmark diagnostics](tools/bench/README.md#profiles-and-generated-code-inspection) |
| Correctness and proof boundaries | [Conformance record](CONFORMANCE.md) · [workflow](../docs/self_hosted/workflow.md#correctness-and-proof-boundaries) |
| Finite JS/C/QBE and public CLI gates | [Qualification guide](tools/conformance/qualification.md) · [copied independent fixtures](tests/consolidation/README.md) |
| Disk/process lifecycle and historical recovery | [`tools/build-retention/`](tools/build-retention/README.md) · [`tools/history/`](tools/history/README.md) |

Program execution preserves the original 45 points from 23 source programs and
independent outputs; native timing has 44 eligible points plus a zero-work control.
Use 20/60/300/600-second ceilings and explicit cases/rounds. Compilation/acquisition,
clean execution and profiling have separate budgets. A compiler request is not
execution of the program it emits, and a warm session edit is not a cold build.

Existing public entries remain:

```sh
node selfhost/cli.mjs input.bend --run
selfhost/bend input.bend -o output.c
```

Run these from the repository root with their selected package assets available.
The qualified Phase174 release is selected by [`manifests/current.json`](manifests/current.json):
JS B2, public native C N1 and direct-QBE N2, bound to the recorded Phase171
canonical source (with the explicit thin public C profile). The operational QBE
assets select the installed N2; hosted QBE remains a separately checked B1 API.
A newly assembled profile or generated image
must retain its actual host/stage/target and capability binding; it does not
inherit every earlier backend/runtime qualification.

Current source and tool migration records are linked from the
[workflow](../docs/self_hosted/workflow.md), including the benchmark
[migration map](tools/bench/migration-map.json) and
[validation status](tools/bench/validation.json). Historical numerical narratives
remain in [`implementation/`](../implementation/),
[`research/`](../research/) and the
[authenticated history index](tools/history/README.md). They describe their own
recorded artifacts, not a fresh benchmark of the maintained checkout.

Read the [experiment frontier](../experiments/STEERING.md) for accepted findings,
qualification limits and the next open question. See
[application examples](apps/README.md) for complete programs; their measured
build/execution and supported effect policies remain distinct from compiler
microbenchmarks.
