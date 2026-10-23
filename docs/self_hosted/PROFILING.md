# Profiling native Bend programs

The [general native profiler](../../selfhost/tools/profiler/) measures arbitrary
sequential native programs, including the Bend compiler. It separates clean
execution time from diagnostic CPU sampling, active Bend dispatch attribution,
selected physical callers and runtime event counts. Workloads and independent
output expectations are data; the profiler contains no compiler-phase or
benchmark-name recognizers.

The first qualified platform is Linux x86-64 with an ELF executable. This is a
research tool for the direct-QBE/P111 runtime, not an installed `bend --profile`
option. Leaf sampling also works with other native ELF programs. JavaScript,
GPU execution, all-thread profiling and complete logical Bend stacks are outside
this version's qualification. See the [Phase127 report](../../implementation/phase127/README.md)
for measurements, overhead and the compiler findings.

## What each measurement means

| Measurement | Meaning and limit |
|---|---|
| Clean wall/CPU/RSS | Complete fresh child process, without profiler instrumentation. Includes startup, input, output and exit. |
| Physical CPU leaf | Sampled machine instruction, mapped to the exact ELF/library and decoded symbol. QBE symbols with no size have explicitly inferred ranges. |
| Physical caller | One return address recovered only where authenticated ELF unwind information establishes a fixed stack rule. Unsupported samples remain unknown. |
| Active dispatch | The Bend segment active when the interrupt or event occurred. Synchronous helper calls retain that outer segment. It is not recursive logical ancestry. |
| Lowered definition owner | Conditional mapping from emitted segment groups to their enclosing Bend definition, checked against the actual linked segment table. Inlining and erased source information are not reconstructed. |
| Runtime events | Executed dispatch, allocation/reclamation, ownership, constructor-take, continuation and register-transport operations. They are counts, not time percentages. |

Allocation counts mean calls/requested words, not live heap size. Reclamation
belongs to its executing context, not necessarily the original allocator.
Generated inline operations can bypass runtime hooks. Requested register-clearing
bytes are not measured memory-bus traffic. Never use diagnostic timing as an
optimization result: even context-only instrumentation changes the executable.

## Basic reproducible workflow

Run from the repository root. Use a fresh output directory for every command.
Target execution belongs inside the existing resource guard. On this research
machine the controlled lane is CPU3; adapt CPU and memory limits to your host.
The guard checks free disk, bounds process-tree memory/time and preserves logs.

Build the reusable sampler once:

```sh
python3 -B selfhost/tools/performance/phase111/guard.py \
  --out selfhost/build/profile-sampler-guard --seconds 30 \
  --rss-mib 2048 --available-mib 16384 --file-mib 64 --cpu 3 -- \
  python3 -B selfhost/tools/profiler/build-sampler.py \
  --out selfhost/build/profile-sampler
```

Write a recipe. Paths are absolute or relative to `cwd`; program arguments stay
exactly as supplied. List input files explicitly so the manifest can authenticate
them. `stdout` and `stderr` are existing independent oracle files, not outputs
learned from the executable being tested. An empty expected stderr file is valid.

```json
{
  "cwd": "/absolute/path/to/bend",
  "sampler": "selfhost/build/profile-sampler/sampler.so",
  "scope": "One fixed sequential native workload",
  "workloads": [{
    "name": "example",
    "timeoutSeconds": 30,
    "variants": [{
      "name": "baseline",
      "command": ["selfhost/build/example/program", "--threads", "1", "--gpu", "off"],
      "inputs": ["example.bend"],
      "stdout": "expected.stdout",
      "stderr": "expected.stderr"
    }]
  }]
}
```

Freeze the recipe, then run alternating clean and sampled captures:

```sh
python3 -B selfhost/tools/profiler/freeze.py \
  --recipe profile-recipe.json --out profile-manifest.json
python3 -B selfhost/tools/performance/phase111/guard.py \
  --out selfhost/build/profile-run-guard --seconds 300 \
  --rss-mib 2048 --available-mib 16384 --file-mib 64 --cpu 3 -- \
  python3 -B selfhost/tools/profiler/run.py \
  --manifest profile-manifest.json --out selfhost/build/profile-run \
  --modes clean,sample --rounds 3 --periods-us 8000,13000,8000,13000
python3 -B selfhost/tools/profiler/compare.py \
  --report selfhost/build/profile-run/report.json \
  --out selfhost/build/profile-comparison.json
python3 -B selfhost/tools/profiler/render.py \
  --comparison selfhost/build/profile-comparison.json \
  --out selfhost/build/profile-summary.md
```

Add another variant with the same input/output contract to compare compilers or
generated binaries. `--reference baseline` adds relative comparisons. `--names`
selects workloads; `--check-only` checks pins without executing anything.
Scale the loop with repetitions and workload selection, not by weakening outputs.
A benchmark that prints elapsed time must explicitly declare the
`prefix-integer-line` contract; it accepts a fixed complete prefix followed by
exactly one unsigned integer line. No other text is discarded.

## Runtime attribution and event counters

`runtime.py` accepts pinned runtime C, its headers, compiler/linker and an
optional retained program object. It creates a diagnostic runtime in a fresh
directory; every insertion has an exact anchor and inverse reconstruction must
recover every original byte. `build-runtime.py` executes its frozen build plan
under the resource guard. Relink the same generated object rather than rebuilding
the Bend compiler merely to add counters. Production runtime files stay intact.

