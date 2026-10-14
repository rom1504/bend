# Bounded main-isolate JS profiles while the compiler remains busy

`js-partial-preload.mjs` starts a separate worker with `execArgv:[]` (no recursive
preload), awaits that worker's successful inspector `Profiler.start` handshake,
and then allows the target module to run. The worker uses
`Session.connectToMainThread()`: the profile is of the main isolate, not the
worker. A worker timer requests `Profiler.stop`; it writes `partial.cpuprofile`
and `metadata.json` even if synchronous main-thread compilation has not returned.
The actual interrupt/stop behavior must be proved by the control below; these
files alone do not establish that the installed Node permits it.

Root runs all targets under the existing serial guard. First run the tiny control:

```sh
env P90_JS_PROFILE_OUT=ABS_FRESH_OUTPUT P90_JS_PROFILE_MS=500 P90_JS_PROFILE_INTERVAL_US=4000 \
  NODE --import ABS/js-partial-preload.mjs ABS/js-partial-control.mjs
python3 -B selfhost/tools/performance/phase90/profiling/js-partial-verify.py ABS_FRESH_OUTPUT
```

The target executes one 2-second synchronous `busySpin`, with no event-loop
turns. The verifier requires stop request, acknowledgement and completed profile
write strictly before the loop finishes, and at least one sample in the control
function's call subtree. This rejects a stop merely queued until main-thread
work has ended. All timestamps used for that check are process monotonic
`hrtime` microseconds from the same Node process, across its threads.

Only after that control passes, root can add the preload to the unchanged
`emit-self-v5.mjs` command, set `P90_JS_PROFILE_MS=60000` and
`P90_JS_PROFILE_INTERVAL_US=16000`, and retain the existing 90-second request
guard. The output directory must be new and its parent must exist. The 60-second
window starts when the profiler is ready, before target imports and Base setup;
it is **not** a 60-second native-emission-only window. Correlate target progress
markers and profile stack content before assigning costs to compilation phases.

The worker has a 64-MiB old-generation limit and 2-MiB stack; emitted profile
bytes are capped at 20 MiB. Default 16-ms sampling produces about 3,750 nominal
samples over 60 seconds; actual intervals/sampling count may differ. A target
whose event loop drains early requests an early profile stop. Explicit process
exit, fatal failure, or an outer guard kill before stop/write can prevent capture.
The metadata starts incomplete, records stop-request/acknowledgement clocks, and
only marks capture complete after the profile is flushed. It always records
`compilerCompletion: "not-observed"` and `compilerSuccess: null`.

Sampling and the extra worker perturb timing. This profile is diagnostic evidence,
not a replacement for clean timings, a complete CPU/process accounting, or proof
that a compilation finished. Inspector sampling attributes main-thread JS/native
stacks, not all background V8 compilation or native helper CPU. A saved partial
profile remains useful when the compiler subsequently hits its outer deadline.

Preparation validation: Node syntax checks for the three modules and Python AST
parsing for the verifier pass. No compiler or control target was executed by the
preparing agent. Root's guarded control result must be recorded separately.
