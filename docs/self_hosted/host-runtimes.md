# Choosing a host runtime for the Bend compiler

Keep Node as the default for the qualified JavaScript B2 compiler. Phase89's
controlled screen found that Bun starts the upstream TypeScript source compiler
faster overall, but starts and runs our frozen B2 image more slowly. There is no
single fastest host independent of the compiler implementation and workload.

For the qualified native B1 pilot, follow [NATIVE_HOST.md](NATIVE_HOST.md).
It runs the compiler written in Bend as native code, with Python only for
authentication and resource supervision. It supports one module importing
canonical Base and the three audited scalar effects. It is a separate host
option, not a native self-emitted B2 or a general replacement for the JS driver.

## What the measurements say

Phase89 compares exactly pinned upstream source under Node24.18.0/Bun1.4.3,
the same frozen genuine Phase82 B2 under both engines, and Phase88 native02 B1.
Six sources run in two fresh-process rounds, followed by one five-call process
per source/role. Every one of210 generated C products matches its assigned
pinned TS or B2 oracle. These are **compiler execution times**, not speeds of
the programs produced by it.

| Scenario | Evidence from the six-source screen |
| --- | --- |
| Upstream TS, fresh process | Bun/Node process-time ratio0.7985×; Bun import about25ms versus263ms |
| Upstream TS, first request excluding imports | Bun/Node1.3821×; Node's request itself is faster |
| Our B2, fresh process | Bun/Node1.4215×; Node wins all six cases |
| Our B2, fifth repeated request | Bun/Node1.3641× geometric mean; only one observation per source |
| Native B1, fresh process | Five wins versus TS Bun, Map1.963× slower; six-source geometric mean0.5170× |
| Native B1, fifth request | Map5.455× TS Bun /6.949× TS Node; Lexer also slower |

Ratios mean numerator time divided by denominator time; lower is better.
Aggregates are equal-source geometric means and include Map. Fresh process does
not mean cold OS caches or absent prepared Base. Cross-implementation request
clocks have different Base/cache/report/consumption boundaries, so they must not
be read as equal-work backend-only ratios. The five-call results are not a proven
steady state. See the [complete report and source identities](../../implementation/phase89/engines.md)
before quoting a number.

Changing TS's host from Node to Bun changes the performance denominator. For
example, the unchanged B2 Node process scores0.967× against TS Node but1.211×
against TS Bun. That is baseline selection, not a compiler regression or gain.
Always name the engine, source/image identity, cache state and measured interval.

## Repeat the bounded engine screen

Once the exact Phase88 assets and Phase89 pinned Bun installation are present,
run the existing method from the recorded repository path:

```sh
python3 -B selfhost/tools/performance/phase89/measure.py NEW_COLD_DIRECTORY \
  --calls 1 --rounds 2
python3 -B selfhost/tools/performance/phase89/measure.py NEW_REPEATED_DIRECTORY \
  --calls 5 --rounds 1
```

Use `--cases small,map_closed` and explicit comma-separated `--roles` for a
smaller loop. Roles are `ts-bun,ts-node,b2-bun,b2-node,native`. The method rotates
execution order, uses the serial CPU3 resource guard, retains every C file and
stops on job/output failure. Use fresh output directories. It reads immutable
source/image pins; changing the installed default does not silently change this
historical comparison. Running programs emitted by the compiler or measuring
Clang requires separate execution benchmarks.

The separately downloaded official Bend2.0.36 executable failed even `--version`
with SIGILL on this host. Lack of advertised AVX2 is a possible explanation,
not a proven diagnosis. It supplies no timing result and was not substituted
for the successful pinned-source Node/Bun comparison. The installed source pin
and the latest released executable are distinct artifacts.
