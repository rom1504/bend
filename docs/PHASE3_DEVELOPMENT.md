# Phase 3 compiler efficiency workflow

Phase 3 makes the Bend-in-Bend compiler cheaper to validate and improves the
runtime used by emitted JavaScript. The reference behavior remains the
isolated conformance runner and the pinned TypeScript compiler at revision
`6018e28ecc67cf1fffc0c20c64b11023474c2df8`.

Build a fresh candidate API to exercise source optimizations. Keep the resulting
bootstrap provenance sidecar with it and select it explicitly when validating:

```sh
BEND_UPSTREAM=/absolute/path/to/pinned-bend \
BEND_TYPED_API=selfhost/build/phase3/my-candidate/api.mjs \
  node selfhost/tools/typed-driver.mjs --bootstrap
BEND_TYPED_API=selfhost/build/phase3/my-candidate/api.mjs \
  node selfhost/cli.mjs selfhost/tests/conformance/typed-smoke/base-u32.bend --check-only
```

The distributed default API remains the previously verified release artifact.
A checked B1 bootstrap and a self-emitted fixed point establish different gates.

## Fast repeated validation

Use persistent workers only for parse and check lanes. Each scheduling slot has
one worker, each request receives a new source graph and work directory, and
the worker is recycled after a bounded request count or RSS limit. Results are
never served from a request cache. The runner records the worker generation,
session index, RSS and startup attribution in the report.

```sh
node selfhost/tools/conformance/run.mjs \
  --upstream /absolute/path/to/pinned-bend \
  --adapter selfhost/tools/conformance/adapters/typed.mjs \
  --lanes parse,check --worker-mode persistent --jobs 4 \
  --recycle-after 64 --rss-limit-mb 1024 \
  --output selfhost/tests/conformance/typed-phase3.json
```

Persistent mode rejects a selected lane that the adapter has not declared
safe. Run interpreter and backend execution lanes in the default isolated mode.
Timeouts, malformed completions, output overflow and worker crashes kill the
whole worker process group. A retained persistent request stores its session
prefix; `replay.mjs REQUEST.json` reconstructs that prefix before checking the
requested result. Pass `--isolated` when a fresh one-request replay is desired.

The worker protocol is bounded at 16 KiB for commands, requests and completions,
4 MiB for responses, and 1 MiB for combined logs. Completion requires both output
stream boundaries and a matching response hash. Replay validates a chained digest
of the original request/result prefix and the recorded worker identity. Requests are sent through an
atomic file queue, while the worker's FD3 completion is consumed when the host
provides it. This keeps the protocol usable under supervisors that close
inherited stdin without weakening the process-group deadline.

## Reusing a native compiler build

The checked Bend emission and native C compilation are separate artifacts. Once
a checked `.c` file and its source provenance exist, the content-addressed
cache avoids repeating Clang work:

```sh
node selfhost/tools/performance/rapid/native-compiler-cache.mjs \
  checked-compiler.c compiler-O1 build/native-compiler-cache \
  --opt=O1 --timeout-ms=180000
```

The cache key includes the C source and canonical path, preprocessed headers,
native build plan, selected Clang executable hash and full version, optimization
level, relevant environment and both build-tool hashes. Every lookup runs the
preprocessor; a hit revalidates the record and binary before publishing a fresh
output. A corrupt or concurrently locked entry fails closed. This is a host-local
cache: system linker and libraries must remain stable. It does not claim a
hermetic toolchain. Source and header changes require new Bend emission/checking
evidence where applicable, even when native caching is enabled.

The [complete native graph recipe](../selfhost/tools/performance/rapid/native-graph.md)
connects checked emission, this cache and validation. Its validation and latency
tools accept both cache reports and legacy C-build reports. A cache hit leaves
the original compilation duration unknown; it is never reported as a zero-cost
original build.

For a new compiler source, use the checked component/native-bundle preparation
tools first; do not treat a cached binary as evidence that checking or Bend
emission ran for the new source.

## Generated-program string comparisons

The JavaScript runtime now compares UTF-16 strings in one pass over code points,
without constructing two `Array.from` arrays. It preserves the `String.cmp`
return shape and only reports malformed UTF-16 when comparison reaches the bad
code unit. The canonical fragments are
`selfhost/src/runtime/js/core.mjs` and `base.mjs`; regenerate
`selfhost/src/runtime.mjs` with:

```sh
node selfhost/src/runtime/js/build.mjs
```

Compiler throughput and generated-program runtime must be measured separately.
The runtime kernel probe is useful for the latter, while compiler comparisons
must use alternating fresh processes, identical Base/workloads, fixed and hashed
API identities per variant, and a consumed output checksum.

## Correctness gates

The source optimizations keep the old diagnostic and analysis paths available
as conservative fallbacks. The exact checker verdict remains authoritative;
detailed diagnostic replay is used only when it independently reproduces that
verdict. Before broad conformance, run the checked assembled-source gate and
the component/harness tests:

```sh
node selfhost/tools/assemble.mjs --output /tmp/compiler-phase3.bend
node --test selfhost/tests/conformance/abi.test.mjs \
  selfhost/tests/conformance/inventory.test.mjs \
  selfhost/tests/conformance/judge.test.mjs \
  selfhost/tests/conformance/selection.test.mjs \
  selfhost/tests/conformance/persistent-worker.test.mjs \
  selfhost/tests/native-build.test.mjs \
  selfhost/tests/native-compiler-cache.test.mjs
```

On Linux, the self-host proof reads the actual process stack limit from
`/proc/self/limits`; the OS soft limit must be at least twice the configured V8
stack. A candidate API is selected explicitly, and stage2/stage3 must compile
the same frozen checked source into byte-identical libraries. This is a batch
integration gate. Use checked components and targeted worker requests during
normal editing.

The native backend changes preserve C bytes. Scalar direct-call specialization,
checker suffix indexing, and emission fact caches remain disposable experiments;
their measured gains and correctness limitations are documented in the report.
Do not apply the scalar transform to a production artifact: a retained primitive
accessor exposes a semantic mismatch.

The full measurements, source identities, failed hypotheses and known test
limitations are recorded in
[`implementation/phase3/report.md`](../implementation/phase3/report.md).

## Measured iteration and comparison recipes

The [cold checked-build loop](../selfhost/tools/performance/phase3/cold-edit-loop.md)
rebuilt the complete compiler and ran 21 focused live paired cases in 36.35 seconds
inside the tool. Source assembly and Node startup are outside that measurement;
the compiler-side Base cache starts absent. Use this bounded workflow while
editing, then run the self-emission proof after integration.

The [four-way compiler comparison](../selfhost/tools/performance/phase3/final-compiler-compare.md)
separates historical H, current H, checked B1 and pinned TypeScript. On its final
samples, the slow exact rejection improved 11.54x, while positive compilation
was essentially unchanged. The [full-source TS control](../selfhost/tools/performance/phase3/final-fullsource-typescript.md)
records identical input/root policies and the limits of comparing separately
run compilers. Always report request work, process wall and generated-program
execution separately.
