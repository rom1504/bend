# Native operation accounting

This experiment reuses the **qualified Phase144 final04 N2 object** with the
unchanged generic profiler's sixteen runtime channels. It does not rebuild the
compiler, change its QBE or add instrumentation to its Bend source. The runtime
is the exact selected serial-RFC source, compiled with
`-DP144_SINGLE_MUTATOR_RFC=1`, under the existing one-Bend-mutator policy.

`prepare-v02.py` prepares a reversible diagnostic runtime and a compressed exact
FID/owner map from the object's retained QBE. It performs no target execution.
Plan01 was prepared for two cases; plan02 adds the agreed closures case. Neither
preparation is a measurement. Root executes `commands-v02.sh` sequentially:

1. Build the diagnostic runtime and relink the existing object.
2. Run the frozen independent ABI fixture counters off/on, requiring its exact
   original sixteen per-FID counts and `45\n` result.
3. Compile Lexer, Map and closures with counters off/on. All six complete QBE
   outputs must equal their already-retained final04 hosted ordinary products.

The jobs use CPU3, a 3 GiB RSS bound, a 16 GiB available-memory floor and 64 MiB
per-file limits. Observation additionally bounds each event file to 32 MiB and
all child lifetimes. Runtime source, program object, compiler source, carrier,
input sources, method, oracles and results are pinned. Every emitted FID/address
pair is joined against the actual diagnostic ELF's named dispatch table symbols.
No sampler, privileged profiler or fresh full-compiler request is needed.

## Interpretation

The exact counters cover requests to runtime allocation/free, class-rounded
words, keep/sink/drop entries, constructor take, continuation frames/captures,
returns, primitive calls, dispatches and register copy/clear words. They do not
count distinct live values or measure allocation lifetime. `heap_alloc_miss` is
an allocator refill, not necessarily a new OS allocation; `term_drop` entries
are not all recursively destroyed nodes. Constructor take is not proof of later
reconstruction. Fast generated arithmetic/borrowing can bypass these hooks.

Owner aggregation means **active outer dispatcher context**. Private calls and
inlined code retain that context, so it is neither a source-level call count,
allocation origin nor logical call stack. The source-line link points to the
matched checked source declaration, not the exact operation producing an event.
Outside-dispatch and runtime-FID events remain separate. No owner-prefix rule
pretends to recover exact frontend/backend phase membership.

String character comparisons and query probes are intentionally unreported.
Counting `String.eq` dispatches would miss private borrowed loops and would not
count compared characters. A future complete metric needs an audited operation
boundary, or a separately bounded same-source workload instrumentation with an
explicit bypass census; there is no such completeness claim here.

Counter-enabled wall times are diagnostic overhead, never optimization gains.
Use the independent clean JS/native pilot for timing. The three old full captures
are reused through `history-v01.py` and [the research note](../../../../../research/phase145/native-accounting.md),
with their different source/runtime/generation identities preserved.


The root completed the three counter jobs successfully. See the actual counts
and fixed-carrier subset in the research note. `stages-commands-v01.sh` prepares
the separate root-only stage observation (now executed successfully): runtime relink plus three short
8 ms sampled requests. It reuses the existing stage C include and qualified
sampler without modification. Current marker FIDs and addresses are checked;
optional missing/repeated endpoints produce unavailable intervals. Boundary
clocks are reported separately from descriptive short-run sample counts.

## Compact campaign archive

`archive-v01.py --inventory-only` inventories current Phase145 evidence without
writing an archive or running targets. The reviewed preview selected 618 files,
40.25 MB raw. The final inventory is regenerated only after root finishes late
jobs; it may therefore contain additional evidence. Budgets are 128 MiB raw and
16 MiB compressed. The root-owned archival command is:

```sh
python3 -B selfhost/tools/performance/phase145/native/archive-v01.py \
  --out implementation/phase145/evidence01 \
  --require selfhost/build/phase145/execution-index01/report.json \
  --require selfhost/build/phase130/p145-index-oracle01/report.json
```

The script requires successful principal and explicitly named late receipts and
finished resource guards. Failed historical attempts are preserved with their
actual status. It includes plans, methods, hooks, logs, counter/stage evidence,
owner maps, small source dependencies and the diagnostic/generated checked APIs.
It excludes generated SSA, assembly, objects, binaries and large generated
stdout. The tar inventory authenticates every member; reopening/re-hashing every
member and rechecking source files verifies the completed archive.

This is an evidence capsule, not a hermetic distribution. Final04 native images,
compiler objects, the prepared carrier, host tool executables and parent
qualification artifacts remain pinned external dependencies. Exact runtime
relinking and input/output validation require those files and matching platform
contracts. Fresh machine-address symbolization requires the original diagnostic
ELF, which is not included; the validated source/FID/stage results and their
identities are included. Absolute paths need explicit relocation. Excluded or
unavailable dependency pins are recorded rather than silently treated as
satisfied.
