# Phase 4 compiler development

Phase 4 investigates structural speedups in the compiler written in Bend.
The [design](../design/phase4/structural_compiler_speed.md) defines the correctness
and measurement gates; the [live report](../implementation/phase4/report.md)
distinguishes accepted changes from experiments. The default distributed API is
still the previously verified release artifact. Select a development API
explicitly when reproducing an experiment.

## Keep the edit loop small

Use a checked source build and focused cases while editing. Full frontend
conformance and checked self-reproduction are integration gates. The Phase 3
workflow already demonstrated a fresh checked B1 build plus 21 focused cases in
36.35 seconds inside its tool; a 33-minute H self-build is a different task.

For ordinary development, run these commands from `selfhost/` with Node 24 and
the pinned upstream checkout available. Choose a new attempt directory after
each compiler edit:

```sh
BEND_UPSTREAM="$PWD/.bootstrap/upstream" \
BEND_TYPED_API="$PWD/build/dev/attempt-01/api.mjs" \
  node --stack-size=4096 --max-old-space-size=4096 \
  tools/typed-driver.mjs --bootstrap

BEND_UPSTREAM="$PWD/.bootstrap/upstream" \
BEND_BASE="$PWD/.bootstrap/upstream/bend2/base.bend" \
BEND_TYPED_API="$PWD/build/dev/attempt-01/api.mjs" \
  node --stack-size=4096 --max-old-space-size=4096 \
  tests/frontend/phase2-rules.mjs build/dev/attempt-01/rules-01.json
```