The [Phase127 preparation tools](../../selfhost/tools/performance/phase127/README.md)
provide concrete compiler and ordinary-program examples. The manifest marks
diagnostic variants with `dispatchInstrumentation: true`. `--modes sample`
collects CPU plus active segment IDs with counters disabled; `--modes events`
collects counters in a separate run. `--modes clean` on such a variant measures
instrumentation overhead and is explicitly excluded from clean metrics.

`owners.py` reads the original QBE segment and function tables without executing
them. `attribute.py` joins samples/events with those tables and validates their
FID-to-address correspondence against the linked executable. Its output states
the conditional emitter-contract provenance; symbol names alone are not proof
of source identity. Preserve the build/source receipts alongside the map.

Sample attribution needs only `--analysis`, with optional `--contexts` and
`--owners`. Physical `--callers` and `--table` are optional together. Event
reports also expose observed direct-entry/factory dispatch counts separately from
continuations; private calls and inlining can bypass these entries, so they are
not a universal source-function invocation count.

The binding includes the executable's actual runtime descriptor and capability
bits. An owner map may remain reusable after a capability-only change, but that
requires explicit source/QBE comparison evidence as well as linked-FID checks.
Use `attribute.py --summary-only` when the original ordered vectors already
exist and another per-sample JSONL copy would only consume disk.

Use `compare.py --baseline diagnostic=baseline` to associate diagnostic captures
with a separately measured clean executable. This association is explicit; the
tool does not infer it from naming conventions. The investigator must establish
that relinking preserved the original program object and workload semantics.

## Selected native callers

The optional `unwind.py` prepares fixed-stack return rules from a pinned shared
object's interpreted ELF CFI and explicit code ranges. It rejects unsupported
rules, gaps and overlaps unless partial coverage is explicitly requested.
`build-sampler.py --unwind-table PATH/table.json` compiles that authenticated table
into the collector; the manifest also pins it. The collector checks the mapped
object and stack bounds before applying a rule. No heuristic stack scan occurs.

This is useful for stripped libc copy/fill implementations whose exported symbol
names do not identify the actual hot code. It is intentionally bounded to one
physical caller and supported rules. It does not invent missing stack frames or
recover optimized-away Bend continuations.

## Follow a long computation over time

`timeline.py` reuses authenticated captures and attribution without running the
program again. For example:

```sh
python3 -B selfhost/tools/profiler/timeline.py \
  --analysis CAPTURE/analysis.json --contexts CAPTURE/contexts.txt \
  --owners OWNERS.json --window-cpu-seconds 25 --out FRESH_TIMELINE
```

Contexts and owners are optional for a physical-only view. JSON and Markdown
show the leading physical leaves and active owners in each window, retaining
unknowns in the denominator. Coordinates approximate sampled-thread CPU time
from sample order and timer period; they are not measured wall timestamps.
Loss, unsupported thread coverage or unauthenticated pairing suppress CPU
coordinates and retain ordinal sample windows. A changing mix of function names
does not itself establish compiler phase boundaries. Use `--window-samples`
for explicit ordinal windows.

## Quality gates and interpretation

Every run must match its independent status/stdout/stderr contract. Inputs,
executable, sampler, methods and analysis dependencies are hashed; captures keep
ELF mappings, timer periods, loss, CPU coverage and exact raw sample order.
Fresh output paths prevent accidental overwrite. Cancellation kills and reaps
the workload process group. The runner does not execute shell command strings.

For large compiler outputs, `deduplicate.py --report RUN/report.json --out
RECEIPT.json` can replace completed exact-oracle output copies with hardlinks to
their frozen oracle. It preserves every path and byte and records metadata
changes; those shared files must remain immutable. Never edit retained artifacts
in place. Counter-on and context-only timing distributions stay separate.

Use two sampling periods to expose periodic aliasing. Reports retain low-sample
captures but suppress confident quantitative attribution. Comparison can pool
compatible captures; it requires at least 500 accepted samples, no reported loss,
adequate main-thread CPU coverage and plausible timer delivery before estimating
costs. Absolute CPU estimates additionally require at least 95% capture-window
coverage of the complete child's CPU time. Tiny programs need larger batches.
The default sample threshold is a screening rule, not a statistical confidence
interval or proof against sampling bias.

Period-weighted sample fractions can be multiplied by the independent clean CPU
median to estimate costs. These are approximate: instrumentation and code layout
may change execution. Compare fractions, estimated absolute costs and dynamic
counts together, then perform a controlled semantic transformation to establish
causality. Preserve unknown samples and failures in denominators and evidence.

The collector samples the initial main thread. Substantial worker CPU fails its
coverage gate. Fork/exec trees, later library unload/remapping, custom signal
handling and unsupported unwind states need separate support. Do not describe
this tool as a complete universal stack or memory profiler.

Run the offline tests with:

```sh
python3 -B -m unittest discover -s selfhost/tools/profiler -p 'test_*.py'
```

The checked Bend compiler still owns semantic analysis and code generation.
Python manages manifests, ELF analysis and experimental evidence; C supplies
signal sampling and runtime hooks. Neither host component becomes another Bend
compiler.
