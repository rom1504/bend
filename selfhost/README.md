# Bend2 compiler written in Bend

The maintained compiler source is [`src/`](src/), ordered by
[`src/compiler.json`](src/compiler.json). One module tree supplies the JS, C,
QBE and x86 assembly/object algorithms; explicit entry profiles select the compiler interface. Compiler
algorithms remain in Bend. Python/JavaScript/C host tools provide file/process
transport, runtime support, measurement and independent validation.

Start with the [maintained workflow](../docs/self_hosted/workflow.md). It explains
source assembly, image/asset admission, native requests/builds, actual bootstrap
generations and the distinction between current source and installed artifacts.
The [Phase182 migration report](../implementation/phase182/README.md) and
[Phase189 object-default report](../implementation/phase189/README.md) record the
component identities and qualification. The [consolidation report](../implementation/repository-consolidation/README.md)
retains the source migration and historical recovery record.
Maintained source targets upstream `9a4223d577ba56a0cb53d1fd952d2b481c38930f`
(Bend2.0.40). See the [compatibility boundaries](../docs/self_hosted/upstream-2.0.40.md);
historical and installed artifacts retain their own recorded pins and qualification.

The selected release integrates the earlier frontend improvements and cleanup,
then ports the frontend, Base, effect interfaces and runtimes to the new upstream.
[Phase182](../implementation/phase182/README.md) records native and JS reproduction,
finite backend/public CLI gates, session reuse and independent BendTT checks.
Phase189 installs the Phase188 x86 N2 for AMD64 SysV and the sequential ABI11102
runtime, using direct objects for executable builds and `--run`. Its actual
QBE-built N1 → object-built N2 → object-built N3 lineage reproduces complete
object bytes. All 64 finite catalog cases and ten runtime controls pass through
objects, and all 14 installed public-command controls pass. The previous
Phase183 image and selector remain available for rollback.
Build, bootstrap, benchmark and profiler interfaces are described in the
[x86 guide](../docs/self_hosted/ASSEMBLY.md).
Qualification belongs to the actual image and current release receipts;
source acceptance with zero unresolved holes is not a kernel proof.

| Task | Maintained entry |
| --- | --- |
| Assemble `qbe`, `x86`, `native-c` or `js-api` source | [`tools/build/source.py`](tools/build/source.py) · [assembly recipe](../docs/self_hosted/workflow.md#assemble-before-building) |
| Request/build/bootstrap | [`tools/build/`](tools/build/) · [operational assets](manifests/assets-native.json) |
| Compiler speed and prepared JS/C/QBE/x86 program speed | [`tools/bench/`](tools/bench/README.md) |
| Native sampling, source owners, callers, events and stages | [`tools/profiler/`](tools/profiler/README.md) · [guide](../docs/self_hosted/PROFILING.md) |
| V8 CPU/allocation and generated-code inspection | [Benchmark diagnostics](tools/bench/README.md#profiles-and-generated-code-inspection) |
| Correctness and proof boundaries | [Conformance record](CONFORMANCE.md) · [workflow](../docs/self_hosted/workflow.md#correctness-and-proof-boundaries) |
| Finite JS/C/QBE/x86 and public CLI gates | [Qualification guide](tools/conformance/qualification.md) · [copied independent fixtures](tests/consolidation/README.md) |
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

For the installed x86 compiler, use `selfhost/bend --target x86
input.bend -o output.s` for assembly, `-o output` for an ELF, or `--run` to
compile and execute. The Phase189 release constructs ELF executables directly
from Bend-emitted objects. The JS launcher accepts the same x86 options. Existing
output paths are refused; append application arguments after `--` with `--run`.

Run these from the repository root with their selected package assets available.
The qualified release is selected by [`manifests/current.json`](manifests/current.json):
JS B2, public native C N1, direct-QBE N2 and x86 N2. The first three retain their
Phase182 snapshot08 source bindings (with the explicit thin public C profile);
x86 N2 in the Phase189 release binds the independently checked Phase188 `x86`
entry profile. Operational `qbe-n2` and `x86-n2` assets select the corresponding
installed N2; hosted QBE remains a separately checked B1 API. The release's x86
`defaultEmission` is `object`; an older selector without that field retains
assembly behavior, including the preserved Phase183 rollback selector.
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
