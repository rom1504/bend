# Three-source compilation transport and ready-executable comparison

This screen compares **source→QBE** for two native Bend compiler images with
**source→C** for pinned upstream TypeScript/Bun. These outputs differ: the
request ratio is a configured native-representation workflow comparison, **not
same-format compiler throughput or an isolated frontend speed ratio**. The
separate ready-executable comparison adds fresh QBE/assembly/linking versus
fresh upstream C/Clang construction.

`manifest01.json` freezes the three unchanged, one-shot Phase88 inputs and their
independent complete stdout from the Phase111 coverage manifest:

| Input | Why included | Frozen expected stdout |
| --- | --- | --- |
| lexer | Larger checked source with real scanning and allocation | `1822208108` plus LF |
| coverage-closures-256 | Captures and indirect function use | `33019` plus LF |
| coverage-map-churn-128 | Persistent maps, generic structure and ownership | `3714872484` plus LF |

They are not Phase93's batched runtime benchmark sources. Earlier Phase111
successor observations took5.18/3.58/7.63s for requests and0.032/0.002/0.008s
for one program execution, respectively. Those historical values are planning
bounds, not new candidate/reference measurements. This screen is deliberately
small and cannot replace the45-point compilation or program-speed corpus.

## Images, trust and preparation

The baseline is qualified Phase111 **route N2** at
`selfhost/build/phase111/native-self02/build/program`. The candidate is Phase112
**route N1** at `selfhost/build/phase111/p112-full-native01/program`, acquired
through the checked hosted Bend API. Both execute native Bend compiler
implementations and target the same sequential x86-64 semantic scope, but their
sources and backend implementations differ. This is not a same-source B1/B2
bootstrap-generation comparison; the labels do not update production B1/B2.

Upstream is commit `059266225b77c8ca256ac6b25ee5c21449bab151` under the pinned
Bun1.4.3 binary, using the existing Phase105 checked C worker. Both native roles
use the same authenticated Base and carrier/stamp, runtime-source04 object,
QBE binary, assembler and linker. Upstream loads/checks the exact same source
Base. Native process arguments contain the required explicit `phase111` token
after `--`.

Default `cache` measures the normal native prepared-Base workflow against
upstream's normal source-Base workflow, with that persistent-cache advantage
explicit. `--modes live` checks source Base for all roles. Every sample is a
fresh process; OS page caches are not flushed and no warm service/JIT is reused.
One-time image/API/Base/runtime acquisition is excluded from both workflows.
Do not relabel this as cold filesystem execution.

The frozen manifest fixes both images. A later integrated candidate requires an
explicit new manifest and acquisition provenance; never rewrite manifest01 or
silently substitute another executable into its results.

## Run under the coordinator guard

No target was executed by the preparer. The coordinator owns execution:

```sh
python3 -B selfhost/tools/performance/phase86/guard.py \
  --out selfhost/build/phase112/transport01-guard \
  --seconds 600 --rss-mib 4096 --available-mib 16384 --cpu 3 -- \
  python3 -B selfhost/tools/performance/phase112/transport/run.py \
    --out selfhost/build/phase112/transport01 --rounds 3 --modes cache
```

Every output directory is fresh. `--check-only` authenticates inputs and records
zero target jobs. `--rounds 1` is an exploratory diagnostic; three rounds rotate
each case through every role position. The case order also rotates. A separate
live-Base screen can use `--rounds 1 --modes live` and a fresh directory; per-child
30s limits remain unchanged, so preserve a timeout rather than adapting the
benchmark silently. `--manifest NEW_MANIFEST` is the explicit replacement-image
interface. Inputs are verified before and after completed measurement.

All compiler and construction jobs use one blocking `os.wait4` wall timer with
regular-file output. A watchdog thread kills the child process group at the
frozen limit; there is no timeout polling interval in the measured wait. This
avoids using native-emit.py's timeout-polling clock for very short comparisons.
Resource usage comes from that individual child's wait4 result. Outer guard
wall time and source/asset authentication remain separate.

Each of27 samples compiles, builds and executes its fresh product. Native QBE
construction uses the same recipe as Phase111's builder. Upstream uses the
pinned Clang O2 recipe inherited from Phase105 product qualification. Native
runtime code is cached; upstream's emitted C includes its runtime and is fully
recompiled. There is **no upstream PCH/cache equivalence claim**. This comparison
measures those configured build workflows, and must retain that asymmetry. A
matched upstream runtime/PCH experiment requires separately qualified inputs.

## Read the report

`report.json` retains every command, source/tool/image hash, stdout/stderr hash,
exit status, timeout, per-child resources and raw timing samples. Failed stages
stay failed; the runner stops at the first failure. Each emitted representation
must remain byte-identical within its role/case across rounds and modes; different
roles may emit different representations. Every native executable must exit0,
produce the independent complete stdout and produce no stderr.

- `requestSeconds`: complete compiler child, including startup, reads, Base
  preparation, checking/emission, writing and exit. The output target is in each
  stage label. Upstream internal imports/request clocks are diagnostics only.
- `machineBuildSeconds`: sum of fresh QBE/as/link children or the Clang child.
- `readyExecutableStageSumSeconds`: request plus machine-build child clocks;
  excludes Python checks/reporting and generated-program execution.
- `readyExecutableHarnessSeconds`: observed elapsed through executable
  construction, including intervening host bookkeeping after preflight.
- `executionSeconds`: one correctness observation; not a generated-program
  speed benchmark, and not included in construction clocks.

Per-case medians/ranges and all samples precede the explicit three-case geometric
mean. Ratios are our/reference time, below1 faster. No aggregate is emitted for
an incomplete role/case set. Three rounds are a small screen, not confidence
intervals. Use the separate compiled-program campaign to judge execution speed.

## Final evidence sealing

After source and reports stop changing, root runs:

```sh
python3 -B selfhost/tools/performance/phase112/seal-evidence.py plan \
  --out implementation/phase112/evidence/plan01.json
python3 -B selfhost/tools/performance/phase112/seal-evidence.py seal \
  --plan implementation/phase112/evidence/plan01.json \
  --out implementation/phase112/evidence/capsule01.tar.gz
```

Use fresh names on a later attempt. The sealer retains receipts and failures,
source/API identities and bounded diagnostic logs; machine/API/IR payloads stay
local. Its4MiB compressed cap is explicit. See the
[evidence guide](../../../../../implementation/phase112/evidence/README.md).
