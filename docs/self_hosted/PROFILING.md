# Profiling native Bend programs

For a current compiler example, [Phase129](../../implementation/phase129/README.md)
reuses these tools with workload-specific repeat budgets, an unchanged qualified
N1, a small diagnostic runtime relink and pooled active-owner contexts. Its
[audit](../../research/phase129/profiler-audit.md) demonstrates how authenticated
caller data resolves register-copy cost without another target run. The
[reproduction adapters](../../selfhost/tools/performance/phase129/README.md)
keep diagnostic overhead and cold request time separate.

The [general native profiler](../../selfhost/tools/profiler/) measures arbitrary
sequential native programs, including the Bend compiler. It separates clean
execution time from diagnostic CPU sampling, active Bend dispatch attribution,
selected physical callers and runtime event counts. Workloads and independent
output expectations are data; the profiler contains no compiler-phase or
benchmark-name recognizers.

The first qualified platform is Linux x86-64 with an ELF executable. Runtime
events and dispatch attribution target the direct-QBE/P111 runtime; physical
leaf sampling also works with other native ELF programs. This is not an
installed `bend --profile` option. The default collector samples the main thread;
the optional bounded collector also samples intercepted pthreads. JavaScript,
GPU execution, unobserved thread mechanisms and complete logical Bend stacks
remain outside this support. See the [Phase127 report](../../implementation/phase127/README.md)
for the original qualification and [Phase159](../../implementation/phase159/README.md)
for exact-output sampling of C runtimes whose work runs on a child thread.

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
python3 -B selfhost/tools/build-retention/guard.py \
  --out selfhost/build/profile-sampler-guard \
  --run-root selfhost/build/profile-sampler --seconds 30 --disk-mib 64 \
  --rss-mib 2048 --available-mib 16384 --file-mib 64 --cpu 3 -- \
  python3 -B selfhost/tools/profiler/build-sampler.py \
  --out selfhost/build/profile-sampler
```

Add `--all-threads` to `build-sampler.py` when native work runs in pthreads rather
than on the initial main thread. This selects `sample-threads.c` and records
`samplerScope: all_created_threads` plus exact source/build identities. It
intercepts `pthread_create`, with 32 lifetime slots including main and 25,000
samples per slot; it does not promise to intercept raw-clone or preexisting
threads. Thread overflow and incomplete CPU coverage invalidate attribution.
The collector has no physical-caller unwind or dispatch-context support;
`--all-threads` and `--unwind-table` are mutually exclusive. Keep
`dispatchInstrumentation` false for its physical-only captures. Build and run
it under the same guard and independent output gates as the default collector.

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
      "command": ["selfhost/build/example/program"],
      "inputs": ["example.bend"],
      "stdout": "expected.stdout",
      "stderr": "expected.stderr"
    }]
  }]
}
```

For a native compiler workload, take the exact command and runtime convention
from its completed maintained build request plan, along with all request input
pins. Do not reconstruct flags from the active upstream revision or copy legacy
flags into a current-runtime workload:

```python
plan = json.loads(Path(request_file).read_text())
variant = {
    "name": "compiler", "command": plan["command"],
    "runtimeArgumentConvention": plan["runtimeArgumentConvention"],
    "inputs": [str(request_file), *[row["file"] for row in plan["inputs"]]],
    "argv0": "compiler-work",
    "stdout": "independent-complete-output", "stderr": "empty-stderr"
}
```

This example assumes the native QBE request's stdout output contract. Other
protocols need their actual output contract. The maintained request planner
selects legacy or `+RTS ... -RTS --RTS` arguments from the image metadata; the
profiler freezes them unchanged. For a diagnostic relink of that same object,
replace only `command[0]` with the actual diagnostic executable and also pin its
runtime/build receipts. Set the variant's convention from the diagnostic plan.
RTS-bound profiling refuses ambient `BENDRTS`. A generic non-Bend workload need
not declare a Bend runtime convention.

