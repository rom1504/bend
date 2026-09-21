# Full-suite conformance harness

This directory is testing infrastructure, not a compiler. The upstream checkout
is read only, and must match `6018e28ecc67cf1fffc0c20c64b11023474c2df8`.
Every `.bend` file under upstream `tests/` is discovered recursively, including
imports, foreign effects, proofs, malformed syntax and declaration-only tests.
`#|` lines are the oracle. Namespace names do not determine error phases.

```sh
node --test tests/conformance/judge.test.mjs
BEND_UPSTREAM=/path/to/upstream node tools/conformance/run.mjs
node tools/conformance/run.mjs --adapter /path/to/port-adapter.mjs --output tests/conformance/full-port.json
```

The command returns nonzero unless **every applicable lane** passes on the full
suite. Unsupported capabilities, hardware gates, timeouts, crashes and filters
cannot make an incomplete compiler look complete. The default is the explicitly
unchecked prototype adapter. Its successful JS executions are output evidence,
never evidence of dependent, affine, termination or proof checking.

`--jobs 8` controls concurrency, `--timeout 5000` bounds each entire probe,
`--filter REGEX` selects test IDs, and `--lanes parse,check,interpreter,js,native`
selects lanes. Filters are useful for development but never establish completeness.
Each probe executes in a new process group and temporary working directory;
timeouts kill the group, including subprocesses. Output is bounded to 1 MiB.
Input source remains at its original location so module and foreign paths resolve
normally. Generated artifacts and effect-created relative files belong in the
temporary working directory. GPU probes require explicit `--gpu metal` or
`--gpu cuda`, compatible host hardware, and adapter evidence of GPU execution;
CPU fallback cannot pass a GPU probe.

## Adapter protocol

An adapter ES module exports `name`, `capabilities`, and `async probe(request)`.
Importing it should only inspect configuration, not run the compiler. The request
contains `test`, `lane`, absolute `project`, `upstream`, and `workdir` paths, and
`timeoutMs`. The test includes `id`, absolute `file`, `expected`, `negative`,
`main`, `base`, module imports, foreign imports and backend eligibility.

```js
export const name = 'full-port';
export const capabilities = {
  parse: true, check: true, interpreter: true, js: true, native: true,
  metal: false, cuda: false,
  modules: true, foreign: true, dependentTypes: true,
  affine: true, termination: true, proofs: true,
};
export async function probe(request) {
  // Invoke the implementation under test. Do not return expected fixture text.
  return {status: 'ok', phase: 'runtime', stdout: '42\n', stderr: '',
    exitCode: 0, checked: true};
}
```

Result statuses are `ok`, `error`, `unsupported`, `timeout`, and `crash`. Phases
are `load`, `parse`, `check`, `compile`, and `runtime`. `checked: true` means the
real checker reached this program, including on checker rejection. It must never
be set merely because a parser accepted source or an emitter erased annotations.
`diagnostic` holds rendered language diagnostics; `stdout` holds execution output.
The typed adapter also returns `output`, captured by sharing one file descriptor
between runtime stdout/stderr so their original write order is preserved.
The judge normalizes trailing whitespace just as upstream does and appends
`exit N` on nonzero exit, unless already present. Do not merge unrelated compiler
warnings into program stdout. Nonzero exits never disappear from comparison.

The upstream gate's “check” probe also interprets `main`, so its `Error:` fixtures
can fail during loading, parsing, checking, compilation or runtime. An adapter
should report the actual stage. Every negative requires the exact expected
diagnostic and exit behavior. Matching frontend errors are labeled
`frontend-rejection`, and matching compile/runtime errors have their own labels.
Only `checker-rejection` contributes to the checker rejection count. Successful
checking of declaration-only tests must return upstream's declaration report.

