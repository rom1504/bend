# Compiler and generated-program benchmarks

`bench.py` is the maintained entry for **prepared program execution** and **fresh
compiler requests**. It does not build a compiler, select a release, download
assets, silently acquire missing products or read a historical phase tool.
Build/acquisition and timing are separate. `acquire.py` delegates to maintained
build tools and automatically freezes catalog products; prepared products can
also be frozen directly with an explicit recipe.

The migration preserves the existing JS timing worker, V8 CPU/allocation worker,
JavaScript AST analyzer, original45 and historical15 catalogs, and native
complete-output/count protocol. Native C and QBE use the same timed wrappers and
runner. Their compiler/runtime/toolchain remain explicit role metadata.
`migration-map.json` records original paths, hashes and new ownership; it is a
recovery record, not an operational dependency on those paths.

For handwritten C versus our maintained QBE and C backends, use the
[runtime-only comparison workflow](handwritten-c/README.md). It preserves all45
native inputs/oracles but calibrates repetitions per role, reporting a new
normalized time-per-invocation metric separately from the fixed-count score
documented below. Acquisition and timing remain separate guarded jobs.

## Catalogs and oracles

| Catalog | Contract |
| --- | --- |
| `catalogs/original45/catalog.json` | Original45 fixed JS points across23 sources, exact arguments/scalar or serialized results and original named sets. Catalog bytes and fixture bytes are unchanged. |
| `catalogs/historical15/catalog.json` | Separate older15-point JS catalog; not a substitute for original45. |
| `catalogs/native45/catalog.json` | Exact45 native repetition wrappers and independent complete stdout;44 timing-eligible points and one zero-work correctness control. |

The native catalog retains the qualified50ms reference count profile multiplied
by4 and its warmups. These are explicit fixed work amounts, not new measurements
or a guarantee of200ms on another machine. `--scale` can increase native work
uniformly for all roles; it never changes the input point or expected result.
Native intervals below100ms are flagged and excluded from ratios. Zero-work
controls execute and validate but never contribute a timing ratio.

Native timed wrappers differ from the small ordinary45 conformance inputs.
Both must remain available; successful one-shot ordinary executions do not
replace generated-program timing. Catalog upstream revisions describe historical
fixture provenance. Current compiler/reference revisions belong in role inputs;
the runner does not infer them from a catalog's historical revision.

## Prepare and plan without running targets

A recipe names roles and already built artifacts. File references are paths or
`{file, bytes, sha256}` pins; relative paths resolve against the recipe file.
Supplying an existing pin requires exact agreement. `freeze` pins every declared
input and the consumed methods, validates the independent catalog and writes a
new manifest. Changing a consumed method requires a new manifest.

For example, a native program recipe can contain:

```json
{
  "kind": "programs",
  "cwd": "/absolute/repository",
  "catalog": "/absolute/repository/selfhost/tools/bench/catalogs/native45/catalog.json",
  "reference": "upstream",
  "roles": {
    "upstream": {"host": "typescript-bun", "stage": "upstream", "target": "c", "preparation": "prepared-artifact", "policy": "ordinary", "status": "reference", "inputs": ["/absolute/reference-build-receipt.json"]},
    "candidate": {"host": "native", "stage": "N2", "target": "qbe", "preparation": "prepared-artifact", "policy": "ordinary-serial", "status": "qualified", "inputs": ["/absolute/candidate-build-receipt.json"]}
  },
  "cases": [{
    "id": "coverage-numeric-recurrence-256",
    "products": {
      "upstream": {"artifact": "/absolute/reference-program", "generatedSource": "/absolute/reference.c"},
      "candidate": {"artifact": "/absolute/candidate-program", "generatedSource": "/absolute/candidate.ssa"}
    }
  }]
}
```

Role fields `compiler`, `runtime`, `engine`, and `qualification`, when supplied,
are pinned files. `inputs` binds toolchains, flags/build receipts, Base and other
operational assets. **A supplied `status` label is not independently established
by benchmarking:** preserve the actual qualification receipt. Prototype products
must remain labeled prototypes. JS roles additionally require a pinned Node24+
`engine` and `emitter: "selfhost"` or `"upstream"` for syntax diagnostics.

```sh
python3 -B selfhost/tools/bench/bench.py freeze --recipe recipe.json --out manifest.json
python3 -B selfhost/tools/bench/bench.py run --manifest manifest.json \
  --cases coverage-numeric-recurrence-256 --budget 20 --plan
python3 -B selfhost/tools/bench/bench.py list \
  --catalog selfhost/tools/bench/catalogs/original45/catalog.json
```

Partial acquisition does not shrink a named catalog set: selecting a set with
missing products fails. Choose its explicit acquired case IDs, or acquire all
members first. This prevents an incomplete broad run becoming a favorable small
score under the same name.