A variant can optionally set `"argv0": "compiler-work"` without changing
`command[0]`, which must remain the actual executable. Freezing pins that ELF;
the runner uses an explicit executable path while passing the alternate argv0
to the child, and records actual argv0 in each process receipt. This is useful
when a foreign runtime exposes argv0 through the program's argument API. The
override must be a nonempty string without NUL. Avoid `bash -c 'exec -a ...'`
under sampling: `LD_PRELOAD` would instrument the shell before the target, and
the collector's fresh-file contract cannot be reused across that exec.

Pooling requires the same effective argv0 for the same variant, including its
default executable path. The comparator permits different default executable
names across different variants, preserving ordinary backend comparisons; the
experiment author must establish that those names do not alter the intended
work. If they do matter, use the same explicit override in every variant. Old
manifests without overrides keep their original launch behavior.

Freeze the recipe, then run alternating clean and sampled captures:

```sh
python3 -B selfhost/tools/profiler/freeze.py \
  --recipe profile-recipe.json --out profile-manifest.json
python3 -B selfhost/tools/build-retention/guard.py \
  --out selfhost/build/profile-run-guard \
  --run-root selfhost/build/profile-run --seconds 300 --disk-mib 512 \
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
Declare `runtimeArgumentConvention` from the selected runtime binding, using
`bend-rts-v1` for the current runtime. Omission preserves legacy replay. Runtime
and stage plans carry this field forward; neither infers it from a filename or
the active upstream revision. The existing 14 reversible runtime hooks are
unchanged.

Use the [maintained build workflow](workflow.md) for the actual request and
retained object, then the profiler commands above. The manifest marks
diagnostic variants with `dispatchInstrumentation: true`. `--modes sample`
collects CPU plus active segment IDs with counters disabled; `--modes events`
collects counters in a separate run. `--modes clean` on such a variant measures
instrumentation overhead and is explicitly excluded from clean metrics.

`owners.py --qbe` reads original QBE tables; `--assembly` reads the maintained
GNU x86-64 emitter's typed functions and literal descriptor/segment tables.
Both admit exact 192-byte ABI11101 and ABI11102 descriptors. No target executes.
`attribute.py` joins samples/events with those tables and validates their
FID-to-address correspondence against the linked executable. Its output states
the conditional emitter-contract provenance; symbol names alone are not proof
of source identity. Preserve the build/source receipts alongside the map.

For the Phase183 maintained assembly target, bind the completed native build
receipt and, when available, the exact maintained source map:

```sh
python3 -B selfhost/tools/profiler/owners.py \
  --assembly BUILD/program.s --build-receipt BUILD/report.json \
  --source-map SOURCE/compiler.map.json --source-root selfhost \
  --emitter-source selfhost/src/back/x86/program.bend \
  --emitter-source selfhost/src/back/x86/function.bend \
  --output FRESH/owners.json