Every fixture with main, including expected failures, receives an interpreter lane.
Expected failures are also compiled when eligible, so runtime-negative programs
are not silently omitted. A check-only acceptance on a runtime-negative fixture
requires phase-specific triage; it is not by itself a checker soundness failure.
Positive fixtures require separate checking and interpreter lanes. Compiled lanes
use the upstream eligibility rules: `import Base`, a `main` declaration and a
matching foreign-language twin where foreign imports exist. The upstream's exact
checked `Error: main's type ... cannot be printed` refusal exempts a compiled
lane; arbitrary unsupported-type errors do not. No whole namespace is excluded.

For separate frontend/core/backend adapters, use `adapters/pipeline.mjs`:

```sh
BEND_CONFORMANCE_FRONT=/path/front.mjs \
BEND_CONFORMANCE_CORE=/path/core.mjs \
BEND_CONFORMANCE_BACKEND=/path/backend.mjs \
node tools/conformance/run.mjs --adapter tools/conformance/adapters/pipeline.mjs
```

The frontend exports `load(request)` returning `{status, program, ...}`. The core
exports `validate({...request, program})` and `interpret({...request, program})`;
validation may return a replacement `program`. The backend exports
`execute({...request, program})`, using `request.lane` to select JS/native/GPU.
Each exports its own `capabilities`. These calls all run inside one isolated
worker, so rich in-memory ASTs need not be JSON-serializable. For upstream's
negative fixtures requiring interpreter/backend diagnostics after checking,
implement the single-module adapter protocol directly.

## Reports and provenance

The JSON report records every discovered source hash, source implementation
inventory, support/effect files, every probe result, timestamps, Node/platform,
adapter capabilities, and prototype compiler/runtime hashes. `complete` is a
strict all-suite verdict. Summaries retain unsupported and gated counts rather
than dropping them from denominators.

`tests/conformance/prototype-baseline.json` is the captured baseline. It used
immutable temporary copies of the dist compiler and runtime, avoiding concurrent
compiler changes during the run. The full report contains exact hashes; those
temporary paths need not exist when reading the report. To reproduce against
specific artifacts set `BEND_CONFORMANCE_COMPILER` and
`BEND_CONFORMANCE_RUNTIME`. To regenerate the human-readable matrix:

```sh
node tools/conformance/report.mjs tests/conformance/prototype-baseline.json
```

## Typed compiler adapter

```sh
node tools/typed-driver.mjs --bootstrap
node tools/typed-driver.mjs --prepare-base
node tools/conformance/run.mjs --adapter tools/conformance/adapters/typed.mjs --timeout 300000 --output tests/conformance/typed-full.json
```

Bootstrap alone invokes the pinned upstream compiler. Normal checks, interpretation,
and both emitters call the generated Bend implementation. `BEND_TYPED_API` and
`BEND_TYPED_RUNTIME` select immutable artifacts for independent runs. Bootstrap
reports preserve the exact module bytes and assembled source in a hashed snapshot.
The Base cache is produced by the new checker and bound to compiler and Base source
hashes. Seeded loading additionally checks canonical Base path and exact source text
in Bend; checking reuses the prefix only after structural equality of every core
field. No names or native flags alone authorize skipping a check.

Each current run writes a `.progress.jsonl` next to its report. A partial progress
file is evidence only for its completed rows and never a complete-suite result.
Historical baseline reports retain their original probe inventory; newer runs also
include interpreter/backend lanes for expected-error fixtures.

Before a long run, `node tools/conformance/freeze-adapter.mjs` snapshots the IO
shell and prints an adapter path for `--adapter`. Use absolute API/runtime paths
and that frozen adapter so concurrent development cannot change a running suite.

## Checked self-hosting fixed point

For an existing successfully emitted compiler seed, the direct gate avoids
repeating its original generation. It runs every ordinary checking and emission
phase, then requires the result to be byte-identical to the seed:

```sh
BEND_TYPED_RUNTIME=/absolute/path/to/frozen-runtime.mjs \
BEND_SELFHOST_DRIVER=/absolute/path/to/frozen-host/typed-driver.mjs \
BEND_SELFHOST_SEED_REPORT=/absolute/path/to/seed-emission-report.json \
node tools/conformance/verify-seed.mjs compiler.bend seed.mjs build/typed/seed-proof
```