## Run with one resource supervisor

The benchmark child loop measures fresh process clocks and cleans up process
groups. Memory, disk, available-memory reserve and CPU affinity are enforced by
the **single outer** maintained guard; do not nest another guard in role commands.
The runner requires `--guarded` and exact requested CPU affinity. This flag is an
explicit caller contract, not an automatic proof that a guard exists.

```sh
python3 -B selfhost/tools/build-retention/guard.py \
  --out selfhost/build/my-benchmark-guard \
  --run-root selfhost/build/my-benchmark --disk-mib 512 \
  --seconds 30 --rss-mib 2048 --available-mib 16384 --file-mib 128 --cpu 3 -- \
  python3 -B selfhost/tools/bench/bench.py run --manifest manifest.json \
    --cases coverage-numeric-recurrence-256 --budget 20 \
    --guarded --out selfhost/build/my-benchmark
```

All output paths must be new. Keep clean execution free of sampling/preload/event
variables. Compiler emission, machine construction and diagnostic profiling have
their own budgets and receipts.

| Budget ceiling | Default set | Default rounds | JS minimum warmup | JS timed block |
| ---: | --- | ---: | --- | ---: |
|20s|fast|3|3 calls and100ms|50ms|
|60s|core|3|3 calls and350ms|150ms|
|300s|broad|5|3 calls and600ms|250ms|
|600s|full|5|3 calls and1,000ms|300ms|

These retain the original JS presets. Raytrace retains one warmup call plus the
time floor and at most three JS rounds. Native programs use explicit catalog
counts and do not inherit V8 warmup assumptions. `--set`, `--cases`, `--rounds`
and `--scale` expose workload/depth choices separately. For balanced position
coverage choose a round count divisible by the number of roles; default3 rounds
is not position-balanced when four roles are requested, and makes no such claim.

The ceiling includes manifest checking, startup, calibration, validation and
reporting, with any cleanup overrun reported. It is not a portable coverage/time
promise. Roles rotate serially. Failed, timed-out, partial and low-resolution
observations remain visible; incomplete cases have no comparison ratio. The
aggregate requires every selected timing-eligible case. Ratios never use an old
timing as denominator. Reports include equal-point geometric mean, positive log
slowdown, per-family ratios and individual samples. Small samples are screens,
not confidence intervals or proof of stabilized V8 performance.

## Cold compiler timing and bootstrap dimensions

Use `kind: "compiler"`. Each case contains `source` and a `requests` mapping for
every role. A request supplies an argv vector, `scope: "request"` or
`"source-to-executable"`, explicit empty-or-exact `stderr`, and an independent
`stdout` and/or `product` oracle. Tokens `{source}`, `{output}` and `{work}` are
replaced as complete argv elements; shell strings are never evaluated. Pin every
script, image, runtime, toolchain, Base/carrier and input dependency in role or
request `inputs`. Other argument paths must already be absolute or valid under
the recipe's explicit `cwd`.

```json
{
  "id": "lexer-request",
  "source": "/absolute/lexer.bend",
  "requests": {
    "candidate": {
      "scope": "request",
      "command": ["/absolute/native-compiler", "--threads", "1", "--gpu", "off", "--", "phase111", "{source}", "/absolute/prepared-base", "cache", "/absolute/carrier", "EXACT_STAMP"],
      "stdout": "/absolute/independent-complete-output.ssa",
      "stderr": "/absolute/expected-empty.stderr",
      "inputs": ["/absolute/prepared-base", "/absolute/carrier"]
    }
  }
}
```

Compiler recipes also supply roles, reference, cases and optional case sets like
the program recipe. Each request runs in a new child process. Complete output
comparison, including EOF, occurs after the recorded child clock and uses bounded
streaming. Request and complete-build scopes cannot be compared within a case.
This runner records process wall/CPU/RSS, not an invented internal compiler-only
clock. Finer stage clocks belong to the existing profiler's exact stage workflow.

Name compiler **host**, **output target**, **generation lineage**, **preparation**
and **policy** independently. Native N1/N2 are not renamed upstream-produced
B1/B2. Prepared versus live Base are different workflow comparisons. Ordinary
versus session outputs require mode-matched oracles. Cold means a fresh process
without source-specific semantic/object reuse; OS caches are not flushed.
Source-to-executable requests must invoke fresh machine construction, not a cached
object. The generic runner cannot prove these semantic properties from argv;
the frozen acquisition/command recipe and reviewer establish them.

## Profiles and generated-code inspection

`diagnostics.py --manifest … --cases … --kind all --budget 60 --out FRESH`
prepares ordered diagnostic jobs without executing targets. Supply `--sampler`
for native CPU profiles. Run those jobs under one separate outer guard/deadline.
The program timing report is never amended with diagnostic clocks.