```

The new `bend-native-lowered-owners-v1` map records
`sourceFormat: gnu-x86-64-assembly`; the existing QBE map schema remains accepted.
The optional receipt must be a completed current `bend-native-build` for `x86`,
including the actual compiler emission, assembly and linking stages. Its source,
producer image, assembly, runtime and binary pins must match existing artifacts;
linked attribution rechecks the selected ELF against that exact binary.
Without a receipt, producer provenance remains explicitly unverified.

`--source-map` and `--source-root` require the build receipt. Each declaration's
generated bytes, physical module bytes, name, kind and line offsets must agree
with the actual compiled source. Modules are taken from the map, including
profile-specific modules and the replacement entry. Exact lowered-name matches
receive `sourceLocation`; unmatched or composite owners remain unknown. These
locations identify the containing declaration, not instruction-level source
lines or inlined origins. Explicit emitter-source pins still describe a
conditional lowering contract; a build receipt does not prove that contract.

Sample attribution needs only `--analysis`, with optional `--contexts` and
`--owners`. Physical `--callers` and `--table` are optional together. Event
reports also expose observed direct-entry/factory dispatch counts separately from
continuations; private calls and inlining can bypass these entries, so they are
not a universal source-function invocation count.

The binding includes the executable's actual runtime descriptor and capability
bits. A historical QBE owner map may remain reusable after a capability-only change, but that
requires explicit source/QBE comparison evidence as well as linked-FID checks.
Assembly maps bind the exact descriptor transport/capability fields; regenerate
the map and receipt binding when those fields or the selected binary change.
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

The thread-aware collector writes PCs grouped by thread, not in a global time
order. Do not use `timeline.py` to infer stages or chronological behavior from
that stream, even with `--window-samples`; use aggregate physical attribution.
Its collector scope is explicit in the capture header.

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

Use two sampling periods to expose periodic aliasing. Shorter is not always
better: the name-search control produced timer overruns at2–3ms on this host;
8ms/13ms captures were therefore collected separately. Retain and exclude
failed captures rather than counting more interrupts as better evidence. Reports retain low-sample
captures but suppress confident quantitative attribution. Comparison can pool
compatible captures; it requires at least 500 accepted samples, no reported loss,
adequate sampled-thread CPU coverage and plausible timer delivery before estimating
costs. Absolute CPU estimates additionally require at least 95% capture-window
coverage of the complete child's CPU time. Tiny programs need larger batches.
The default sample threshold is a screening rule, not a statistical confidence
interval or proof against sampling bias.

For a thread-aware capture, coverage uses summed observed thread CPU versus
process CPU and checks lifecycle/overflow evidence. A single short capture can
fail the 500-sample threshold while passing all other checks; `compare.py` may
pool compatible same-workload/variant captures and weight samples by their
periods. It cannot rescue loss, overruns, incomplete thread coverage or implausible
delivery. Retain rejected captures. Several 8ms/13ms captures are preferable to
2–3ms periods that overrun on this host. The comparison keeps effective argv0,
binary identity and argument/output contracts bound across pooled observations.

Period-weighted sample fractions can be multiplied by the independent clean CPU
median to estimate costs. These are approximate: instrumentation and code layout
may change execution. Compare fractions, estimated absolute costs and dynamic
counts together, then perform a controlled semantic transformation to establish
causality. Preserve unknown samples and failures in denominators and evidence.

The default collector samples the initial main thread; substantial worker CPU
fails its coverage gate. The optional collector covers the main thread and
intercepted pthreads within its fixed lifetime limits, without caller or context
support. Fork/exec trees, later library unload/remapping, custom signal handling
and unsupported unwind states need separate support. Do not describe this tool
as a complete universal stack or memory profiler.

Run the offline tests with:

```sh
python3 -B -m unittest discover -s selfhost/tools/profiler -p 'test_*.py'
```

The checked Bend compiler still owns semantic analysis and code generation.
Python manages manifests, ELF analysis and experimental evidence; C supplies
signal sampling and runtime hooks. Neither host component becomes another Bend
compiler.

## Full native compiler requests

[Phase136](../../implementation/phase136/README.md) demonstrates a bounded
full-source investigation with an ordinary cold build, checked Bend stage clocks
and exact-object physical sampling. Its [stage recipe](../../selfhost/tools/performance/phase136/stages/README.md)
separates parsing, checking, ownership, annotation, erasure, lowering,
verification and rendering while preserving complete independent QBE oracles.
The overlay is pinned to the qualified Phase134 source; a different source must
re-establish its stage bridge rather than silently reuse old boundaries.

The [exact-object profile recipe](../../selfhost/tools/performance/phase136/profiling/README.md)
relinks a retained qualified object with an authenticated diagnostic runtime,
avoiding a full compiler rebuild. Stage clocks, physical leaves, active contexts,
ownership events and clean timing are complementary measurements. In particular,
the ownership-checking stage is not the runtime reference-management cost, and
rendering can include reclamation and downstream backpressure. Preserve those
distinctions when interpreting a large interval or adding its apparent costs.
