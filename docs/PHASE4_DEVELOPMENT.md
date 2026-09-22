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

The Phase 4 overlay builder takes a frozen baseline and optional replacement
modules, assembles a new compiler, and checks it with the untouched pinned
TypeScript compiler. It checks ownership and completeness before emitting an API.
The build report records source, roots, tool and input identities and revalidates
consumed files after the build. It emits development evidence, not a fabricated
normal-bootstrap sidecar.

Example configuration, using absolute paths:

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

## Profile representative requests

Use the bounded sampling wrapper for small successful programs:

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

## Separate compiler images from public libraries

The private-image experiment places the compiler behind a dedicated process
boundary accepting data-only file/mode requests. Its internal function objects
do not enter or leave that process. This permits experiments with simpler private
calls and projections while ordinary emitted libraries retain their existing ABI.

These artifacts are explicitly experimental until the report records their
final gates. Do not import a private image as an ordinary public library or apply
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