The first command checks the current Bend sources and records genuine bootstrap
provenance. The second reuses that compiler for 21 live TypeScript/Bend
acceptance and rejection-phase witnesses. When only a fixture changes, reuse the
API and choose a new report filename. Exact diagnostics and wider selections use
[`target.mjs`](PHASE2_DEVELOPMENT.md#select-exact-upstream-probes), with
`"workerMode": "persistent"` in its configuration. These focused commands do not
replace broader frontend and self-reproduction gates.

The [final-source command measurements](../implementation/phase4/development-final.md)
record 20.735 seconds for bootstrap and 16.483 seconds for cold focused
validation: 37.217 seconds of child-process work together. Reusing the checked
API and its validated Base cache gives a 9.328-second median for the full paired
21-case command. The live TypeScript checks and provenance work are included.

The Phase 4 overlay builder takes a frozen baseline and optional replacement
modules, assembles a new compiler, and checks it with the untouched pinned
TypeScript compiler. It checks ownership and completeness before emitting an API.
The build report records source, roots, tool and input identities and revalidates
consumed files after the build. It emits development evidence, not a fabricated
normal-bootstrap sidecar.

Run the overlay example below from the repository root. Its configuration uses
absolute paths:

```json
{
  "baseline": "/work/bend/selfhost/build/phase4/baseline",
  "overlay": "/work/bend/selfhost/build/phase4/my-overlay",
  "upstream": "/work/bend/selfhost/.bootstrap/upstream",
  "extraRoots": []
}
```

The overlay contains only changed modules at their normal paths, such as
`src/core/normalize.bend`. Other modules come from the frozen baseline.

```sh
timeout 180 node --stack-size=4096 --max-old-space-size=3072 \
  selfhost/tools/performance/phase4/checked-overlay.mjs \
  my-overlay-config.json selfhost/build/phase4/my-checked-build
```

Choose a fresh output directory. Keep the report, assembled source, copied
modules and builder snapshot together. A new source edit requires a new checked
build; an older API's success does not validate it.

To recover an unchanged experimental starting point, use the versioned
[checked compiler capsule](../implementation/phase4/final-source-capsule/README.md)
or [private image archive](../implementation/phase4/private-final-images/README.md).
Their extractors verify hashes and refuse an existing destination. Restoration
preserves historical provenance; it does not check new source or fabricate a new
bootstrap. The archives document canonical Base and original path requirements.

## Run the full frontend gate with four workers

After the focused cases pass, the existing persistent harness can schedule the
full parse/check inventory across four physical cores. From `selfhost/`, reuse
the checked API from the edit-loop example, prepare its validated Base cache,
and freeze the host adapter before starting:

```sh
export BEND_UPSTREAM="$PWD/.bootstrap/upstream"
export BEND_BASE="$PWD/.bootstrap/upstream/bend2/base.bend"
export BEND_TYPED_API="$PWD/build/dev/attempt-01/api.mjs"
export BEND_TYPED_RUNTIME="$PWD/src/runtime.mjs"
node --stack-size=4096 --max-old-space-size=4096 tools/typed-driver.mjs --prepare-base
phase4_adapter="$(node tools/conformance/freeze-adapter.mjs)"
taskset -c 0,1,2,3 node --stack-size=4096 --max-old-space-size=4096 \
  tools/conformance/run.mjs --upstream "$BEND_UPSTREAM" \
  --adapter "$phase4_adapter" --lanes parse,check --jobs 4 \
  --worker-mode persistent --recycle-after 64 --rss-limit-mb 4096 \
  --timeout 300000 --stack-kb 4096 --heap-mb 4096 --retain failed \
  --output build/dev/attempt-01/frontend-01.json
```

Choose four available physical cores on your machine; `0,1,2,3` is the measured
machine's mask. All workers share that mask rather than each being pinned to one
core. Keep the selected API, runtime, Base, fixtures and harness unchanged for
the whole run. Use a fresh output path. A nonzero harness exit can report
retained conformance failures; inspect the full report and never reinterpret
those failures as successful checks. Request deadlines, failed reproductions,
worker recycling and replay histories still apply.

[P4-021](../implementation/phase4/frontend-scheduling.md) measures a frozen
historical final B1 with 1,378 fixtures / 2,756 observations and a previously
validated Base cache. An otherwise-idle serial run took 1,036.017 seconds;
four-worker runs before and after took 299.376 and 297.699 seconds. That is
**3.47× full-gate throughput using four cores**, with every raw result, harness
verdict and worker history verified. The same 377 known failed checks remain
failed. These measurements exclude a new source bootstrap and do not establish
correctness of future edits. The command above
selects your newly checked development API; its report supplies its own inputs
and outcomes. The experiment's separate prepare/run/compare recipe freezes the
entire historical harness and verifies every recorded worker history.

## Profile representative requests

Use the bounded sampling wrapper for small successful programs:

Run this command from the repository root:

```sh
node selfhost/tools/performance/phase4/bounded-profile.mjs \
  my-profile-config.json selfhost/build/phase4/my-profile
```

The profile configuration supplies `api`, `driver`, `base`, `runtime`, `input`,
`mode`, and optionally `cpu`, `intervalUs` and `profileTimeoutMs`. Relative file
paths resolve against the configuration. `mode` is normally `compile`;
`intervalUs` defaults to 1,000. The wrapper limits the root input to 128 KiB and
the diagnostic deadline to at most three minutes, uses a 3 GiB Node heap, and
kills the child process group on timeout. It records incomplete runs explicitly.

One full-source 1 ms inspector profile hit a 30-minute deadline while other
experiments experienced resource disruption. Its timings were discarded.
Deep recursive profiles can be expensive even when the underlying compilation
finishes normally without sampling. Keep large builds outside the sampler.

The profiler primes Base and discovers dependencies before sampling. Its API
spans include host argument conversion, and its CPU samples include profiler
overhead. Use it to locate costs, then use uninstrumented alternating fresh
processes for performance claims. A profile duration is not a benchmark result.

## Run a private compiler image

The private compiler places the compiler behind a dedicated process
boundary accepting data-only file/mode requests. Its internal function objects
do not enter or leave that process. This permits experiments with simpler private
calls and projections while ordinary emitted libraries retain their existing ABI.

From the repository root, build it from a completed checked self-reproduction report:

```sh
node --stack-size=4096 selfhost/tools/private-compiler/build.mjs \
  PROOF/report.json PROOF/stage2.mjs PROOF/runtime.mjs NEW_IMAGE_DIRECTORY
node selfhost/tools/private-compiler/run.mjs NEW_IMAGE_DIRECTORY \
  /absolute/main.bend compile NEW_RESULT_DIRECTORY
```

For the reviewed Phase 4 H (`b33b38e3…`), append
`--profile=phase4-boolean-stable` to the build command to select the tested
Boolean/stability specialization. It reproduces private image `4318bbcd…`;
omitting the option retains default `61e7d94c…` for that H. The opt-in profile
rejects other H revisions and retains the same worker boundary. Its full-source
comparison found 2.28% lower mean process wall, with visible variation and 3.16%
higher mean maximum-child RSS. The [final gates](../implementation/phase4/private-frontend-final.md)
include unchanged frontend observations, exact full H emissions, 25 package
checks and seven profile guards. This option is independent of the ordinary B1
edit workflow above.

For a focused group, use one finite batch. This amortizes compiler loading and
artifact verification while retaining an external deadline for every request:

```sh
node selfhost/tools/private-compiler/batch.mjs NEW_IMAGE_DIRECTORY \
  REQUESTS.json NEW_BATCH_DIRECTORY --recycle=32 --timeout-ms=120000
```

`REQUESTS.json` contains at most 256 records, for example
`[{"input":"/absolute/main.bend","mode":"check"}]`. Each request creates a fresh
source graph. Keep its inputs unchanged until its worker finishes; outputs are
published only after identity verification. A failed request remains failed,
and later requests can continue in a new worker. Parse/type rejections remain
ordinary compiler observations. See the [tool guide](../selfhost/tools/private-compiler/README.md)
for modes, resources, reports, proof requirements and retained failure behavior.

The [controlled 21-case comparison](../implementation/phase4/private-cli.md)
measured 17.524 seconds for one private H batch versus 43.023 seconds for separate
private CLI invocations. Checked B1 in a reused process remained faster at
7.850 seconds. Choose B1 for routine source development; private H is useful
when the compiler itself must run from Bend-emitted code. These numbers use
previously validated Base caches and exclude rebuilding the compiler.

Do not import a private image as an ordinary public library or apply
its transformations to arbitrary generated programs. Existing public function
objects, accessors, partial applications, and argument ownership have observable
behavior. The worker boundary is part of the optimization's correctness contract.

## Compare the right quantities

[`compiler-compare.mjs`](../selfhost/tools/performance/phase4/compiler-compare.mjs)
extends the Phase 3 exact compiler comparison with asynchronous file-backed child
supervision and checked-overlay provenance. Configure the same canonical Base,
host, runtime and workloads for each Bend compiler; retain pinned TypeScript as
a separate reference variant. Every compiler gets its own validated Base cache,
prepared in a separate process before timed requests. Variant order alternates.

Report request work, process wall, generated-program execution and rebuild cost
separately. Require exact outcomes and, for compiler algorithms intended to
preserve emission, identical Bend output bytes. A microbenchmark of one helper
does not establish a whole-compiler speedup. Retain failed and excluded samples
with their reasons rather than silently dropping them.