JS jobs reuse the exact V8 CPU/allocation worker and Acorn AST/token/source
comparison, including HTML comparison. The analyzer pins the embedded Acorn
version; use its recorded Node24.18.0 rather than silently falling back to regex.
Native jobs delegate to `tools/profiler/` for sampling, mapping, comparison and
reporting. Low main-thread coverage remains a failed attribution gate; use the
profiler's explicit runtime/event/owner/stage workflow for richer evidence.
The benchmark front door does not invent allocation information without hooks.

`inspect.py --target c|qbe --source FILE --binary ELF --out FRESH` records
**lexical** source counts plus exact ELF disassembly/symbol/section output.
`--compare-source` adds a second source with explicit identities. C/QBE lexical
occurrences are not an AST, static legality proof or dynamic cost measurement.
JS retains its stronger existing parser-based inspection. None of these tools
executes the inspected ELF.

## Acquire selected cases from current build assets

`acquire.py` fills the complete case/role product map from one small role recipe.
It calls maintained `build/request.py` and `build/native.py`, or the pinned upstream
public TypeScript APIs in `upstream.mjs`; C machine construction uses the explicit
asset manifest's C toolchain policy. Compiler algorithms are never reimplemented
in the benchmark shell. It performs one independent scalar/full-output/count check
before freezing either manifest. Acquisition has a separate deadline and is excluded
from the 20/60/300/600 second execution budgets.

An executable current-assets example compares upstream C with native N2 QBE:

```sh
python3 -B selfhost/tools/bench/acquire.py \
  --recipe selfhost/tools/bench/examples/acquire-native.json \
  --cases mandelbrot \
  --out selfhost/build/bench-acquire01 --seconds 600 --plan
```

Replace `--plan` with `--guarded --cpu 3` **inside the outer resource guard** to
acquire. Use the actual catalog IDs shown by `bench.py list`; `--set full` selects
all original45 points without writing 45 product entries. Each role declares its
assets manifest, actual host/stage/target, image key (or image+binding receipt),
preparation mode, policy and status. An explicit reference checkout must match the
asset manifest's upstream revision and have clean tracked `bend2` sources.

Successful acquisition writes `programs.manifest.json`, ready for:

```sh
python3 -B selfhost/tools/bench/bench.py run \
  --manifest selfhost/build/bench-acquire01/programs.manifest.json \
  --cases mandelbrot --budget 20 --rounds 2 \
  --out selfhost/build/bench-run01 --guarded --cpu 3
```

That run also belongs inside its own outer guard. A partial acquisition preserves
the full named catalog sets; it does not turn two acquired cases into a full score.
For JS use `catalogs/original45/catalog.json`, target `js`, own hosted image+binding
and `mode: live`, and an explicit Node `executionEngine` for every role. Own emission
uses the checked public library operation; upstream uses checked `js_lib(book,true)`.
The scalar point and all timings stay in the same maintained JS worker.

`examples/acquire-compiler-qbe.json` acquires the same wrappers through explicitly
bound B1 and N2 QBE images. It writes `compiler.manifest.json` as well as program
products. Each cold sample directly starts the underlying native image or hosted
adapter, writes fresh output, and must reproduce the complete independently
execution-checked emitted product. This is a whole-child request clock: hosted
adapter identity checks and engine startup are included, and OS caches remain.
It is distinct from pure frontend/emitter CPU time or source-to-executable time.
Mixed-target compiler recipes describe different backend work; do not interpret
those ratios as same-target compiler parity.

Native-C cold replay starts the native image directly, transports the authenticated
five runtime parts before timing, and gives each sample a fresh output prefix.
After the child clock stops, the runner checks the complete `.1.c` product and
empty stdout, then reuses the maintained build adapter's strict telemetry/verdict
parser for stderr. No Python acquisition/preflight time enters that child clock.
An unrecognized output protocol fails rather than borrowing another timing scope.

## Migration validation

```sh
python3 -B -m unittest discover -s selfhost/tools/bench -p 'test_*.py'
node selfhost/tools/bench/js/execute.test.mjs
node --test selfhost/tools/bench/js/analyze.test.mjs selfhost/tools/bench/js/profile.test.mjs
```

The Python controls are offline. JS controls execute only synthetic modules;
they do not compile or run Bend programs. The actual two-case native acquisition,
C/QBE program timing and fresh compiler-request smoke passed: see the
[smoke report](../../../implementation/repository-consolidation/benchmark-tools.md)
and `validation.json`. This is not a full45 score or same-target compiler parity;
the reference emits C and the N2 candidate emits QBE. Real JS acquisition/timing,
native-C telemetry replay and same-target B1/N2 coverage retain their own gates.
Exact catalog/worker copies preserve inputs and mechanisms without enlarging
what these bounded smokes prove.