The report records both the seed's original host and the verification host,
including the ABI adapter dependency. The condition is `B = H(B, S)` for frozen
compiler `B`, source `S`, and host `H`. The host that originally produced the seed
may differ. Failed earlier attempts remain separate evidence.
Foreign-function metadata embeds canonical source paths. Moving a checkout can
therefore change emitted bytes while preserving behavior; generate a local seed
with the successive-stage runner below before checking a relocated environment.

The self-host runner gives child Node processes a 4 MiB V8 stack and verifies
that the operating-system stack limit is at least 8 MiB. Ordinary CLI commands
retain Node's default stack. The report records the exact resource configuration.
Set `BEND_SELFHOST_STACK_KB` to change this limit (zero uses Node's default).
Set `BEND_SELFHOST_HEAP_MB` to configure Node's old-generation heap limit;
this also appears in the recorded launch arguments. Full compiler annotation can
exceed Node's default 4 GiB heap, so use a host with sufficient physical memory.
`BEND_SELFHOST_RESUME=3` or `4` resumes from existing verified stage outputs;
it verifies source, runtime, driver and compiler hashes and preserves the earlier
attempt and log before restarting. No checking or emission gate is skipped.

```sh
BEND_TYPED_API=/absolute/path/to/bootstrap-api.mjs \
BEND_TYPED_RUNTIME=/absolute/path/to/frozen-runtime.mjs \
BEND_SELFHOST_DRIVER=/absolute/path/to/frozen-host/typed-driver.mjs \
BEND_SELFHOST_HEAP_MB=12288 BEND_SELFHOST_TIMEOUT=10800000 \
node tools/conformance/selfhost.mjs /absolute/path/to/compiler.bend build/typed/fixedpoint
```

This compiles the same source twice, using the generated stage2 library as the
compiler for stage3. Every stage performs actual checking through the ordinary driver.
The report includes source/runtime/driver/API/output hashes and per-stage logs, and only
reports completion only if both emitted libraries are byte-identical. This is the
fixed-point gate: the resulting compiler reproduces its own bytes from the same
source. `BEND_SELFHOST_REPEAT=1` adds an optional third emission (stage4).
The report distinguishes requested, completed and interrupted attempts. Each stage
has a 30-minute process-group deadline (`BEND_SELFHOST_TIMEOUT` in milliseconds).
An upstream-generated API or successful self-typecheck alone is not this proof.

For an isolated compiler experiment, `bootstrap-variant.mjs REPORT OUTPUT_DIR
MODULE REPLACEMENT` copies and verifies every module in an existing bootstrap
snapshot, replaces only the specified module, assembles the source, and checks it
with the pinned bootstrap compiler. Its resulting API and source can be passed to
the fixed-point runner without changing production source files.

Compare two complete recorded runs with:

```sh
node tools/conformance/compare-artifacts.mjs BEFORE.json AFTER.json COMPARISON.json
```

The tool requires the same pinned revision and fixture hashes. It compares
verdict, rejection phase, checked flag, exit code, diagnostic and output, ignoring
timing and compiler/toolchain identity. Only the exact upstream checkout prefix
is normalized. Every changed or missing probe is retained; negative check rows
are listed separately. Matching observations do not establish intended-rule
coverage for previously unproven negative cases, or turn GPU hardware gates into
execution evidence. Keep both source reports alongside the comparison.

For long runs, fixtures may be partitioned into disjoint `--filter` groups and
run with the same artifact, host, pin and timeout. Retain every raw group report,
then combine them with:

```sh
node tools/conformance/merge-reports.mjs MERGED.json SHARD_1.json SHARD_2.json ...
```

The merger requires every inventory probe exactly once. It rejects missing or
duplicate probes, changed artifacts, differing inventories, hosts or timeout/GPU
policies, and unfinished reports. It preserves every verdict and records input
report hashes. `coverageComplete` means that every probe was observed;
`complete` retains the runner's stricter conformance condition. Merging cannot
turn timeouts, diagnostic mismatches, or hardware gates into passes. Do not mix
initial attempts with retries to select favorable results.
