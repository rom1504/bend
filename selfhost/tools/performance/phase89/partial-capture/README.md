# Bounded, intentionally incomplete native self-emission capture

The existing Phase88 ownership sampler writes PCs/marks only in its destructor.
The outer execution guard uses SIGKILL at its deadline, leaving only the initial
sample header. There is no dump signal. Ordinary `analyze.py` correctly refuses a
missing `END`, non-main final thread, or unfinished request clocks. Do not relabel
a timeout or this stopped diagnostic as successful compiler self-emission.

`watchdog.c` is a separate tiny Linux/glibc preload. It starts its detached timer
thread inside an interposed main, after all sampler constructors have finished.
After `BEND_CAPTURE_SECONDS` (default60, allowed1–120), that ordinary thread calls
`exit(77)`, allowing the unchanged sampler destructor to flush raw evidence.
There is no signal-handler stdio, forced call into a stopped thread, compiler C
rewrite, or join of the watchdog thread. An atomic exit owner avoids concurrent
normal-main return and watchdog exit. Compiler calls to `exit` on error remain a
separate failure path; the exact generated image contains no registered atexit
handler or destructor. Preserve any failed or incomplete dump.

The existing sampler destructor disarms timers, snapshots only atomically
published sample counts, and tolerates live threads without joining/freeing them.
Its final thread is now the watchdog. The compiler can briefly keep running while
the destructor writes; this is a prefix diagnostic, not a completed timing. A
libc lock could still delay exit/dumping, so keep the outer75–90s RSS/time guard.
No production or parallel-runtime correctness claim follows from this mechanism.

Offline table preparation completed for exact native-self01 SHA256
`8bacae268296d6fe16d02ce50a7a2189bd587506c074532c6e5d74e622716e45`:
`selfhost/build/phase89/ownership-self01-table/` contains55 accepted CFI rows.
Build the existing sampler against that table, plus this separate preload under
root's small-library guard. Do not reuse another image's sampler/table pair.

Root's proposed validation sequence:

1. Run a tiny successful target with a long watchdog deadline. Require ordinary
   return0, unchanged output and normal completed sampler evidence.
2. Use the same compiler image on an existing bounded request long enough to
   exceed a1–2s watchdog (for example Map COUNT5). Require guard return77 without
   `stoppedFor`, exactly one stop marker, complete `END`, zero sample drops/overruns,
   and usable stopped-profile analysis. Keeping the same image reuses its exact
   table; a different executable would need its own compatible table/sampler.
3. Only if the original self-emission fails, run one60s capture with the exact
   native-self image/input/assets and `--threads 1 --gpu off`; retain a90s outer
   guard. Use `BEND_SAMPLE_PERIOD_US=4000` (about15,000 samples, below25,000/thread).
   Set `LD_PRELOAD=WATCHDOG_SO:EXACT_IMAGE_SAMPLER_SO`, `BEND_CAPTURE_SECONDS=60`
   and `BEND_SAMPLE_OUT=FRESH_SAMPLE_FILE` on the target command only.

The normal guard marks intentional exit77 incomplete; keep that status. Analyze
only the prefix with the new independent reader:

```sh
python3 -B selfhost/tools/performance/phase89/partial-capture/analyze.py \
  --samples FRESH_SAMPLE_FILE --binary EXACT_NATIVE_IMAGE \
  --table EXACT_TABLE_DIRECTORY/table.json --stderr GUARD/stderr.log \
  --process GUARD/process.json --out FRESH_PARTIAL_ANALYSIS.json
```

It requires intentional exit77 before the outer guard, exact image/table identity,
complete raw data and loss-free sampling. It bins physical leaf PCs into10s windows
from the first sample. It retains raw phase marks but never fabricates a completed
request or output oracle. The original sampler and analyzer remain unchanged.
This preparation has run no compiler, preload build or profiling target.

## Serial controls and gated self capture

`run.py` executes those controls with the immutable eight-pass
`native-b1-nine-gates01/gates.json`, its exact4584… source, all nine effects,
authenticated runtime/Base/cache, the image-bound unwind table and supplied
preload libraries. It pins inputs before execution and rechecks them afterward,
including on failure. Root must first build the two libraries from the recorded
sources/table under a small compilation guard.

```sh
python3 -B selfhost/tools/performance/phase89/partial-capture/run.py FRESH_DIRECTORY \
  --sampler EXACT_IMAGE_SAMPLER_SO --watchdog WATCHDOG_SO \
  --self-after selfhost/build/phase89/native-b1-nine-gates01/report.json \
  --check-only
```

Remove `--check-only` to execute. Omit `--self-after` to run only the two controls.
Normal Small must return0, retain its exact independent C oracle, and pass the
original completed-profile analyzer. Stopped Map must return77 before its outer
32s guard and pass the partial reader. Only then can self capture run; its prior
report must record a finished, failed full-self attempt with the same image and
source. The actual preceding attempt hit the600s guard with return−9 and no C.
The self capture uses a60s watchdog and90s outer guard. Intentional77 remains
`compilationPassed:false`; `diagnosticUsable:true` means only the capture was valid.

## v2: controls with sufficient samples

Use `run-v2.py` for the next attempt, with the same arguments and a fresh output
directory. The retained `partial-self01` attempt compiled Small successfully and
matched its complete C oracle, but the original analyzer rejected its insufficient
sample count. That failed diagnostic and `run.py` remain unchanged; the500-sample
minimum is not weakened.

V2 replaces the normal Small control with Map COUNT5 and checks all five complete
C outputs against the independent Map oracle before the original analyzer runs.
Its watchdog remains60s. The stopped Map control now uses3s (outer guard33s),
providing more sample margin. The optional self60s gate and all input bindings
remain unchanged. V2 SHA256:
`53eebb004ddcee00a5ba55af138f599b56019f2abb05da27763870ea538598b5`.
Preparation checked Python syntax only; root owns all executions.
